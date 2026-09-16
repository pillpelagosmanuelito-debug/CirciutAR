#!/usr/bin/env python3
"""Verificación estática ligera: imports resueltos, imports sin uso e
identificadores ASCII. Complementa a `flutter analyze`; no lo reemplaza."""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DECL = re.compile(
    r'^(?:abstract\s+|final\s+|base\s+|sealed\s+|interface\s+)*'
    r'(?:class|enum|mixin|typedef|extension)\s+([A-Za-z_]\w*)', re.M)
TOP_VAR = re.compile(r'^(?:const|final|late\s+final)\s+(?:[\w<>?,\s]+\s)?([A-Za-z_]\w*)\s*=', re.M)
TOP_FN = re.compile(r'^(?:[\w<>?,]+\s+)+([A-Za-z_]\w*)\s*\(', re.M)
IMPORT = re.compile(r"^import\s+'([^']+)'(?:\s+as\s+(\w+))?;", re.M)
STRING = re.compile(r"'(?:\\.|[^'\\])*'|\"(?:\\.|[^\"\\])*\"")
COMMENT = re.compile(r'//.*')

PACKAGE_USES = {
    'package:flutter/material.dart': r'\b(\w*Widget\w*|Material\w*|Colors|Icons|Theme\w*|Scaffold|Color|Canvas|Paint|runApp)\b',
    'package:flutter_riverpod/flutter_riverpod.dart': r'\b(\w*Provider\w*|\w*Notifier|Ref|Consumer\w*|WidgetRef)\b',
    'package:shared_preferences/shared_preferences.dart': r'\bSharedPreferences\b',
    'package:flutter_test/flutter_test.dart': r'\b(test|testWidgets|expect|group)\b',
    'dart:convert': r'\b(jsonDecode|jsonEncode|utf8)\b',
    'dart:async': r'\b(unawaited|Timer|StreamController|Completer)\b',
}

def declared(path: Path) -> set:
    text = path.read_text(encoding='utf-8')
    names = set(DECL.findall(text)) | set(TOP_VAR.findall(text))
    names |= {n for n in TOP_FN.findall(text) if n not in {'if', 'for', 'switch', 'while'}}
    # Exports transitivos no se usan en este proyecto.
    return names

def main() -> int:
    errors = []
    files = list((ROOT / 'lib').rglob('*.dart')) + list((ROOT / 'test').rglob('*.dart'))
    for f in files:
        text = f.read_text(encoding='utf-8')
        body = IMPORT.sub('', text)
        code = COMMENT.sub('', STRING.sub("''", body))
        code_with_strings = COMMENT.sub('', body)
        # Identificadores no ASCII fuera de cadenas y comentarios.
        for n, line in enumerate(code.splitlines(), 1):
            if "'" in line or '"' in line:
                continue
            m = re.search(r'[A-Za-z_][\w]*[^\x00-\x7F]|[^\x00-\x7F][\w]', line)
            if m:
                errors.append(f'{f.relative_to(ROOT)}:{n}: identificador no ASCII: {m.group()}')
        for uri, alias in IMPORT.findall(text):
            if alias:
                if not re.search(rf'\b{alias}\.', code):
                    errors.append(f'{f.relative_to(ROOT)}: import sin uso {uri}')
                continue
            if uri.startswith('package:circuitar/'):
                target = ROOT / 'lib' / uri[len('package:circuitar/'):]
            elif uri.startswith(('package:', 'dart:')):
                pattern = PACKAGE_USES.get(uri)
                if pattern and not re.search(pattern, code):
                    errors.append(f'{f.relative_to(ROOT)}: import sin uso {uri}')
                continue
            else:
                target = (f.parent / uri).resolve()
            if not target.exists():
                errors.append(f'{f.relative_to(ROOT)}: import inexistente {uri}')
                continue
            names = declared(target)
            if not any(re.search(rf'\b{re.escape(n)}\b', code_with_strings) for n in names):
                errors.append(f'{f.relative_to(ROOT)}: import posiblemente sin uso {uri}')
    for e in errors:
        print(e)
    print(f'Archivos revisados: {len(files)} · problemas: {len(errors)}')
    return 1 if errors else 0

if __name__ == '__main__':
    sys.exit(main())

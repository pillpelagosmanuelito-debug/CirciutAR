import 'package:circuitar/core/utils/formatters.dart';
import 'package:circuitar/domain/models/competency.dart';
import 'package:circuitar/domain/models/progress.dart';
import 'package:circuitar/domain/simulation/color_code.dart';
import 'package:circuitar/domain/simulation/standard_values.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Serie E12', () {
    test('redondea hacia arriba al valor normalizado', () {
      expect(nextE12(200), 220);
      expect(nextE12(220), 220);
      expect(nextE12(221), 270);
      expect(nextE12(830), 1000);
      expect(nextE12(1000), 1000);
      expect(nextE12(4.5), 4.7);
      expect(nextE12(0), 1.0);
    });

    test('lista valores entre límites', () {
      final values = e12Between(10, 100);
      expect(values.first, 10);
      expect(values.last, 100);
      expect(values, contains(47));
      expect(values.length, 13);
    });

    test('tensión nominal comercial', () {
      expect(nextVoltageRating(18), 25);
      expect(nextVoltageRating(16), 16);
      expect(nextVoltageRating(500), 100);
    });
  });

  group('Código de colores', () {
    test('amarillo, violeta, rojo, dorado = 4.7 kΩ ±5 %', () {
      final r = ColorCode.decode(const [
        BandColor.yellow,
        BandColor.violet,
        BandColor.red,
        BandColor.gold,
      ]);
      expect(r.ohms, 4700);
      expect(r.tolerance, 5);
      expect(r.minOhms, closeTo(4465, 1e-9));
      expect(r.maxOhms, closeTo(4935, 1e-9));
    });

    test('cinco bandas: marrón, negro, negro, rojo, marrón = 10 kΩ ±1 %', () {
      final r = ColorCode.decode(const [
        BandColor.brown,
        BandColor.black,
        BandColor.black,
        BandColor.red,
        BandColor.brown,
      ]);
      expect(r.ohms, 10000);
      expect(r.tolerance, 1);
    });

    test('multiplicador dorado', () {
      final r = ColorCode.decode(const [
        BandColor.green,
        BandColor.blue,
        BandColor.gold,
        BandColor.gold,
      ]);
      expect(r.ohms, closeTo(5.6, 1e-12));
    });

    test('rechaza colores inválidos en cada posición', () {
      expect(
        () => ColorCode.decode(const [
          BandColor.gold,
          BandColor.black,
          BandColor.red,
          BandColor.gold,
        ]),
        throwsArgumentError,
      );
      expect(
        () => ColorCode.decode(const [
          BandColor.red,
          BandColor.black,
          BandColor.white,
          BandColor.gold,
        ]),
        throwsArgumentError,
      );
      expect(
        () => ColorCode.decode(const [
          BandColor.red,
          BandColor.black,
          BandColor.red,
          BandColor.orange,
        ]),
        throwsArgumentError,
      );
      expect(() => ColorCode.decode(const [BandColor.red]), throwsArgumentError);
    });

    test('codificar y decodificar todos los valores E12 es reversible', () {
      for (final v in e12Between(10, 1000000)) {
        final bands = ColorCode.encode4(v);
        expect(ColorCode.decode(bands).ohms, closeTo(v, v * 1e-9),
            reason: 'valor $v');
      }
    });

    test('codifica 1 kΩ como marrón, negro, rojo', () {
      expect(ColorCode.encode4(1000).take(3).toList(), [
        BandColor.brown,
        BandColor.black,
        BandColor.red,
      ]);
    });
  });

  group('Formato de ingeniería', () {
    test('prefijos', () {
      expect(EngFormat.format(4700, 'Ω'), '4.70 kΩ');
      expect(EngFormat.format(0.0047, 'A'), '4.70 mA');
      expect(EngFormat.format(0.000001, 'F'), '1.00 µF');
      expect(EngFormat.format(220, 'Ω'), '220 Ω');
      expect(EngFormat.format(1000000, 'Ω'), '1.00 MΩ');
      expect(EngFormat.format(0, 'V'), '0 V');
      expect(EngFormat.format(-5, 'V'), '−5.00 V');
    });

    test('corrige el redondeo en el límite de la década', () {
      expect(EngFormat.format(999.96, 'Ω'), '1.00 kΩ');
      expect(EngFormat.format(1000, 'Ω'), '1.00 kΩ');
    });

    test('formato simple', () {
      expect(EngFormat.plain(53.42, '%'), '53.42%');
      expect(EngFormat.plain(25, '°C', decimals: 0), '25 °C');
      expect(EngFormat.plain(double.nan, 'V'), '—');
    });
  });

  group('Lectura de números escritos por el estudiante', () {
    test('acepta coma, punto y sufijos', () {
      expect(parseUserNumber('4,7'), 4.7);
      expect(parseUserNumber(' 4.7 '), 4.7);
      expect(parseUserNumber('4,7k'), closeTo(4700, 1e-9));
      expect(parseUserNumber('1M'), 1e6);
      expect(parseUserNumber('−3'), -3);
      expect(parseUserNumber(''), isNull);
      expect(parseUserNumber('abc'), isNull);
    });
  });

  group('Progreso', () {
    test('niveles de dominio', () {
      expect(MasteryLevel.fromStats(attempts: 0, correct: 0),
          MasteryLevel.noEvidence);
      expect(MasteryLevel.fromStats(attempts: 10, correct: 4),
          MasteryLevel.developing);
      expect(MasteryLevel.fromStats(attempts: 10, correct: 5),
          MasteryLevel.acceptable);
      expect(MasteryLevel.fromStats(attempts: 10, correct: 8),
          MasteryLevel.achieved);
    });

    test('serialización de ida y vuelta', () {
      const p = LearningProgress(
        viewedComponents: {'resistor', 'led'},
        usedSimulations: {'ohm_power'},
        completedCases: {'night_light'},
        bestScores: {'quiz_passive': 80},
        competencies: {
          Competency.selection: CompetencyStat(attempts: 5, correct: 3),
        },
        mistakesByComponent: {'led': 2, 'resistor': 1},
      );
      final back = LearningProgress.fromJson(p.toJson());
      expect(back.viewedComponents, p.viewedComponents);
      expect(back.usedSimulations, p.usedSimulations);
      expect(back.completedCases, p.completedCases);
      expect(back.bestScores, p.bestScores);
      expect(back.statFor(Competency.selection).correct, 3);
      expect(back.statFor(Competency.functional).attempts, 0);
      expect(back.reviewSuggestions(), ['led', 'resistor']);
      expect(back.totalAttempts, 5);
    });

    test('tolera datos incompletos', () {
      final p = LearningProgress.fromJson(const {'viewed': 'no es lista'});
      expect(p.viewedComponents, isEmpty);
    });
  });
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/simulation/color_code.dart';

enum BandRole { digit, multiplier, tolerance }

class ColorCodeState {
  const ColorCodeState({required this.bands});

  final List<BandColor> bands;

  int get bandCount => bands.length;

  BandRole roleOf(int index) {
    if (index == bands.length - 1) return BandRole.tolerance;
    if (index == bands.length - 2) return BandRole.multiplier;
    return BandRole.digit;
  }

  List<BandColor> optionsFor(int index) => switch (roleOf(index)) {
        BandRole.digit => BandColor.digits,
        BandRole.multiplier => BandColor.multipliers,
        BandRole.tolerance => BandColor.tolerances,
      };

  ResistorReading get reading => ColorCode.decode(bands);
}

/// ViewModel del lector de código de colores.
class ColorCodeViewModel extends AutoDisposeNotifier<ColorCodeState> {
  static const _default4 = [
    BandColor.yellow,
    BandColor.violet,
    BandColor.red,
    BandColor.gold,
  ];

  static const _default5 = [
    BandColor.brown,
    BandColor.black,
    BandColor.black,
    BandColor.red,
    BandColor.brown,
  ];

  @override
  ColorCodeState build() => const ColorCodeState(bands: _default4);

  void setBandCount(int count) {
    if (count == state.bandCount) return;
    state = ColorCodeState(bands: count == 5 ? _default5 : _default4);
  }

  void setBand(int index, BandColor color) {
    if (index < 0 || index >= state.bandCount) return;
    if (!state.optionsFor(index).contains(color)) return;
    final bands = [...state.bands];
    bands[index] = color;
    state = ColorCodeState(bands: List.unmodifiable(bands));
  }
}

final colorCodeViewModelProvider =
    NotifierProvider.autoDispose<ColorCodeViewModel, ColorCodeState>(
  ColorCodeViewModel.new,
);

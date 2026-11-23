import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Paleta de cores do Petfy (muda conforme o tema de acessibilidade).
class PetColors extends ThemeExtension<PetColors> {
  final Color bg, surface, surface2, text, muted, line, accent, accent2, accentSoft, onAccent, danger;
  final Gradient grad;
  const PetColors({
    required this.bg,
    required this.surface,
    required this.surface2,
    required this.text,
    required this.muted,
    required this.line,
    required this.accent,
    required this.accent2,
    required this.accentSoft,
    required this.onAccent,
    required this.danger,
    required this.grad,
  });

  static const padrao = PetColors(
    bg: Color(0xFFFAF6F1),
    surface: Colors.white,
    surface2: Color(0xFFF4EDE4),
    text: Color(0xFF2B2018),
    muted: Color(0xFF7A6A5D),
    line: Color(0xFFEADFD3),
    accent: Color(0xFF9A6A44),
    accent2: Color(0xFFD4A574),
    accentSoft: Color(0xFFF3E7DA),
    onAccent: Colors.white,
    danger: Color(0xFFB3382C),
    grad: LinearGradient(colors: [Color(0xFF9A6A44), Color(0xFF9A6A44)]),
  );

  static const escuro = PetColors(
    bg: Color(0xFF16110D),
    surface: Color(0xFF221B15),
    surface2: Color(0xFF2C231B),
    text: Color(0xFFF5ECE3),
    muted: Color(0xFFB9A999),
    line: Color(0xFF3A2E24),
    accent: Color(0xFFD4A574),
    accent2: Color(0xFFE8C99F),
    accentSoft: Color(0xFF33281D),
    onAccent: Color(0xFF1D140C),
    danger: Color(0xFFFF8C7E),
    grad: LinearGradient(colors: [Color(0xFFD4A574), Color(0xFFD4A574)]),
  );

  /// Azul + laranja (Okabe-Ito): não depende de vermelho/verde.
  static const daltonico = PetColors(
    bg: Color(0xFFF1F5FA),
    surface: Colors.white,
    surface2: Color(0xFFE4ECF5),
    text: Color(0xFF0F1B2D),
    muted: Color(0xFF44546A),
    line: Color(0xFFB9C7DA),
    accent: Color(0xFF0057A3),
    accent2: Color(0xFFE69F00),
    accentSoft: Color(0xFFDBE8F6),
    onAccent: Colors.white,
    danger: Color(0xFFA30000),
    grad: LinearGradient(colors: [Color(0xFF0057A3), Color(0xFF0057A3)]),
  );

  static PetColors byName(String n) => n == 'escuro' ? escuro : (n == 'daltonico' ? daltonico : padrao);

  @override
  PetColors copyWith() => this;
  @override
  PetColors lerp(ThemeExtension<PetColors>? other, double t) => t < .5 ? this : (other as PetColors? ?? this);
}

extension PetCtx on BuildContext {
  PetColors get pal => Theme.of(this).extension<PetColors>()!;
}

ThemeData buildTheme(String name) {
  final c = PetColors.byName(name);
  final dark = name == 'escuro';
  final base = ThemeData(
    useMaterial3: true,
    brightness: dark ? Brightness.dark : Brightness.light,
    colorScheme: ColorScheme.fromSeed(seedColor: c.accent, brightness: dark ? Brightness.dark : Brightness.light).copyWith(
      primary: c.accent,
      onPrimary: c.onAccent,
      surface: c.surface,
      onSurface: c.text,
      error: c.danger,
    ),
    scaffoldBackgroundColor: c.bg,
    extensions: [c],
  );
  final text = GoogleFonts.latoTextTheme(base.textTheme).apply(bodyColor: c.text, displayColor: c.text);
  final border = (Color col) => OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: col, width: name == 'daltonico' ? 2 : 1.6));
  return base.copyWith(
    textTheme: text,
    splashFactory: InkSparkle.splashFactory,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: c.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: TextStyle(color: c.muted.withValues(alpha: .8)),
      border: border(c.line),
      enabledBorder: border(c.line),
      focusedBorder: border(c.accent),
      errorBorder: border(c.danger),
      focusedErrorBorder: border(c.danger),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: dark ? c.text : const Color(0xFF2B2018),
      contentTextStyle: TextStyle(color: dark ? c.bg : Colors.white, fontWeight: FontWeight.w700),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: c.bg,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    ),
  );
}

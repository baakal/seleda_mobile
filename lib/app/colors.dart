import 'package:flutter/material.dart';

// Royal blue palette
const Color kSeledaRoyalBlue = Color(0xFF4169E1); // primary accent
const Color kSeledaDark = Color(0xFF101320);   // dark scaffold / background
const Color kSeledaLightBg = Color(0xFFEFEFEF);
const Color kSeledaSuccess = Color(0xFF32CDC5);
const Color kSeledaDanger = Color(0xFFFF0000);

ColorScheme buildSeledaLightScheme() => const ColorScheme(
  brightness: Brightness.light,
  primary: kSeledaRoyalBlue,
  onPrimary: Colors.white,
  secondary: kSeledaRoyalBlue,
  onSecondary: Colors.white,
  error: kSeledaDanger,
  onError: Colors.white,
  background: kSeledaLightBg,
  onBackground: kSeledaDark,
  surface: Colors.white,
  onSurface: kSeledaDark,
);

ColorScheme buildSeledaDarkScheme() => const ColorScheme(
  brightness: Brightness.dark,
  primary: kSeledaRoyalBlue,
  onPrimary: Colors.white,
  secondary: kSeledaRoyalBlue,
  onSecondary: Colors.white,
  error: kSeledaDanger,
  onError: Colors.white,
  background: kSeledaDark,
  onBackground: Colors.white,
  surface: kSeledaDark,
  onSurface: Colors.white,
);

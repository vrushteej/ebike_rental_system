import 'package:flutter/material.dart';

class CustomTheme extends ThemeExtension<CustomTheme> {
  final LinearGradient primaryGradient;

  const CustomTheme({required this.primaryGradient});

  @override
  CustomTheme copyWith({LinearGradient? primaryGradient}) {
    return CustomTheme(
      primaryGradient: primaryGradient ?? this.primaryGradient,
    );
  }

  @override
  CustomTheme lerp(CustomTheme? other, double t) {
    if (other is! CustomTheme) return this;
    return CustomTheme(
      primaryGradient: LinearGradient.lerp(primaryGradient, other.primaryGradient, t)!,
    );
  }
}
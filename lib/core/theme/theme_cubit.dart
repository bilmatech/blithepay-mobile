import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(const ThemeState(brightness: Brightness.light));

  void toggleTheme() {
    final isDark = state.brightness == Brightness.dark;
    emit(ThemeState(brightness: isDark ? Brightness.light : Brightness.dark));
  }

  void setTheme(Brightness brightness) {
    emit(ThemeState(brightness: brightness));
  }
}

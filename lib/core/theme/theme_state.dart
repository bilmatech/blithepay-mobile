part of 'theme_cubit.dart';

class ThemeState extends Equatable {
  final Brightness brightness;

  const ThemeState({required this.brightness});

  @override
  List<Object?> get props => [brightness];
}

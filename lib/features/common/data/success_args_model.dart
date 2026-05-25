class SuccessArgs {
  final String title;
  final String message;
  final String buttonLabel;
  final String nextRoute;
  final Object? nextExtra;
  final bool useAuthBackground;

  const SuccessArgs({
    required this.title,
    required this.message,
    required this.buttonLabel,
    required this.nextRoute,
    this.nextExtra,
    this.useAuthBackground = false,
  });
}

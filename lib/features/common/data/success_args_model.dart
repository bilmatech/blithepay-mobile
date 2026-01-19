
class SuccessArgs {
  final String title;
  final String message;
  final String buttonLabel;
  final String nextRoute;
  final Object? nextExtra;

  const SuccessArgs({
    required this.title,
    required this.message,
    required this.buttonLabel,
    required this.nextRoute,
    this.nextExtra,
  });
}

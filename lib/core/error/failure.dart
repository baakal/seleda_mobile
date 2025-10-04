class AppFailure {
  const AppFailure(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => 'AppFailure(message: $message, cause: $cause)';
}

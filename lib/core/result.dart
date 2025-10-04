sealed class Result<T, E> {
  const Result();

  R fold<R>(R Function(T value) onSuccess, R Function(E error) onFailure);

  bool get isSuccess => this is Success<T, E>;
  bool get isFailure => this is Failure<T, E>;
}

class Success<T, E> extends Result<T, E> {
  const Success(this.value);

  final T value;

  @override
  R fold<R>(R Function(T value) onSuccess, R Function(E error) onFailure) =>
      onSuccess(value);
}

class Failure<T, E> extends Result<T, E> {
  const Failure(this.error);

  final E error;

  @override
  R fold<R>(R Function(T value) onSuccess, R Function(E error) onFailure) =>
      onFailure(error);
}

sealed class Result<T, E> {
  const Result();

  bool get isSuccess => this is Success<T, E>;
  bool get isFailure => this is FailureResult<T, E>;
}

final class Success<T, E> extends Result<T, E> {
  const Success(this.value);
  final T value;
}

final class FailureResult<T, E> extends Result<T, E> {
  const FailureResult(this.failure);
  final E failure;
}

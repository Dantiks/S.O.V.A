import 'package:freezed_annotation/freezed_annotation.dart';

part 'result.freezed.dart';

@freezed
class Result<T> with _$Result<T> {
  const factory Result.success(T data) = Success<T>;
  const factory Result.failure(String message, {String? code}) = Failure<T>;
}

extension ResultExtension<T> on Result<T> {
  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get dataOrNull => when(
        success: (data) => data,
        failure: (_, __) => null,
      );

  String? get errorOrNull => when(
        success: (_) => null,
        failure: (message, _) => message,
      );
}

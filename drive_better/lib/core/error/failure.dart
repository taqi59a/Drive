sealed class Failure {
  const Failure(this.message);
  final String message;
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network error. Please check your connection.']);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error. Please try again.']);
  final int? statusCode = null;
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Local data error.']);
}

class OcrFailure extends Failure {
  const OcrFailure([super.message = 'Could not read text from image.']);
}

class PermissionFailure extends Failure {
  const PermissionFailure([super.message = 'Camera permission required.']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'An unexpected error occurred.']);
}

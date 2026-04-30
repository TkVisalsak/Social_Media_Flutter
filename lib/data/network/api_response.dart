/// Generic typed wrapper — every repo returns this.
class ApiResponse<T> {
  final T? data;
  final String? error;
  final bool success;

  const ApiResponse.success(this.data)
    : success = true, error = null;

  const ApiResponse.failure(this.error)
    : success = false, data = null;
}

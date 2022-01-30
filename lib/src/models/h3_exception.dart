class H3Exception implements Exception {
  H3Exception(this.message);

  final String message;

  @override
  String toString() {
    return "H3Exception: $message";
  }
}

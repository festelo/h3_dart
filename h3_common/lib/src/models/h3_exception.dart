/// Error messages corresponding to the core library error codes. See
/// https://h3geo.org/docs/library/errors#table-of-error-codes
/// [H3ExceptionCode.internal] corresponds to exceptions originating from `h3_dart` itself.
enum H3ExceptionCode {
  success,
  failed,
  domain,
  latlngDomain,
  resolutionDomain,
  cellInvalid,
  dirEdgeInvalid,
  undirEdgeInvalid,
  vertexInvalid,
  pentagon,
  duplicateInput,
  notNeighbors,
  resolutionMismatch,
  memoryAlloc,
  memoryBounds,
  optionInvalid,
  internal,
}

/// Class for all H3-related exceptions
class H3Exception implements Exception {
  const H3Exception(this.code, this.message);

  H3Exception.fromCode(this.code)
      : message = switch (code) {
          H3ExceptionCode.success => 'Success',
          H3ExceptionCode.failed =>
            'The operation failed but a more specific error is not available',
          H3ExceptionCode.domain => 'Argument was outside of acceptable range',
          H3ExceptionCode.latlngDomain =>
            'Latitude or longitude arguments were outside of acceptable range',
          H3ExceptionCode.resolutionDomain =>
            'Resolution argument was outside of acceptable range',
          H3ExceptionCode.cellInvalid => 'Cell argument was not valid',
          H3ExceptionCode.dirEdgeInvalid =>
            'Directed edge argument was not valid',
          H3ExceptionCode.undirEdgeInvalid =>
            'Undirected edge argument was not valid',
          H3ExceptionCode.vertexInvalid => 'Vertex argument was not valid',
          H3ExceptionCode.pentagon => 'Pentagon distortion was encountered',
          H3ExceptionCode.duplicateInput => 'Duplicate input',
          H3ExceptionCode.notNeighbors => 'Cell arguments were not neighbors',
          H3ExceptionCode.resolutionMismatch =>
            'Cell arguments had incompatible resolutions',
          H3ExceptionCode.memoryAlloc => 'Memory allocation failed',
          H3ExceptionCode.memoryBounds =>
            'Bounds of provided memory were insufficient',
          H3ExceptionCode.optionInvalid =>
            'Mode or flags argument was not valid',
          H3ExceptionCode.internal => throw ArgumentError(
              'Do not use H3Exception.fromCode(code) with H3ExceptionCode.internal as code',
            )
        };

  final String message;
  final H3ExceptionCode code;

  @override
  String toString() {
    return "H3Exception: $message";
  }
}

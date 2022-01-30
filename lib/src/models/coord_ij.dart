/// Coordinates as an {i, j} pair
class CoordIJ {
  const CoordIJ({
    required this.i,
    required this.j,
  });

  final int i;
  final int j;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CoordIJ && other.j == j && other.i == i;
  }

  @override
  int get hashCode => j.hashCode ^ i.hashCode;

  @override
  String toString() => 'CoordIJ(i: $i, i: $j)';
}

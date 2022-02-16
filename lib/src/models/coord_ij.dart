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
  int get hashCode => Object.hash(j, i);

  @override
  String toString() => 'CoordIJ(i: $i, j: $j)';
}

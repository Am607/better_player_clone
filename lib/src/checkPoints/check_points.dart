class CheckPointData {
  final double videoFraction;
  final bool status;

  CheckPointData({required this.status, required this.videoFraction});

  CheckPointData copyWith({
    double? value,
    bool? status,
  }) {
    return CheckPointData(
      videoFraction: value ?? this.videoFraction,
      status: status ?? this.status,
    );
  }

  @override
  String toString() {
    return 'CheckPointData(value: $videoFraction, status: $status)';
  }
}
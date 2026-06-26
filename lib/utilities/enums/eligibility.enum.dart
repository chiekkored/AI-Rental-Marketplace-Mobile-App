enum VerificationLevel {
  none('None'),
  basic('Basic'),
  full('Full');

  final String label;
  const VerificationLevel(this.label);

  bool get canRent =>
      this == VerificationLevel.basic || this == VerificationLevel.full;
  bool get canList => this == VerificationLevel.full;

  static VerificationLevel fromLabel(String? label) {
    return VerificationLevel.values.firstWhere(
      (level) => level.label == label,
      orElse: () => VerificationLevel.none,
    );
  }
}

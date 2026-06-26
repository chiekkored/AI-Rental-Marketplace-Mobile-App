enum TokenType {
  handOver('Hand Over'),
  returning('Return');

  final String label;
  const TokenType(this.label);

  static TokenType fromString(String value) {
    return TokenType.values.firstWhere(
      (e) => e.label.toLowerCase() == value.toLowerCase(),
      orElse: () => TokenType.handOver,
    );
  }
}

enum UserStatus {
  active('Active'),
  deactivated('Deactivated'),
  deleted('Deleted'),
  disabled('Disabled');

  final String label;
  const UserStatus(this.label);

  static UserStatus fromLabel(String? label) {
    return UserStatus.values.firstWhere(
      (level) => level.label == label,
      orElse: () => UserStatus.active,
    );
  }
}

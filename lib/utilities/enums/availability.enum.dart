enum Availability {
  available('Available', ''),
  underMaintenance('Under Maintenance', 'Displayed but not available for rent'),
  hidden('Hidden', '');

  final String label;
  final String subtitle;
  const Availability(this.label, this.subtitle);
}

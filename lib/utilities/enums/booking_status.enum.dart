enum BookingStatus {
  pending('Pending'),
  confirmed('Confirmed'),
  handedOver('HandedOver'),
  returned('Returned'),
  completed('Completed'),
  declined('Declined'),
  cancelled('Cancelled'),
  cancellationRequested('Cancellation Requested');

  final String label;
  const BookingStatus(this.label);

  static const List<BookingStatus> active = [
    BookingStatus.confirmed,
    BookingStatus.handedOver,
    BookingStatus.returned,
  ];

  static const List<BookingStatus> dateBlocking = [
    BookingStatus.confirmed,
    BookingStatus.handedOver,
    BookingStatus.returned,
    BookingStatus.cancellationRequested,
  ];

  static List<String> get activeLabels =>
      active.map((status) => status.label).toList(growable: false);

  static List<String> get dateBlockingLabels =>
      dateBlocking.map((status) => status.label).toList(growable: false);

  static BookingStatus fromString(String value) {
    return BookingStatus.values.firstWhere(
      (e) => e.label.toLowerCase() == value.toLowerCase(),
      orElse: () => BookingStatus.pending,
    );
  }
}

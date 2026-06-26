import 'package:get/get.dart';
import 'package:lend/presentation/controllers/booking_document_pdf/booking_document_pdf.controller.dart';

class BookingDocumentPdfBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(BookingDocumentPdfController());
  }
}

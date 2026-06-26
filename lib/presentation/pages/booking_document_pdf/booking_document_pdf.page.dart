import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/spinner.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/booking_document_pdf/booking_document_pdf.controller.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class BookingDocumentPdfPage extends GetView<BookingDocumentPdfController> {
  static const routeName = '/booking-document-pdf';

  const BookingDocumentPdfPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        surfaceTintColor: colors.surface,
        backgroundColor: colors.surface,
        leading: LNDButton.back(),
        title: LNDText.bold(text: controller.title, fontSize: 18.0),
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: LNDSpinner());
          }

          final path = controller.localPath.value;
          if (path == null || path.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LNDText.medium(
                      text:
                          controller.errorMessage.value ??
                          'Unable to open this document.',
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.visible,
                    ),
                    const SizedBox(height: 16.0),
                    LNDButton.primary(
                      text: 'Try again',
                      enabled: true,
                      onPressed: controller.loadDocument,
                    ),
                  ],
                ),
              ),
            );
          }

          return PDFView(
            filePath: path,
            enableSwipe: true,
            swipeHorizontal: false,
            autoSpacing: true,
            pageFling: true,
          );
        }),
      ),
    );
  }
}

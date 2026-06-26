import 'package:get/get.dart';
import 'package:lend/presentation/controllers/deleted_listing_notice/deleted_listing_notice.controller.dart';

class DeletedListingNoticeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(DeletedListingNoticeController());
  }
}

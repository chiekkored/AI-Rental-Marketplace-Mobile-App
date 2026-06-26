import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:lend/core/models/asset.model.dart';
import 'package:lend/presentation/controllers/create_listing/chunks/create_listing.chunk.dart';

class CreateListingDetailsChunk implements CreateListingChunk {
  final formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final ownerInstructionsController = TextEditingController();

  final canContinue = false.obs;

  @override
  void onInit() {
    titleController.addListener(_updateCanContinue);
    _updateCanContinue();
  }

  void _updateCanContinue() {
    canContinue.value = titleController.text.trim().isNotEmpty;
  }

  bool validate() {
    return formKey.currentState?.validate() != false;
  }

  void populateFromAsset(Asset asset) {
    titleController.text = asset.title ?? '';
    descriptionController.text = asset.description ?? '';
    ownerInstructionsController.text = asset.ownerInstructions ?? '';
  }

  Map<String, dynamic> toDraftMap() {
    return toMap();
  }

  Map<String, dynamic> toMap() {
    return {
      'title': titleController.text.trim(),
      'description': descriptionController.text.trim(),
      'ownerInstructions': ownerInstructionsController.text.trim(),
    };
  }

  void loadFromDraft(Map<String, dynamic> draft) {
    titleController.text = draft['title'] as String? ?? '';
    descriptionController.text = draft['description'] as String? ?? '';
    ownerInstructionsController.text =
        draft['ownerInstructions'] as String? ?? '';
  }

  @override
  void onClose() {
    titleController.removeListener(_updateCanContinue);

    canContinue.close();

    titleController.dispose();
    descriptionController.dispose();
    ownerInstructionsController.dispose();
  }
}

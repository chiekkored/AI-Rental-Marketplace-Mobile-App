import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/core/models/asset.model.dart';
import 'package:lend/presentation/controllers/create_listing/chunks/create_listing.chunk.dart';
import 'package:lend/presentation/common/snackbar.common.dart';

class CreateListingInclusionsChunk implements CreateListingChunk {
  final inclusionController = TextEditingController();
  final RxList<String> inclusions = <String>[].obs;

  @override
  void onInit() {
    // No listeners/workers needed for now.
  }

  void addInclusion() {
    final value = inclusionController.text.trim().capitalizeFirst ?? '';

    if (value.isEmpty) return;

    if (value.length > 30) {
      LNDSnackbar.showWarning('Inclusions must be 30 characters or fewer.');
      return;
    }

    inclusions.add(value);
    inclusionController.clear();
  }

  void removeInclusion(int index) {
    inclusions.removeAt(index);
  }

  void populateFromAsset(Asset asset) {
    inclusions.assignAll(asset.inclusions ?? []);
  }

  void loadFromDraft(Map<String, dynamic> draft) {
    inclusions.assignAll(List<String>.from(draft['inclusions'] ?? []));
  }

  Map<String, dynamic> toDraftMap() {
    return {'inclusions': inclusions.toList()};
  }

  @override
  void onClose() {
    inclusionController.dispose();
    inclusions.close();
  }
}

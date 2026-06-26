import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/controllers/create_listing/create_listing.controller.dart';
import 'package:lend/presentation/pages/create_listing/widgets/create_listing_section.dart';
import 'package:lend/presentation/pages/create_listing/widgets/create_listing_step_scaffold.dart';
import 'package:lend/presentation/pages/create_listing/widgets/forms/listing_details_form_registry.dart';

class DynamicDetailsStep extends StatefulWidget {
  const DynamicDetailsStep({super.key, required this.dynamicStepIndex});

  final int dynamicStepIndex;

  @override
  State<DynamicDetailsStep> createState() => _DynamicDetailsStepState();
}

class _DynamicDetailsStepState extends State<DynamicDetailsStep> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final controller = CreateListingController.instance;
    return Obx(() {
      controller.detailSchemaKey.value;
      controller.listingKind.value;

      Widget buildStep() {
        final content = buildCreateListingDynamicDetailsStepContent(
          context: context,
          chunk: controller.dynamicDetails,
          stepIndex: widget.dynamicStepIndex,
        );

        return CreateListingStepScaffold(
          stepIndex:
              controller.dynamicDetailsStartStepIndex + widget.dynamicStepIndex,
          title: content.title,
          description: content.description,
          secondaryText: 'Back',
          secondaryAction:
              () => controller.goToStep(
                widget.dynamicStepIndex == 0
                    ? 2
                    : controller.dynamicDetailsStartStepIndex +
                        widget.dynamicStepIndex -
                        1,
              ),
          primaryText: 'Continue',
          primaryEnabled: content.canContinue,
          primaryAction: () {
            if (!(_formKey.currentState?.validate() ?? true)) return;
            controller.continueFromDynamicDetails(widget.dynamicStepIndex);
          },
          child: Form(
            key: _formKey,
            child: CreateListingSection(
              title: content.sectionTitle,
              required: content.required,
              description: content.sectionDescription,
              child: content.child,
            ),
          ),
        );
      }

      final content = buildCreateListingDynamicDetailsStepContent(
        context: context,
        chunk: controller.dynamicDetails,
        stepIndex: widget.dynamicStepIndex,
      );
      if (content.listenables.isEmpty) return buildStep();

      return AnimatedBuilder(
        animation: Listenable.merge(content.listenables),
        builder: (_, _) => buildStep(),
      );
    });
  }
}

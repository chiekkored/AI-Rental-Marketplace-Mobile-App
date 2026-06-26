import 'package:flutter/material.dart';
import 'package:lend/presentation/common/shimmer.common.dart';

class PaymentMethodsShimmer extends StatelessWidget {
  final int count;

  const PaymentMethodsShimmer({this.count = 2, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < count; i++)
          const Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: LNDShimmer(child: _PaymentMethodShimmerRow()),
          ),
      ],
    );
  }
}

class _PaymentMethodShimmerRow extends StatelessWidget {
  const _PaymentMethodShimmerRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        LNDShimmerBox(height: 36.0, width: 48.0),
        SizedBox(width: 12.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LNDShimmerBox(height: 14.0, width: 110.0),
              SizedBox(height: 8.0),
              LNDShimmerBox(height: 12.0, width: 170.0),
            ],
          ),
        ),
        SizedBox(width: 12.0),
        LNDShimmerBox(height: 22.0, width: 22.0),
      ],
    );
  }
}

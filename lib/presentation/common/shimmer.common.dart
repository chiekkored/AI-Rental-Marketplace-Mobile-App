import 'package:flutter/widgets.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';
import 'package:shimmer/shimmer.dart';

class LNDShimmer extends StatelessWidget {
  final Widget child;
  const LNDShimmer({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return Shimmer.fromColors(
      baseColor: colors.surfaceMuted,
      highlightColor: colors.surface,
      child: child,
    );
  }
}

class LNDShimmerBox extends StatelessWidget {
  final double height;
  final double width;
  final Widget? child;
  const LNDShimmerBox({
    required this.height,
    required this.width,
    this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: child,
    );
  }
}

class LNDShimmerCircle extends StatelessWidget {
  final double size;
  final Widget? child;

  const LNDShimmerCircle({required this.size, this.child, super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return LNDShimmer(
      child: Container(
        height: size,
        width: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors.surface,
        ),
        child: child,
      ),
    );
  }
}

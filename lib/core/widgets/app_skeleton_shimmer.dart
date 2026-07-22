import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../config/theme/app_colors.dart';

class AppSkeletonShimmer extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const AppSkeletonShimmer({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
      highlightColor: isDark ? AppColors.darkBorder : Colors.white,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }

  static Widget listTilePlaceholder({int itemCount = 4}) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => Row(
        children: [
          const AppSkeletonShimmer(width: 44, height: 44, borderRadius: 10),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                AppSkeletonShimmer(width: double.infinity, height: 14),
                SizedBox(height: 8),
                AppSkeletonShimmer(width: 160, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

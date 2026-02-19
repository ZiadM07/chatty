import '../../../core/constants/exports.dart';

import '../skeletons/src/stylings.dart';
import '../skeletons/src/widgets.dart';
import 'app_lottie_image.dart';

class Loading {
  static Widget loader(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.black38,
            borderRadius: AppBorderRadius.set(all: 9.0),
          ),
          padding: AppPadding.set(horizontal: 12.0, vertical: 12.0),
          child: Column(
            children: [
              AppLottieImage(
                Jsons.loading,
                width: 90,
                height: 50,
                fit: BoxFit.fitHeight,
              ).addPadding(bottom: 4.0),
              AppText(
                context.locale.loading,
                color: Colors.white,
                size: 12,
                weight: FontWeight.w500,
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget loadingSkeleton({
    double? height,
    double? width,
    AppPadding padding = const AppPadding.set(horizontal: 24.0, vertical: 12.0),
    AppBorderRadius? borderRadius,
  }) {
    return Padding(
      padding: padding,
      child: SkeletonLine(
        style: SkeletonLineStyle(
          width: width,
          height: height,
          borderRadius: borderRadius ?? AppBorderRadius.set(all: 16.0),
        ),
      ),
    );
  }

  static Widget loadingText({
    required double height,
    required double width,
    int count = 1,
    AppPadding padding = const AppPadding.set(horizontal: 24.0, vertical: 2.0),
  }) {
    return Padding(
      padding: padding,
      child: SkeletonParagraph(
        style: SkeletonParagraphStyle(
          lines: count,
          spacing: 6,
          lineStyle: SkeletonLineStyle(
            randomLength: true,
            height: height,
            borderRadius: BorderRadius.circular(5.0),
            maxLength: width,
            minLength: width * 0.7,
          ),
        ),
      ),
    );
  }
}

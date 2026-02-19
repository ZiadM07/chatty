import '../../../core/constants/exports.dart';

class AppFileImage extends StatelessWidget {
  final File file;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Color? color;
  final double borderRadius;
  final AlignmentGeometry alignment;

  const AppFileImage(
    this.file, {
    super.key,
    this.borderRadius = 0,
    this.height = 25,
    this.width = 25,
    this.fit = BoxFit.contain,
    this.color,
    this.alignment = Alignment.topCenter,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.file(
        file,
        width: width,
        height: height,
        fit: fit,
        color: color,
        alignment: alignment,
      ),
    );
  }
}

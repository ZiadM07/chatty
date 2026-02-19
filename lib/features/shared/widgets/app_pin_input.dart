import '../../../core/constants/exports.dart';
import 'package:pinput/pinput.dart';

class AppPinInput extends StatelessWidget {
  final AppPinState appPinState;
  final void Function(String) onPinEntered;

  const AppPinInput({
    super.key,
    required this.appPinState,
    required this.onPinEntered,
  });

  @override
  Widget build(BuildContext context) {
    final baseTextStyle = context.textTheme.bodyLarge!;
    final successColor = context.colorScheme.success;
    final outlineColor = context.colorScheme.outline;

    final isSuccess = appPinState == AppPinState.success;
    final isError = appPinState == AppPinState.error;

    final borderColor =
        isSuccess
            ? successColor
            : isError
            ? context.colorScheme.error
            : outlineColor;

    final pinTextStyle = baseTextStyle.copyWith(color: borderColor);

    final baseDecoration = BoxDecoration(
      color: Colors.transparent,
      border: Border.all(color: borderColor),
      borderRadius: BorderRadius.circular(10),
    );

    return Pinput(
      length: AppConstants.otpLength,
      pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
      onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
      forceErrorState: isError,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "";
        } else {
          return null;
        }
      },
      defaultPinTheme: PinTheme(
        width: 48,
        height: 48,
        textStyle: pinTextStyle,
        decoration: baseDecoration,
      ),
      focusedPinTheme: PinTheme(
        width: 48,
        height: 48,
        textStyle: pinTextStyle.copyWith(color: context.colorScheme.primary),
        decoration: BoxDecoration(
          border: Border.all(color: context.colorScheme.primary, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      submittedPinTheme: PinTheme(
        width: 48,
        height: 48,
        textStyle: pinTextStyle.copyWith(color: context.colorScheme.onPrimary),
        decoration: BoxDecoration(
          color: context.colorScheme.primary,
          border: Border.all(color: context.colorScheme.primary, width: 1.5),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      errorPinTheme: PinTheme(
        width: 48,
        height: 48,
        textStyle: context.textTheme.bodySmall!.copyWith(
          color: context.colorScheme.error,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: context.colorScheme.errorContainer),
          borderRadius: AppBorderRadius.set(all: 8),
        ),
      ),
      onCompleted: onPinEntered,
    );
  }
}

enum AppPinState { normal, error, success, initial }

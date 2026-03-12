import '../../../core/constants/exports.dart';

class AppTextFormField extends StatefulWidget {
  final TextEditingController? controller;

  final String? hintText;
  final bool isPasswordField;
  final bool readOnly;
  final TextInputType textInputType;
  final TextInputAction? textInputAction;
  final Widget? prefix;
  final Widget? suffixIcon;
  final Function(String value)? onChanged;
  final Function(String value)? onFieldSubmitted;
  final FormFieldSetter<String>? onSaved;
  final VoidCallback? onTap;
  final VoidCallback? onEditingComplete;
  final String? label;
  final double borderRadius;
  final Color? fillColor;
  final EdgeInsetsGeometry? contentPadding;
  final TextStyle? textStyle;
  final AutovalidateMode? autoValidationMode;
  final FormFieldValidator<String>? validator;
  final FocusNode? focusNode;
  final bool? enabled;
  final int? maxLength;
  final int? maxLines;
  final int? minLines;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final bool autocorrect;
  final bool enableSuggestions;
  final String? errorText;
  final String? helperText;
  final bool autofocus;
  final TextAlign textAlign;
  final TextDirection? hintTextDirection;
  final bool? obscureText;

  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? errorBorderColor;
  final double borderWidth;
  final double focusedBorderWidth;

  const AppTextFormField({
    super.key,
    this.controller,
    this.hintText,
    this.isPasswordField = false,
    this.readOnly = false,
    this.textInputType = TextInputType.text,
    this.textInputAction,
    this.prefix,
    this.suffixIcon,
    this.onChanged,
    this.onFieldSubmitted,
    this.onSaved,
    this.onTap,
    this.onEditingComplete,
    this.label,
    this.borderRadius = 20,
    this.fillColor,
    this.contentPadding,
    this.textStyle,
    this.autoValidationMode,
    this.validator,
    this.focusNode,
    this.enabled,
    this.maxLength,
    this.maxLines = 1,
    this.minLines,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.errorText,
    this.helperText,
    this.autofocus = false,
    this.textAlign = TextAlign.start,
    this.hintTextDirection,
    this.obscureText,
    this.borderColor,
    this.focusedBorderColor,
    this.errorBorderColor,
    this.borderWidth = 1,
    this.focusedBorderWidth = 1.2,
  });

  @override
  State<AppTextFormField> createState() => _AppTextFormFieldState();
}

class _AppTextFormFieldState extends State<AppTextFormField> {
  late final ValueNotifier<bool> _obscureNotifier;
  late final ValueNotifier<TextDirection> _textDirectionNotifier;

  @override
  void initState() {
    super.initState();
    _obscureNotifier = ValueNotifier(
      widget.obscureText ?? widget.isPasswordField,
    );
    _textDirectionNotifier = ValueNotifier(TextDirection.ltr);

    widget.controller?.addListener(_updateTextDirection);
    _updateTextDirection();
  }

  void _updateTextDirection() {
    final text = widget.controller?.text ?? '';
    final isRTL = _isArabic(text);
    final newDir = isRTL ? TextDirection.rtl : TextDirection.ltr;
    if (_textDirectionNotifier.value != newDir) {
      _textDirectionNotifier.value = newDir;
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_updateTextDirection);
    _obscureNotifier.dispose();
    _textDirectionNotifier.dispose();
    super.dispose();
  }

  void _toggleObscure() => _obscureNotifier.value = !_obscureNotifier.value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;

    return ValueListenableBuilder(
      valueListenable: _obscureNotifier,
      builder: (context, obscure, _) {
        return ValueListenableBuilder(
          valueListenable: _textDirectionNotifier,
          builder: (context, direction, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.label != null) ...[
                  AppText(
                    widget.label!,
                    style: context.textTheme.titleSmall,
                  ).addPadding(start: 4, bottom: 8),
                ],
                TextFormField(
                  cursorRadius: const Radius.circular(6),
                  cursorColor: colors.primary,
                  cursorWidth: 2,
                  enabled: widget.enabled,
                  focusNode: widget.focusNode,
                  controller: widget.controller,
                  obscureText: widget.isPasswordField ? obscure : false,
                  readOnly: widget.readOnly,
                  keyboardType: widget.textInputType,
                  textInputAction: widget.textInputAction,
                  textCapitalization: widget.textCapitalization,
                  textAlign: widget.textAlign,
                  autofocus: widget.autofocus,
                  autocorrect: widget.isPasswordField
                      ? false
                      : widget.autocorrect,
                  enableSuggestions: widget.isPasswordField
                      ? false
                      : widget.enableSuggestions,
                  maxLength: widget.maxLength,
                  maxLines: widget.isPasswordField ? 1 : widget.maxLines,
                  minLines: widget.minLines,
                  inputFormatters: widget.inputFormatters,
                  autovalidateMode:
                      widget.autoValidationMode ??
                      AutovalidateMode.onUserInteraction,
                  validator: widget.validator,
                  onChanged: widget.onChanged,
                  onFieldSubmitted: widget.onFieldSubmitted,
                  onSaved: widget.onSaved,
                  onTap: widget.onTap,
                  onEditingComplete: widget.onEditingComplete,
                  textDirection: direction,
                  style:
                      widget.textStyle ??
                      context.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: colors.onSurface,
                      ),
                  decoration: _buildDecoration(context, colors, obscure),
                ),
              ],
            );
          },
        );
      },
    );
  }

  InputDecoration _buildDecoration(
    BuildContext context,
    ColorScheme colors,
    bool obscure,
  ) {
    return InputDecoration(
      filled: true,
      fillColor:
          widget.fillColor ?? colors.onPrimaryContainer.withValues(alpha: 0.08),
      hintText: widget.hintText,
      hintTextDirection: widget.hintTextDirection,
      hintStyle: context.textTheme.bodyMedium?.copyWith(
        color: colors.onSurfaceVariant.withValues(alpha: 0.6),
      ),
      errorText: widget.errorText,
      helperText: widget.helperText,
      helperStyle: context.textTheme.bodySmall?.copyWith(
        color: colors.onSurfaceVariant,
        height: 1.4,
      ),
      errorStyle: context.textTheme.bodySmall?.copyWith(
        color: colors.error,
        fontWeight: FontWeight.w500,
        height: 1.4,
      ),
      errorMaxLines: 2,
      counterText: widget.maxLength != null ? '' : null,
      contentPadding:
          widget.contentPadding ??
          AppPadding.set(
            vertical: widget.maxLines == 1 ? 18 : 16,
            horizontal: 20,
          ),
      prefixIcon: widget.prefix?.addPadding(start: 12, end: 8),
      prefixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      suffixIcon: widget.isPasswordField
          ? _buildPasswordToggle(colors, obscure)
          : widget.suffixIcon,
      suffixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      border: _buildBorder(BorderSide.none),
      enabledBorder: _buildBorder(
        BorderSide(
          color: widget.borderColor ?? colors.outline.withValues(alpha: 0.3),
          width: widget.borderWidth,
        ),
      ),
      focusedBorder: _buildBorder(
        BorderSide(
          color: widget.focusedBorderColor ?? colors.primary,
          width: widget.focusedBorderWidth,
        ),
      ),
      errorBorder: _buildBorder(
        BorderSide(
          color: widget.errorBorderColor ?? colors.error,
          width: widget.borderWidth,
        ),
      ),
      focusedErrorBorder: _buildBorder(
        BorderSide(
          color: widget.errorBorderColor ?? colors.error,
          width: widget.focusedBorderWidth,
        ),
      ),
      disabledBorder: _buildBorder(
        BorderSide(
          color: colors.outline.withValues(alpha: 0.15),
          width: widget.borderWidth,
        ),
      ),
    );
  }

  OutlineInputBorder _buildBorder(BorderSide side) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      borderSide: side,
    );
  }

  Widget _buildPasswordToggle(ColorScheme colors, bool obscure) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (child, animation) {
        return ScaleTransition(scale: animation, child: child);
      },
      child: Icon(
        obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        key: ValueKey(obscure),
        color: colors.onSurfaceVariant,
        size: 22,
      ).addAction(onBounce: _toggleObscure, padding: AppPadding.set(all: 12)),
    );
  }

  bool _isArabic(String text) {
    final arabicRegex = RegExp(
      r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFEFC]',
    );
    return arabicRegex.hasMatch(text);
  }
}

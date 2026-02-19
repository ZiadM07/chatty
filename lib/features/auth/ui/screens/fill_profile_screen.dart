import 'package:chatty/core/framework/pick_file.dart';
import 'package:chatty/features/auth/cubits/auth_cubit.dart';
import 'package:chatty/features/auth/cubits/auth_state.dart';
import 'package:chatty/features/auth/data/models/user_model.dart';
import 'package:chatty/features/shared/widgets/app_asset_image.dart';
import 'package:chatty/features/shared/widgets/app_file_image.dart';
import 'package:chatty/features/shared/widgets/app_gradient_button.dart';
import 'package:chatty/features/shared/widgets/app_image.dart';
import 'package:chatty/features/shared/widgets/app_text_form_field.dart';
import 'package:chatty/config/router/app_router.gr.dart';
import '../../../../core/constants/exports.dart';
import '../../../shared/widgets/app_toast.dart';

@RoutePage()
class FillProfileScreen extends StatefulWidget {
  const FillProfileScreen({super.key});

  @override
  State<FillProfileScreen> createState() => _FillProfileScreenState();
}

class _FillProfileScreenState extends State<FillProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController()..text = 'i am new user';
  final _usernameFocusNode = FocusNode();
  final _nameFocusNode = FocusNode();
  final _bioFocusNode = FocusNode();
  Gender _gender = Gender.male;
  File? _selectedImage;

  @override
  void dispose() {
    _usernameController.dispose();
    _nameController.dispose();
    _bioController.dispose();
    _usernameFocusNode.dispose();
    _nameFocusNode.dispose();
    _bioFocusNode.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final file = await PickFile.image();
    if (file != null) setState(() => _selectedImage = file);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final currentUser = context.read<AuthCubit>().state.currentUser;
    if (currentUser == null) return;

    context.read<AuthCubit>().saveProfile(
      user: UserModel(
        uid: currentUser.uid,
        email: currentUser.email,
        username: _usernameController.text.trim(),
        fullName: _nameController.text.trim(),
        bio: _bioController.text.trim(),
        gender: _gender,
        createdAt: DateTime.now(),
      ),
      imageFile: _selectedImage,
    );
  }

  void _onSuccess() {
    context.read<AuthCubit>().resetFillProfileState();
    context.router.replaceAll([const AuthenticatedRoutes()]);
  }

  void _onFailure(AuthState state) {
    context.read<AuthCubit>().resetFillProfileState();
    AppToast.showError(
      message: state.fillProfileState.message ?? context.locale.unexpectedError,
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      buildWhen: (prev, curr) => prev.fillProfileState != curr.fillProfileState,
      listenWhen: (prev, curr) =>
          prev.fillProfileState != curr.fillProfileState,
      listener: (context, state) {
        if (state.fillProfileState.status == StateStatus.success) _onSuccess();
        if (state.fillProfileState.status == StateStatus.error) {
          _onFailure(state);
        }
      },
      builder: (context, state) {
        // loadingOverlay → form stays visible, spinner shows on top via StateHandler
        return StateHandler(
          state: state.fillProfileState,
          builder: (context, _) => AppScaffold(
            appbarSize: 0,
            showBackButton: false,
            body: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 40),

                    Align(
                      alignment: Alignment.center,
                      child: AppAssetImage(
                        Pngs.chatty,
                        fit: BoxFit.contain,
                        width: 200,
                        height: 100,
                      ),
                    ),

                    const SizedBox(height: 10),

                    AppText(
                      context.locale.completeProfileMessage,
                      style: context.textTheme.bodyLarge,
                    ),

                    const SizedBox(height: 30),

                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        _selectedImage != null
                            ? AppFileImage(
                                _selectedImage!,
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                                borderRadius: 100,
                              )
                            : AppImage(
                                imageUrl: AppConstants.fakeUserImage,
                                width: 120,
                                height: 120,
                                borderRadius: 100,
                              ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 35,
                            height: 35,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  context.colorScheme.primary,
                                  context.colorScheme.secondary,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: IconButton(
                              onPressed: _pickImage,
                              icon: Icon(
                                SolarIconsOutline.cameraAdd,
                                size: 20,
                                color: context.colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    AppTextFormField(
                      controller: _usernameController,
                      label: context.locale.username,
                      hintText: context.locale.username,
                      maxLength: 30,
                      validator: (v) => Validator.validateUsername(v?.trim()),
                      focusNode: _usernameFocusNode,
                      onFieldSubmitted: (_) => _nameFocusNode.requestFocus(),
                    ),

                    const SizedBox(height: 10),

                    AppTextFormField(
                      controller: _nameController,
                      label: context.locale.name,
                      hintText: context.locale.name,
                      maxLength: 50,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? context.locale.nameIsRequired
                          : null,
                      focusNode: _nameFocusNode,
                      onFieldSubmitted: (_) => _bioFocusNode.requestFocus(),
                    ),

                    const SizedBox(height: 10),

                    AppTextFormField(
                      controller: _bioController,
                      label: context.locale.bio,
                      hintText: context.locale.bio,
                      maxLines: 1,
                      maxLength: 100,
                      focusNode: _bioFocusNode,
                    ),

                    const SizedBox(height: 20),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: AppText(
                        context.locale.gender,
                        style: context.textTheme.titleMedium,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _genderTile(
                          gender: Gender.male,
                          icon: Icons.male_rounded,
                          label: context.locale.male,
                          activeColor: context.colorScheme.primary,
                        ),
                        const SizedBox(width: 20),
                        _genderTile(
                          gender: Gender.female,
                          icon: Icons.female_rounded,
                          label: context.locale.female,
                          activeColor: context.colorScheme.tertiary,
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    AppButton(
                      text: context.locale.continueButton,
                      onTap: _submit,
                    ).addPadding(horizontal: 10),

                    const SizedBox(height: 40),
                  ],
                ).addPadding(horizontal: 20),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _genderTile({
    required Gender gender,
    required IconData icon,
    required String label,
    required Color activeColor,
  }) {
    final selected = _gender == gender;

    return GestureDetector(
      onTap: () => setState(() => _gender = gender),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: selected ? 115 : 110,
        height: selected ? 60 : 50,
        decoration: BoxDecoration(
          color: selected
              ? activeColor.withValues(alpha: 0.2)
              : context.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? activeColor.withValues(alpha: 0.8)
                : context.colorScheme.surfaceContainerHighest,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selected
                  ? activeColor
                  : context.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 10),
            AppText(
              label,
              style: context.textTheme.bodyMedium?.copyWith(
                color: selected
                    ? activeColor
                    : context.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

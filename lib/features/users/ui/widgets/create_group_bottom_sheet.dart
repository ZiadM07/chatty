import 'package:chatty/core/constants/exports.dart';
import 'package:chatty/core/framework/pick_file.dart';
import 'package:chatty/features/shared/widgets/app_file_image.dart';
import 'package:chatty/features/shared/widgets/app_gradient_button.dart';
import 'package:chatty/features/shared/widgets/app_image.dart';
import 'package:chatty/features/shared/widgets/app_text_form_field.dart';

class CreateGroupBottomSheet extends StatefulWidget {
  const CreateGroupBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateGroupBottomSheet(),
    );
  }

  @override
  State<CreateGroupBottomSheet> createState() => _CreateGroupBottomSheetState();
}

class _CreateGroupBottomSheetState extends State<CreateGroupBottomSheet> {
  File? _selectedImage;
  int step = 1;

  Future<void> _pickImage() async {
    final file = await PickFile.image();
    if (file != null) setState(() => _selectedImage = file);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Container(
                width: 60,
                height: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      context.colorScheme.primary,
                      context.colorScheme.secondary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            Expanded(
              child: step == 1
                  ? ListView(
                      children: [
                        SizedBox(height: 15),
                        AppText(
                          context.locale.createGroup,
                          style: context.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 5),
                        AppText(
                          context.locale.step1Of2,
                          style: context.textTheme.bodyMedium!.copyWith(
                            color: context.colorScheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 50),
                        Center(
                          child: Stack(
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
                        ),
                        const SizedBox(height: 40),
                        AppTextFormField(
                          label: context.locale.groupName,
                          hintText: context.locale.enterGroupName,
                          maxLength: 50,
                          autocorrect: false,
                          enableSuggestions: false,
                          textInputType: TextInputType.text,
                          validator: (v) => v == null || v.trim().isEmpty
                              ? context.locale.requiredField
                              : null,
                        ),
                        const SizedBox(height: 20),
                        AppTextFormField(
                          label:
                              '${context.locale.description} (${context.locale.optional})',
                          hintText: context.locale.groupDescriptionHint,
                          maxLength: 100,
                          maxLines: 2,
                          autocorrect: false,
                          enableSuggestions: false,
                        ),
                        const SizedBox(height: 50),

                        AppButton(
                          text: context.locale.nextAddMembers,
                          onTap: () => setState(() => step = 2),
                        ),
                      ],
                    ).addPadding(horizontal: 15)
                  : step == 2
                  ? ListView(
                      children: [
                        SizedBox(height: 15),
                        AppText(
                          context.locale.addMembers,
                          style: context.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        AppText(
                          context.locale.step2Of2,
                          style: context.textTheme.bodyMedium!.copyWith(
                            color: context.colorScheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 40),
                        Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: context.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            children: [
                              SizedBox(width: 10),
                              Icon(
                                SolarIconsOutline.magnifier,
                                color: context.colorScheme.textSecondary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: TextEditingController(),
                                  focusNode: FocusNode(),
                                  keyboardType: TextInputType.text,
                                  cursorColor: context.colorScheme.primary,
                                  style: context.textTheme.bodyMedium?.copyWith(
                                    color: context.colorScheme.textPrimary,
                                  ),
                                  decoration: InputDecoration(
                                    hintText:
                                        context.locale.searchByNameOrEmail,
                                    hintStyle: context.textTheme.bodyMedium
                                        ?.copyWith(
                                          color:
                                              context.colorScheme.textSecondary,
                                        ),
                                    border: InputBorder.none,
                                    isDense: true,
                                  ),
                                  onChanged: (value) {},
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        AnimatedOpacity(
                          opacity: 1,
                          duration: const Duration(milliseconds: 300),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                SolarIconsOutline.checkCircle,
                                color: context.colorScheme.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              AppText(
                                context.locale.membersSelected(10),
                                style: context.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 350,
                          child: ListView.builder(
                            itemCount: 10,
                            itemBuilder: (context, index) {
                              return Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 10,
                                ),
                                height: 65,
                                decoration: BoxDecoration(
                                  color: context
                                      .colorScheme
                                      .surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Row(
                                  children: [
                                    AppImage(
                                      imageUrl: AppConstants.fakeUserImage,
                                      width: 40,
                                      height: 40,
                                      borderRadius: 100,
                                    ),
                                    const SizedBox(width: 16),
                                    AppText(
                                      'User Name',
                                      style: context.textTheme.bodyMedium
                                          ?.copyWith(
                                            color:
                                                context.colorScheme.textPrimary,
                                          ),
                                    ),
                                    const Spacer(),
                                    Icon(
                                      Icons.check_circle,
                                      color: context.colorScheme.primary,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ).addPadding(horizontal: 15, vertical: 10);
                            },
                          ),
                        ),
                        const SizedBox(height: 20),

                        Row(
                          children: [
                            Expanded(
                              child: AppButton(
                                type: AppGradientButtonType.normal,
                                text: context.locale.back,
                                onTap: () => setState(() => step = 1),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: AppButton(
                                type: AppGradientButtonType.gradient,
                                text: context.locale.create,
                                onTap: () {},
                              ),
                            ),
                          ],
                        ),
                      ],
                    ).addPadding(horizontal: 15)
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:chatty/config/router/app_router.gr.dart';
import 'package:chatty/core/constants/exports.dart';
import 'package:chatty/core/framework/pick_file.dart';
import 'package:chatty/features/auth/cubits/auth_cubit.dart';
import 'package:chatty/features/auth/data/models/user_model.dart';
import 'package:chatty/features/chats/cubits/conversations_cubit.dart';
import 'package:chatty/features/shared/widgets/app_file_image.dart';
import 'package:chatty/features/shared/widgets/app_gradient_button.dart';
import 'package:chatty/features/shared/widgets/app_image.dart';
import 'package:chatty/features/shared/widgets/app_text_form_field.dart';
import 'package:chatty/features/shared/widgets/app_toast.dart';
import 'package:chatty/features/users/cubits/users_cubit.dart';
import 'package:chatty/features/users/cubits/users_state.dart';

class CreateGroupBottomSheet extends StatefulWidget {
  const CreateGroupBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreateGroupBottomSheet(),
    );
  }

  @override
  State<CreateGroupBottomSheet> createState() => _CreateGroupBottomSheetState();
}

class _CreateGroupBottomSheetState extends State<CreateGroupBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _searchController = TextEditingController();

  File? _selectedImage;
  int _step = 1;
  final Set<String> _selectedMemberIds = {};
  List<UserModel> _filteredUsers = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);

    // Load users when bottom sheet opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentUid = context.read<AuthCubit>().state.currentUser?.uid ?? '';
      context.read<UsersCubit>().loadUsers(currentUid: currentUid);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    final allUsers = context.read<UsersCubit>().state.users;
    final currentUid = context.read<AuthCubit>().state.currentUser?.uid ?? '';

    setState(() {
      _filteredUsers = allUsers.where((user) {
        if (user.uid == currentUid) return false; // Exclude current user
        if (query.isEmpty) return true;
        return user.displayName.toLowerCase().contains(query) ||
            (user.email.toLowerCase().contains(query));
      }).toList();
    });
  }

  Future<void> _pickImage() async {
    final file = await PickFile.image();
    if (file != null) setState(() => _selectedImage = file);
  }

  void _toggleMember(String uid) {
    setState(() {
      if (_selectedMemberIds.contains(uid)) {
        _selectedMemberIds.remove(uid);
      } else {
        _selectedMemberIds.add(uid);
      }
    });
  }

  Future<void> _createGroup() async {
    if (_selectedMemberIds.isEmpty) {
      AppToast.showError(
        message: context.locale.selectAtLeastOneMember,
        context: context,
      );
      return;
    }

    final currentUid = context.read<AuthCubit>().state.currentUser?.uid;
    if (currentUid == null) return;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await context.read<ConversationsCubit>().createGroupChat(
        groupName: _nameController.text.trim(),
        memberIds: _selectedMemberIds.toList(),
        groupPhotoFile: _selectedImage,
        createdBy: currentUid,
      );

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // Close bottom sheet
      if (mounted) Navigator.pop(context);

      // Show success message
      if (mounted) {
        AppToast.showSuccess(
          message: context.locale.groupCreated,
          context: context,
        );
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // Show error
      if (mounted) {
        AppToast.showError(message: e.toString(), context: context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConversationsCubit, ConversationsState>(
      listenWhen: (prev, curr) => prev.openChatState != curr.openChatState,
      listener: (context, state) async {
        final openState = state.openChatState;

        if (openState.isLoading) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(child: CircularProgressIndicator()),
          );
          return;
        }

        if (!mounted) return;

        if (openState.isSuccess) {
          // Close loading dialog safely
          if (Navigator.of(context, rootNavigator: true).canPop()) {
            Navigator.of(context, rootNavigator: true).pop();
          }

          // Close bottom sheet safely
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }

          final chatId = openState.data;

          if (chatId != null) {
            context.router.push(ChatRoute(chatId: chatId));
          }

          context.read<ConversationsCubit>().resetOpenChatState();
          return;
        }

        if (openState.isError) {
          if (Navigator.of(context, rootNavigator: true).canPop()) {
            Navigator.of(context, rootNavigator: true).pop();
          }

          AppToast.showError(
            message: openState.message ?? 'Failed to create group',
            context: context,
          );

          context.read<ConversationsCubit>().resetOpenChatState();
        }
      },

      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              // Drag handle
              Container(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
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

              Expanded(child: _step == 1 ? _buildStep1() : _buildStep2()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return Form(
      key: _formKey,
      child: ListView(
        children: [
          const SizedBox(height: 15),
          AppText(
            context.locale.createGroup,
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          AppText(
            context.locale.step1Of2,
            style: context.textTheme.bodyMedium!.copyWith(
              color: context.colorScheme.textSecondary,
            ),
          ),
          const SizedBox(height: 50),

          // Group photo picker
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

          // Group name
          AppTextFormField(
            controller: _nameController,
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

          // Description (optional)
          AppTextFormField(
            controller: _descriptionController,
            label: '${context.locale.description} (${context.locale.optional})',
            hintText: context.locale.groupDescriptionHint,
            maxLength: 100,
            maxLines: 2,
            autocorrect: false,
            enableSuggestions: false,
          ),
          const SizedBox(height: 50),

          // Next button
          AppButton(
            text: context.locale.nextAddMembers,
            onTap: () {
              if (_formKey.currentState?.validate() ?? false) {
                setState(() => _step = 2);
                _onSearchChanged(); // Initialize filtered users
              }
            },
          ),
        ],
      ).addPadding(horizontal: 15),
    );
  }

  Widget _buildStep2() {
    return BlocBuilder<UsersCubit, UsersState>(
      buildWhen: (prev, curr) => prev.usersState != curr.usersState,
      builder: (context, state) {
        if (_filteredUsers.isEmpty && _searchController.text.isEmpty) {
          _filteredUsers = state.users
              .where(
                (u) =>
                    u.uid != context.read<AuthCubit>().state.currentUser?.uid,
              )
              .toList();
        }

        return ListView(
          children: [
            const SizedBox(height: 15),
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

            // Search bar
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: context.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  Icon(
                    SolarIconsOutline.magnifier,
                    color: context.colorScheme.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      keyboardType: TextInputType.text,
                      cursorColor: context.colorScheme.primary,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: context.locale.searchByNameOrEmail,
                        hintStyle: context.textTheme.bodyMedium?.copyWith(
                          color: context.colorScheme.textSecondary,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Selected count
            AnimatedOpacity(
              opacity: _selectedMemberIds.isNotEmpty ? 1.0 : 0.0,
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
                    context.locale.membersSelected(_selectedMemberIds.length),
                    style: context.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Users list
            if (state.usersState.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_filteredUsers.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: AppText(
                    _searchController.text.isEmpty
                        ? context.locale.noUsersFound
                        : context.locale.noResultsFound,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.textSecondary,
                    ),
                  ),
                ),
              )
            else
              SizedBox(
                height: 350,
                child: ListView.builder(
                  itemCount: _filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = _filteredUsers[index];
                    final isSelected = _selectedMemberIds.contains(user.uid);

                    return GestureDetector(
                      onTap: () => _toggleMember(user.uid),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 10,
                        ),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 5,
                        ),
                        height: 65,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? context.colorScheme.primaryContainer.withValues(
                                  alpha: 0.3,
                                )
                              : context.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(18),
                          border: isSelected
                              ? Border.all(
                                  color: context.colorScheme.primary,
                                  width: 2,
                                )
                              : null,
                        ),
                        child: Row(
                          children: [
                            AppImage(
                              imageUrl:
                                  user.photoUrl ?? AppConstants.fakeUserImage,
                              width: 40,
                              height: 40,
                              borderRadius: 100,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AppText(
                                    user.displayName,
                                    style: context.textTheme.bodyMedium
                                        ?.copyWith(
                                          color:
                                              context.colorScheme.textPrimary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  AppText(
                                    user.email,
                                    style: context.textTheme.bodySmall
                                        ?.copyWith(
                                          color:
                                              context.colorScheme.textSecondary,
                                        ),
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              isSelected
                                  ? Icons.check_circle
                                  : Icons.circle_outlined,
                              color: isSelected
                                  ? context.colorScheme.primary
                                  : context.colorScheme.outline,
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 20),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    type: AppGradientButtonType.normal,
                    text: context.locale.back,
                    onTap: () => setState(() => _step = 1),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AppButton(
                    type: AppGradientButtonType.gradient,
                    text: context.locale.create,
                    onTap: _createGroup,
                  ),
                ),
              ],
            ),
          ],
        ).addPadding(horizontal: 15);
      },
    );
  }
}

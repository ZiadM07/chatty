import 'package:Chatty/config/router/app_router.gr.dart';
import 'package:Chatty/core/constants/exports.dart';
import 'package:Chatty/core/framework/pick_file.dart';
import 'package:Chatty/features/auth/cubits/auth_cubit.dart';
import 'package:Chatty/features/auth/data/models/user_model.dart';
import 'package:Chatty/features/chats/cubits/conversations_cubit.dart';
import 'package:Chatty/features/shared/widgets/app_file_image.dart';
import 'package:Chatty/features/shared/widgets/app_gradient_button.dart';
import 'package:Chatty/features/shared/widgets/app_image.dart';
import 'package:Chatty/features/shared/widgets/app_text_form_field.dart';
import 'package:Chatty/features/shared/widgets/app_toast.dart';
import 'package:Chatty/features/users/cubits/users_cubit.dart';

import '../../../shared/widgets/profile_placeholder.dart';

class CreateGroupBottomSheet extends StatefulWidget {
  final UserModel? preSelectedUser;

  const CreateGroupBottomSheet({super.key, this.preSelectedUser});

  static void show(BuildContext context, {UserModel? preSelectedUser}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          CreateGroupBottomSheet(preSelectedUser: preSelectedUser),
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
  final Set<String> _selectedIds = {};
  List<UserModel> _allUsers = [];
  List<UserModel> _filtered = [];
  bool _loadingUsers = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearch);

    if (widget.preSelectedUser != null) {
      _selectedIds.add(widget.preSelectedUser!.uid);
      _allUsers = [widget.preSelectedUser!];
      _filtered = [widget.preSelectedUser!];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsersIfNeeded() async {
    if (_loadingUsers) return;
    setState(() => _loadingUsers = true);

    final currentUid = context.read<AuthCubit>().state.currentUser?.uid ?? '';
    await context.read<UsersCubit>().loadUsers(currentUid: currentUid);
    if (!mounted) return;

    final users = context
        .read<UsersCubit>()
        .state
        .users
        .where((u) => u.uid != currentUid)
        .toList();

    if (!mounted) return;
    setState(() {
      _allUsers = users;
      _filtered = users;
      _loadingUsers = false;
    });
  }

  void _onSearch() {
    final q = _searchController.text.trim().toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? _allUsers
          : _allUsers.where((u) {
              return u.displayName.toLowerCase().contains(q) ||
                  u.username.toLowerCase().contains(q);
            }).toList();
    });
  }

  Future<void> _pickImage() async {
    final file = await PickFile.image();
    if (file != null) setState(() => _selectedImage = file);
  }

  void _toggle(String uid) {
    setState(() {
      _selectedIds.contains(uid)
          ? _selectedIds.remove(uid)
          : _selectedIds.add(uid);
    });
  }

  Future<void> _createGroup() async {
    if (_selectedIds.isEmpty) {
      AppToast.showError(
        message: context.locale.selectAtLeastOneMember,
        context: context,
      );
      return;
    }

    final currentUser = context.read<AuthCubit>().state.currentUser;
    if (currentUser == null) return;

    final memberNames = <String, String>{
      currentUser.uid: currentUser.name,
      for (final u in _allUsers.where((u) => _selectedIds.contains(u.uid)))
        u.uid: u.displayName,
    };

    try {
      await context.read<ConversationsCubit>().createGroupChat(
        groupName: _nameController.text.trim(),
        memberIds: _selectedIds.toList(),
        memberNames: memberNames,
        groupPhotoFile: _selectedImage,
        createdBy: currentUser.uid,
        groupDescription: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
      );
    } catch (e) {
      if (mounted) AppToast.showError(message: e.toString(), context: context);
    }
  }

  void _goToStep2() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _step = 2);
      _loadUsersIfNeeded();
    }
  }

  void _goToStep1() => setState(() => _step = 1);

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
          if (Navigator.of(context, rootNavigator: true).canPop()) {
            Navigator.of(context, rootNavigator: true).pop();
          }
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
          final chatId = openState.data;
          if (chatId != null) context.router.push(ChatRoute(chatId: chatId));
          context.read<ConversationsCubit>().resetOpenChatState();
          return;
        }

        if (openState.isError) {
          if (Navigator.of(context, rootNavigator: true).canPop()) {
            Navigator.of(context, rootNavigator: true).pop();
          }
          AppToast.showError(
            message: context.locale.thisOperationFailed,
            context: context,
          );
          context.read<ConversationsCubit>().resetOpenChatState();
        }
      },
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.colorScheme.outline.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _step == 1
                    ? _GroupInfoStep(
                        formKey: _formKey,
                        nameController: _nameController,
                        descriptionController: _descriptionController,
                        selectedImage: _selectedImage,
                        onPickImage: _pickImage,
                        onNext: _goToStep2,
                      )
                    : _SelectMembersStep(
                        searchController: _searchController,
                        allUsers: _allUsers,
                        filtered: _filtered,
                        selectedIds: _selectedIds,
                        loadingUsers: _loadingUsers,
                        onToggle: _toggle,
                        onCreate: _createGroup,
                        onBack: _goToStep1,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupInfoStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final File? selectedImage;
  final VoidCallback onPickImage;
  final VoidCallback onNext;

  const _GroupInfoStep({
    required this.formKey,
    required this.nameController,
    required this.descriptionController,
    required this.selectedImage,
    required this.onPickImage,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          AppText(
            context.locale.createGroup,
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          AppText(
            context.locale.step1Of2,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.textSecondary,
            ),
          ),
          const SizedBox(height: 32),

          Center(
            child: Stack(
              children: [
                selectedImage != null
                    ? AppFileImage(
                        selectedImage!,
                        width: 110,
                        height: 110,
                        fit: BoxFit.cover,
                        borderRadius: 100,
                      )
                    : ProfilePlaceholder(name: context.locale.group, size: 110),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: onPickImage,
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            context.colorScheme.primary,
                            context.colorScheme.secondary,
                          ],
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: context.colorScheme.surface,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        SolarIconsOutline.cameraAdd,
                        size: 16,
                        color: context.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          AppTextFormField(
            controller: nameController,
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
          const SizedBox(height: 16),

          AppTextFormField(
            controller: descriptionController,
            label: '${context.locale.description} (${context.locale.optional})',
            hintText: context.locale.groupDescriptionHint,
            maxLength: 100,
            maxLines: 2,
            autocorrect: false,
            enableSuggestions: false,
          ),
          const SizedBox(height: 32),

          AppButton(text: context.locale.nextAddMembers, onTap: onNext),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _SelectMembersStep extends StatelessWidget {
  final TextEditingController searchController;
  final List<UserModel> allUsers;
  final List<UserModel> filtered;
  final Set<String> selectedIds;
  final bool loadingUsers;
  final void Function(String uid) onToggle;
  final VoidCallback onCreate;
  final VoidCallback onBack;

  const _SelectMembersStep({
    required this.searchController,
    required this.allUsers,
    required this.filtered,
    required this.selectedIds,
    required this.loadingUsers,
    required this.onToggle,
    required this.onCreate,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      context.locale.addMembers,
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    AppText(
                      context.locale.step2Of2,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (selectedIds.isNotEmpty)
                GestureDetector(
                  onTap: onCreate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          context.colorScheme.primary,
                          context.colorScheme.secondary,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: AppText(
                      context.locale.createCount(selectedIds.length),
                      style: context.textTheme.labelLarge?.copyWith(
                        color: context.colorScheme.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: context.colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Icon(
                  SolarIconsOutline.magnifier,
                  size: 18,
                  color: context.colorScheme.textSecondary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: searchController,
                    style: context.textTheme.bodyLarge,
                    decoration: InputDecoration(
                      hintText: context.locale.searchUsers,
                      hintStyle: context.textTheme.bodyLarge?.copyWith(
                        color: context.colorScheme.textSecondary,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        if (selectedIds.isNotEmpty) ...[
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: allUsers
                  .where((u) => selectedIds.contains(u.uid))
                  .map(
                    (u) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _SelectedChip(
                        user: u,
                        onRemove: () => onToggle(u.uid),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 8),
        ],

        Expanded(
          child: loadingUsers
              ? const Center(child: CircularProgressIndicator())
              : filtered.isEmpty
              ? Center(
                  child: AppText(
                    searchController.text.isEmpty
                        ? context.locale.noUsersFound
                        : context.locale.noResultsFound,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.textSecondary,
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                  itemCount: filtered.length,
                  separatorBuilder: (_, i) => Divider(
                    height: 1,
                    color: context.colorScheme.outline.withValues(alpha: 0.08),
                  ),
                  itemBuilder: (_, i) {
                    final user = filtered[i];
                    return _UserSelectTile(
                      user: user,
                      selected: selectedIds.contains(user.uid),
                      onTap: () => onToggle(user.uid),
                    );
                  },
                ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: AppButton(
            type: AppButtonType.normal,
            text: context.locale.back,
            onTap: onBack,
          ),
        ),
      ],
    );
  }
}

class _SelectedChip extends StatelessWidget {
  final UserModel user;
  final VoidCallback onRemove;

  const _SelectedChip({required this.user, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: context.colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (user.photoUrl != null)
            AppImage(
              imageUrl: user.photoUrl!,
              width: 22,
              height: 22,
              borderRadius: 100,
            )
          else
            ProfilePlaceholder(name: user.displayName, size: 22),
          const SizedBox(width: 6),
          AppText(
            user.displayName,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              Icons.close_rounded,
              size: 14,
              color: context.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _UserSelectTile extends StatelessWidget {
  final UserModel user;
  final bool selected;
  final VoidCallback onTap;

  const _UserSelectTile({
    required this.user,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            if (user.photoUrl != null)
              AppImage(
                imageUrl: user.photoUrl!,
                width: 46,
                height: 46,
                borderRadius: 100,
              )
            else
              ProfilePlaceholder(name: user.displayName, size: 46),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    user.displayName,
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  AppText(
                    '@${user.username}',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: selected
                    ? LinearGradient(
                        colors: [
                          context.colorScheme.primary,
                          context.colorScheme.secondary,
                        ],
                      )
                    : null,
                border: selected
                    ? null
                    : Border.all(
                        color: context.colorScheme.outline.withValues(
                          alpha: 0.4,
                        ),
                        width: 2,
                      ),
              ),
              child: selected
                  ? const Icon(
                      Icons.check_rounded,
                      size: 15,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

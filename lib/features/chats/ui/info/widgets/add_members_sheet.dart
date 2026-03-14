import 'package:Chatty/core/constants/exports.dart';
import 'package:Chatty/core/di/injectable.dart';
import 'package:Chatty/features/auth/data/models/user_model.dart';
import 'package:Chatty/features/shared/widgets/app_image.dart';
import 'package:Chatty/features/users/data/repositories/users_repository.dart';

import '../../../../shared/widgets/profile_placeholder.dart';

class AddMembersSheet extends StatefulWidget {
  final String chatId;
  final String currentUid;
  final List<String> existingMemberIds;
  final Future<void> Function(List<String> newIds, Map<String, String> newNames)
  onAddMembers;

  const AddMembersSheet({
    super.key,
    required this.chatId,
    required this.currentUid,
    required this.existingMemberIds,
    required this.onAddMembers,
  });

  @override
  State<AddMembersSheet> createState() => _AddMembersSheetState();
}

class _AddMembersSheetState extends State<AddMembersSheet> {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();

  List<UserModel> _allUsers = [];
  List<UserModel> _filtered = [];
  final Set<String> _selectedIds = {};
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _searchController.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    final users = await getIt<UsersRepository>().getUsers(
      currentUid: widget.currentUid,
      limit: 100,
    );
    if (!mounted) return;
    // Exclude anyone already in the group
    final available = users
        .where((u) => !widget.existingMemberIds.contains(u.uid))
        .toList();
    setState(() {
      _allUsers = available;
      _filtered = available;
      _loading = false;
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

  void _toggle(String uid) {
    setState(() {
      _selectedIds.contains(uid)
          ? _selectedIds.remove(uid)
          : _selectedIds.add(uid);
    });
  }

  Future<void> _confirm() async {
    if (_selectedIds.isEmpty) return;
    setState(() => _saving = true);

    final selected = _allUsers.where((u) => _selectedIds.contains(u.uid));
    final names = {for (final u in selected) u.uid: u.displayName};

    await widget.onAddMembers(_selectedIds.toList(), names);

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final sheetHeight = MediaQuery.of(context).size.height * 0.85;

    return Container(
      height: sheetHeight,
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: AppText(
                    context.locale.addMembers,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                if (_selectedIds.isNotEmpty)
                  _saving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : GestureDetector(
                          onTap: _confirm,
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
                              context.locale.addCount(_selectedIds.length),
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
                      controller: _searchController,
                      focusNode: _searchFocus,
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

          if (_selectedIds.isNotEmpty)
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: _allUsers
                    .where((u) => _selectedIds.contains(u.uid))
                    .map(
                      (u) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _SelectedChip(
                          user: u,
                          onRemove: () => _toggle(u.uid),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),

          if (_selectedIds.isNotEmpty) const SizedBox(height: 8),

          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                ? Center(
                    child: AppText(
                      context.locale.noUsersFound,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.textSecondary,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                    itemCount: _filtered.length,
                    separatorBuilder: (_, i) => Divider(
                      height: 1,
                      color: context.colorScheme.outline.withValues(
                        alpha: 0.08,
                      ),
                    ),
                    itemBuilder: (_, i) {
                      final user = _filtered[i];
                      final selected = _selectedIds.contains(user.uid);
                      return _UserSelectTile(
                        user: user,
                        selected: selected,
                        onTap: () => _toggle(user.uid),
                      );
                    },
                  ),
          ),
        ],
      ),
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
          user.photoUrl != null
              ? AppImage(
                  imageUrl: user.photoUrl!,
                  width: 22,
                  height: 22,
                  borderRadius: 100,
                )
              : ProfilePlaceholder(name: user.displayName, size: 22),
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
            user.photoUrl != null
                ? AppImage(
                    imageUrl: user.photoUrl!,
                    width: 46,
                    height: 46,
                    borderRadius: 100,
                  )
                : ProfilePlaceholder(name: user.displayName, size: 46),
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

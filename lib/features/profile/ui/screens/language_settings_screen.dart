import 'package:chatty/core/constants/exports.dart';

import '../../../shared/cubits/app_cubit.dart';

@RoutePage()
class LanguageSettingsScreen extends StatelessWidget {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appCubit = context.watch<AppCubit>();

    final selectedLanguage = appCubit.locale.languageCode;

    final languages = [
      LanguageItem(
        name: context.locale.english,
        nativeName: "English",
        code: "en",
        icon: "🇺🇸",
      ),
      LanguageItem(
        name: context.locale.arabic,
        nativeName: "العربية",
        code: "ar",
        icon: "🇸🇦",
      ),
    ];

    return AppScaffold(
      showBackButton: true,
      title: context.locale.languageSettings,
      body: Column(
        children: [
          const SizedBox(height: 30),
          Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    context.colorScheme.primary,
                    context.colorScheme.secondary,
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: context.colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                Icons.language,
                color: context.colorScheme.onPrimary,
                size: 48,
              ),
            ),
          ),
          const SizedBox(height: 30),

          AppText(
            context.locale.selectYourLanguage,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.colorScheme.secondaryContainer.withValues(
                alpha: 0.15,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: context.colorScheme.secondaryContainer.withValues(
                  alpha: 0.25,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: context.colorScheme.secondary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppText(
                    context.locale.languageAppliesInstantly,
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: context.colorScheme.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ).addPadding(horizontal: 20),
          const SizedBox(height: 50),
          SizedBox(
            height: 300,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              separatorBuilder: (context, index) => const SizedBox(height: 25),
              itemCount: languages.length,
              itemBuilder: (context, index) {
                final lang = languages[index];
                final isSelected = lang.code == selectedLanguage;

                return LanguageItemWidget(
                  lang: lang,
                  isSelected: isSelected,
                  onTap: () => appCubit.changeLang(lang.code),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class LanguageItemWidget extends StatelessWidget {
  final LanguageItem lang;
  final bool isSelected;
  final VoidCallback onTap;

  const LanguageItemWidget({
    super.key,
    required this.lang,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected
              ? context.colorScheme.primary
              : context.colorScheme.outlineVariant.withValues(alpha: 0.25),
          width: isSelected ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? context.colorScheme.primary.withValues(alpha: 0.25)
                : context.colorScheme.outlineVariant.withValues(alpha: 0.25),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          /* ── Flag ── */
          Text(lang.icon, style: const TextStyle(fontSize: 28)),

          const SizedBox(width: 16),

          /* ── Name + Native ── */
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  lang.name,
                  style: context.textTheme.titleSmall?.copyWith(
                    color: context.colorScheme.onSurface,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
                AppText(
                  lang.nativeName,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          /* ── Selected indicator ── */
          if (isSelected)
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    context.colorScheme.primary,
                    context.colorScheme.secondary,
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_rounded,
                size: 14,
                color: context.colorScheme.onPrimary,
              ),
            ),
        ],
      ),
    ).addAction(onTap: onTap);
  }
}

class LanguageItem {
  final String name;
  final String nativeName;
  final String code;
  final String icon;

  LanguageItem({
    required this.name,
    required this.nativeName,
    required this.code,
    required this.icon,
  });
}

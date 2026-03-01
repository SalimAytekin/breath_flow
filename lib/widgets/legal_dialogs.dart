import 'package:flutter/material.dart';
import 'package:breathe_flow/constants/app_colors.dart';
import 'package:breathe_flow/constants/app_spacing.dart';
import 'package:breathe_flow/constants/app_strings.dart';
import 'package:breathe_flow/constants/app_typography.dart';

Future<void> showPrivacyPolicyDialog(BuildContext context) {
  final sections = <_LegalSection>[
    _LegalSection(AppStrings.privacyDataCollectionTitle, AppStrings.privacyDataCollectionDesc),
    _LegalSection(AppStrings.privacyUsageTitle, AppStrings.privacyUsageDesc),
    _LegalSection(AppStrings.privacyStorageTitle, AppStrings.privacyStorageDesc),
    _LegalSection(AppStrings.privacyThirdPartyTitle, AppStrings.privacyThirdPartyDesc),
    _LegalSection(AppStrings.privacyHealthTitle, AppStrings.privacyHealthDesc),
    _LegalSection(AppStrings.privacyDeletionTitle, AppStrings.privacyDeletionDesc),
    _LegalSection(AppStrings.privacyRightsTitle, AppStrings.privacyRightsDesc),
    _LegalSection(AppStrings.privacyChildrenTitle, AppStrings.privacyChildrenDesc),
    _LegalSection(AppStrings.privacyChangesTitle, AppStrings.privacyChangesDesc),
    _LegalSection(AppStrings.privacySummaryTitle, AppStrings.privacySummaryDesc),
  ];

  return _showLegalDialog(
    context,
    title: AppStrings.privacyPolicy,
    subtitle: AppStrings.privacyPolicySubtitle,
    lastUpdated: AppStrings.privacyLastUpdated,
    contactInfo: AppStrings.privacyContactInfo,
    sections: sections,
  );
}

Future<void> showTermsOfUseDialog(BuildContext context) {
  final sections = <_LegalSection>[
    _LegalSection(AppStrings.termsServiceTitle, AppStrings.termsServiceDesc),
    _LegalSection(AppStrings.termsAccountsTitle, AppStrings.termsAccountsDesc),
    _LegalSection(AppStrings.termsPremiumTitle, AppStrings.termsPremiumDesc),
    _LegalSection(AppStrings.termsContentTitle, AppStrings.termsContentDesc),
    _LegalSection(AppStrings.termsResponsibilitiesTitle, AppStrings.termsResponsibilitiesDesc),
    _LegalSection(AppStrings.termsHealthTitle, AppStrings.termsHealthDesc),
    _LegalSection(AppStrings.termsChangesTitle, AppStrings.termsChangesDesc),
    _LegalSection(AppStrings.termsTerminationTitle, AppStrings.termsTerminationDesc),
  ];

  return _showLegalDialog(
    context,
    title: AppStrings.termsOfService,
    subtitle: AppStrings.termsOfServiceSubtitle,
    lastUpdated: AppStrings.termsLastUpdated,
    contactInfo: AppStrings.termsContactInfo,
    sections: sections,
  );
}

Future<void> _showLegalDialog(
  BuildContext context, {
  required String title,
  required String subtitle,
  required String lastUpdated,
  required String contactInfo,
  required List<_LegalSection> sections,
}) {
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xsmall),
          Text(
            subtitle,
            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.small),
          Text(
            lastUpdated,
            style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary),
          ),
          Text(
            contactInfo,
            style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: sections
              .map(
                (section) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.large),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        section.title,
                        style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: AppSpacing.small),
                      Text(
                        section.description,
                        style: AppTypography.bodyMedium,
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryAccent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
            ),
          ),
          child: Text(AppStrings.ok),
        ),
      ],
    ),
  );
}

class _LegalSection {
  final String title;
  final String description;

  const _LegalSection(this.title, this.description);
}

import 'package:confindant/app/theme/app_spacing.dart';
import 'package:confindant/features/profile/presentation/view_models/profile_settings_view_model.dart';
import 'package:confindant/features/profile/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpCenterPage extends ConsumerWidget {
  const HelpCenterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileSettingsProvider);
    final vm = ref.read(profileSettingsProvider.notifier);

    return ProfileDetailScaffold(
      title: 'Help Center',
      subtitle: 'Find answers and support',
      child: Column(
        children: [
          ProfileSettingsCard(
            title: 'FAQ',
            child: Column(
              children: [
                for (var i = 0; i < state.faqItems.length; i++) ...[
                  FaqExpandableCard(
                    question: state.faqItems[i].question,
                    answer: state.faqItems[i].answer,
                    expanded: state.faqItems[i].expanded,
                    onTap: () => vm.toggleFaqExpanded(i),
                  ),
                  if (i != state.faqItems.length - 1)
                    const SizedBox(height: AppSpacing.sm),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ProfileSettingsCard(
            title: 'Contact Support',
            child: Column(
              children: [
                SettingsActionTile(
                  label: 'Email Support',
                  subtitle: 'tokichimikuni51@gmail.com',
                  icon: Icons.mail_outline_rounded,
                  onTap: () => _launchEmail(context),
                ),
                const Divider(height: 1),
                SettingsActionTile(
                  label: 'WhatsApp Support',
                  subtitle: '+62 813 8009 1046',
                  icon: Icons.chat_bubble_outline_rounded,
                  onTap: () => _launchWhatsApp(context),
                ),
                const Divider(height: 1),
                SettingsActionTile(
                  label: 'Report a Problem',
                  subtitle: 'Send bug report and screenshots',
                  icon: Icons.bug_report_outlined,
                  onTap: () => _launchEmail(context, subject: 'Bug Report - Confindant'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchEmail(BuildContext context, {String subject = 'Support Request - Confindant'}) async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'tokichimikuni51@gmail.com',
      queryParameters: {'subject': subject},
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak bisa membuka aplikasi email. Hubungi: tokichimikuni51@gmail.com')),
      );
    }
  }

  Future<void> _launchWhatsApp(BuildContext context) async {
    const phone = '6281380091046';
    const message = 'Halo, saya butuh bantuan dengan aplikasi Confindant.';
    final uri = Uri.parse('https://wa.me/$phone?text=${Uri.encodeComponent(message)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak bisa membuka WhatsApp. Hubungi: 081380091046')),
      );
    }
  }
}

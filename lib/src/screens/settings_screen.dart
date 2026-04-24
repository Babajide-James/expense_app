import 'package:flutter/material.dart';

import '../state/app_scope.dart';
import '../widgets/common_widgets.dart';
import 'biometric_intro_screen.dart';
import 'change_password_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.onNavigateToAllocation,
    required this.onNavigateToTransport,
  });

  final VoidCallback onNavigateToAllocation;
  final VoidCallback onNavigateToTransport;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);

    return PagePadding(
      child: ListView(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 12,
                backgroundColor: Color(0xFF0F172A),
                child: Icon(Icons.person, size: 14, color: Colors.white),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Sovereign Ledger',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1148A5),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_none_rounded),
              ),
            ],
          ),
          const SizedBox(height: 18),
          WhiteCard(
            child: Row(
              children: [
                Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8EEF8),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(Icons.person, color: Color(0xFF1148A5)),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Alexander Sterling',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 4),
                      StatusPill(
                        label: 'PRO MEMBER',
                        backgroundColor: Color(0xFFDDF8EB),
                        textColor: Color(0xFF12805C),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: WhiteCard(
                  onTap: onNavigateToAllocation,
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.account_balance_wallet_outlined,
                          color: Color(0xFF1148A5)),
                      SizedBox(height: 18),
                      Text(
                        'Default Ledger',
                        style: TextStyle(fontSize: 12, color: Color(0xFF667085)),
                      ),
                      Text(
                        'Main Savings',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: onNavigateToTransport,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1148A5),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.auto_awesome_outlined, color: Colors.white),
                        SizedBox(height: 18),
                        Text(
                          'Upgrade to Sovereign',
                          style: TextStyle(fontSize: 12, color: Color(0xFFD8E4FF)),
                        ),
                        Text(
                          'Executive',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const SectionLabel('SECURITY & ACCESS'),
          const SizedBox(height: 10),
          SettingsRow(
            title: 'Biometrics',
            subtitle: app.biometricVerified
                ? 'Facial verification enabled'
                : 'Set up facial recognition',
            leadingIcon: Icons.fingerprint,
            trailing: app.biometricVerified
                ? const Icon(Icons.verified_rounded, color: Color(0xFF12B76A))
                : const Icon(Icons.chevron_right_rounded),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const BiometricIntroScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          SettingsRow(
            title: 'User Password',
            subtitle: 'Last updated 5 days ago',
            leadingIcon: Icons.key_outlined,
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const ChangePasswordScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          const SectionLabel('PREFERENCES'),
          const SizedBox(height: 10),
          const SettingsRow(
            title: 'Currency',
            subtitle: 'USD (\$)',
            leadingIcon: Icons.attach_money_rounded,
            trailing: Icon(Icons.chevron_right_rounded),
          ),
          const SizedBox(height: 10),
          const SettingsRow(
            title: 'Language',
            subtitle: 'English (US)',
            leadingIcon: Icons.language,
            trailing: Icon(Icons.chevron_right_rounded),
          ),
          const SizedBox(height: 10),
          const SettingsRow(
            title: 'Help Center',
            subtitle: 'FAQs and direct support',
            leadingIcon: Icons.help_outline_rounded,
            trailing: Icon(Icons.chevron_right_rounded),
          ),
          const SizedBox(height: 18),
          FilledButton.tonal(
            onPressed: () {},
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFEE4E2),
              foregroundColor: const Color(0xFFD92D20),
              minimumSize: const Size.fromHeight(54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: const Text(
              'Sign Out',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 14),
          const Center(
            child: Text(
              'SOVEREIGN LEDGER V2.4.0',
              style: TextStyle(
                color: Color(0xFF98A2B3),
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.leadingIcon,
    required this.trailing,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData leadingIcon;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return WhiteCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFF4F7FB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(leadingIcon, color: const Color(0xFF1148A5), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF667085),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

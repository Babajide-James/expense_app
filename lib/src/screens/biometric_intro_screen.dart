import 'package:flutter/material.dart';

import '../widgets/common_widgets.dart';
import 'biometric_liveness_screen.dart';

class BiometricIntroScreen extends StatelessWidget {
  const BiometricIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PagePadding(
        child: Column(
          children: [
            const BackHeader(title: 'Identity Verification'),
            const Spacer(),
            const CircleAvatar(
              radius: 24,
              backgroundColor: Color(0xFFDCE7FF),
              child: Icon(
                Icons.verified_user_outlined,
                color: Color(0xFF1148A5),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Identity Verification',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F254B),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'We need to perform a quick liveness check before enabling biometrics on this device.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF667085),
                height: 1.45,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.info_outline, size: 16, color: Color(0xFF1148A5)),
                  SizedBox(width: 8),
                  Text(
                    'Center your face in the frame',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              height: 184,
              width: 184,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFCFE0FF),
                border: Border.all(color: const Color(0xFF2962E8), width: 5),
              ),
              child: const Icon(
                Icons.videocam_outlined,
                size: 54,
                color: Color(0xFF91ABD9),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock_outline, size: 14),
                  SizedBox(width: 6),
                  Text(
                    'End-to-end encrypted',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const Spacer(),
            ActionBottomBar(
              children: [
                PrimaryButton(
                  label: 'Start Verification',
                  trailing: Icons.arrow_forward_rounded,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const BiometricLivenessScreen(),
                      ),
                    );
                  },
                ),
                SecondaryButton(
                  label: 'Cancel',
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../widgets/common_widgets.dart';

class VerificationSuccessScreen extends StatelessWidget {
  const VerificationSuccessScreen({
    super.key,
    required this.title,
    required this.message,
    required this.buttonLabel,
  });

  final String title;
  final String message;
  final String buttonLabel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PagePadding(
        child: Column(
          children: [
            const Spacer(),
            WhiteCard(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Color(0xFFDCE7FF),
                    child: Icon(
                      Icons.check_rounded,
                      color: Color(0xFF0F254B),
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F254B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF667085),
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const SizedBox(
                    width: 120,
                    child: LinearProgressIndicator(
                      value: 0.8,
                      minHeight: 5,
                      color: Color(0xFF2962E8),
                      backgroundColor: Color(0xFFD9E3F3),
                    ),
                  ),
                  const SizedBox(height: 26),
                  PrimaryButton(
                    label: buttonLabel,
                    trailing: Icons.arrow_forward_rounded,
                    onPressed: () =>
                        Navigator.of(context).popUntil((route) => route.isFirst),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline, size: 14, color: Color(0xFF475467)),
                SizedBox(width: 6),
                Text(
                  'Secured by Enterprise Grade Encryption',
                  style: TextStyle(
                    color: Color(0xFF475467),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

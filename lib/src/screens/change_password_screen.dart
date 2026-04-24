import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../utils/password_strength.dart';
import '../widgets/common_widgets.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  PasswordStrength _strength = PasswordStrengthEvaluator.evaluate('');

  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(_handlePasswordChanged);
  }

  @override
  void dispose() {
    _newPasswordController.removeListener(_handlePasswordChanged);
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: PagePadding(
        child: Column(
          children: [
            const BackHeader(title: 'Change Password'),
            const SizedBox(height: 18),
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 28,
                        backgroundColor: Color(0xFFDCE7FF),
                        child: Icon(Icons.lock_reset, color: Color(0xFF1148A5)),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Change Password',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F254B),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Update your credentials to maintain strict account security and data protection.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF667085),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 22),
                      WhiteCard(
                        child: Column(
                          children: [
                            AppTextField(
                              label: 'Current Password',
                              controller: _currentPasswordController,
                              hint: 'Enter current password',
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Current password is required';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            AppTextField(
                              label: 'New Password',
                              controller: _newPasswordController,
                              hint: 'Create a new password',
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'New password is required';
                                }
                                if (_strength.score < 0.75) {
                                  return 'Please create a stronger password';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Text(
                                  'Strength:',
                                  style: TextStyle(
                                    color: Color(0xFF667085),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _strength.label,
                                  style: TextStyle(
                                    color: _strength.color,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(99),
                                    child: LinearProgressIndicator(
                                      value: _strength.score,
                                      minHeight: 6,
                                      color: _strength.color,
                                      backgroundColor: const Color(0xFFD9E3F3),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF4FF),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SectionLabel('SECURITY REQUIREMENTS'),
                                  const SizedBox(height: 12),
                                  ..._strength.requirements.map(
                                    (item) => Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: _RequirementRow(item: item),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            AppTextField(
                              label: 'Confirm New Password',
                              controller: _confirmPasswordController,
                              hint: 'Re-enter new password',
                              obscureText: true,
                              validator: (value) {
                                if (value != _newPasswordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            ActionBottomBar(
              children: [
                PrimaryButton(
                  label: 'Update Password',
                  leading: Icons.refresh_rounded,
                  onPressed: _submit,
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

  void _handlePasswordChanged() {
    setState(() {
      _strength = PasswordStrengthEvaluator.evaluate(_newPasswordController.text);
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password updated successfully')),
    );
    Navigator.of(context).pop();
  }
}

class _RequirementRow extends StatelessWidget {
  const _RequirementRow({required this.item});

  final PasswordRequirement item;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          item.met ? Icons.check_circle : Icons.radio_button_unchecked,
          color: item.met ? const Color(0xFF12B76A) : const Color(0xFF98A2B3),
          size: 16,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            item.label,
            style: const TextStyle(
              color: Color(0xFF344054),
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

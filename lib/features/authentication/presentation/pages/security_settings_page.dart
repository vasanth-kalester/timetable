import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';

class SecuritySettingsPage extends ConsumerStatefulWidget {
  const SecuritySettingsPage({super.key});

  @override
  ConsumerState<SecuritySettingsPage> createState() => _SecuritySettingsPageState();
}

class _SecuritySettingsPageState extends ConsumerState<SecuritySettingsPage> {
  bool _biometricEnabled = true;
  bool _autoLoginEnabled = true;
  final _currentPassController = TextEditingController();
  final _newPassController = TextEditingController();

  @override
  void dispose() {
    _currentPassController.dispose();
    _newPassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security & Biometrics'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Biometrics & Session Settings
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Biometric Authentication', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Use Fingerprint or Face ID for quick sign in'),
                    secondary: const Icon(Icons.fingerprint_rounded, color: Colors.indigoAccent),
                    value: _biometricEnabled,
                    onChanged: (val) {
                      setState(() {
                        _biometricEnabled = val;
                      });
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Automatic Login', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Restore session automatically when launching app'),
                    secondary: const Icon(Icons.autorenew_rounded, color: Colors.greenAccent),
                    value: _autoLoginEnabled,
                    onChanged: (val) {
                      setState(() {
                        _autoLoginEnabled = val;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Active Device Sessions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Active Device Sessions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.laptop_mac_rounded, color: Colors.indigoAccent),
                      title: const Text('macOS Desktop Client (Current)'),
                      subtitle: const Text('Active now • San Francisco, CA'),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('Active', style: TextStyle(fontSize: 11, color: Colors.greenAccent)),
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.phone_iphone_rounded, color: Colors.grey),
                      title: const Text('iPhone 15 Pro'),
                      subtitle: const Text('Last active 2 hours ago'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Logged out of all other devices.')),
                        );
                      },
                      icon: const Icon(Icons.phonelink_erase_rounded, size: 18),
                      label: const Text('Logout Other Devices'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Change Password Form
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Change Password', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Current Password',
                      hint: '••••••••',
                      controller: _currentPassController,
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'New Password',
                      hint: '••••••••',
                      controller: _newPassController,
                      obscureText: true,
                    ),
                    const SizedBox(height: 20),
                    AppButton(
                      label: 'Update Password',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Password updated successfully.')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

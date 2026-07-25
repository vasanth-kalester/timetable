import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../application/providers/auth_provider.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => _initSession());
  }

  Future<void> _initSession() async {
    await ref.read(authProvider.notifier).checkSession();
    if (!mounted) return;

    final authState = ref.read(authProvider);
    if (authState is Authenticated) {
      context.go('/dashboard');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.4),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.hub_rounded, color: Colors.white, size: 48),
            ),
            const SizedBox(height: 24),
            const Text(
              'EduFlow',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -0.5),
            ),
            const SizedBox(height: 6),
            Text(
              'Intelligent Campus Operating System',
              style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface.withOpacity(0.6)),
            ),
            const SizedBox(height: 48),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
          ],
        ),
      ),
    );
  }
}

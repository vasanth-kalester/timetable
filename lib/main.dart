import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/services/hive_cache_service.dart';
import 'core/widgets/offline_banner.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveCacheService.init();

  runApp(
    const ProviderScope(
      child: EduFlowApp(),
    ),
  );
}

class EduFlowApp extends ConsumerWidget {
  const EduFlowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'EduFlow - Intelligent Campus OS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, // Modern slate dark theme
      routerConfig: router,
      builder: (context, child) {
        return OfflineBannerWrapper(
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}

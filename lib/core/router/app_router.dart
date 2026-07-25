import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/responsive_layout.dart';

import '../../features/authentication/presentation/pages/splash_page.dart';
import '../../features/authentication/presentation/pages/login_page.dart';
import '../../features/authentication/presentation/pages/forgot_password_page.dart';
import '../../features/authentication/presentation/pages/profile_page.dart';
import '../../features/authentication/presentation/pages/security_settings_page.dart';
import '../../features/authentication/application/providers/auth_provider.dart';
import '../../features/academic/presentation/pages/academic_dashboard_page.dart';

// Role-specific dashboards
import '../../features/principal/presentation/pages/principal_dashboard_page.dart';
import '../../features/hod/presentation/pages/hod_dashboard_page.dart';
import '../../features/faculty/presentation/pages/faculty_dashboard_page.dart';
import '../../features/student/presentation/pages/student_dashboard_page.dart';

// Phase 2 Management Pages
import '../../features/academic/presentation/pages/academic_structure_page.dart';
import '../../features/infrastructure/presentation/pages/infrastructure_management_page.dart';
import '../../features/infrastructure/presentation/pages/institution_settings_page.dart';
import '../../features/hod/presentation/pages/department_overview_page.dart';
import '../../features/faculty/presentation/faculty_list_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    redirect: (context, state) {
      final isSplashing = state.uri.toString() == '/splash';
      final isAuthRoute = ['/login', '/forgot-password'].contains(state.uri.toString());

      final authState = ref.read(authProvider);

      if (authState is AuthInitial) return null;

      final isLoggedIn = authState is Authenticated;

      if (!isLoggedIn && !isAuthRoute && !isSplashing) {
        return '/login';
      }

      if (isLoggedIn && isAuthRoute) {
        final user = (authState as Authenticated).user;
        return user.dashboardRoute;
      }

      return null;
    },
    routes: [
      // ── Public routes ───────────────────────────────────────────────────
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),

      // ── Profile routes (accessible from any authenticated role) ─────────
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: '/security-settings',
        builder: (context, state) => const SecuritySettingsPage(),
      ),

      // ── Role-specific dashboards (direct, no shell nav) ─────────────────
      GoRoute(
        path: '/principal-dashboard',
        builder: (context, state) => const PrincipalDashboardPage(),
      ),
      GoRoute(
        path: '/hod-dashboard',
        builder: (context, state) => const HodDashboardPage(),
      ),
      GoRoute(
        path: '/faculty-dashboard',
        builder: (context, state) => const FacultyDashboardPage(),
      ),
      GoRoute(
        path: '/student-dashboard',
        builder: (context, state) => const StudentDashboardPage(),
      ),

      // ── Phase 2 Management Routes ─────────────────────────────────────────
      GoRoute(
        path: '/academic-structure',
        builder: (context, state) => const AcademicStructurePage(),
      ),
      GoRoute(
        path: '/infrastructure',
        builder: (context, state) => const InfrastructureManagementPage(),
      ),
      GoRoute(
        path: '/institution-settings',
        builder: (context, state) => const InstitutionSettingsPage(),
      ),
      GoRoute(
        path: '/department-overview/:id',
        builder: (context, state) => DepartmentOverviewPage(departmentId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/faculty',
        builder: (context, state) => const FacultyListScreen(),
      ),

      // ── Legacy shell layout (admin / general) ───────────────────────────
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return EduFlowShellLayout(child: child);
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const CampusDashboardScreen(),
          ),
          GoRoute(
            path: '/timetable',
            builder: (context, state) => const TimetablePlaceholderScreen(),
          ),
          GoRoute(
            path: '/academic',
            builder: (context, state) => const AcademicDashboardPage(),
          ),
          GoRoute(
            path: '/campus',
            builder: (context, state) => const CampusPlaceholderScreen(),
          ),
          GoRoute(
            path: '/analytics',
            builder: (context, state) => const AnalyticsPlaceholderScreen(),
          ),
        ],
      ),
    ],
  );

  ref.listen(authProvider, (previous, next) {
    router.refresh();
  });

  return router;
});

// ── Shell layout (used by admin / general routes) ──────────────────────────
class EduFlowShellLayout extends ConsumerWidget {
  final Widget child;
  const EduFlowShellLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.toString();
    final user = ref.watch(authProvider.notifier).currentUser;

    int selectedIndex = 0;
    if (location.startsWith('/timetable')) selectedIndex = 1;
    if (location.startsWith('/academic')) selectedIndex = 2;
    if (location.startsWith('/campus')) selectedIndex = 3;
    if (location.startsWith('/analytics')) selectedIndex = 4;

    void onDestinationSelected(int index) {
      switch (index) {
        case 0: context.go('/dashboard'); break;
        case 1: context.go('/timetable'); break;
        case 2: context.go('/academic'); break;
        case 3: context.go('/campus'); break;
        case 4: context.go('/analytics'); break;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.hub_rounded, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          const Text('EduFlow OS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ]),
        actions: [
          if (user != null)
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: ActionChip(
                avatar: CircleAvatar(
                  backgroundColor: Colors.indigo.shade300,
                  child: Text(user.fullName[0], style: const TextStyle(fontSize: 10, color: Colors.white)),
                ),
                label: Text('${user.fullName.split(' ')[0]} (${user.role.name})'),
                onPressed: () => context.push('/profile'),
              ),
            ),
        ],
      ),
      body: ResponsiveLayout(
        mobile: Scaffold(
          body: child,
          bottomNavigationBar: NavigationBar(
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
            destinations: const [
              NavigationDestination(icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
              NavigationDestination(icon: Icon(Icons.calendar_month_rounded), label: 'Timetable'),
              NavigationDestination(icon: Icon(Icons.school_rounded), label: 'Academic'),
              NavigationDestination(icon: Icon(Icons.business_rounded), label: 'Campus'),
              NavigationDestination(icon: Icon(Icons.bar_chart_rounded), label: 'Analytics'),
            ],
          ),
        ),
        desktop: Scaffold(
          body: Row(children: [
            NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
              extended: ResponsiveLayout.isDesktop(context),
              destinations: const [
                NavigationRailDestination(icon: Icon(Icons.dashboard_rounded), label: Text('Dashboard')),
                NavigationRailDestination(icon: Icon(Icons.calendar_month_rounded), label: Text('Timetable')),
                NavigationRailDestination(icon: Icon(Icons.school_rounded), label: Text('Academic')),
                NavigationRailDestination(icon: Icon(Icons.business_rounded), label: Text('Campus')),
                NavigationRailDestination(icon: Icon(Icons.bar_chart_rounded), label: Text('Analytics')),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: child),
          ]),
        ),
      ),
    );
  }
}

// ── Placeholder screens ─────────────────────────────────────────────────────
class TimetablePlaceholderScreen extends StatelessWidget {
  const TimetablePlaceholderScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(child: Text('Timetable Scheduling Engine', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
  );
}

class CampusPlaceholderScreen extends StatelessWidget {
  const CampusPlaceholderScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(child: Text('Campus Infrastructure', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
  );
}

class AnalyticsPlaceholderScreen extends StatelessWidget {
  const AnalyticsPlaceholderScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(child: Text('Campus Analytics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
  );
}

class CampusDashboardScreen extends StatelessWidget {
  const CampusDashboardScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(child: Text('Admin Dashboard', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
  );
}

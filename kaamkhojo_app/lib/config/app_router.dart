import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/phone_input_screen.dart';
import '../screens/auth/otp_screen.dart';
import '../screens/auth/role_selection_screen.dart';
import '../screens/customer/home_screen.dart';
import '../screens/customer/search_screen.dart';
import '../screens/customer/worker_profile_screen.dart';
import '../screens/customer/booking_history_screen.dart';
import '../screens/booking/booking_step1_screen.dart';
import '../screens/booking/booking_step2_screen.dart';
import '../screens/booking/booking_step3_screen.dart';
import '../screens/worker/worker_registration_screen.dart';
import '../screens/worker/worker_dashboard_screen.dart';
import '../screens/worker/job_requests_screen.dart';
import '../screens/worker/worker_profile_edit_screen.dart';
import '../screens/shared/chat_screen.dart';
import '../screens/shared/settings_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter buildRouter(BuildContext context) {
  final auth = Provider.of<AuthProvider>(context, listen: false);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    redirect: (ctx, state) {
      final isAuth = auth.isAuthenticated;
      final isOnAuth = state.uri.path.startsWith('/auth');
      final isSplash = state.uri.path == '/splash';

      if (isSplash) return null;
      if (!isAuth && !isOnAuth) return '/auth/phone';
      if (isAuth && isOnAuth) {
        return auth.currentUser?.role == 'worker' ? '/worker/dashboard' : '/home';
      }
      return null;
    },
    refreshListenable: auth,
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),

      // Auth
      GoRoute(path: '/auth/phone', builder: (_, __) => const PhoneInputScreen()),
      GoRoute(
        path: '/auth/otp',
        builder: (_, state) => OtpScreen(phone: state.extra as String? ?? ''),
      ),
      GoRoute(path: '/auth/role', builder: (_, __) => const RoleSelectionScreen()),

      // Customer
      GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
      GoRoute(
        path: '/search',
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return SearchScreen(initialCategory: extra?['category'] as String?);
        },
      ),
      GoRoute(
        path: '/worker/:id',
        builder: (_, state) => WorkerProfileScreen(workerId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/bookings', builder: (_, __) => const BookingHistoryScreen()),

      // Booking flow
      GoRoute(
        path: '/booking/step1',
        builder: (_, state) => BookingStep1Screen(extra: state.extra as Map<String, dynamic>?),
      ),
      GoRoute(path: '/booking/step2', builder: (_, __) => const BookingStep2Screen()),
      GoRoute(path: '/booking/step3', builder: (_, __) => const BookingStep3Screen()),

      // Worker
      GoRoute(path: '/worker/register', builder: (_, __) => const WorkerRegistrationScreen()),
      GoRoute(path: '/worker/dashboard', builder: (_, __) => const WorkerDashboardScreen()),
      GoRoute(path: '/worker/jobs', builder: (_, __) => const JobRequestsScreen()),
      GoRoute(path: '/worker/edit', builder: (_, __) => const WorkerProfileEditScreen()),

      // Shared
      GoRoute(
        path: '/chat/:bookingId',
        builder: (_, state) => ChatScreen(
          bookingId: state.pathParameters['bookingId']!,
          extra: state.extra as Map<String, dynamic>?,
        ),
      ),
      GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
    ],
    errorBuilder: (_, __) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text('पृष्ठ फेला परेन।', style: TextStyle(fontSize: 18)),
            TextButton(
              onPressed: () => GoRouter.of(_rootNavigatorKey.currentContext!).go('/home'),
              child: const Text('होम पृष्ठमा जानुहोस्'),
            ),
          ],
        ),
      ),
    ),
  );
}

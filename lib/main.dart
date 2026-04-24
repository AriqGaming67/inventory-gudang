import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';

import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/main_scaffold.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const ProviderScope(child: MyApp()));
}

final _router = GoRouter(
  initialLocation: '/dashboard',
  redirect: (context, state) {
    final session = Supabase.instance.client.auth.currentSession;
    final isLoggingIn = state.uri.toString() == '/login';
    final isRegistering = state.uri.toString() == '/register';

    if (session == null && !isLoggingIn && !isRegistering) {
      return '/login';
    }

    if (session != null && (isLoggingIn || isRegistering)) {
      return '/dashboard';
    }

    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) {
        return MainScaffold(child: child);
      },
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/items',
          builder: (context, state) => Scaffold(
            appBar: AppBar(title: const Text('Items')),
            body: const Center(child: Text('Items CRUD pending...')),
          ),
        ),
        GoRoute(
          path: '/transactions',
          builder: (context, state) => Scaffold(
            appBar: AppBar(title: const Text('Transactions')),
            body: const Center(child: Text('Movements pending...')),
          ),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => Scaffold(
            appBar: AppBar(title: const Text('Profile')),
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  Supabase.instance.client.auth.signOut();
                  context.go('/login');
                },
                child: const Text('Logout'),
              ),
            ),
          ),
        ),
      ],
    ),
  ],
);

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Inventory Gudang',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: false,
          scrolledUnderElevation: 0,
        ),
      ),
      routerConfig: _router,
    );
  }
}

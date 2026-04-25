import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/animated_button.dart';
import 'items/add_edit_item_screen.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Current route to determine bottom nav index
    final String location = GoRouterState.of(context).uri.toString();
    int currentIndex = _calculateSelectedIndex(location);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: child,
      floatingActionButton: location.startsWith('/items')
          ? AnimatedFAB(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddEditItemScreen(),
                  ),
                );
              },
              icon: Icons.add,
              backgroundColor: const Color(0xFF2563EB),
              tooltip: 'Tambah Barang',
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: const Color(0xFF2563EB),
        unselectedItemColor: const Color(0xFF64748B),
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/dashboard');
              break;
            case 1:
              context.go('/items');
              break;
            case 2:
              context.go('/transactions');
              break;
            case 3:
              context.go('/profile');
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.inventory), label: 'Items'),
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  static int _calculateSelectedIndex(String location) {
    if (location.startsWith('/dashboard')) return 0;
    if (location.startsWith('/items')) return 1;
    if (location.startsWith('/transactions')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/theme_provider.dart';

class AppDrawer extends ConsumerStatefulWidget {
  const AppDrawer({super.key});

  @override
  ConsumerState<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends ConsumerState<AppDrawer> {
  bool _notifLowStock = false;
  String _userName = 'Loading...';
  String _userRole = 'Loading...';
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _loadUserProfile();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) {
      return;
    }
    setState(() {
      _notifLowStock = prefs.getBool('notif_low_stock') ?? true;
    });
  }

  Future<void> _savePreference(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _loadUserProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      if (!mounted) {
        return;
      }
      setState(() {
        _userEmail = user.email ?? '';
      });
      try {
        final profile = await Supabase.instance.client
            .from('profiles')
            .select()
            .eq('id', user.id)
            .single();
        if (!mounted) {
          return;
        }
        setState(() {
          _userName = profile['name'] ?? 'User';
          _userRole = profile['role'] ?? 'staff';
        });
      } catch (e) {
        if (!mounted) {
          return;
        }
        setState(() {
          _userName = 'User';
          _userRole = 'staff';
        });
      }
    }
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tentang Aplikasi'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nama App: Inventory Gudang'),
            Text('Versi: 1.0.0'),
            Text('Tim: Developer Flutter'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();
    if (!mounted) {
      return;
    }
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;
    final location = GoRouterState.of(context).uri.toString();
    final isDashboard = location.startsWith('/dashboard');
    final isItems = location.startsWith('/items');
    final isTransactions = location.startsWith('/transactions');
    final isProfile = location.startsWith('/profile');

    Color roleColor = _userRole == 'manager'
        ? const Color(0xFF2563EB)
        : Colors.grey;
    final selectedTileColor = Theme.of(context).colorScheme.primaryContainer;
    final selectedIconColor = Theme.of(context).colorScheme.primary;

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFFF8FAFC)),
            accountName: Row(
              children: [
                Text(
                  _userName,
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: roleColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _userRole.toUpperCase(),
                    style: TextStyle(
                      color: roleColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            accountEmail: Text(
              _userEmail,
              style: const TextStyle(color: Color(0xFF64748B)),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: const Color(0xFF2563EB),
              child: Text(
                _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
                style: const TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: const Icon(Icons.dashboard),
                  title: const Text('Dashboard'),
                  selected: isDashboard,
                  selectedTileColor: selectedTileColor,
                  selectedColor: selectedIconColor,
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/dashboard');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.inventory_2),
                  title: const Text('Barang'),
                  selected: isItems,
                  selectedTileColor: selectedTileColor,
                  selectedColor: selectedIconColor,
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/items');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.swap_horiz),
                  title: const Text('Transaksi'),
                  selected: isTransactions,
                  selectedTileColor: selectedTileColor,
                  selectedColor: selectedIconColor,
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/transactions');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Profil'),
                  selected: isProfile,
                  selectedTileColor: selectedTileColor,
                  selectedColor: selectedIconColor,
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/profile');
                  },
                ),
                const Divider(),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'Pengaturan',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SwitchListTile(
                  title: const Text('Dark Mode'),
                  secondary: const Icon(Icons.dark_mode),
                  value: isDarkMode,
                  onChanged: (val) =>
                      ref.read(themeModeProvider.notifier).setDarkMode(val),
                ),
                SwitchListTile(
                  title: const Text('Peringatan Stok Rendah'),
                  secondary: const Icon(Icons.notifications),
                  value: _notifLowStock,
                  onChanged: (val) {
                    setState(() => _notifLowStock = val);
                    _savePreference('notif_low_stock', val);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text('Tentang Aplikasi'),
                  onTap: () {
                    Navigator.pop(context);
                    _showAboutDialog();
                  },
                ),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Keluar', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _logout();
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

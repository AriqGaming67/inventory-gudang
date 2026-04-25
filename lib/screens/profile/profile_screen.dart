import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/app_drawer.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  String _userName = 'Loading...';
  String _userRole = 'Loading...';
  String _userEmail = '';
  String _joinedDate = '';
  int _totalTransactions = 0;

  String _mapPasswordError(Object error) {
    if (error is AuthException) {
      final message = error.message.toLowerCase();
      if (message.contains('invalid login credentials') ||
          message.contains('invalid credentials') ||
          message.contains('password')) {
        return 'Password lama salah.';
      }
      return error.message;
    }
    return 'Gagal mengganti password. Coba lagi.';
  }

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      if (!mounted) {
        return;
      }
      setState(() => _userEmail = user.email ?? '');

      try {
        final profile = await Supabase.instance.client
            .from('profiles')
            .select()
            .eq('id', user.id)
            .single();

        final rawCreatedAt = profile['created_at'];
        final date = rawCreatedAt is String
            ? DateTime.tryParse(rawCreatedAt)
            : null;
        final joinedFormatted = date != null
            ? '${date.day} ${date.month} ${date.year}'
            : '-';

        // Count transactions
        final res = await Supabase.instance.client
            .from('stock_movements')
            .select()
            .eq('created_by', user.id)
            .count(CountOption.exact);
        final count = res.count;

        if (mounted) {
          setState(() {
            _userName = profile['name'] ?? 'User';
            _userRole = profile['role'] ?? 'staff';
            _joinedDate = joinedFormatted;
            _totalTransactions = count;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _userName = 'User';
            _userRole = 'staff';
            _joinedDate = '-';
          });
        }
      }
    }
  }

  void _showEditNameSheet() {
    final controller = TextEditingController(text: _userName);
    final pageContext = context;
    showModalBottomSheet(
      context: pageContext,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Edit Nama',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Nama Lengkap',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final navigator = Navigator.of(sheetContext);
                final messenger = ScaffoldMessenger.of(pageContext);
                final newName = controller.text.trim();
                if (newName.isEmpty) {
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Nama tidak boleh kosong')),
                  );
                  return;
                }

                final user = Supabase.instance.client.auth.currentUser;
                if (user == null) {
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Sesi login tidak valid')),
                  );
                  return;
                }

                await Supabase.instance.client
                    .from('profiles')
                    .update({'name': newName})
                    .eq('id', user.id);

                if (!mounted) {
                  return;
                }

                setState(() => _userName = newName);
                navigator.pop();
                messenger.showSnackBar(
                  const SnackBar(content: Text('Nama berhasil diperbarui')),
                );
              },
              child: const Text('Simpan'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordSheet() {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final pageContext = context;
    showModalBottomSheet(
      context: pageContext,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Ganti Password',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: oldPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password Lama (Verifikasi)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password Baru',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final navigator = Navigator.of(sheetContext);
                final messenger = ScaffoldMessenger.of(pageContext);
                final oldPass = oldPasswordController.text.trim();
                final newPass = newPasswordController.text.trim();

                if (oldPass.isEmpty || newPass.isEmpty) {
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Password lama dan baru wajib diisi'),
                    ),
                  );
                  return;
                }

                if (newPass.length < 6) {
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Password baru minimal 6 karakter'),
                    ),
                  );
                  return;
                }

                final auth = Supabase.instance.client.auth;
                final currentUser = auth.currentUser;
                final email = currentUser?.email;

                if (email == null) {
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Email akun tidak ditemukan')),
                  );
                  return;
                }

                try {
                  await auth.signInWithPassword(
                    email: email,
                    password: oldPass,
                  );
                  await auth.updateUser(UserAttributes(password: newPass));

                  if (!mounted) {
                    return;
                  }

                  navigator.pop();
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Password berhasil diubah')),
                  );
                } catch (e) {
                  messenger.showSnackBar(
                    SnackBar(content: Text(_mapPasswordError(e))),
                  );
                }
              },
              child: const Text('Simpan'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Ya, Keluar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await Supabase.instance.client.auth.signOut();
      if (!mounted) {
        return;
      }
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;
    final colorScheme = Theme.of(context).colorScheme;
    Color roleColor = _userRole == 'manager'
        ? const Color(0xFF2563EB)
        : Colors.grey;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Text(
          'Profil Saya',
          style: TextStyle(color: colorScheme.onSurface),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: Container(
        color: colorScheme.surface,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(
                    alpha: isDarkMode ? 0.32 : 0.24,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: const Color(0xFF2563EB),
                      child: Text(
                        _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          fontSize: 32,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _userName,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: roleColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _userRole.toUpperCase(),
                        style: TextStyle(
                          color: roleColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _userEmail,
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Stats Row
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Bergabung Sejak',
                      value: _joinedDate,
                      icon: Icons.calendar_today,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatCard(
                      title: 'Total Transaksi',
                      value: '$_totalTransactions',
                      icon: Icons.swap_horiz,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Settings
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(
                    alpha: isDarkMode ? 0.28 : 0.18,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.edit,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      title: Text(
                        'Edit Nama',
                        style: TextStyle(color: colorScheme.onSurface),
                      ),
                      trailing: Icon(
                        Icons.chevron_right,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      onTap: _showEditNameSheet,
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(
                        Icons.lock,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      title: Text(
                        'Ganti Password',
                        style: TextStyle(color: colorScheme.onSurface),
                      ),
                      trailing: Icon(
                        Icons.chevron_right,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      onTap: _showChangePasswordSheet,
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      secondary: Icon(
                        Icons.dark_mode,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      title: Text(
                        'Dark Mode',
                        style: TextStyle(color: colorScheme.onSurface),
                      ),
                      value: isDarkMode,
                      onChanged: (val) =>
                          ref.read(themeModeProvider.notifier).setDarkMode(val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.surface,
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _logout,
                  icon: const Icon(Icons.logout),
                  label: const Text(
                    'Keluar Akun',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF2563EB), size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

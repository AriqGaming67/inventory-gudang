import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/auth_repository.dart';
import '../models/profile.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository());

final authStateProvider = StreamProvider((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

final currentUserProfileProvider = FutureProvider<Profile?>((ref) async {
  final session = ref.watch(authStateProvider).value?.session;
  if (session == null) return null;

  return await ref.watch(authRepositoryProvider).getProfile(session.user.id);
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bluesky/bluesky_chat.dart';
import 'auth_repository.dart';

final blueskyChatProvider = FutureProvider<BlueskyChat?>((ref) async {
  final session = await ref.watch(authSessionProvider.future);
  if (session == null) return null;
  return BlueskyChat.fromSession(session);
});

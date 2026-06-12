import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bluesky/bluesky.dart' as bsky;
import 'package:bluesky/app_bsky_actor_defs.dart' as bsky_actor;
import '../../auth/data/auth_repository.dart';

final followingProvider = FutureProvider.autoDispose<List<bsky_actor.ProfileView>>((ref) async {
  final session = await ref.watch(authSessionProvider.future);
  if (session == null) return [];

  final bluesky = bsky.Bluesky.fromSession(session);
  final response = await bluesky.graph.getFollows(actor: session.did);
  return response.data.follows;
});

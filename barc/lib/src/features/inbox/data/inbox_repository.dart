import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bluesky/bluesky_chat.dart';
import 'package:bluesky/chat_bsky_convo_defs.dart';
import '../../auth/data/chat_provider.dart';

final inboxRepositoryProvider = Provider<InboxRepository>((ref) {
  final chat = ref.watch(blueskyChatProvider).valueOrNull;
  return InboxRepository(chat);
});

class InboxRepository {
  final BlueskyChat? _chat;

  InboxRepository(this._chat);

  Future<List<ConvoView>> fetchConvos() async {
    if (_chat == null) return [];
    
    // The bluesky package automatically handles the 'did:web:api.bsky.chat#bsky_chat' 
    // proxying header for chat endpoints natively.
    final response = await _chat.convo.listConvos();
    
    return response.data.convos;
  }
}

final inboxConvosProvider = FutureProvider.autoDispose<List<ConvoView>>((ref) async {
  final repo = ref.watch(inboxRepositoryProvider);
  return repo.fetchConvos();
});

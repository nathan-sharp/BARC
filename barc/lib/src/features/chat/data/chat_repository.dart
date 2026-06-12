import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bluesky/bluesky_chat.dart';
import 'package:bluesky/chat_bsky_convo_defs.dart';
import 'package:bluesky/app_bsky_richtext_facet.dart';
// ignore: implementation_imports
import 'package:bluesky/src/services/codegen/chat/bsky/convo/getMessages/union_main_messages.dart';
import 'package:bluesky_text/bluesky_text.dart';
import '../../auth/data/chat_provider.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final chat = ref.watch(blueskyChatProvider).valueOrNull;
  return ChatRepository(chat);
});

class ChatRepository {
  final BlueskyChat? _chat;

  ChatRepository(this._chat);

  Future<List<MessageView>> fetchMessages(String convoId) async {
    if (_chat == null) return [];
    
    final response = await _chat.convo.getMessages(convoId: convoId);
    return response.data.messages
        .where((m) => m.isMessageView)
        .map((m) => m.messageView!)
        .toList();
  }

  Future<void> sendMessage(String convoId, String text) async {
    if (_chat == null || text.trim().isEmpty) return;

    final bskyText = BlueskyText(text);
    
    // Extract byte-indexed facets using bluesky_text
    final rawFacets = await bskyText.entities.toFacets();
    
    // Convert to atproto/bluesky Facet objects
    final facets = rawFacets.map((e) => RichtextFacet.fromJson(e)).toList();

    await _chat.convo.sendMessage(
      convoId: convoId,
      message: MessageInput(
        text: bskyText.value,
        facets: facets,
      ),
    );
  }

  Future<String?> getConvoForMembers(List<String> dids) async {
    if (_chat == null) return null;
    try {
      final response = await _chat!.convo.getConvoForMembers(members: dids);
      return response.data.convo.id;
    } catch (e) {
      return null;
    }
  }
}

final chatMessagesProvider = FutureProvider.family.autoDispose<List<MessageView>, String>((ref, convoId) async {
  final repo = ref.watch(chatRepositoryProvider);
  return repo.fetchMessages(convoId);
});

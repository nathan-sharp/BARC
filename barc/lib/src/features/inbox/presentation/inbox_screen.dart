import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bluesky/chat_bsky_convo_defs.dart';
import '../data/inbox_repository.dart';
import '../../auth/data/auth_repository.dart';

class InboxScreen extends ConsumerWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final convosAsync = ref.watch(inboxConvosProvider);
    final sessionAsync = ref.watch(authSessionProvider);
    final currentDid = sessionAsync.value?.did ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => ref.invalidate(inboxConvosProvider),
          ),
        ],
      ),
      body: convosAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF128C7E)),
        ),
        error: (err, stack) => Center(
          child: Text('Error: $err', style: const TextStyle(color: Colors.red)),
        ),
        data: (convos) {
          if (convos.isEmpty) {
            return const Center(child: Text('No active chats', style: TextStyle(color: Colors.black54)));
          }
          return ListView.separated(
            itemCount: convos.length,
            separatorBuilder: (_, _) => const Divider(
              color: Colors.black12,
              thickness: 1,
              height: 1,
              indent: 80, // Indent to align with text
            ),
            itemBuilder: (context, index) {
              final convo = convos[index];
              return _ConvoTile(convo: convo, currentDid: currentDid);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF25D366),
        foregroundColor: Colors.white,
        child: const Icon(Icons.chat),
      ),
    );
  }
}

class _ConvoTile extends StatelessWidget {
  final ConvoView convo;
  final String currentDid;

  const _ConvoTile({required this.convo, required this.currentDid});

  @override
  Widget build(BuildContext context) {
    final counterparties = convo.members.where((m) => m.did != currentDid).toList();
    final counterparty = counterparties.isNotEmpty ? counterparties.first : (convo.members.isNotEmpty ? convo.members.first : null);
    
    final handle = counterparty?.handle ?? 'Unknown';
    final avatar = counterparty?.avatar;
    final unread = convo.unreadCount > 0;
    
    String snippet = 'Tap to chat';
    final lastMsg = convo.lastMessage;
    if (lastMsg != null) {
      if (lastMsg.isMessageView) {
        final msg = lastMsg.messageView!;
        final isMe = msg.sender.did == currentDid;
        snippet = isMe ? 'You: ${msg.text}' : msg.text;
      } else if (lastMsg.isDeletedMessageView) {
        snippet = 'Message deleted';
      } else {
        snippet = 'Message received';
      }
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        radius: 28,
        backgroundColor: Colors.grey.shade300,
        backgroundImage: avatar != null ? NetworkImage(avatar) : null,
        child: avatar == null ? const Icon(Icons.person, color: Colors.white, size: 32) : null,
      ),
      title: Text(
        handle,
        style: TextStyle(
          fontWeight: unread ? FontWeight.bold : FontWeight.w600,
          color: Colors.black87,
          fontSize: 16,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        snippet,
        style: TextStyle(
          color: Colors.black54,
          fontWeight: unread ? FontWeight.w600 : FontWeight.normal,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (unread)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Color(0xFF25D366),
                shape: BoxShape.circle,
              ),
              child: Text(
                '${convo.unreadCount}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            )
        ],
      ),
      onTap: () {
        context.push('/chat/${convo.id}');
      },
    );
  }
}

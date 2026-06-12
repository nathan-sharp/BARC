import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bluesky/chat_bsky_convo_defs.dart';
import '../data/inbox_repository.dart';

class InboxScreen extends ConsumerWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final convosAsync = ref.watch(inboxConvosProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('BARC // INBOX'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(inboxConvosProvider),
          ),
        ],
      ),
      body: convosAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF00FF00)),
        ),
        error: (err, stack) => Center(
          child: Text('ERR: $err', style: const TextStyle(color: Colors.red)),
        ),
        data: (convos) {
          if (convos.isEmpty) {
            return const Center(child: Text('> NO ACTIVE CONNECTIONS'));
          }
          return ListView.separated(
            itemCount: convos.length,
            separatorBuilder: (_, _) => const Divider(
              color: Color(0xFF00FF00),
              thickness: 2,
              height: 2,
            ),
            itemBuilder: (context, index) {
              final convo = convos[index];
              return _ConvoTile(convo: convo);
            },
          );
        },
      ),
    );
  }
}

class _ConvoTile extends StatelessWidget {
  final ConvoView convo;

  const _ConvoTile({required this.convo});

  @override
  Widget build(BuildContext context) {
    final counterparty = convo.members.isNotEmpty ? convo.members.first : null;
    final handle = counterparty?.handle ?? 'UNKNOWN';
    final avatar = counterparty?.avatar;
    final unread = convo.unreadCount > 0;
    
    String snippet = '...';
    if (convo.lastMessage != null) {
       snippet = '> ENCRYPTED_PAYLOAD_DETECTED'; 
    }

    return ListTile(
      contentPadding: const EdgeInsets.all(16),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF00FF00), width: 2),
          image: avatar != null
              ? DecorationImage(image: NetworkImage(avatar), fit: BoxFit.cover)
              : null,
        ),
        child: avatar == null ? const Icon(Icons.person, color: Color(0xFF00FF00)) : null,
      ),
      title: Text(
        handle,
        style: TextStyle(
          fontWeight: unread ? FontWeight.bold : FontWeight.normal,
          color: unread ? const Color(0xFFFFB000) : const Color(0xFF00FF00),
        ),
      ),
      subtitle: Text(
        snippet,
        style: TextStyle(
          color: const Color(0xFF00FF00).withValues(alpha: 0.7),
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: unread
          ? Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFFFB000),
                shape: BoxShape.circle,
              ),
              child: Text(
                '${convo.unreadCount}',
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : const Icon(Icons.chevron_right, color: Color(0xFF00FF00)),
      onTap: () {
        context.push('/chat/${convo.id}');
      },
    );
  }
}

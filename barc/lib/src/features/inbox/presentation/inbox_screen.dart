import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bluesky/chat_bsky_convo_defs.dart';
import '../data/inbox_repository.dart';
import '../../auth/data/auth_repository.dart';
import 'inbox_state.dart';
import '../../chat/presentation/chat_screen.dart';
import '../../chat/data/chat_repository.dart';

class InboxScreen extends ConsumerWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final convosAsync = ref.watch(inboxConvosProvider);
    final sessionAsync = ref.watch(authSessionProvider);
    final currentDid = sessionAsync.value?.did ?? '';
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    final selectedConvoId = ref.watch(selectedConvoIdProvider);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: isDesktop ? 0 : NavigationToolbar.kMiddleSpacing,
        title: isDesktop
            ? Row(
                children: [
                  SizedBox(
                    width: 350,
                    child: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text('Chats', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () {},
                        ),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'settings') {
                              context.push('/settings');
                            } else if (value == 'refresh') {
                              ref.invalidate(inboxConvosProvider);
                            }
                          },
                          itemBuilder: (BuildContext context) {
                            return const [
                              PopupMenuItem(
                                value: 'refresh',
                                child: Text('Refresh'),
                              ),
                              PopupMenuItem(
                                value: 'settings',
                                child: Text('Settings'),
                              ),
                            ];
                          },
                        ),
                      ],
                    ),
                  ),
                  if (selectedConvoId != null)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: _ChatHeader(convoId: selectedConvoId, currentDid: currentDid),
                      ),
                    ),
                ],
              )
            : const Text('Chats', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: isDesktop
            ? [
                if (selectedConvoId != null) ...[
                  IconButton(icon: const Icon(Icons.videocam), onPressed: () {}),
                  IconButton(icon: const Icon(Icons.call), onPressed: () {}),
                  IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
                ],
              ]
            : [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {},
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'settings') {
                      context.push('/settings');
                    } else if (value == 'refresh') {
                      ref.invalidate(inboxConvosProvider);
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return const [
                      PopupMenuItem(
                        value: 'refresh',
                        child: Text('Refresh'),
                      ),
                      PopupMenuItem(
                        value: 'settings',
                        child: Text('Settings'),
                      ),
                    ];
                  },
                ),
              ],
      ),
      body: isDesktop
          ? _buildDesktopView(context, ref, convosAsync, currentDid)
          : _buildMobileView(context, ref, convosAsync, currentDid),
      floatingActionButton: isDesktop ? null : FloatingActionButton(
        onPressed: () {
          context.push('/new_contact');
        },
        backgroundColor: const Color(0xFF25D366),
        foregroundColor: Colors.white,
        child: const Icon(Icons.chat),
      ),
    );
  }

  Widget _buildMobileView(BuildContext context, WidgetRef ref, AsyncValue<List<ConvoView>> convosAsync, String currentDid) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return convosAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: Color(0xFF128C7E)),
      ),
      error: (err, stack) => Center(
        child: Text('Error: $err', style: const TextStyle(color: Colors.red)),
      ),
      data: (convos) {
        if (convos.isEmpty) {
          return Center(child: Text('No active chats', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54)));
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
            return _ConvoTile(convo: convo, currentDid: currentDid, isDesktop: false);
          },
        );
      },
    );
  }

  Widget _buildDesktopView(BuildContext context, WidgetRef ref, AsyncValue<List<ConvoView>> convosAsync, String currentDid) {
    final selectedConvoId = ref.watch(selectedConvoIdProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        SizedBox(
          width: 350,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: convosAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: Color(0xFF128C7E)),
              ),
              error: (err, stack) => Center(
                child: Text('Error: $err', style: const TextStyle(color: Colors.red)),
              ),
              data: (convos) {
                if (convos.isEmpty) {
                  return Center(child: Text('No active chats', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54)));
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
                    return _ConvoTile(convo: convo, currentDid: currentDid, isDesktop: true);
                  },
                );
              },
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                context.push('/new_contact');
              },
              backgroundColor: const Color(0xFF25D366),
              foregroundColor: Colors.white,
              child: const Icon(Icons.chat),
            ),
          ),
        ),
        const VerticalDivider(width: 1, thickness: 1, color: Colors.black12),
        Expanded(
          child: selectedConvoId == null
              ? Center(
                  child: Text(
                    'Select a chat to start messaging',
                    style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 16),
                  ),
                )
              : ChatScreen(convoId: selectedConvoId, isSplitView: true),
        ),
      ],
    );
  }
}

class _ConvoTile extends ConsumerWidget {
  final ConvoView convo;
  final String currentDid;
  final bool isDesktop;

  const _ConvoTile({required this.convo, required this.currentDid, required this.isDesktop});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 16,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        snippet,
        style: TextStyle(
          color: isDark ? Colors.white70 : Colors.black54,
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
        if (isDesktop) {
          ref.read(selectedConvoIdProvider.notifier).state = convo.id;
        } else {
          context.push('/chat/${convo.id}');
        }
      },
    );
  }
}

class _ChatHeader extends ConsumerWidget {
  final String convoId;
  final String currentDid;

  const _ChatHeader({required this.convoId, required this.currentDid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final convoAsync = ref.watch(convoProvider(convoId));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return convoAsync.when(
      loading: () => const Text('Loading...'),
      error: (err, stack) => const Text('Chat'),
      data: (convo) {
        if (convo == null) return const Text('Chat');
        final otherMembers = convo.members.where((m) => m.did != currentDid).toList();
        if (otherMembers.isEmpty) return const Text('Chat');
        
        final other = otherMembers.first;
        return Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white24,
              backgroundImage: other.avatar != null ? NetworkImage(other.avatar!) : null,
              child: other.avatar == null ? const Icon(Icons.person, color: Colors.white, size: 20) : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    other.displayName ?? other.handle,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : Colors.black87),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    other.handle,
                    style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.black54),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

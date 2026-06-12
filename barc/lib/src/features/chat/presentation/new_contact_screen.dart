import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bluesky/app_bsky_actor_defs.dart' as bsky_actor;
import '../data/contacts_provider.dart';
import '../data/chat_repository.dart';

enum ChatPermission { normal, request, none }

ChatPermission _getPermission(bsky_actor.ProfileView user) {
  final setting = user.associated?.chat?.allowIncoming.knownValue?.value ?? 'following';
  final followsMe = user.viewer?.hasFollowedBy == true;

  if (setting == 'none') return ChatPermission.none;
  if (followsMe) return ChatPermission.normal;
  if (setting == 'all') return ChatPermission.request;
  
  return ChatPermission.none;
}

class NewContactScreen extends ConsumerWidget {
  const NewContactScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final followingAsync = ref.watch(followingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select contact'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: followingAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
        data: (follows) {
          final filtered = follows.where((u) => _getPermission(u) != ChatPermission.none).toList();
          
          filtered.sort((a, b) {
            final pA = _getPermission(a);
            final pB = _getPermission(b);
            if (pA == pB) {
              return (a.displayName ?? a.handle).toLowerCase().compareTo((b.displayName ?? b.handle).toLowerCase());
            }
            return pA == ChatPermission.normal ? -1 : 1;
          });

          return ListView.builder(
            itemCount: filtered.length + 2, // +2 for the static header items
            itemBuilder: (context, index) {
              if (index == 0) {
                return ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF128C7E),
                    child: Icon(Icons.person_add, color: Colors.white),
                  ),
                  title: const Text('New contact', style: TextStyle(fontWeight: FontWeight.bold)),
                  onTap: () {},
                );
              }
              if (index == 1) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text('Contacts on Bluesky', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                );
              }
              
              final user = filtered[index - 2];
              final perm = _getPermission(user);
              final isRequest = perm == ChatPermission.request;

              return Opacity(
                opacity: isRequest ? 0.5 : 1.0,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: user.avatar != null ? NetworkImage(user.avatar!) : null,
                    child: user.avatar == null ? const Icon(Icons.person, color: Colors.white) : null,
                  ),
                  title: Text(
                    user.displayName ?? user.handle,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    isRequest ? '${user.handle}\nRequires message request' : user.handle,
                    style: const TextStyle(color: Colors.grey),
                    maxLines: isRequest ? 2 : 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () async {
                    // Try to get or create a convo with this user
                    final repo = ref.read(chatRepositoryProvider);
                    final convoId = await repo.getConvoForMembers([user.did]);
                    
                    if (convoId != null && context.mounted) {
                      // Replace the 'select contact' screen with the actual chat screen
                      context.pushReplacement('/chat/$convoId');
                    } else if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Could not start a chat with this user.')),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

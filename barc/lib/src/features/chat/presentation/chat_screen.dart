import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bluesky/chat_bsky_convo_defs.dart';
import '../data/chat_repository.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String convoId;
  const ChatScreen({super.key, required this.convoId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _textController = TextEditingController();
  bool _isSending = false;

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSending = true);
    try {
      final repo = ref.read(chatRepositoryProvider);
      await repo.sendMessage(widget.convoId, text);
      _textController.clear();
      ref.invalidate(chatMessagesProvider(widget.convoId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ERR_SEND_FAIL: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(chatMessagesProvider(widget.convoId));

    return Scaffold(
      appBar: AppBar(
        title: Text('BARC // THREAD: ${widget.convoId.length > 8 ? widget.convoId.substring(0, 8) : widget.convoId}...'),
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: Color(0xFF00FF00)),
              ),
              error: (err, stack) => Center(
                child: Text('ERR: $err', style: const TextStyle(color: Colors.red)),
              ),
              data: (messages) {
                if (messages.isEmpty) {
                  return const Center(child: Text('> NO LOGS FOUND'));
                }
                return ListView.builder(
                  reverse: true, // Render bottom up
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    return _MessageBubble(message: msg);
                  },
                );
              },
            ),
          ),
          _buildInputTerminal(),
        ],
      ),
    );
  }

  Widget _buildInputTerminal() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFF00FF00), width: 2)),
        color: Colors.black,
      ),
      padding: const EdgeInsets.all(8),
      child: SafeArea(
        child: Row(
          children: [
            const Text('> ', style: TextStyle(color: Color(0xFF00FF00), fontSize: 20)),
            Expanded(
              child: TextField(
                controller: _textController,
                style: const TextStyle(color: Color(0xFF00FF00)),
                decoration: const InputDecoration(
                  hintText: 'TRANSMIT_PAYLOAD...',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            if (_isSending)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF00FF00)),
                ),
              )
            else
              IconButton(
                icon: const Icon(Icons.send, color: Color(0xFF00FF00)),
                onPressed: _sendMessage,
              ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageView message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final sender = message.sender.did;
    final text = message.text;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF00FF00), width: 1),
          color: const Color(0xFF111111),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SRC: $sender',
              style: const TextStyle(
                color: Color(0xFFFFB000),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              text,
              style: const TextStyle(color: Color(0xFF00FF00)),
            ),
          ],
        ),
      ),
    );
  }
}

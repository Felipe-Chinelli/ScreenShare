import 'package:flutter/material.dart';

import '../models/chat_message.dart';
import '../services/room_manager.dart';

/// Painel de chat de texto da sala. Mostra o histórico, agrupa mensagens
/// seguidas da mesma pessoa e rola sozinho até a mensagem mais recente.
class ChatPanel extends StatefulWidget {
  final RoomManager manager;
  final VoidCallback onClose;

  const ChatPanel({super.key, required this.manager, required this.onClose});

  @override
  State<ChatPanel> createState() => _ChatPanelState();
}

class _ChatPanelState extends State<ChatPanel> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  final _focus = FocusNode();
  int _lastCount = 0;

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text;
    if (text.trim().isEmpty) return;
    widget.manager.sendChat(text);
    _controller.clear();
    _focus.requestFocus();
  }

  void _scrollToBottomIfNeeded(int count) {
    if (count == _lastCount) return;
    _lastCount = count;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  String _formatTime(DateTime t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Widget _bubble(ChatMessage m, {required bool mine, required bool showHeader}) {
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 280),
        child: Container(
          margin: EdgeInsets.only(top: showHeader ? 10 : 2),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: mine ? Colors.blueAccent.shade700 : const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showHeader && !mine)
                Text(
                  m.senderName,
                  style: TextStyle(
                    color: Colors.blueAccent.shade100,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              SelectableText(
                m.text,
                style: const TextStyle(color: Colors.white),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  _formatTime(m.time),
                  style: const TextStyle(color: Colors.white54, fontSize: 10),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final manager = widget.manager;
    final messages = manager.messages;
    _scrollToBottomIfNeeded(messages.length);

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        border: Border(left: BorderSide(color: Colors.white12)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 4, 8),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Chat da sala',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  tooltip: 'Fechar chat',
                  icon: const Icon(Icons.close),
                  onPressed: widget.onClose,
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.white12),
          Expanded(
            child: messages.isEmpty
                ? const Center(
                    child: Text(
                      'Nenhuma mensagem ainda.\nDiga olá!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white38),
                    ),
                  )
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.all(12),
                    itemCount: messages.length,
                    itemBuilder: (context, i) {
                      final m = messages[i];
                      final showHeader = i == 0 || messages[i - 1].senderId != m.senderId;
                      return _bubble(
                        m,
                        mine: m.senderId == manager.myId,
                        showHeader: showHeader,
                      );
                    },
                  ),
          ),
          const Divider(height: 1, color: Colors.white12),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focus,
                      enabled: manager.isConnected,
                      maxLength: 2000,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      buildCounter: (context,
                              {required currentLength, required isFocused, required maxLength}) =>
                          null,
                      decoration: InputDecoration(
                        hintText: manager.isConnected
                            ? 'Digite uma mensagem...'
                            : 'Desconectado',
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    tooltip: 'Enviar',
                    onPressed: manager.isConnected ? _send : null,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

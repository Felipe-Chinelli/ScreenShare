import 'package:flutter/material.dart';
import '../services/room_manager.dart';
import '../widgets/chat_panel.dart';
import '../widgets/participant_tile.dart';

class RoomScreen extends StatefulWidget {
  final RoomManager manager;

  const RoomScreen({super.key, required this.manager});

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  bool _chatOpen = false;

  RoomManager get manager => widget.manager;

  void _toggleChat() {
    setState(() => _chatOpen = !_chatOpen);
    manager.setChatOpen(_chatOpen);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: manager,
      builder: (context, _) {
        final tiles = <Widget>[
          ParticipantTile(
            name: manager.myName,
            stream: manager.localScreenStream,
            isLocal: true,
          ),
          ...manager.peers.values.map(
            (p) => ParticipantTile(name: p.name, stream: p.remoteStream),
          ),
        ];

        final grid = Padding(
          padding: const EdgeInsets.all(12),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 420,
              childAspectRatio: 16 / 10,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: tiles.length,
            itemBuilder: (context, i) => tiles[i],
          ),
        );

        final controls = Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              FloatingActionButton.extended(
                heroTag: 'mic',
                onPressed: manager.toggleMic,
                backgroundColor: manager.isSharingMic ? Colors.green : Colors.grey.shade800,
                icon: Icon(manager.isSharingMic ? Icons.mic : Icons.mic_off),
                label: Text(manager.isSharingMic ? 'Mic ligado' : 'Mic desligado'),
              ),
              FloatingActionButton.extended(
                heroTag: 'screen',
                onPressed: manager.toggleScreenShare,
                backgroundColor: manager.isSharingScreen ? Colors.redAccent : Colors.blueAccent,
                icon: Icon(manager.isSharingScreen ? Icons.stop_screen_share : Icons.screen_share),
                label: Text(manager.isSharingScreen ? 'Parar de compartilhar' : 'Compartilhar tela'),
              ),
            ],
          ),
        );

        final main = Column(
          children: [
            Expanded(child: grid),
            controls,
          ],
        );

        return Scaffold(
          backgroundColor: const Color(0xFF121212),
          appBar: AppBar(
            title: Text('Sala: ${manager.roomId}  •  ${manager.peers.length + 1} participante(s)'),
            actions: [
              IconButton(
                tooltip: _chatOpen ? 'Fechar chat' : 'Abrir chat',
                icon: Badge(
                  isLabelVisible: manager.unreadCount > 0,
                  label: Text('${manager.unreadCount}'),
                  child: Icon(_chatOpen ? Icons.chat_bubble : Icons.chat_bubble_outline),
                ),
                onPressed: _toggleChat,
              ),
              IconButton(
                tooltip: 'Sair da sala',
                icon: const Icon(Icons.call_end, color: Colors.redAccent),
                onPressed: () async {
                  await manager.leaveRoom();
                  if (context.mounted) Navigator.of(context).pop();
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 800;
              final chat = ChatPanel(manager: manager, onClose: _toggleChat);

              // Telas estreitas (celular): o chat ocupa a tela toda.
              if (_chatOpen && !wide) return chat;

              // Telas largas: chat como painel lateral ao lado das telas.
              if (_chatOpen && wide) {
                return Row(
                  children: [
                    Expanded(child: main),
                    SizedBox(width: 340, child: chat),
                  ],
                );
              }

              return main;
            },
          ),
        );
      },
    );
  }
}

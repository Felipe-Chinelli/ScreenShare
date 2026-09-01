import 'package:flutter/material.dart';
import '../services/room_manager.dart';
import '../widgets/participant_tile.dart';

class RoomScreen extends StatelessWidget {
  final RoomManager manager;

  const RoomScreen({super.key, required this.manager});

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

        return Scaffold(
          backgroundColor: const Color(0xFF121212),
          appBar: AppBar(
            title: Text('Sala: ${manager.roomId}  •  ${manager.peers.length + 1} participante(s)'),
            actions: [
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
          body: Padding(
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
          ),
          floatingActionButton: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton.extended(
                heroTag: 'mic',
                onPressed: manager.toggleMic,
                backgroundColor: manager.isSharingMic ? Colors.green : Colors.grey.shade800,
                icon: Icon(manager.isSharingMic ? Icons.mic : Icons.mic_off),
                label: Text(manager.isSharingMic ? 'Mic ligado' : 'Mic desligado'),
              ),
              const SizedBox(width: 12),
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
      },
    );
  }
}

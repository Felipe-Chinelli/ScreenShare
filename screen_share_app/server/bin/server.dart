import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_static/shelf_static.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Servidor local que faz duas coisas:
///  1) Serve os arquivos estáticos do app Flutter Web já compilado
///     (pasta build/web), para qualquer pessoa na VPN abrir no navegador.
///  2) Faz o "relay" de sinalização WebRTC (/ws): repassa join/offer/
///     answer/candidate entre os participantes de cada sala. Depois que
///     a conexão WebRTC é estabelecida, o vídeo/áudio vai direto de
///     peer para peer — o servidor não fica no meio do fluxo de mídia.
class _Client {
  final String id;
  final String name;
  final WebSocketChannel channel;
  _Client({required this.id, required this.name, required this.channel});
}

class RoomHub {
  final Map<String, Map<String, _Client>> _rooms = {};

  // Histórico de chat por sala (só em memória). Some quando a sala esvazia.
  final Map<String, List<Map<String, dynamic>>> _chatHistory = {};
  static const int _maxHistory = 100;
  static const int _maxChatLength = 2000;
  int _chatSeq = 0;

  void join(String room, String id, String name, WebSocketChannel channel) {
    final r = _rooms.putIfAbsent(room, () => {});

    final existing = r.values.map((c) => {'id': c.id, 'name': c.name}).toList();
    channel.sink.add(jsonEncode({'type': 'peers', 'peers': existing}));

    final history = _chatHistory[room];
    if (history != null && history.isNotEmpty) {
      channel.sink.add(jsonEncode({'type': 'chat-history', 'messages': history}));
    }

    for (final c in r.values) {
      c.channel.sink.add(jsonEncode({'type': 'peer-joined', 'id': id, 'name': name}));
    }

    r[id] = _Client(id: id, name: name, channel: channel);
  }

  /// Recebe uma mensagem de chat, carimba remetente/horário (o remetente é
  /// sempre o dono da conexão, nunca um id enviado pelo cliente) e envia
  /// para todos da sala, inclusive quem enviou.
  void chat(String room, String fromId, String text) {
    final r = _rooms[room];
    final sender = r?[fromId];
    if (r == null || sender == null) return;

    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    final clipped =
        trimmed.length > _maxChatLength ? trimmed.substring(0, _maxChatLength) : trimmed;

    final now = DateTime.now();
    final message = <String, dynamic>{
      'type': 'chat',
      'id': '${now.microsecondsSinceEpoch}-${_chatSeq++}',
      'from': fromId,
      'name': sender.name,
      'text': clipped,
      'ts': now.millisecondsSinceEpoch,
    };

    final history = _chatHistory.putIfAbsent(room, () => []);
    history.add(message);
    if (history.length > _maxHistory) history.removeAt(0);

    final encoded = jsonEncode(message);
    for (final c in r.values) {
      c.channel.sink.add(encoded);
    }
  }

  void relay(String room, String toId, Map<String, dynamic> msg) {
    _rooms[room]?[toId]?.channel.sink.add(jsonEncode(msg));
  }

  void leave(String room, String id) {
    final r = _rooms[room];
    if (r == null) return;
    r.remove(id);
    for (final c in r.values) {
      c.channel.sink.add(jsonEncode({'type': 'peer-left', 'id': id}));
    }
    if (r.isEmpty) {
      _rooms.remove(room);
      _chatHistory.remove(room);
    }
  }
}

final hub = RoomHub();

Future<void> main(List<String> args) async {
  final port = args.isNotEmpty ? int.tryParse(args[0]) ?? 8080 : 8080;

  final wsHandler = webSocketHandler((webSocket, protocol) {
    String? myRoom;
    String? myId;

    webSocket.stream.listen(
      (raw) {
        try {
          final msg = jsonDecode(raw as String) as Map<String, dynamic>;
          switch (msg['type']) {
            case 'join':
              myRoom = msg['room'] as String;
              myId = msg['id'] as String;
              hub.join(myRoom!, myId!, msg['name'] as String, webSocket);
              stdout.writeln('[+] "${msg['name']}" entrou na sala "$myRoom"');
              break;
            case 'chat':
              if (myRoom != null && myId != null) {
                hub.chat(myRoom!, myId!, (msg['text'] as String?) ?? '');
              }
              break;
            case 'offer':
            case 'answer':
            case 'candidate':
              final to = msg['to'] as String;
              if (myRoom != null) hub.relay(myRoom!, to, msg);
              break;
          }
        } catch (e) {
          stderr.writeln('Mensagem de sinalização inválida: $e');
        }
      },
      onDone: () {
        if (myRoom != null && myId != null) {
          hub.leave(myRoom!, myId!);
          stdout.writeln('[-] "$myId" saiu da sala "$myRoom"');
        }
      },
    );
  });

  final router = Router();
  router.get('/ws', wsHandler);

  final webBuildDir = _resolveWebBuildDir();
  if (webBuildDir.existsSync()) {
    router.mount('/', createStaticHandler(webBuildDir.path, defaultDocument: 'index.html'));
  } else {
    stdout.writeln(
      'Aviso: pasta "${webBuildDir.path}" não encontrada.\n'
      'Rode "flutter build web" na pasta do projeto antes de distribuir,\n'
      'ou use "flutter run -d web-server --web-hostname 0.0.0.0" durante o desenvolvimento\n'
      '(nesse caso este servidor só precisa cuidar da sinalização em /ws).',
    );
  }

  final server = await shelf_io.serve(
    router.call,
    InternetAddress.anyIPv4,
    port,
  );

  stdout.writeln('Servidor rodando na porta ${server.port}.');
  stdout.writeln('  Nesta máquina:      http://localhost:${server.port}');
  stdout.writeln('  Via Radmin VPN:     http://SEU_IP_RADMIN:${server.port}');
  stdout.writeln('  Sinalização WS em:  /ws');
}

/// Resolve .../screen_share_app/build/web a partir da localização deste
/// script (server/bin/server.dart), independente de onde o comando
/// "dart run" foi chamado.
Directory _resolveWebBuildDir() {
  final scriptFile = File(Platform.script.toFilePath());
  final binDir = scriptFile.parent; // .../server/bin
  final serverDir = binDir.parent; // .../server
  final projectDir = serverDir.parent; // .../screen_share_app
  return Directory('${projectDir.path}/build/web');
}

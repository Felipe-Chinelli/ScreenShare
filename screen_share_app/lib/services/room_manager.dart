import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:uuid/uuid.dart';

import '../models/peer.dart';
import 'signaling_service.dart';

/// Configuração de ICE. Como o uso é dentro de uma VPN local (Radmin),
/// candidatos "host" já bastam — não é preciso STUN/TURN externo.
/// Se um dia precisar atravessar redes mais complicadas, adicione aqui
/// um servidor STUN (ex: stun:stun.l.google.com:19302).
const Map<String, dynamic> _iceServersConfig = {
  'iceServers': <Map<String, dynamic>>[],
};

/// Orquestra: minha conexão de sinalização, minhas mídias locais
/// (tela + microfone) e uma conexão WebRTC (mesh, ponto-a-ponto)
/// com cada outro participante da sala.
class RoomManager extends ChangeNotifier {
  final SignalingService _signaling = SignalingService();
  final String myId = Uuid().v4();
  late String myName;
  late String roomId;

  final Map<String, Peer> peers = {};
  StreamSubscription? _sub;

  MediaStream? localScreenStream;
  MediaStream? localMicStream;
  bool get isSharingScreen => localScreenStream != null;
  bool get isSharingMic => localMicStream != null;

  String status = 'desconectado';

  Future<void> join({
    required String serverUrl,
    required String name,
    required String room,
  }) async {
    myName = name;
    roomId = room;
    status = 'conectando';
    notifyListeners();

    await _signaling.connect(serverUrl);
    _sub = _signaling.messages.listen(_handleSignal);

    _signaling.send({
      'type': 'join',
      'room': roomId,
      'id': myId,
      'name': myName,
    });
    status = 'conectado';
    notifyListeners();
  }

  Future<void> _handleSignal(Map<String, dynamic> msg) async {
    switch (msg['type']) {
      case 'peers':
        final list = (msg['peers'] as List).cast<Map<String, dynamic>>();
        for (final p in list) {
          await _createPeer(p['id'] as String, p['name'] as String, isInitiator: true);
        }
        break;

      case 'peer-joined':
        await _createPeer(msg['id'] as String, msg['name'] as String, isInitiator: false);
        break;

      case 'peer-left':
        await _removePeer(msg['id'] as String);
        break;

      case 'offer':
        await _onOffer(msg);
        break;

      case 'answer':
        await _onAnswer(msg);
        break;

      case 'candidate':
        await _onCandidate(msg);
        break;

      case 'disconnected':
        status = 'desconectado';
        notifyListeners();
        break;
    }
  }

  bool _politeTowards(String otherId) => myId.compareTo(otherId) > 0;

  Future<void> _createPeer(String id, String name, {required bool isInitiator}) async {
    if (peers.containsKey(id)) return;

    final connection = await createPeerConnection(_iceServersConfig);
    final peer = Peer(
      id: id,
      name: name,
      connection: connection,
      polite: _politeTowards(id),
    );
    peers[id] = peer;

    connection.onIceCandidate = (candidate) {
      if (candidate.candidate == null) return;
      _signaling.send({
        'type': 'candidate',
        'to': id,
        'from': myId,
        'candidate': {
          'candidate': candidate.candidate,
          'sdpMid': candidate.sdpMid,
          'sdpMLineIndex': candidate.sdpMLineIndex,
        },
      });
    };

    connection.onTrack = (event) {
      peer.remoteStream = event.streams.isNotEmpty ? event.streams[0] : peer.remoteStream;
      notifyListeners();
    };

    connection.onRenegotiationNeeded = () async {
      try {
        peer.makingOffer = true;
        final offer = await connection.createOffer();
        await connection.setLocalDescription(offer);
        _signaling.send({
          'type': 'offer',
          'to': id,
          'from': myId,
          'sdp': offer.sdp,
          'sdpType': offer.type,
        });
      } catch (_) {
        // ignora falhas pontuais de negociação
      } finally {
        peer.makingOffer = false;
      }
    };

    connection.onConnectionState = (state) {
      notifyListeners();
    };

    // Já entra com minhas mídias ativas (se eu já estiver compartilhando
    // algo quando esse peer chegou).
    if (localScreenStream != null) {
      for (final track in localScreenStream!.getTracks()) {
        await connection.addTrack(track, localScreenStream!);
      }
    }
    if (localMicStream != null) {
      for (final track in localMicStream!.getTracks()) {
        await connection.addTrack(track, localMicStream!);
      }
    }

    // Quem "descobre" o peer primeiro (via lista inicial de peers)
    // abre um canal vazio só para disparar a negociação e estabelecer
    // a conexão logo, mesmo que ninguém esteja compartilhando tela ainda.
    if (isInitiator) {
      await connection.createDataChannel('chat', RTCDataChannelInit());
    }

    notifyListeners();
  }

  Future<void> _removePeer(String id) async {
    final peer = peers.remove(id);
    if (peer != null) {
      await peer.connection.close();
    }
    notifyListeners();
  }

  Future<void> _onOffer(Map<String, dynamic> msg) async {
    final fromId = msg['from'] as String;
    if (!peers.containsKey(fromId)) {
      await _createPeer(fromId, msg['fromName'] as String? ?? 'Participante', isInitiator: false);
    }
    final peer = peers[fromId]!;
    final connection = peer.connection;

    final offerCollision = peer.makingOffer ||
        connection.signalingState != RTCSignalingState.RTCSignalingStateStable;

    peer.ignoreOffer = !peer.polite && offerCollision;
    if (peer.ignoreOffer) return;

    if (offerCollision && peer.polite) {
      await connection.setLocalDescription(RTCSessionDescription('', 'rollback'));
    }

    await connection.setRemoteDescription(RTCSessionDescription(msg['sdp'] as String, msg['sdpType'] as String));
    final answer = await connection.createAnswer();
    await connection.setLocalDescription(answer);

    _signaling.send({
      'type': 'answer',
      'to': fromId,
      'from': myId,
      'sdp': answer.sdp,
      'sdpType': answer.type,
    });
  }

  Future<void> _onAnswer(Map<String, dynamic> msg) async {
    final fromId = msg['from'] as String;
    final peer = peers[fromId];
    if (peer == null) return;
    await peer.connection.setRemoteDescription(
      RTCSessionDescription(msg['sdp'] as String, msg['sdpType'] as String),
    );
  }

  Future<void> _onCandidate(Map<String, dynamic> msg) async {
    final fromId = msg['from'] as String;
    final peer = peers[fromId];
    if (peer == null) return;
    final c = msg['candidate'] as Map<String, dynamic>;
    try {
      await peer.connection.addCandidate(RTCIceCandidate(
        c['candidate'] as String?,
        c['sdpMid'] as String?,
        c['sdpMLineIndex'] as int?,
      ));
    } catch (_) {
      if (!peer.ignoreOffer) rethrow;
    }
  }

  // ---------- Controle de mídia local ----------

  Future<void> toggleScreenShare() async {
    if (isSharingScreen) {
      await _stopScreenShare();
    } else {
      await _startScreenShare();
    }
  }

  Future<void> _startScreenShare() async {
    final stream = await navigator.mediaDevices.getDisplayMedia({
      'video': true,
      'audio': true, // áudio do sistema, se o navegador/SO permitir marcar a opção
    });
    localScreenStream = stream;

    for (final peer in peers.values) {
      for (final track in stream.getTracks()) {
        await peer.connection.addTrack(track, stream);
      }
    }

    // Se o usuário parar o compartilhamento pelo controle nativo do
    // navegador (em vez do botão do app), detectamos aqui.
    stream.getVideoTracks().first.onEnded = () {
      _stopScreenShare();
    };

    _signaling.send({'type': 'share-start', 'from': myId});
    notifyListeners();
  }

  Future<void> _stopScreenShare() async {
    final stream = localScreenStream;
    if (stream == null) return;

    for (final peer in peers.values) {
      final senders = await peer.connection.getSenders();
      for (final sender in senders) {
        if (sender.track != null && stream.getTracks().any((t) => t.id == sender.track!.id)) {
          await peer.connection.removeTrack(sender);
        }
      }
    }

    for (final track in stream.getTracks()) {
      await track.stop();
    }
    localScreenStream = null;

    _signaling.send({'type': 'share-stop', 'from': myId});
    notifyListeners();
  }

  Future<void> toggleMic() async {
    if (isSharingMic) {
      final stream = localMicStream!;
      for (final peer in peers.values) {
        final senders = await peer.connection.getSenders();
        for (final sender in senders) {
          if (sender.track != null && stream.getTracks().any((t) => t.id == sender.track!.id)) {
            await peer.connection.removeTrack(sender);
          }
        }
      }
      for (final track in stream.getTracks()) {
        await track.stop();
      }
      localMicStream = null;
    } else {
      final stream = await navigator.mediaDevices.getUserMedia({'audio': true, 'video': false});
      localMicStream = stream;
      for (final peer in peers.values) {
        for (final track in stream.getTracks()) {
          await peer.connection.addTrack(track, stream);
        }
      }
    }
    notifyListeners();
  }

  Future<void> leaveRoom() async {
    await _stopScreenShare();
    if (isSharingMic) await toggleMic();
    for (final peer in peers.values) {
      await peer.connection.close();
    }
    peers.clear();
    await _sub?.cancel();
    _signaling.disconnect();
    status = 'desconectado';
    notifyListeners();
  }

  @override
  void dispose() {
    leaveRoom();
    _signaling.dispose();
    super.dispose();
  }
}

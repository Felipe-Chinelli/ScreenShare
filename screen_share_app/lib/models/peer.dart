import 'package:flutter_webrtc/flutter_webrtc.dart';

/// Representa um participante remoto da sala: sua conexão WebRTC,
/// o stream de vídeo/áudio que ele está compartilhando (se houver)
/// e se somos nós ou ele quem deve ceder em caso de conflito de
/// negociação (padrão "perfect negotiation").
class Peer {
  final String id;
  final String name;
  final RTCPeerConnection connection;

  /// true = este lado é "cortês" (cede em caso de colisão de oferta/oferta)
  final bool polite;

  MediaStream? remoteStream;
  bool makingOffer = false;
  bool ignoreOffer = false;
  bool isSharing = false;

  Peer({
    required this.id,
    required this.name,
    required this.connection,
    required this.polite,
  });
}

/// Uma mensagem de texto trocada no chat da sala.
class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime time;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.time,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final ts = (json['ts'] as num?)?.toInt() ?? DateTime.now().millisecondsSinceEpoch;
    return ChatMessage(
      id: json['id'] as String? ?? '',
      senderId: json['from'] as String? ?? '',
      senderName: json['name'] as String? ?? 'Participante',
      text: json['text'] as String? ?? '',
      time: DateTime.fromMillisecondsSinceEpoch(ts),
    );
  }
}

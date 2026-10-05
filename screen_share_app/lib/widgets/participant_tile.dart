import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../utils/avatars.dart';

class ParticipantTile extends StatefulWidget {
  final String name;
  final MediaStream? stream;
  final bool isLocal;

  const ParticipantTile({
    super.key,
    required this.name,
    required this.stream,
    this.isLocal = false,
  });

  @override
  State<ParticipantTile> createState() => _ParticipantTileState();
}

class _ParticipantTileState extends State<ParticipantTile> {
  final _renderer = RTCVideoRenderer();
  bool _rendererReady = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _renderer.initialize();
    _renderer.srcObject = widget.stream;
    if (mounted) setState(() => _rendererReady = true);
  }

  @override
  void didUpdateWidget(covariant ParticipantTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stream != widget.stream) {
      _renderer.srcObject = widget.stream;
    }
  }

  @override
  void dispose() {
    _renderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasVideo = widget.stream != null && widget.stream!.getVideoTracks().isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          border: Border.all(color: Colors.white24),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (hasVideo && _rendererReady)
              RTCVideoView(
                _renderer,
                objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
                mirror: widget.isLocal,
              )
            else
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      avatarFor(widget.name),
                      height: 72,
                      filterQuality: FilterQuality.medium,
                    ),
                    const SizedBox(height: 8),
                    Text(widget.name, style: const TextStyle(color: Colors.white54)),
                  ],
                ),
              ),
            Positioned(
              left: 8,
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  widget.isLocal ? '${widget.name} (você)' : widget.name,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

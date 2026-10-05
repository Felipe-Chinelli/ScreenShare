import 'package:flutter/material.dart';
import '../services/room_manager.dart';
import 'loading_screen.dart';
import 'room_screen.dart';

class JoinScreen extends StatefulWidget {
  const JoinScreen({super.key});

  @override
  State<JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends State<JoinScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ipController = TextEditingController(text: '127.0.0.1');
  final _portController = TextEditingController(text: '8080');
  final _nameController = TextEditingController();
  final _roomController = TextEditingController(text: 'sala1');
  bool _connecting = false;
  String? _error;

  @override
  void dispose() {
    _ipController.dispose();
    _portController.dispose();
    _nameController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _connecting = true;
      _error = null;
    });

    final serverUrl = 'ws://${_ipController.text.trim()}:${_portController.text.trim()}/ws';
    final manager = RoomManager();

    // A conexão acontece dentro da tela de loading (GIF + nome do app).
    // Ela volta com null em caso de sucesso, ou com a mensagem de erro.
    final error = await Navigator.of(context).push<String?>(
      PageRouteBuilder<String?>(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, __, ___) => LoadingScreen(
          task: () => manager.join(
            serverUrl: serverUrl,
            name: _nameController.text.trim(),
            room: _roomController.text.trim(),
          ),
        ),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );

    if (!mounted) return;
    setState(() {
      _connecting = false;
      _error = error;
    });

    if (error == null) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => RoomScreen(manager: manager)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 96,
                    filterQuality: FilterQuality.medium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Compartilhamento de Tela',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const Text(
                    'Conecte-se via Radmin VPN',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: _ipController,
                          decoration: const InputDecoration(
                            labelText: 'IP do host (Radmin)',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => (v == null || v.isEmpty) ? 'Obrigatório' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          controller: _portController,
                          decoration: const InputDecoration(
                            labelText: 'Porta',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => (v == null || v.isEmpty) ? 'Obrigatório' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Seu nome',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => (v == null || v.isEmpty) ? 'Obrigatório' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _roomController,
                    decoration: const InputDecoration(
                      labelText: 'Nome da sala',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => (v == null || v.isEmpty) ? 'Obrigatório' : null,
                  ),
                  const SizedBox(height: 20),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(_error!, style: const TextStyle(color: Colors.red)),
                    ),
                  FilledButton.icon(
                    onPressed: _connecting ? null : _connect,
                    icon: _connecting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.login),
                    label: Text(_connecting ? 'Conectando...' : 'Entrar na sala'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

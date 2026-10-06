import 'dart:async';

import 'package:flutter/material.dart';

import '../utils/app_info.dart';

/// Tela de carregamento exibida entre "Entrar na sala" e a sala em si.
///
/// Executa [task] (a conexão com o servidor) enquanto mostra o GIF animado
/// e o nome do app. Ao terminar, fecha a si mesma devolvendo:
///  - `null`  -> deu certo;
///  - `String` -> mensagem de erro para a tela de entrada exibir.
class LoadingScreen extends StatefulWidget {
  final Future<void> Function() task;
  final String message;

  /// Tempo mínimo na tela, para a animação não "piscar" quando a conexão
  /// é instantânea (comum em localhost).
  final Duration minDuration;

  const LoadingScreen({
    super.key,
    required this.task,
    this.message = 'Entrando na sala...',
    this.minDuration = const Duration(milliseconds: 2200),
  });

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    String? error;
    try {
      await widget.task().timeout(
            const Duration(seconds: 12),
            onTimeout: () => throw TimeoutException('o servidor não respondeu'),
          );
      // Só espera o tempo mínimo se a conexão deu certo; em caso de erro
      // volta logo para a tela de entrada.
      await Future<void>.delayed(widget.minDuration);
    } catch (e) {
      error = 'Não foi possível conectar: $e';
    }
    if (!mounted) return;
    Navigator.of(context).pop(error);
  }

  @override
  Widget build(BuildContext context) {
    // Impede voltar com o botão/gesto de voltar durante a conexão.
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Image.asset(
                    'assets/images/gato_loading.gif',
                    gaplessPlayback: true,
                    filterQuality: FilterQuality.medium,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  appName,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.message,
                  style: const TextStyle(color: Colors.white54),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

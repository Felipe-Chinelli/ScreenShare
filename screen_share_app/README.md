# Compartilhamento de Tela (Flutter Web + Radmin VPN)

App multi-apresentador: qualquer pessoa na sala pode compartilhar tela + áudio
a qualquer momento. Feito 100% em Dart/Flutter — o app roda no navegador
(Flutter Web) e um pequeno servidor Dart local cuida só de apresentar os
participantes uns aos outros (sinalização WebRTC). Depois que a conexão é
estabelecida, o vídeo/áudio vai **direto de peer para peer**, sem passar
pelo servidor.

## Pré-requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) instalado (canal stable, com suporte web habilitado: `flutter config --enable-web`).
- [Radmin VPN](https://www.radmin-vpn.com/) instalado e todo mundo na mesma rede virtual.
- Google Chrome nas máquinas que forem **compartilhar tela** (é o navegador com melhor suporte a `getDisplayMedia` + WebRTC).

## 1. Instalar dependências

Na pasta do app:

```bash
cd screen_share_app
flutter pub get
```

Na pasta do servidor:

```bash
cd screen_share_app/server
dart pub get
```

## 2. Compilar o app para produção

Na raiz do projeto (`screen_share_app/`):

```bash
flutter build web
```

Isso gera a pasta `build/web` com os arquivos estáticos do app.

## 3. Rodar o servidor local

```bash
cd screen_share_app/server
dart run bin/server.dart 8080
```

Você verá algo como:

```
Servidor rodando na porta 8080.
  Nesta máquina:      http://localhost:8080
  Via Radmin VPN:     http://SEU_IP_RADMIN:8080
  Sinalização WS em:  /ws
```

Descubra seu IP do Radmin VPN abrindo o programa Radmin VPN — ele mostra o
IP (algo como `26.x.x.x`) da sua rede virtual.

## 4. Conectar os participantes

- **Você (host/máquina que roda o servidor):** abra `http://localhost:8080` no Chrome.
- **Demais participantes (na mesma rede Radmin):** abram `http://SEU_IP_RADMIN:8080` no Chrome.
- Todos preenchem: IP do host + porta (8080), nome e nome da sala (precisa ser igual para todos).

## ⚠️ Aviso importante sobre permissões do navegador

Navegadores só liberam captura de tela/microfone (`getDisplayMedia`/`getUserMedia`)
em "contextos seguros": `https://` ou `localhost`. Isso funciona sem configuração
nenhuma **para você, no host**, acessando por `localhost`. Mas os outros
participantes vão acessar por um IP puro (`http://26.x.x.x:8080`), que o Chrome
não considera seguro por padrão — eles conseguirão **ver** as telas
compartilhadas normalmente, mas para conseguirem **compartilhar a própria tela**
cada um precisa liberar essa exceção uma vez:

1. No Chrome, acesse: `chrome://flags/#unsafely-treat-insecure-origin-as-secure`
2. Cole a URL usada para acessar o app, por exemplo: `http://26.x.x.x:8080`
3. Habilite a flag e reinicie o Chrome.

Isso é uma configuração local do navegador de cada pessoa, não expõe nada
para fora da rede Radmin.

*(Alternativa mais robusta, se quiser evoluir o projeto depois: gerar um
certificado autoassinado e servir tudo em HTTPS a partir do próprio
`server/bin/server.dart`, eliminando a necessidade dessa flag.)*

## Como funciona (resumo técnico)

- **Cliente** (`lib/`): Flutter Web. `RoomManager` mantém uma `RTCPeerConnection`
  para cada outro participante (topologia *mesh*), usando o padrão
  *perfect negotiation* para evitar conflitos quando várias pessoas ligam/desligam
  compartilhamento ao mesmo tempo.
- **Servidor** (`server/`): Dart puro com `shelf`. Serve os arquivos estáticos
  de `build/web` e um endpoint WebSocket `/ws` que só repassa mensagens de
  sinalização (`join`, `offer`, `answer`, `candidate`) entre os participantes
  da mesma sala. Não processa nem retransmite vídeo/áudio.
- Como todos estão na mesma rede virtual do Radmin VPN, não é necessário
  servidor STUN/TURN externo — as conexões usam candidatos ICE locais direto.

## Estrutura do projeto

```
screen_share_app/
├── lib/                  # app Flutter (cliente)
│   ├── main.dart
│   ├── models/peer.dart
│   ├── services/
│   │   ├── signaling_service.dart   # conexão WebSocket
│   │   └── room_manager.dart        # WebRTC mesh + perfect negotiation
│   ├── screens/
│   │   ├── join_screen.dart
│   │   └── room_screen.dart
│   └── widgets/participant_tile.dart
├── web/                  # template web do Flutter
├── server/               # servidor de sinalização (Dart puro)
│   ├── pubspec.yaml
│   └── bin/server.dart
└── build/web/            # gerado por "flutter build web"
```

## Modo desenvolvimento (opcional)

Para iterar mais rápido sem recompilar toda hora, dá pra rodar o app em modo
dev com hot reload, expondo na rede:

```bash
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 5000
```

Nesse modo o próprio Flutter serve o app na porta 5000; o `server/bin/server.dart`
continua rodando só para a sinalização (`/ws` na porta 8080). Ajuste o IP/porta
digitados na tela inicial do app de acordo.

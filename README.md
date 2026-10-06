
# ScreanShare

<p align="center">
  <img width="3508" height="3508" alt="Image" src="https://github.com/user-attachments/assets/f53f962b-c229-4bd4-b9ba-6735aaf29b37" />
</p>

<p align="center">
  <strong>Transmissão de tela e áudio do sistema em tempo real (<50ms), resolução 1080p a 60 FPS e suporte a Multi-Streaming simultâneo sem cadastro obrigatório.</strong>
</p>

<p align="center">
  <a href="#-proposta-de-valor"><img src="https://img.shields.io/badge/Latência-%3C50ms%20WebRTC-emerald?style=flat-square" alt="Latência WebRTC" /></a>
  <a href="#-principais-funcionalidades"><img src="https://img.shields.io/badge/Resolução-1080p%2060FPS-blue?style=flat-square" alt="Resolução" /></a>
  <a href="#-arquitetura-e-stack-tecnológica"><img src="https://img.shields.io/badge/Stack-React%20%7C%20Flutter%20%7C%20Node-indigo?style=flat-square" alt="Stack" /></a>
  <a href="#-modelo-de-negócio"><img src="https://img.shields.io/badge/Licença-MIT%20%2F%20Freemium-purple?style=flat-square" alt="Licença" /></a>
</p>

- Gabriel Jorge Coutinho RM565441
- Bruna Marques e Queiroz RM565648
- Pedro Henrique Lisboa RM565722
- Felipe Rodrigues Ribeiro dos Santos RM565274
- Manoela Oliveira Bello RM563952                                           
- Miguel Lima da Silva  RM565141

---

## 📑 Tabela de Conteúdos
- [💡 Naming Rationale (Fundamentação do Nome)](#-naming-rationale-fundamentação-do-nome)
- [🎯 Proposta de Valor](#-proposta-de-valor)
- [⚡ Principais Funcionalidades](#-principais-funcionalidades)
- [🎙️ Tom de Voz da Marca](#️-tom-de-voz-da-marca)
- [🏆 Pitch de Mercado: Por Que o ScreenStream Existe?](#-pitch-de-mercado-por-que-o-screenstream-existe)
- [💼 Modelo de Negócio & Monetização](#-modelo-de-negócio--monetização)
- [🛡️ Diferenciais Competitivos](#️-diferenciais-competitivos)
- [🏗️ Arquitetura e Stack Tecnológica](#️-arquitetura-e-stack-tecnológica)
- [🚀 Como Executar o Projeto](#-como-executar-o-projeto)
  - [Web Client (React + Vite + Express)](#web-client-react--vite--express)
  - [Mobile & Desktop Client (Flutter)](#mobile--desktop-client-flutter)
- [📄 Resumo Executivo (Elevator Pitch)](#-resumo-executivo-elevator-pitch)

---

## 💡 Naming Rationale (Fundamentação do Nome)

### **ScreenShare**
*(Subprodutos: ScreenShare Core, ScreenShare Pro, ScreenShare Enterprise)*

1. **Zero Cognitive Load (Carga Cognitiva Nula)**: A união literal de *Screen* (Tela) e *Share* (Compartilhar) comunica a funcionalidade do produto de imediato para qualquer usuário no mundo, eliminando a necessidade de campanhas de reeducação de marca.
2. **Semântica de Velocidade e Praticiadade**: O termo *Share* evoca continuidade sem engasgos, reforçando a promessa técnica central: **latência sub-50ms e 60 FPS**.
3. **Versatilidade Dual-Market**: Ao contrário de nomes focados unicamente em jogos ou burocráticos demais, o **ScreenShare** soa natural tanto para gamers jogando em conjunto quanto para equipes de engenharia e design em sessões de *code review* e *design critique*.

---

## 🎯 Proposta de Valor

> **"Democratizar o compartilhamento de tela e áudio do sistema com latência zero (<50ms), resolução nativa 1080p 60 FPS e capacidade multi-stream simultânea, sem exigir cadastros, sem compressão destrutiva de som e sem custos abusivos de planos pagos, e principalmente dentro da lei ."**

### Matriz Comparativa de Dores vs. Solução:

| Dor do Mercado | O Que as Ferramentas Tradicionais Fazem | Como o ScreenStream Resolve |
| :--- | :--- | :--- |
| **Delay Alto de Transmissão** | Twitch e YouTube introduzem de 4 a 15 segundos de buffer. | Conexões diretas P2P WebRTC com latência inferior a **50ms**. |
| **Paredes Pagas em Resolução** | Discord bloqueia 1080p 60 FPS atrás do Nitro ($9.99/mês), limitando o plano grátis a 720p 30 FPS. | Entrega **1080p 60 FPS nativo** gratuitamente e sem limites. |
| **Áudio de Jogos/Músicas Cortado** | Zoom e Google Meet usam cancelamento de ruído agressivo que muta músicas e jogos. | Mixer de áudio dedicado que transmite o **som do sistema em estéreo puro** junto ao microfone. |
| **Uma Única Transmissão por Vez** | Plataformas tradicionais não permitem que vários usuários apresentem juntos. | **Multi-Stream Nativo**: Vários participantes transmitem ao mesmo tempo com modo **Mosaico (Grid)**. |
| **Atrito de Instalação e Cadastro** | Exigem download de instaladores de 200MB e criação de login/senha antes de entrar. | **Zero-Friction**: Basta abrir um link no navegador ou app leve para assistir instantaneamente. |
| **Totalmente Legal** | Autoridade Nacional de Proteção de Dados barrou o compartilhamento de leta por falta de verificação dos usuarias. | **100% de outonomia**: Aqui o Hoste da sala está totalmente no controle permitindo somente quem ele quiser entre na sala. |

---

## ⚡ Principais Funcionalidades

- 🎛️ **Multi-Streaming Simultâneo (Multi-Cast P2P)**: Múltiplos apresentadores compartilham a tela na mesma sala; espectadores escolhem a tela ou assistem em modo **Mosaico (Grid)** adaptativo.
- 📐 **Motor de Correção de Proporção (16:9 / 1080p)**: Corrige resoluções assimétricas geradas por janelas cortadas (ex: 1907x1080) com 4 modos de exibição: *16:9 Nativo*, *Ajustar à Tela (Contain)*, *Esticar (Fill)* e *Zoom/Preencher (Cover)*.
- 🔊 **Mixer de Áudio em Tempo Real**: Captura independente do som interno do computador (jogos, vídeos) e do microfone, com controle de volume individual por apresentador.
- 📱 **Ecossistema Multiplataforma**: Cliente Web SPA instantâneo (React + Vite) e aplicativo nativo multiplataforma (Flutter para Android, iOS, Windows, macOS e Linux) com suporte a Picture-in-Picture (PiP).
- 💬 **Chat em Tempo Real**: Mensagens instantâneas via WebSockets, lista de participantes e status de áudio/voz.
- 📊 **Telemetria e Diagnóstico WebRTC**: Painel com monitoramento em tempo real de RTT (Ping), FPS, Bitrate (kbps) e perda de pacotes.

---

## 🎙️ Tom de Voz da Marca

- **Ultra-Direto e Sem Rodeios (No-Nonsense)**: Sem barreiras promocionais ou menus confusos. Em vez de *"Descubra a revolução do streaming"*, dizemos: *"Transmitir Minha Tela (1080p 60FPS)"*.
- **Focado em Performance e Precisão Técnica**: Comunicação segura sobre codecs (VP8/VP9/H.264), taxas de quadros e latência, transmitindo autoridade para desenvolvedores e jogadores.
- **Acessível e Acolhedor**: Qualquer pessoa que apenas queira assistir à partida do amigo consegue entrar com um clique sem ler tutoriais.
- **Transparente**: Métricas reais de rede expostas na interface, sem falsas promessas de qualidade inatingível.

---

## 🏆 Pitch de Mercado: Por Que o ScreenShare Existe?

### 🔴 O Cenário Atual
1. **Streaming Massivo (Twitch / YouTube Gaming)**: Feito para 1 pessoa transmitindo para milhares. O atraso de 5 a 15 segundos impede bate-papos imediatos ou partidas cooperativas entre amigos.
2. **Reuniões Corporativas (Zoom / Google Meet)**: Feitos para chamadas de voz de escritório. Tratam sons de jogos, vídeos e músicas como ruído indesejado, destruindo a fidelidade sonora e travando a tela em 15–30 FPS.
3. **Comunicação Gamer (Discord)**: Cobra assinatura cara para liberar 1080p a 60 FPS e exige instalação de software pesado e cadastro obrigatório de todos os membros.

### 🟢 A Resposta ScreenShare
O **ScreenShare** ocupa a interseção perfeita: entrega **qualidade de estúdio (1080p 60FPS)**, **áudio estéreo sem filtros** e **latência de LAN local (<50ms)** diretamente pelo navegador ou aplicativo leve, sem cadastros e sem custos abusivos.

---

## 💼 Modelo de Negócio & Monetização

```
                              ┌───────────────────────────┐
                              │   SCREENSTREAM ECOSYSTEM  │
                              └─────────────┬─────────────┘
                                            │
     ┌──────────────────────────────┬───────┴───────────────────────┬─────────────────────────────┐
     ▼                              ▼                               ▼                             ▼
┌──────────────────┐      ┌───────────────────┐          ┌─────────────────────┐        ┌─────────────────────┐
│  Plano Free P2P  │      │  ScreenStream PRO │          │  B2B Teams / Studio │        │    SDK / API Dev    │
│  (100% Gratuito) │      │ (R$ 19,90 / mês)  │          │ (R$ 49/usuário/mês) │        │ ($0.002 / min TURN) │
└──────────────────┘      └───────────────────┘          └─────────────────────┘        └─────────────────────┘
```

### 1. Plano Comunitário Gratuito (P2P Mesh - B2C)
- Resolução de até 1080p a 60 FPS.
- Até 6 participantes por sala com multi-streaming simultâneo.
- Custo de infraestrutura para o negócio próximo de zero (transmissão direta entre nós).

### 2. Plano ScreenStream Pro / Creator (R$ 19,90/mês ou $4.99/mês)
- **Servidores TURN Globais Dedicados**: Garante conexão mesmo atrás de firewalls corporativos restritos, redes 4G/5G com CGNAT ou Wi-Fi universitário.
- Salas para até 30 espectadores simultâneos.
- **Gravação na Nuvem (Cloud Recording)** direto em MP4 HD.
- Links de sala personalizados e permanentes (ex: `screenstream.live/meucanal`).

### 3. Plano B2B Enterprise / Creative Studios (R$ 49,00 a R$ 99,00/usuário/mês)
- Autenticação corporativa via **Single Sign-On (SSO / SAML)**.
- Opção de deploy **On-Premise / Self-Hosted** (o tráfego de vídeo não sai da rede privada da empresa).
- Auditoria de sessões e conformidade total LGPD/GDPR.

---

## 🛡️ Diferenciais Competitivos

1. **Custo Marginal Zero (Zero Marginal Cost)**: Ao utilizar malha P2P para o tráfego de vídeo, a plataforma escala para milhares de usuários sem contas astronômicas de servidores de mídia.
2. **Áudio Não-Comprimido em Estéreo**: Única solução gratuita com mixer dedicado de áudio de sistema e microfone separado de canceladores de ruído destrutivos.
3. **Multi-Stream em Mosaico Nativo**: Transmissão simultânea de múltiplos usuários sem dependência de planos pagos.

---

## 🏗️ Arquitetura e Stack Tecnológica

- **Frontend Web**: React 18, TypeScript, Tailwind CSS, Lucide Icons, Web Audio API.
- **Mobile / Desktop**: Flutter (Dart), `flutter_webrtc`, `provider`, `web_socket_channel`.
- **Backend de Sinalização**: Node.js, Express, WebSockets (`ws`), `tsx`, `esbuild`.
- **Protocolo de Mídia**: WebRTC P2P (Unified-Plan SDP), STUN/TURN, ICE Candidates.

---

# Figma

## 🎯 Telas 

### Tela 1
<div align ="center">
<img width="1039" height="581" alt="Image" src="https://github.com/user-attachments/assets/743eadbb-a4fe-4ea9-a8ce-0e0a2f588bd9" />
</div>

### Tela 2
<div align="center">
<img width="649" height="367" alt="Image" src="https://github.com/user-attachments/assets/28429c19-516a-48ce-9e2b-b1d9c936d39b" />
</div>

### Tela 3
<div align ="center">
<img width="646" height="359" alt="Image" src="https://github.com/user-attachments/assets/6f385913-e980-44bb-9306-c50f2f8dfe1d" />
</div>

### Tela 4
<div align ="center">
<img width="649" height="364" alt="Image" src="https://github.com/user-attachments/assets/a627a9b6-d876-48ac-995a-72ebe6800158" />
</div>

## Icons, fontes e cores

## Icons
<div align="center">
<img width="311" height="543" alt="Image" src="https://github.com/user-attachments/assets/0f83d7b9-72b2-4b17-a96d-57c00bdcc231" />
</div>

## Fontes 
<div align="center">
<img width="486" height="360" alt="Image" src="https://github.com/user-attachments/assets/226e075d-4ffe-43f3-9109-4a7f4e8b76ee" />
</div>

## Cores 
<div align="center">
<img width="1289" height="772" alt="Image" src="https://github.com/user-attachments/assets/a08c8a56-3509-4489-9253-9faf5b130bbf" />
</div>

## Links

### Link Figma Prototipo
- https://www.figma.com/proto/NbDta0fGI5vcVZpujemIHC/Sem-t%C3%ADtulo?node-id=1-1682&t=uuFx7jhHPtYVEs4o-1

### Link Figma Projeto
- https://www.figma.com/design/NbDta0fGI5vcVZpujemIHC/Sem-t%C3%ADtulo?node-id=1-1681&t=uuFx7jhHPtYVEs4o-1

---

## 🚀 Como Executar o Projeto

### Web Client Flutter

1. Clone o repositório e instale as dependências na root do projeto:
   ```bash
   flutter pub get
   ```
2. Inicie o servidor de desenvolvimento na pasta server:
   ```bash
   cd server && dart pub get
   ```
3. Volte a pasta sreen_share_app e de bild no projeto:
   ```bash
   flutter build web
   ```
4. Inicie o servidor de desenvolvimento na pasta server:
   ```bash
   dart run bin/server.dart 8080
   ```
   
3. Acesse `http://localhost:8080` no seu navegador.

---

## 📄 Resumo Executivo (Elevator Pitch)

> *"O Discord cobra caro por 1080p a 60 FPS. A Twitch tem 10 segundos de atraso. O Zoom e o Meet destroem o áudio de jogos e vídeos.*
> 
> *O **ScreenStream** é a resposta definitiva: uma plataforma leve e multiplataforma onde qualquer pessoa clica em um link e transmite sua tela e som do sistema com **latência zero (<50ms), 60 FPS reais e multi-transmissão simultânea em mosaico**, sem login obrigatório e sem custos ocultos."*

---

<p align="center">
  Desenvolvido com foco em alta performance, zero atrito e fidelidade de áudio/vídeo.
</p>

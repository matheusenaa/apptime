# App Time Vasco

Aplicativo mobile do **Club de Regatas Vasco da Gama** para torcedores,
reescrito em **Flutter** com Material 3, arquitetura limpa e dados reais de
futebol. Acompanha jogos, classificação, elenco e o histórico do Gigante da
Colina.

> **Nota:** este repositório substituiu a base original em **Flet/Python**
> por uma implementação Flutter (iOS/Android/Web-PWA). O código legado foi
> preservado em [`legacy_python/`](legacy_python/) e num backup Git
> (`tag original-flet-8beea6e`).

## Funcionalidades

| Aba | Descrição |
| --- | --- |
| Início | Destaque do próximo jogo / jogo ao vivo + acesso rápido a Histórico e Notícias |
| Jogos | Seção **AO VIVO** (atualização a cada 30s) e próximos jogos do Vasco |
| Tabela | Classificação do **Brasileirão Série A** (dados reais) |
| Elenco | Atletas do profissional carregados da API |
| Mais | Notícias/Fatos, Configurações (tema + chave da API) e Sobre |

Dados de futebol: **API-Football** (api-sports.io) — Brasileirão Série A,
Copa do Brasil e placar ao vivo. Histórico do clube: dados verificados
(Brasileirão 1974–2025 + Copa do Brasil).

## Como configurar a chave da API

1. Crie uma conta gratuita em [api-football.com](https://www.api-football.com)
   (plano **Free**, 100 requisições/dia — suficiente para este app).
2. Copie sua **API Key** do painel.
3. Faça o build informando a chave (recomendado para release):

   ```bash
   flutter build web --dart-define=APIFOOTBALL_KEY=SUA_CHAVE_AQUI
   ```

   Ou, em desenvolvimento, edite o arquivo `.env` (modelo em
   `.env.exemplo`) e rode `flutter run`.

4. **Sem chave**, o app entra em **Modo Demonstração** (dados históricos e
   institucionais, sem placares falsos).

> **Segurança:** a chave fica em `.env` ou `--dart-define`, ambos fora do Git.
> Nunca envie a chave para o repositório.

## Requisitos

- Flutter 3.32+ / Dart 3.12+ (desenvolvido com Flutter 3.44.8)
- Para Android: Android SDK
- Para iOS: macOS + Xcode (build do IPA)

## Como executar

```bash
flutter pub get
flutter run                 # dispositivo/emulador conectado
flutter run -d chrome       # ou web (desenvolvimento)
```

## Build (PWA — testável no iPhone)

```bash
flutter build web
```

O diretório `build/web` é um PWA instalável (service worker + offline do
app shell). Para servir na sua rede e abrir no iPhone:

```bash
cd build/web
python -m http.server 8080 --bind 0.0.0.0
```

Acesse de outro dispositivo em `http://IP_DA_MAQUINA:8080`. No iPhone, toque
em **Compartilhar → Adicionar à Tela de Início** para instalar como app.

### Android

```bash
flutter build apk --release          # requer Android SDK
```

### iOS

```bash
flutter build ipa                     # necessário macOS + Xcode
```

## Testes

```bash
flutter test
```

A suíte cobre parsing dos modelos (jogos ao vivo/agendado, classificação),
integridade dos dados históricos e um smoke test da interface em modo
demonstração (zero rede).

## Estrutura

```
lib/
├── main.dart                 # Bootstrap (dotenv, tema, provider)
├── core/                     # constantes, tema, rede, formatação
├── data/                     # histórico verificado + fatos do clube
├── models/                   # Match, Standing, Player, NewsItem
├── services/
│   ├── api/                  # interface + API-Football + demo
│   └── storage/              # preferências e cache local
├── repositories/             # orquestração: API → cache → demo
├── state/                    # AppState (ChangeNotifier) + polling
├── screens/                  # Início, Jogos, Tabela, Elenco, Mais, ...
└── widgets/                  # cartões, banners, tabela, esqueletos

legacy_python/                # código Flet original (referência)
```

## Fontes dos dados históricos

Todos os números em `lib/data/historical_data.dart` vêm de tabelas oficiais
de cada edição (Wikipédia — classificação final —, CBF e site oficial).
Campos sem fonte são exibidos como *"Não disponível"*. Nada foi inventado. A
temporada 2026 está em andamento e não entra no histórico.

## Licença

Uso livre para fins de torcida e aprendizado. Dados de terceiros pertencem às
suas respectivas fontes.

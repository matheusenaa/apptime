# Relatório Técnico — Migração para Flutter + API-Football

**Projeto:** App Time Vasco (Vasco Hub 2026)
**Data:** 03/09/2026
**Repositório:** `https://github.com/matheusenaa/apptime` (branch `master`)

---

## 1. Contexto e decisão

O aplicativo original foi construído em **Flet/Python** e apresentava um
defeito crítico no iPhone: **"Unknown control: Audio"**, causado pelo
`flet_audio` usado na aba *Cantos*. A correção isolada era frágil e mantinha
as demais limitações (placares simulados, scraping de notícias e ausência de
dados reais de jogos).

Após análise, foi **confirmada a decisão de migrar o app para Flutter**,
aproveitando o mesmo SDK já usado internamente pelo Flet, e de integrar a
**API-Football** para fornecer dados reais de futebol brasileiro
(Brasileirão Série A + Copa do Brasil + placar ao vivo).

**Objetivo:** app mobile profissional em Flutter (iOS/Android/PWA), com
arquitetura limpa, dados reais, modo offline e modo demonstração seguro.

---

## 2. Diagnóstico do ambiente (na data da migração)

| Item | Status |
| --- | --- |
| Flutter | `3.44.8` disponível em `C:\Users\mmath\flutter\3.44.8` |
| Dart | `3.12.2` |
| Android SDK | **Não instalado** → sem APK nativo local |
| Visual Studio | Não instalado → sem desktop Windows nativo |
| macOS/Xcode | Não disponível → sem IPA iOS local |
| Buildável nesta máquina | **Web/PWA** (Chrome/Edge) e Windows (sem VS) |

Por isso, o app foi construído e validado com **build Web/PWA** (testável no
iPhone) e a estrutura Android/iOS foi **gerada e documentada** para build
futuro (instalando Android SDK ou usando um Mac).

---

## 3. Backup e preservação do projeto original

Para garantir a regra de **não destruir o original**:

1. **Cópia física** do estado original (commit `8beea6e`) em:
   `C:\Users\mmath\AppData\Local\Temp\opencode\App_Time_Vasco_original`
2. **Tag Git** de backup imutável: `original-flet-8beea6e`
3. Código Flet preservado no repositório em **`legacy_python/central_vasco/`**
   (inclui `historico.py` com os dados históricos verificados).

---

## 4. Arquitetura do novo app Flutter

Camadas e fluxo de dados (conforme diretriz *ApiService → FootballRepository →
GameState → UI*):

```
lib/
├── core/
│   ├── constants/app_constants.dart   # identidade Vasco, cores, intervalos
│   ├── theme/app_theme.dart           # Material 3 claro/escuro
│   ├── network/api_config.dart        # chave (--dart-define ou .env)
│   └── utils/formatters.dart          # datas/horas
├── data/
│   ├── historical_data.dart           # Brasileirão 1974–2025 + Copa do Brasil
│   └── club_facts.dart                # fatos verificados (tela Notícias)
├── models/                            # Match, Standing, Player, NewsItem
├── services/
│   ├── api/football_api.dart          # interface (contrato)
│   ├── api/api_football_service.dart  # implementação real (API-Football)
│   ├── api/demo_service.dart          # modo demonstração (sem dados falsos)
│   └── storage/preferences_service.dart# cache local + preferências
├── repositories/vasco_repository.dart # orquestração: API → cache → demo
├── state/app_state.dart               # ChangeNotifier + polling inteligente
├── screens/                           # Início, Jogos, Tabela, Elenco, Mais...
└── widgets/                           # cartões, banners, tabela, esqueletos
```

**Decisões-chave:**

- **Interface `FootballApi`** desacopla a UI da fonte de dados; permite
  trocar entre API real, demonstração e cache sem tocar nas telas.
- **`VascoRepository`** aplica o fluxo: tenta API (se houver chave) → sucesso
  grava no cache local → falha de rede devolve o cache sinalizado `fromCache`.
- **`AppState` (ChangeNotifier)** expõe os dados observáveis e o modo de
  tema; as telas consomem via `provider`.
- **Polling inteligente:** a cada 30s quando há **jogo ao vivo**; a cada 5
  minutos fora de jogo (economiza a cota diária de 100 requisições).
- **Chave da API segura:** via `--dart-define=APIFOOTBALL_KEY=...` (release)
  ou arquivo `.env` (desenvolvimento). Ambos fora do Git. Sem chave → modo
  demonstração.

---

## 5. Integração de dados (API-Football)

A chave é lida de `--dart-define` ou `.env`. Endpoints usados (plano Free):

- `fixtures?team=129&next=10` — próximos jogos do Vasco (id estável 129)
- `fixtures?team=129&last=10` — últimos/ao vivo
- `standings?league=71&season=<ano>` — Brasileirão Série A (liga 71)
- `players/squads?team=129` — elenco profissional

**Modo demonstração:** sem chave, o app **não fabrica placares nem
classificações falsas**. Exibe um banner claro *"MODO DEMONSTRAÇÃO"* e informa
como configurar a chave — apenas os dados históricos e institucionais reais
permanecem visíveis.

**Offline:** via `SharedPreferences` (cache local). Ao falhar a rede, o app
mostra "Sem conexão. Exibindo as informações atualizadas pela última vez."

---

## 6. Tratamento do problema original (áudio no iPhone)

O `flet_audio` (origem do erro *"Unknown control: Audio"* no iPhone) **não
existe no Flutter**. A funcionalidade de áudio da antiga aba *Cantos* foi
**reprojetada e removida** do novo app: as abas foram reorganizadas e a tela
de Notícias passou a exibir *fatos verificados do clube* (com fonte), em vez
de depender de áudio local. Assim, o problema não tem como se repetir no
Flutter, qualquer que seja a plataforma (iOS/Android/Web).

---

## 7. Integridade do histórico (nada inventado)

Os dados de `lib/data/historical_data.dart` foram **portados fielmente** do
`historico.py` original (também preservado em `legacy_python/`). Conferem com
as tabelas oficiais (Wikipédia/CBF):

- **Brasileirão Série A:** 4 títulos (1974, 1989, 1997, 2000), vice em 2011,
  rebaixamentos em 2008, 2013, 2015 e 2020; temporadas 1974–2025 verificadas.
- **Copa do Brasil:** campeão 2011 (final vs Coritiba), vices 2006 (Flamengo)
  e 2025 (Corinthians).
- Campos sem fonte → **"Não disponível"**. A temporada 2026 segue em
  andamento e **não** é inventada no histórico.

A suíte de testes inclui verificação específica de que **não existe
temporada 2026 inventada** na base.

---

## 8. Testes e validação

```
flutter analyze   → No issues found
flutter test      → 9/9 testes passam
flutter build web → Build OK (PWA instalável)
```

Cobertura dos testes:

- **Parsing de modelos** — jogo agendado, jogo ao vivo (placar, minuto,
  detecção de "casa/fora" do Vasco) e classificação.
- **Integridade dos dados históricos** — títulos, contagem de temporadas,
  ausência de temporada 2026 não verificada, sumarização (jogos/vitórias/
  empates/derrotas/aproveitamento).
- **Smoke test da interface** — carrega em modo demonstração sem erros
  (zero rede, `SharedPreferences` mockado).

---

## 9. Como testar no iPhone (PWA)

Como não há macOS/Xcode nesta máquina, a validação mobile no iPhone é feita
via **PWA**:

1. `flutter build web`
2. `cd build/web && python -m http.server 8080 --bind 0.0.0.0`
3. No iPhone (mesma rede): acessar `http://IP_DA_MAQUINA:8080`
4. **Compartilhar → Adicionar à Tela de Início** para instalar como app.

### Para gerar apps nativos

- **Android:** instalar Android SDK → `flutter build apk --release`
- **iOS (IPA/TestFlight):** exigido macOS + Xcode + conta de desenvolvedor →
  `flutter build ipa`

---

## 10. Segurança

- **Nenhuma chave/segredo é commitado:** `.env` está no `.gitignore`; a chave
  entra por `--dart-define` ou `.env`.
- `.env.exemplo` (sem segredo) é commitado como modelo seguro.
- A chave nunca aparece em logs.
- Observação (web/PWA): em build web, qualquer chave embutida é visível no
  cliente (limitação inerente a apps client-side); para produção com dados
  sensíveis, recomenda-se um proxy/backend ou app nativo.

---

## 11. Versionamento e Git

- Tag de backup: `original-flet-8beea6e`
- Código legado: `legacy_python/`
- Migração será registrada em novo commit para `origin/master`
  (`https://github.com/matheusenaa/apptime`).

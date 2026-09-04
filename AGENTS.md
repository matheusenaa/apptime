# AGENTS.md

Guia para agentes trabalhando neste repositório (App Time Vasco em Flutter).

## Ferramentas

- Flutter/Dart **não estão no PATH global** por padrão em todas as máquinas.
  Nesta máquina (`matheus.silva`), o SDK está em:
  `C:\Users\matheus.silva\flutter\3.44.8\bin` (adicionado ao PATH do usuário).

  Para usar em qualquer máquina, localize o SDK ou use o caminho completo:

  ```bash
  C:\Users\matheus.silva\flutter\3.44.8\bin\flutter.bat
  ```

- Nesta máquina **não há Android SDK nem macOS/Xcode** → só é possível
  compilar para **Web/PWA** (`flutter build web`). Não tente
  `flutter build apk`/`ipa` aqui.

## Comandos padrão

```bash
# Análise estática (lint) — sempre rodar após alterações
flutter analyze

# Testes — sempre rodar após alterações
flutter test

# Build PWA (testável no iPhone via endereço local)
flutter build web

# Executar em desenvolvimento (web)
flutter run -d chrome
```

## Estrutura do projeto

- `lib/` → código Flutter (arquitetura limpa: `core/`, `data/`, `models/`,
  `services/`, `repositories/`, `state/`, `screens/`, `widgets/`).
- `legacy_python/central_vasco/` → código Flet/Python original (referência;
  não modificar sem necessidade).
- `.env` / `--dart-define=APIFOOTBALL_KEY=...` → chave da API-Football
  (**nunca commitar chave**; `.env` está no `.gitignore`).

## Regras de dados

- **Nunca inventar placares, resultados ou classificações.**
- Dados históricos vêm de fontes verificadas (Wikipédia/CBF) e residem em
  `lib/data/historical_data.dart`. Temporada em andamento não entra.
- Sem chave de API → modo demonstração (nunca simular dados reais como se
  fossem verdadeiros).

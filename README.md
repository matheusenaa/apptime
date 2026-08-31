# Vasco Hub 2026

App da torcida vascaína construído com **Flet** (Python). Reúne notícias,
placar ao vivo (match day), cantos da torcida, elenco e **estatísticas
históricas** com dados reais e verificados.

## Funcionalidades

| Aba | Descrição |
| --- | --- |
| Notícias | Feed com as principais notícias do Vasco (online com cache SQLite offline) |
| MatchDay | Card da próxima partida + dados ao vivo do jogo (placar, estatísticas, escalação e lances) |
| Cantos | Playlist de cantos da bancada com reprodução de áudio (flet_audio) |
| História | Estatísticas históricas do Brasileirão e da Copa do Brasil, com temporadas verificadas |
| Mais | Elenco oficial e modo de economia de bateria (tema AMOLED) |

## Requisitos

- Python 3.10+
- Flet `~=0.86.5` (compatibilidade verificada com a versão 0.86.5)
- flet-audio `~=0.86.5`

## Como executar

```bash
python -m venv .venv
.\.venv\Scripts\activate        # Windows
pip install -r requirements.txt

python central_vasco\main.py    # abre na janela do desktop
```

Para rodar em modo web (preview no navegador):

```bash
flet run central_vasco\main.py --web --port 8550
```

## Testes

A suíte usa um harness próprio (`central_vasco/testes.py`) com um `Page`
simulado — não depende do `flet.testing` nem abre janelas, e realiza **zero
requisições de rede**:

```bash
python central_vasco\testes.py
```

Os testes cobrem integridade dos dados históricos (V+E+D = total de jogos,
aproveitamento dentro de 0–100%, resumos consistentes) e um smoke test da
interface (carregamento, troca entre as 5 abas e alternância de campeonato).

## Estrutura

```
central_vasco/
├── main.py        # App Flet: navegação e montagem das abas
├── theme.py       # Identidade visual (preto/branco Vasco) e widgets
├── historico.py   # Estatísticas históricas verificadas
├── banco_dados.py # Cache híbrido notícias: internet + SQLite offline
├── match_day.py   # Motor de dados ao vivo da partida
├── scraping.py    # Coleta de notícias/cantos/elenco com fallback
└── testes.py      # Suíte de testes (Page simulado)
```

## Fontes dos dados históricos

Todos os números em `historico.py` vêm de tabelas oficiais de cada edição
(Wikipédia — tabela de classificação final —, CBF e site oficial). Campos sem
fonte confiável são exibidos como *"Não disponível"*. Nenhum dado foi
inventado. A temporada 2026 está em andamento e não entra no histórico.

## Build para iPhone 12 Pro (iOS)

O alvo iOS é o iPhone 12 Pro (arm64). O build do IPA precisa de **macOS com
Xcode** e de uma conta de desenvolvedor Apple:

1. Preencha `[tool.flet.ios]` em `pyproject.toml` (Apple `team_id`,
   provisioning profile e certificado de assinatura).
2. No macOS, dentro da pasta do projeto:

   ```bash
   flet build ipa
   ```

3. Instale o IPA via Xcode/Apple Configurator no iPhone 12 Pro.

Os recursos usados pelo app (NavigationBar com 5 abas, GridView, áudio,
cache local) são suportados pelo iOS no Flet 0.86.5.

## Licença

Uso livre para fins de torcida e aprendizado. Dados de terceiros pertencem às
suas respectivas fontes.
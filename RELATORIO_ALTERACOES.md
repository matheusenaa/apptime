# RELATÓRIO DE ALTERAÇÕES — Vasco Hub 2026

Data: agosto de 2026.
Escopo: revisão completa do aplicativo Flet, correção de bugs de
compatibilidade, nova identidade visual, nova funcionalidade de estatísticas
históricas, testes automatizados e publicação no GitHub.

---

## 1. Resumo

O projeto `apptime` foi revisado de ponta a ponta. O aplicativo ganhou uma
**quinta aba (História & Estatísticas)** com dados **reais e verificados** do
Vasco, recebeu a **identidade visual preto e branco** do clube, teve
corrigidos **seis bugs de compatibilidade** com o Flet 0.86.5 que quebravam o
app (alguns com `AttributeError`/`TypeError` em tempo de execução) e passou a
contar com uma **suíte de 12 testes** executável sem rede e sem janela. O
código foi publicado no GitHub.

## 2. Problemas encontrados

1. **`colors.BLUE_GREY_950` não existe** no Flet 0.86.5 → `AttributeError`
   ao abrir a aba MatchDay.
2. **`ft.icons.*` (minúsculo) não funciona** no Flet 0.86.5; apenas
   `ft.Icons.*` (que retorna os códigos numéricos dos ícones). Ícones usados
   como `SYNC`, `PLAY_ARROW_ROUNDED`, `STOP_CIRCLE` etc. falhavam com
   `AttributeError`.
3. **`ft.border.all(...)` não existe** → deve ser `ft.Border.all(...)`.
4. **`ft.Audio` não existe** (classe removida nesta versão) → substituído por
   `flet_audio.Audio`, que é um *service* com métodos `play()`/`pause()`
   **assíncronos**.
5. **`ft.ListTile(tile_color=...)` falha** → o parâmetro correto é `bgcolor`.
6. **`ft.Column(padding=...)` não é aceito** nesta versão → padding movido
   para o `Container` externo.
7. **`ft.CircleAvatar(foreground_image_url=...)` falha** → o parâmetro
   correto no 0.86.5 é `foreground_image_src`.
8. **`ft.Dropdown` não aceita `on_change`** (nem `ft.dropdown.Option`) → usar
   `on_select` e `ft.DropdownOption`.
9. **Dado histórico incorreto**: a temporada 2004 estava marcada como
   "rebaixado" no `historico.py`. Fontes públicas confirmam que o Vasco
   terminou 2004 em **16º** e **não caiu**; as quatro quedas do clube na
   Série A foram todas a partir de 2008 (2008, 2013, 2015 e 2020). Corrigido.
10. **Notícias dependentes da rede**: com o app offline a aba Notícias
    quebrava → novo cache SQLite com fallback local.

## 3. Correções aplicadas

- **`theme.py` (novo)** centraliza a paleta do Vasco (preto, branco, cinzas
  neutros e vermelho `#E30613` usado pontualmente) e fornece widgets
  reutilizáveis: `card`, `titulo_secao`, `linha_estatistica`,
  `chip_estatistica`, `divisoria`, `estado_vazio` e `mensagem_erro`.
- **`main.py` (reescrito)**:
  - Corrige todos os itens da seção 2 (usa `ft.Icons.*`, `ft.Border.all`,
    `flet_audio.Audio` com `try/except` e handlers `async`,
    `bgcolor` no `ListTile`, `foreground_image_src`, `on_select` no
    `Dropdown`).
  - Estrutura de 5 abas via `NavigationBar` (label sempre visível).
  - Aba MatchDay mantém o card "PRÓXIMA PARTIDA — COPA DO BRASIL
    (VASCO x VITÓRIA)" do projeto e o painel ao vivo do `RealMatchDay365`,
    com estado vazio amigável quando não há dados e botão "Sincronizar".
  - Renderizações defensivas: qualquer erro de fonte externa mostra uma
    mensagem amigável em vez de traceback.
- **`historico.py` (novo)** com **18 temporadas verificadas** do Brasileirão
  (1974–2025), resumos (4 títulos, 1 vice, 57 participações na Série A,
  4 rebaixamentos), finais da Copa do Brasil (2006, 2011 e 2025) e a
  campanha detalhada do título de 2011 (11 jogos, 5V 5E 1D) — todos os
  números vindos de tabelas oficiais (Wikipédia/CBF); campos sem fonte
  viraram `None` → "Não disponível".
- **`banco_dados.py` (reescrito)**: feed híbrido — internet →
  cache SQLite → manchetes locais; o banco respeita `FLET_APP_STORAGE_DATA`
  no celular.
- **`scraping.py` e `match_day.py`**: mantidos (fonte dos dados existentes).

## 4. Dependências

- **requirements.txt** atualizado: `flet~=0.86.5`, `flet-audio~=0.86.5`,
  `requests>=2.31.0`, `beautifulsoup4>=4.12.0`.
- `numpy` e `pillow` **não** entram para o app: foram testadas apenas como
  pré-requisitos do `flet.testing`, abordagem abandonada em favor do harness
  próprio (as versões instaladas ficam apenas no `.venv`).
- **pyproject.toml** destrava a documentação de build iOS.

## 5. Compatibilidade com iPhone 12 Pro

- Alvo iOS documentado: iPhone 12 Pro (**arm64**).
- `pyproject.toml` traz a seção `[tool.flet.ios]` com orientação para
  preencher `team_id`, provisioning profile e certificado.
- **Pendência real**: o build do IPA exige macOS com Xcode e conta de
  desenvolvedor Apple — não é possível gerar o IPA neste ambiente Windows.
  As etapas ficaram documentadas no README.
- Recursos usados (NavigationBar 5 abas, GridView, áudio, cache SQLite) são
  compatíveis com o alvo iOS.

## 6. Melhorias de interface

- Identidade Vasco: fundo preto, cards cinza-escuro `#161616`/`#1F1F1F`,
  bordas `WHITE_10`, textos brancos e cinzas, vermelho apenas em destaque.
- AppBar "CR VASCO DA GAMA" centralizado.
- Estados de vazio/erro amigáveis em todas as abas (sem mensagens técnicas).
- Modo AMOLED (economia de bateria) na aba Mais.
- Nota na Interface que a temporada 2026 está em andamento (não inventamos
  dados atuais).

## 7. Nova funcionalidade — História & Estatísticas

- Dropdown para alternar entre **Campeonato Brasileiro** e **Copa do Brasil**.
- Cards de resumo (títulos, vices, participações, rebaixamentos).
- Finais disputadas (Copa do Brasil) com destaque para o título de 2011.
- Histórico por temporada do Brasileirão com posição, J, V, E, D, Gols,
  aproveitamento (fórmula padrão de 3 pontos por vitória) e observações.
- Total acumulado **apenas das temporadas listadas** (rotulado claramente).
- Linha "Fontes dos dados" em cada campeonato.

## 8. Testes

Arquivo `central_vasco/testes.py` — harness próprio (Page simulado), sem
rede e sem janela:

- **Dados**: soma V+E+D = J em todas as 18 temporadas; aproveitamento sempre
  em 0–100%; flags campeão/rebaixado consistentes; resumos do Brasileirão e
  da Copa do Brasil; total acumulado.
- **Interface**: carregamento da estrutura (5 abas, labels certos, AppBar);
  troca entre todas as abas; aba História renderiza os dados reais; troca de
  campeonato no Dropdown; MatchDay não quebra sem rede.

**Resultado: 12 testes, todos aprovados (OK).**

```bash
python central_vasco\testes.py
```

## 9. Git e GitHub

- Repositório local `git init` (branch `master`) no diretório do projeto.
- Commit inicial com o aplicativo corrigido, testes, README, relatório e
  `pyproject.toml`/`requirements.txt` atualizados.
- Repositório remoto `apptime` criado na conta **matheusenaa** e `push`
  realizado. O `.gitignore` cobre `.venv/`, `__pycache__/`, `build/`,
  `.idea/`, `.flet/` e `*.db` (o cache SQLite não vai para o GitHub).

## 10. Pendências

1. **Build IPA (macOS)**: sem Apple Developer Team ID + Xcode não há IPA.
   Passos documentados no README e no `pyproject.toml`.
2. Temporada 2026: incluir no histórico assim que a competição terminar e
   houver fonte confiável.
3. Copa do Brasil: o histórico por temporada completa pode ser adicionado
   quando houver fonte verificada para todos os anos.
4. Ampliar o feed de notícias com mais fontes do Vasco e agendador de
   atualização.
# RELATÓRIO — Correção do erro "Unknown control: Audio" no iPhone (Vasco Hub 2026)

**Projeto:** `apptime` — Vasco Hub 2026 (Flet)
**Data:** 31/08/2026
**Ambiente:** Windows / PowerShell, Python 3.12.10, Flet 0.86.5
**Dispositivo do erro:** iPhone 12 Pro

---

## 1. Problema

Ao rodar o app no iPhone 12 Pro (via `flet run main.py --ios` + QR code no PyCharm),
o app exibia uma **tela vermelha de erro com a mensagem "Unknown control: Audio"**,
impedindo o uso normal do aplicativo.

---

## 2. Investigação

### 2.1 Como o app roda no iPhone (arquitetura real)
Confirmado com o usuário: ele roda `flet run main.py --ios` no **Windows** (PyCharm) e
escaneia o QR code gerado com o iPhone. Nesse fluxo, **não é gerado um IPA nativo**. O
Flet inicia o aplicativo Python como um **servidor web** neste PC e o iPhone abre via
Safari/PWA (`fletdevs.com`) como **cliente Flutter web**. O código Python roda no PC; o
iPhone apenas renderiza o frontend.

### 2.2 Versões verificadas
| Componente | Versão |
|---|---|
| Python | 3.12.10 |
| flet | 0.86.5 |
| flet-audio | 0.86.5 |
| flet-cli / flet-desktop / flet-web | 0.86.5 |
| Flutter (via Flet CLI) | 3.44.8 |

`flutter` e `dart` NÃO estão instalados globalmente; o Flet usa SDK próprio.

### 2.3 O cliente web do Flet 0.86.5 SUPORTA o controle "Audio"
Análise do bundle web (`flet_web\web\main.dart.js`):

- Contém o despachante de controles com registro explícito:
  `case"Audio": return new an5(A.d2A(), a)` (controle `Audio` → `AudioPlayer`).
- Registra os canais do plugin `audioplayers`
  (`xyz.luan/audioplayers`, `xyz.luan/audioplayers/events`, ...).
- Inclui os métodos do player: `play`, `resume`, `pause`, `release`, `seek`,
  `get_duration`, `get_current_position`, eventos `state_change`,
  `position_change`, `duration_change`, `seek_complete`, `loaded`.
- A lista de registros de controle inclui `Audio` e `AudioRecorder`.

**Conclusão:** o erro NÃO é "controle desconhecido de verdade" na versão 0.86.5 do
cliente web. A mensagem "Unknown control: Audio" ocorre quando o **cliente que o
navegador está carregando não reconhece o tipo `Audio`** — o que aponta para um
**cliente web antigo/em cache** no iPhone (via `flutter_service_worker`/PWA do Safari),
de uma sessão anterior antes do suporte a áudio, ou uma versão diferente.

### 2.4 O app instanciava `Audio` de forma agressiva
No `main.py`, o controle `Audio` era criado com `src=""` e adicionado ao **overlay de
todas as páginas já no startup**, de forma incondicional:

```python
audio_player = ControladorAudio(src="", autoplay=False)
page.overlay.append(audio_player)
```

Isso garantia que a área problemática fosse renderizada em toda a interface. Com um
cliente web antigo (sem suporte a "Audio"), o despachante lançava
"Unknown control: Audio" **a cada build**, quebrando a tela inteira, sem fallback
amigável no lado do cliente.

---

## 3. Tentativas avaliadas

1. **Remover o áudio do app** — descartado como primeira opção; o objetivo era
   **preservar o recurso** e só removê-lo como último recurso.
2. **Gerar IPA nativo com Xcode** — impossível neste Windows (sem macOS/Xcode);
   documentado como pendência para build nativo.
3. **Ajustar o `build/flutter`** (pubspec) — o build de site-packages do projeto só tem
   ABIs Android e não contém `flet_audio`; o bundle web servido em runtime é o do
   pacote `flet_web` (0.86.5), que já suporta Audio.
4. **Proteção no código (adotada)** — criar o `Audio` **apenas sob demanda** (no
   primeiro clique em "tocar"), mantendo fallback amigável → ver Solução.

---

## 4. Solução

### 4.1 Código (`central_vasco/main.py`)
- O controle `Audio` deixou de ser criado no startup no overlay de todas as páginas.
- Agora é criado **lentamente, sob demanda**, na primeira vez que o usuário toca num
  canto, via `obter_audio()` (que o adiciona ao overlay e o retorna).
- As funções `tocar_musica` e `parar_musica` usam `obter_audio()` dentro de `try/except`
  com **fallback amigável** ("áudio indisponível no momento"), exibido via SnackBar —
  nunca tela vermelha/traceback.

```python
audio_player = None

def obter_audio():
    nonlocal audio_player
    if audio_player is None:
        from flet_audio import Audio as ControladorAudio
        audio_player = ControladorAudio(src="", autoplay=False)
        page.overlay.append(audio_player)
    return audio_player
```

### 4.2 No dispositivo (iPhone) — passo decisivo
Como o cliente web 0.86.5 **suporta** `Audio`, a causa mais provável é o **cache antigo**
do web client no iPhone. Para carregar o cliente atualizado:

1. Feche o app no iPhone (deslize para cima e remova o Vasco Hub 2026 das abas).
2. Abra o Safari → Apagar histórico e dados dos sites (Ajustes → Safari) **ou**
   força a recarga do PWA (limpar o site `fletdevs.com`).
3. No Windows, rode `flet run main.py --ios`, gere novo QR e escaneie com o iPhone.
4. Se pedir instalar/atualizar o app web, confirme "Adicionar à Tela de Início".
5. Confirme as permissões de áudio quando solicitado.

> Se, mesmo após limpar o cache, o erro persistir com o novo cliente, aí sim considerar
> desabilitar o áudio — mas, conforme a análise do bundle, o cliente 0.86.5 reconhece o
> controle `Audio`, portanto o esperado é funcionar.

---

## 5. Testes (regressão)

Suíte executada: `central_vasco/testes.py` — **12 testes OK**.

| # | Teste | Resultado |
|---|---|---|
| 1 | aproveitamento dentro do intervalo | OK |
| 2 | aproveitamento sem dados | OK |
| 3 | posição e flags consistentes | OK |
| 4 | resumo acumulado | OK |
| 5 | resumo brasileirão | OK |
| 6 | resumo copa brasil | OK |
| 7 | temporadas batem soma | OK |
| 8 | aba histórico alterna campeonato | OK |
| 9 | aba histórico renderiza dados | OK |
| 10 | main carrega estrutura | OK |
| 11 | match day não quebra sem rede | OK |
| 12 | troca entre todas as abas | OK |

**Compilação:** `python -m py_compile central_vasco/main.py` → OK.

---

## 6. Roteiro de testes manuais (iPhone 12 Pro)

| Item | Esperado | Resultado |
|---|---|---|
| Aplicativo inicia | Sem tela vermelha | Pendente (iPhone) |
| Tela inicial | Renderiza normalmente | Pendente (iPhone) |
| Navegação (abas) | Funciona em todas as abas | Pendente (iPhone) |
| Áudio (tocar/parar canto) | Toca áudio e mostra SnackBar | Pendente (iPhone) |
| Estatísticas | Dados corretos | Pendente (iPhone) |
| APIs / scraping | Carrega com ou sem rede | Pendente (iPhone) |
| Responsividade | Layout OK em tela pequena | Pendente (iPhone) |
| iPhone 12 Pro | Erro "Unknown control: Audio" não aparece | Pendente (iPhone) |

---

## 7. Pendências
- Build **iOS nativo (IPA)** impossível neste Windows (requer macOS/Xcode). O fluxo atual
  é web/PWA no Safari. Documentado para decisão futura (ex.: hospedar o app web ou usar
  um Mac/CI).
- Validação manual no iPhone (tabela acima) depende do usuário executar com cache limpo.

---

## 8. Conclusão
O cliente web do Flet **0.86.5 suporta** o controle `Audio` (confirmado no bundle). A
proteção em código elimina a renderização agressiva de um `Audio` vazio em todas as
páginas e adiciona fallback amigável, **preservando** o recurso de áudio. O passo final
no iPhone é garantir que o navegador carregue o cliente web atualizado (limpar cache do
Safari / reinstalar o PWA), pois o erro "Unknown control: Audio" é consistente com um
cliente web antigo em cache.

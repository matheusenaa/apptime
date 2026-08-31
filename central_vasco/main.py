import flet as ft

import banco_dados as bd
import historico
import match_day as md
import scraping as src
import theme as tema


def main(page: ft.Page):
    page.title = "Vasco Hub 2026"
    page.theme_mode = ft.ThemeMode.DARK
    page.bgcolor = tema.COR_FUNDO
    page.padding = 0
    page.spacing = 0

    gerenciador_dados = bd.DBManager365()
    motor_jogo = md.RealMatchDay365()

    # Áudio da torcida (com degradação graciosa quando não houver suporte)
    audio_player = None
    try:
        from flet_audio import Audio as ControladorAudio

        audio_player = ControladorAudio(src="", autoplay=False)
        page.overlay.append(audio_player)
    except Exception:
        print("[Aviso] Áudio indisponível neste ambiente.")

    def notificar(mensagem, cor=None):
        page.snack_bar = ft.SnackBar(
            content=ft.Text(mensagem, weight=ft.FontWeight.BOLD),
            bgcolor=cor or tema.COR_CARD_2,
        )
        page.snack_bar.open = True
        page.update()

    async def tocar_musica(url, titulo):
        if audio_player:
            try:
                audio_player.src = url or ""
                await audio_player.play()
                notificar(f"🔊 Tocando agora: {titulo}")
            except Exception:
                notificar("Não foi possível reproduzir este áudio no momento.")
        else:
            notificar(f"📖 Canto selecionado: {titulo} (áudio indisponível no momento)")
        page.update()

    async def parar_musica():
        if audio_player:
            try:
                await audio_player.pause()
                notificar("⏸️ Áudio pausado")
            except Exception:
                pass
        page.update()

    def criar_handler_canto(url, titulo):
        async def handler(e):
            await tocar_musica(url, titulo)

        return handler

    def alternar_economia_energia(e):
        if e.control.value:
            page.bgcolor = tema.COR_FUNDO
            notificar("🔋 Modo Economia Máxima (AMOLED) Ativado!")
        else:
            page.bgcolor = tema.COR_CARD
            notificar("Modo Escuro Padrão Ativado.")
        page.update()

    def abrir_link(url):
        if not url:
            notificar("Este link ainda não está disponível.")
            return
        try:
            page.launch_url(url)
        except Exception:
            notificar("Não foi possível abrir o link no navegador.")

    # ABA 1 — FEED DE NOTÍCIAS
    def render_noticias_bastidores():
        lista = ft.ListView(padding=12, expand=True, spacing=10)
        try:
            dados = gerenciador_dados.obter_noticias_hibrido()
        except Exception:
            dados = {"ultimas": [], "entrevistas": [], "bastidores": [], "online": False}

        if not dados.get("online"):
            lista.controls.append(
                ft.Container(
                    content=ft.Text(
                        "📴 Modo offline: exibindo notícias salvas no dispositivo.",
                        size=12, color=tema.COR_TEXTO_SEC),
                    padding=10, border_radius=8, bgcolor=tema.COR_CARD,
                    border=ft.Border.all(1, tema.COR_BORDA)))

        noticias = dados.get("ultimas") or []
        if not noticias:
            lista.controls.append(tema.estado_vazio(
                "Nenhuma notícia disponível agora. Verifique sua conexão e tente novamente."))
        else:
            for n in noticias[:10]:
                url = n.get("url") or ""
                lista.controls.append(tema.card(
                    ft.ListTile(
                        leading=ft.Icon(ft.Icons.ARTICLE, color=tema.COR_TEXTO),
                        title=ft.Text(n.get("titulo") or "Sem título", size=13, max_lines=2,
                                      overflow=ft.TextOverflow.ELLIPSIS),
                        subtitle=ft.Text(f"Fonte: {n.get('fonte') or 'Desconhecida'}",
                                         size=11, color=tema.COR_TEXTO_SEC),
                        on_click=lambda _, u=url: abrir_link(u),
                    ), padding=4))
        return lista

    # ABA 2 — MATCH DAY
    painel_tempo_real = ft.Column(expand=True, scroll=ft.ScrollMode.AUTO)

    def render_estatisticas_partida(jogo):
        estatisticas = jogo.get("estatisticas") or {}
        return tema.card(
            ft.Column([
                tema.titulo_secao("Estatísticas da partida", icone=ft.Icons.INSIGHTS),
                tema.linha_estatistica("Posse de bola", str(estatisticas.get("posse", "—")) + "%"),
                tema.linha_estatistica("Finalizações (VASCO)",
                                       str(estatisticas.get("finalizacoes_vasco", "—"))),
                tema.linha_estatistica("Finalizações (adv.)",
                                       str(estatisticas.get("finalizacoes_adv", "—"))),
                tema.linha_estatistica("Faltas (VASCO)", str(estatisticas.get("faltas_vasco", "—"))),
                tema.linha_estatistica("Faltas (adv.)", str(estatisticas.get("faltas_adv", "—"))),
            ], spacing=4), padding=12)

    def render_escalacao(jogo):
        escalacao = jogo.get("escalacao") or []
        lista = ft.ListView(spacing=2, padding=0)
        for atleta in escalacao[:15]:
            lista.controls.append(ft.Text(f"• {atleta}", size=12, color=tema.COR_TEXTO_SEC))
        return tema.card(
            ft.Column([
                tema.titulo_secao("Escalação", icone=ft.Icons.GROUPS),
                lista,
            ], spacing=4), padding=12)

    def render_lances(jogo):
        lances = jogo.get("lances") or []
        lista = ft.Column(spacing=4)
        for lance in lances[:12]:
            lista.controls.append(ft.Text(lance, size=12, color=tema.COR_TEXTO_SEC))
        return tema.card(
            ft.Column([
                tema.titulo_secao("Lances e cronologia", icone=ft.Icons.TIMELINE),
                (ft.Text("Nenhum lance registrado ainda.", size=12, color=tema.COR_TEXTO_SEC)
                 if not lances else lista),
            ], spacing=4), padding=12)

    def atualizar_painel_jogo(e=None):
        painel_tempo_real.controls.clear()
        try:
            dados_jogo = motor_jogo.coletar_dados_ao_vivo()
        except Exception:
            dados_jogo = {}

        campo_pre_jogo = tema.card(
            ft.Column([
                tema.titulo_secao("PRÓXIMA PARTIDA — COPA DO BRASIL",
                                  icone=ft.Icons.EMOJI_EVENTS),
                ft.Row([
                    ft.Text("VASCO", size=16, weight=ft.FontWeight.BOLD, color=tema.COR_TEXTO),
                    ft.Text("VS", size=12, color=tema.COR_TEXTO_SEC),
                    ft.Text("VITÓRIA", size=16, weight=ft.FontWeight.BOLD, color=tema.COR_TEXTO),
                ], alignment=ft.MainAxisAlignment.SPACE_EVENLY),
                ft.Text("📺 Transmissão ao vivo na CazéTV", size=12,
                        color=tema.COR_TEXTO_SEC),
            ], horizontal_alignment=ft.CrossAxisAlignment.CENTER),
            cor="#101010")
        painel_tempo_real.controls.append(campo_pre_jogo)

        if dados_jogo:
            adversario = dados_jogo.get("adversario") or "Adversário"
            placar = f"{dados_jogo.get('placar_vasco', 0)} x {dados_jogo.get('placar_adv', 0)}"
            painel_tempo_real.controls.append(tema.card(
                ft.Column([
                    tema.titulo_secao(f"PLACAR AO VIVO — VASCO x {str(adversario).upper()}",
                                      icone=ft.Icons.SPORTS_SOCCER),
                    ft.Text(placar, size=30, weight=ft.FontWeight.BOLD,
                            color=tema.COR_TEXTO, text_align=ft.TextAlign.CENTER),
                ], horizontal_alignment=ft.CrossAxisAlignment.CENTER, spacing=6),
                cor="#101010"))
            painel_tempo_real.controls.append(render_estatisticas_partida(dados_jogo))
            painel_tempo_real.controls.append(render_escalacao(dados_jogo))
            painel_tempo_real.controls.append(render_lances(dados_jogo))
        else:
            painel_tempo_real.controls.append(tema.estado_vazio(
                "Dados da partida indisponíveis no momento. "
                "Verifique sua conexão e sincronize novamente.",
                icone=ft.Icons.WIFI_OFF))

        painel_tempo_real.controls.append(ft.ElevatedButton(
            "Sincronizar Placar Real",
            icon=ft.Icons.REFRESH,
            style=ft.ButtonStyle(bgcolor=tema.COR_TEXTO, color=ft.Colors.BLACK),
            on_click=atualizar_painel_jogo))
        page.update()

    # ABA 3 — PLAYLIST DA TORCIDA
    def render_playlist_torcida():
        lista = ft.ListView(padding=12, expand=True, spacing=10)
        lista.controls.append(ft.Row([
            ft.Icon(ft.Icons.MUSIC_NOTE, color=tema.COR_TEXTO),
            ft.Text("Cantos da Bancada Vascaína", size=16, weight=ft.FontWeight.BOLD,
                    color=tema.COR_TEXTO, expand=True),
            ft.IconButton(icon=ft.Icons.STOP_CIRCLE,
                          icon_color=tema.COR_VERMELHO_VASCO,
                          on_click=parar_musica, tooltip="Parar áudio"),
        ]))

        for musica in src.obter_playlist_torcida():
            lista.controls.append(tema.card(
                ft.ListTile(
                    leading=ft.Icon(ft.Icons.PLAY_ARROW_ROUNDED, color=tema.COR_TEXTO),
                    title=ft.Text(musica.get("titulo") or "Canto", weight=ft.FontWeight.BOLD,
                                  size=13),
                    subtitle=ft.Text(musica.get("sub") or "", size=11,
                                     color=tema.COR_TEXTO_SEC),
                    on_click=criar_handler_canto(musica.get("url") or "",
                                                 musica.get("titulo") or "Canto"),
                ), padding=4))
        return lista

    # ABA 4 — HISTÓRIA & ESTATÍSTICAS
    def render_momento_historico(campeonato_id):
        dados = None
        for camp in historico.obter_campeonatos():
            if camp["id"] == campeonato_id:
                dados = camp["dados"]
                break
        if not dados:
            return tema.estado_vazio("Dados históricos indisponíveis para este campeonato.")

        controles = []
        controles.append(tema.card(ft.Column([
            tema.titulo_secao(dados["nome"], icone=ft.Icons.EMOJI_EVENTS),
            ft.Text(dados["divisao"], size=12, color=tema.COR_TEXTO_SEC),
            ft.Text(dados["descricao"], size=12, color=tema.COR_TEXTO_SEC),
        ], spacing=2), cor="#101010"))

        resumo = dados["resumo"]
        itens = [
            ("Títulos", resumo.get("titulos"), tema.COR_VERMELHO_VASCO),
            ("Vices", resumo.get("vices"), tema.COR_TEXTO),
            ("Participações", resumo.get("participacoes_serie_a")
             if resumo.get("participacoes_serie_a") is not None
             else resumo.get("finais"), tema.COR_TEXTO),
            ("Rebaixamentos", resumo.get("rebaixamentos"), tema.COR_TEXTO),
        ]
        chips = ft.Row(wrap=True, spacing=8, run_spacing=8)
        for rotulo, valor, cor in itens:
            valor = "N/D" if valor is None else valor
            chips.controls.append(tema.chip_estatistica(rotulo, valor, cor))
        controles.append(chips)

        linhas = [tema.linha_estatistica(
            "Anos dos títulos", resumo.get("anos_titulos") or "Não disponível",
            cor_valor=tema.COR_VERMELHO_VASCO, negrito=True)]
        if resumo.get("anos_vices"):
            linhas.append(tema.linha_estatistica("Anos de vice", resumo["anos_vices"]))
        if resumo.get("anos_rebaixados"):
            linhas.append(tema.linha_estatistica(
                "Rebaixamentos", resumo["anos_rebaixados"]))
        if resumo.get("campanha_titulo_2011"):
            linhas.append(tema.linha_estatistica(
                "Campanha do título (2011)", resumo["campanha_titulo_2011"]))
        controles.append(tema.card(ft.Column(linhas, spacing=4)))

        finais = dados.get("finais") or []
        if finais:
            controles.append(tema.titulo_secao("Finais disputadas",
                                               icone=ft.Icons.MILITARY_TECH))
            for f in finais:
                campeao = str(f.get("resultado")) == "CAMPEÃO"
                controles.append(tema.card(ft.Row([
                    ft.Text(str(f.get("ano", "—")), size=14, weight=ft.FontWeight.BOLD,
                            color=tema.COR_TEXTO, expand=True),
                    ft.Text(str(f.get("resultado", "—")), size=13,
                            weight=ft.FontWeight.BOLD,
                            color=tema.COR_VERMELHO_VASCO if campeao else tema.COR_TEXTO),
                    ft.Text(f"vs. {f.get('adversario', '—')}", size=12,
                            color=tema.COR_TEXTO_SEC),
                ], spacing=8), padding=10))

        temporadas = dados.get("temporadas")
        if temporadas:
            acumulado = historico.resumo_acumulado(temporadas)
            if acumulado:
                controles.append(tema.titulo_secao("Acumulado das temporadas listadas",
                                                   icone=ft.Icons.BAR_CHART))
                controles.append(tema.card(ft.Column([
                    tema.linha_estatistica("Jogos", acumulado["jogos"]),
                    tema.linha_estatistica("Vitórias", acumulado["vitorias"],
                                           cor_valor=tema.COR_OK),
                    tema.linha_estatistica("Empates", acumulado["empates"]),
                    tema.linha_estatistica("Derrotas", acumulado["derrotas"],
                                           cor_valor=tema.COR_VERMELHO_VASCO),
                    tema.linha_estatistica("Gols marcados", acumulado["gols_pro"]),
                    tema.linha_estatistica("Gols sofridos", acumulado["gols_contra"]),
                    tema.linha_estatistica("Saldo de gols",
                                           f"{acumulado['saldo']:+d}"),
                    tema.linha_estatistica("Aproveitamento",
                                           acumulado["aproveitamento"], negrito=True),
                ], spacing=4)))

            controles.append(tema.divisoria())
            controles.append(tema.titulo_secao("Histórico por temporada",
                                               icone=ft.Icons.HISTORY))
            controles.append(ft.Text(
                "Aproveitamento calculado no padrão atual (3 pontos por vitória). "
                "Fontes: tabelas oficiais de cada edição.",
                size=11, color=tema.COR_TEXTO_SEC))
            for t in temporadas:
                controles.append(render_temporada(t))
        else:
            controles.append(tema.estado_vazio(
                "O histórico detalhado por temporada ainda não está disponível "
                "para este campeonato. Será adicionado quando houver fonte "
                "confiável.", icone=ft.Icons.INFO_OUTLINE))

        if dados.get("nota_temporada_atual"):
            controles.append(tema.card(ft.Row([
                ft.Icon(ft.Icons.INFO_OUTLINE, size=16, color=tema.COR_TEXTO_SEC),
                ft.Text(dados["nota_temporada_atual"], size=12,
                        color=tema.COR_TEXTO_SEC, expand=True),
            ], spacing=8), cor="#111111"))

        controles.append(ft.Text(
            "Fontes dos dados: " + ", ".join(dados.get("fonte") or []),
            size=10, color=tema.COR_TEXTO_SEC))
        return ft.Column(controles, spacing=12)

    def render_temporada(t):
        pos = t.get("posicao")
        if pos is None:
            posicao = "—"
            cor_posicao = tema.COR_TEXTO_SEC
        elif t.get("campeao"):
            posicao = "1º  (CAMPEÃO)"
            cor_posicao = tema.COR_VERMELHO_VASCO
        elif t.get("rebaixado"):
            posicao = f"{pos}º  (Rebaixado)"
            cor_posicao = tema.COR_TEXTO_SEC
        else:
            posicao = f"{pos}º"
            cor_posicao = tema.COR_TEXTO

        obs = t.get("obs")
        aproveitamento = historico.calcular_aproveitamento(
            t.get("vitorias"), t.get("empates"), t.get("derrotas"))

        def liga(rotulo, valor):
            return tema.chip_estatistica(
                rotulo, "—" if valor is None else valor)

        return tema.card(ft.Column([
            ft.Row([
                ft.Text(str(t["ano"]), size=15, weight=ft.FontWeight.BOLD,
                        color=tema.COR_TEXTO, expand=True),
                ft.Text(posicao, size=13, weight=ft.FontWeight.BOLD,
                        color=cor_posicao),
            ]),
            ft.Row(wrap=True, spacing=6, run_spacing=6, controls=[
                liga("Jogos", t.get("jogos")),
                liga("Vit", t.get("vitorias")),
                liga("Emp", t.get("empates")),
                liga("Der", t.get("derrotas")),
                liga("Gols", (f"{t.get('gols_pro')}–{t.get('gols_contra')}"
                              if t.get("gols_pro") is not None else "—")),
                liga("Aprov", aproveitamento or "—"),
            ]),
            (ft.Text(obs, size=11, color=tema.COR_TEXTO_SEC) if obs else ft.Text("")),
        ], spacing=8), padding=12)

    def ao_selecionar_campeonato(e):
        valor = None
        if e is not None:
            control = getattr(e, "control", None)
            valor = getattr(control, "value", None) or getattr(e, "data", None)
        valor = valor or seletor_campeonato.value or "brasileirao"
        seletor_campeonato.value = valor
        conteudo_app.content = render_historico_completo()
        page.update()

    seletor_campeonato = ft.Dropdown(
        value="brasileirao",
        bgcolor=tema.COR_CARD,
        label="Campeonato",
        text_style=ft.TextStyle(color=tema.COR_TEXTO),
        options=[
            ft.DropdownOption(key="brasileirao", text="Campeonato Brasileiro"),
            ft.DropdownOption(key="copa_brasil", text="Copa do Brasil"),
        ],
        on_select=ao_selecionar_campeonato,
    )

    def render_historico_completo():
        coluna = ft.Column(expand=True, scroll=ft.ScrollMode.AUTO, spacing=8)
        coluna.controls.append(
            tema.titulo_secao("Estatísticas Históricas", icone=ft.Icons.HISTORY))
        coluna.controls.append(ft.Text(
            "Desempenho do Vasco nos campeonatos acompanhados pelo app. "
            "Dados não fictícios, verificados em fontes públicas.",
            size=11, color=tema.COR_TEXTO_SEC))
        coluna.controls.append(seletor_campeonato)
        for camp in historico.obter_campeonatos():
            if camp["id"] == seletor_campeonato.value:
                coluna.controls.extend(
                    render_momento_historico(camp["id"]).controls)
                break
        coluna.controls.append(ft.Container(height=24))
        return ft.Container(content=coluna, padding=12)

    # ABA 5 — ELENCO & AJUSTES DE ENERGIA
    def render_elenco_config():
        coluna = ft.Column(scroll=ft.ScrollMode.AUTO, spacing=15)

        box_bateria = tema.card(ft.Row([
            ft.Icon(ft.Icons.SOLAR_POWER, color=tema.COR_OK),
            ft.Text("Modo AMOLED (Economizar Bateria)", expand=True, size=13,
                    color=tema.COR_TEXTO),
            ft.Switch(value=True, on_change=alternar_economia_energia),
        ]))
        coluna.controls.extend([
            tema.titulo_secao("Gerenciamento de Energia",
                              icone=ft.Icons.BATTERY_SAVER),
            box_bateria,
            tema.divisoria(),
        ])

        grid_atletas = ft.GridView(expand=False, runs_count=2, max_extent=180,
                                   child_aspect_ratio=0.85, spacing=10)
        for j in src.obter_elenco_completo():
            grid_atletas.controls.append(ft.Container(
                content=ft.Column([
                    ft.CircleAvatar(foreground_image_src=j.get("foto") or "", radius=32),
                    ft.Text(j.get("nome") or "-", weight=ft.FontWeight.BOLD, size=13,
                            overflow=ft.TextOverflow.ELLIPSIS),
                    ft.Text(f"N° {j.get('num', '-')} - {j.get('pos', '-')}", size=11,
                            color=tema.COR_TEXTO_SEC),
                ], horizontal_alignment=ft.CrossAxisAlignment.CENTER),
                bgcolor=tema.COR_CARD, border_radius=10, padding=10,
                border=ft.Border.all(1, tema.COR_BORDA)))
        coluna.controls.extend([
            tema.titulo_secao("Elenco Oficial", icone=ft.Icons.GROUPS),
            grid_atletas,
        ])
        return ft.Container(content=coluna, padding=12)

    # ESTRUTURA GLOBAL DE ABAS
    conteudo_app = ft.Container(content=render_noticias_bastidores(), expand=True)

    def alternar_aba(e):
        idx = e.control.selected_index
        if idx == 0:
            conteudo_app.content = render_noticias_bastidores()
        elif idx == 1:
            conteudo_app.content = painel_tempo_real
            atualizar_painel_jogo()
        elif idx == 2:
            conteudo_app.content = render_playlist_torcida()
        elif idx == 3:
            conteudo_app.content = render_historico_completo()
        elif idx == 4:
            conteudo_app.content = render_elenco_config()
        page.update()

    page.navigation_bar = ft.NavigationBar(
        selected_index=0,
        on_change=alternar_aba,
        bgcolor=tema.COR_CARD,
        indicator_color=ft.Colors.WHITE,
        label_behavior=ft.NavigationBarLabelBehavior.ALWAYS_SHOW,
        destinations=[
            ft.NavigationBarDestination(icon="article", label="Notícias"),
            ft.NavigationBarDestination(icon="sports_soccer", label="MatchDay"),
            ft.NavigationBarDestination(icon="music_note", label="Cantos"),
            ft.NavigationBarDestination(icon="bar_chart", label="História"),
            ft.NavigationBarDestination(icon="people", label="Mais"),
        ],
    )

    page.appbar = ft.AppBar(
        title=ft.Text("CR VASCO DA GAMA", weight=ft.FontWeight.BOLD),
        center_title=True,
        bgcolor=tema.COR_FUNDO,
        color=tema.COR_TEXTO,
    )
    page.add(conteudo_app)


if __name__ == "__main__":
    ft.app(target=main)
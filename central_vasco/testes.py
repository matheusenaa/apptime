"""Suíte de testes do Vasco Hub 2026 (harness próprio, sem flet.testing).

Os testes não executam nenhuma requisição real de rede nem abrem window.
Um Page simulado (PaginaSimulada) atende o que main() utiliza, seguindo a
mesma API pública do Flet 0.86.5.

Execução:
    python central_vasco/testes.py
    ou
    python -m unittest central_vasco.testes -v
"""

import os
import sys
import unittest
from unittest import mock

CAMINHO_PACOTE = os.path.dirname(__file__)
if CAMINHO_PACOTE not in sys.path:
    sys.path.insert(0, CAMINHO_PACOTE)

import historico  # noqa: E402


# ---------------------------------------------------------------------------
# Dublês de teste (test doubles)
# ---------------------------------------------------------------------------
class PaginaSimulada:
    """Substituto leve do ft.Page usado por main()."""

    def __init__(self):
        self.title = None
        self.theme_mode = None
        self.bgcolor = None
        self.padding = None
        self.spacing = None
        self.appbar = None
        self.navigation_bar = None
        self.snack_bar = None
        self.overlay = []
        self.adicionados = []
        self.lancamentos = []
        self.atualizacoes = 0

    def add(self, *controles):
        self.adicionados.extend(controles)

    def update(self):
        self.atualizacoes += 1

    def launch_url(self, url):
        self.lancamentos.append(url)


class ControleSimulado:
    """Objeto genérico que carrega selected_index/value conforme o uso."""

    def __init__(self, selected_index=None, value=None):
        self.selected_index = selected_index
        self.value = value


class EventoSimulado:
    """Substituto do objeto de evento (e) passado aos handlers do Flet."""

    def __init__(self, control):
        self.control = control


# ---------------------------------------------------------------------------
# Helpers de inspeção
# ---------------------------------------------------------------------------
def _coletar_textos(controle, acumulador=None, vistos=None):
    """Retorna todos os textos renderizados em uma árvore de controles
    (percorre controles aninhados, inclusive os guardados em atributos
    como title/subtitle/content, com proteção contra referências cíclicas)."""
    if acumulador is None:
        acumulador = []
    if vistos is None:
        vistos = set()
    oid = id(controle)
    if oid in vistos:
        return acumulador
    vistos.add(oid)

    valor = getattr(controle, "value", None)
    if isinstance(valor, str):
        acumulador.append(valor)

    # Flet 0.86.5 armazena os atributos dos controles em `_values`
    # (dict), além de possíveis atributos próprios em `vars()`.
    objetos = list(vars(controle).values()) if hasattr(controle, "__dict__") else []
    valores_internos = getattr(controle, "_values", None)
    if isinstance(valores_internos, dict):
        objetos.extend(valores_internos.values())

    for objeto in objetos:
        if objeto is None or isinstance(objeto, (str, int, float, bool)):
            continue
        if isinstance(objeto, (list, tuple)):
            for item in objeto:
                if item is not None and not isinstance(item, (str, int, float, bool)):
                    _coletar_textos(item, acumulador, vistos)
        elif hasattr(objeto, "__dict__") or hasattr(objeto, "_values"):
            _coletar_textos(objeto, acumulador, vistos)
    return acumulador


def _buscar_por_tipo(controle, nome_tipo, vistos=None):
    """Procura o primeiro controle cujo nome de classe é `nome_tipo`."""
    if vistos is None:
        vistos = set()
    oid = id(controle)
    if oid in vistos:
        return None
    vistos.add(oid)

    if type(controle).__name__ == nome_tipo:
        return controle
    objetos = list(vars(controle).values()) if hasattr(controle, "__dict__") else []
    valores_internos = getattr(controle, "_values", None)
    if isinstance(valores_internos, dict):
        objetos.extend(valores_internos.values())
    for objeto in objetos:
        if objeto is None or isinstance(objeto, (str, int, float, bool)):
            continue
        if isinstance(objeto, (list, tuple)):
            for item in objeto:
                if item is not None and not isinstance(item, (str, int, float, bool)):
                    achado = _buscar_por_tipo(item, nome_tipo, vistos)
                    if achado:
                        return achado
        elif hasattr(objeto, "__dict__") or hasattr(objeto, "_values"):
            achado = _buscar_por_tipo(objeto, nome_tipo, vistos)
            if achado:
                return achado
    return None


# ---------------------------------------------------------------------------
# Dados históricos — integridade
# ---------------------------------------------------------------------------
class TesteDadosHistoricos(unittest.TestCase):

    def test_temporadas_batem_soma(self):
        for t in historico.TEMPORADAS_BRASILEIRAO:
            with self.subTest(ano=t["ano"]):
                self.assertEqual(
                    t["vitorias"] + t["empates"] + t["derrotas"],
                    t["jogos"],
                    f"Soma V+E+D não confere para {t['ano']}")

    def test_posicao_e_flags_consistentes(self):
        campeoes = 0
        rebaixados = 0
        for t in historico.TEMPORADAS_BRASILEIRAO:
            self.assertGreaterEqual(t["posicao"], 1)
            if t.get("campeao"):
                campeoes += 1
                self.assertEqual(t["posicao"], 1)
            if t.get("rebaixado"):
                rebaixados += 1
                self.assertGreater(t["posicao"], 16)
        self.assertEqual(campeoes, 4)
        # As 4 quedas do clube na Série A foram todas a partir de 2008
        # (2008, 2013, 2015 e 2020). Em 2004 o Vasco terminou em 16º e subiu
        # de divisão não ocorreu naquele formato.
        self.assertEqual(rebaixados, 4)

    def test_aproveitamento_dentro_do_intervalo(self):
        for t in historico.TEMPORADAS_BRASILEIRAO:
            with self.subTest(ano=t["ano"]):
                valor = historico.calcular_aproveitamento(
                    t["vitorias"], t["empates"], t["derrotas"])
                self.assertIsInstance(valor, str)
                numero = float(valor.replace("%", ""))
                self.assertGreaterEqual(numero, 0.0)
                self.assertLessEqual(numero, 100.0)

    def test_aproveitamento_sem_dados(self):
        self.assertIsNone(historico.calcular_aproveitamento(None, 2, 3))
        self.assertIsNone(historico.calcular_aproveitamento(0, 0, 0))

    def test_resumo_brasileirao(self):
        resumo = historico.DADOS_BRASILEIRAO["resumo"]
        self.assertEqual(resumo["titulos"], 4)
        self.assertEqual(resumo["anos_titulos"], "1974, 1989, 1997 e 2000")
        self.assertEqual(resumo["vices"], 1)
        self.assertEqual(resumo["anos_vices"], "2011")
        self.assertEqual(resumo["anos_rebaixados"], "2008, 2013, 2015 e 2020")
        self.assertEqual(resumo["participacoes_serie_a"], 57)

    def test_resumo_copa_brasil(self):
        resumo = historico.DADOS_COPA_BRASIL["resumo"]
        self.assertEqual(resumo["titulos"], 1)
        self.assertEqual(resumo["anos_titulos"], "2011")
        self.assertEqual(resumo["vices"], 2)
        self.assertEqual(len(historico.DADOS_COPA_BRASIL["finais"]), 3)
        campeao = [f for f in historico.DADOS_COPA_BRASIL["finais"]
                   if f["resultado"] == "CAMPEÃO"]
        self.assertEqual(len(campeao), 1)

    def test_resumo_acumulado(self):
        acumulado = historico.resumo_acumulado(historico.TEMPORADAS_BRASILEIRAO)
        self.assertIsNotNone(acumulado)
        self.assertGreater(acumulado["jogos"], 0)
        self.assertEqual(acumulado["saldo"],
                         acumulado["gols_pro"] - acumulado["gols_contra"])
        self.assertEqual(
            acumulado["jogos"],
            sum(t["jogos"] for t in historico.TEMPORADAS_BRASILEIRAO))


# ---------------------------------------------------------------------------
# Interface — smoke tests de main()
# ---------------------------------------------------------------------------
class TesteInterface(unittest.TestCase):

    def iterar_abas(self, pagina):
        return range(len(pagina.navigation_bar.destinations))

    @mock.patch("match_day.RealMatchDay365.coletar_dados_ao_vivo",
                return_value={"placar_vasco": 3, "placar_adv": 1,
                              "adversario": "Cruzeiro", "estatisticas": {},
                              "escalacao": [], "lances": []})
    @mock.patch("banco_dados.src.obter_noticias_completas",
                return_value={"ultimas": [
                    {"titulo": "Notícia de teste", "fonte": "ge",
                     "url": "https://ge.globo.com"}]})
    def test_main_carrega_estrutura(self, *_patches):
        import main as app
        pagina = PaginaSimulada()
        app.main(pagina)

        self.assertEqual(len(pagina.navigation_bar.destinations), 5)
        rotulos = [d.label for d in pagina.navigation_bar.destinations]
        self.assertEqual(rotulos,
                         ["Notícias", "MatchDay", "Cantos", "História", "Mais"])
        self.assertEqual(pagina.appbar.title.value, "CR VASCO DA GAMA")
        self.assertTrue(pagina.adicionados)
        # Aba inicial é o feed de notícias
        textos_aba0 = _coletar_textos(pagina.adicionados[0])
        self.assertTrue(any("Notícia de teste" in t for t in textos_aba0))

    @mock.patch("match_day.RealMatchDay365.coletar_dados_ao_vivo",
                return_value={"placar_vasco": 3, "placar_adv": 1,
                              "adversario": "Cruzeiro", "estatisticas": {},
                              "escalacao": [], "lances": []})
    @mock.patch("banco_dados.src.obter_noticias_completas",
                return_value={"ultimas": []})
    def test_troca_entre_todas_as_abas(self, *_patches):
        import main as app
        pagina = PaginaSimulada()
        app.main(pagina)

        for indice in self.iterar_abas(pagina):
            with self.subTest(indice=indice):
                evento = EventoSimulado(
                    ControleSimulado(selected_index=indice))
                pagina.navigation_bar.on_change(evento)
                pagina.update()

    @mock.patch("match_day.RealMatchDay365.coletar_dados_ao_vivo",
                return_value={"placar_vasco": 3, "placar_adv": 1,
                              "adversario": "Cruzeiro", "estatisticas": {},
                              "escalacao": [], "lances": []})
    @mock.patch("banco_dados.src.obter_noticias_completas",
                return_value={"ultimas": []})
    def test_aba_historico_renderiza_dados(self, *_patches):
        import main as app
        pagina = PaginaSimulada()
        app.main(pagina)

        evento_tab = EventoSimulado(ControleSimulado(selected_index=3))
        pagina.navigation_bar.on_change(evento_tab)

        conteudo = pagina.adicionados[0].content
        textos = _coletar_textos(conteudo)
        self.assertTrue(any("Estatísticas Históricas" in t for t in textos))
        self.assertTrue(any("Campeonato Brasileiro" in t for t in textos))
        self.assertTrue(any("1974, 1989, 1997 e 2000" in t for t in textos))

    @mock.patch("match_day.RealMatchDay365.coletar_dados_ao_vivo",
                return_value={"placar_vasco": 3, "placar_adv": 1,
                              "adversario": "Cruzeiro", "estatisticas": {},
                              "escalacao": [], "lances": []})
    @mock.patch("banco_dados.src.obter_noticias_completas",
                return_value={"ultimas": []})
    def test_aba_historico_alterna_campeonato(self, *_patches):
        import main as app
        pagina = PaginaSimulada()
        app.main(pagina)

        evento_tab = EventoSimulado(ControleSimulado(selected_index=3))
        pagina.navigation_bar.on_change(evento_tab)

        conteudo = pagina.adicionados[0].content
        dropdown = _buscar_por_tipo(conteudo, "Dropdown")
        self.assertIsNotNone(dropdown, "Dropdown do histórico não encontrado")

        dropdown.value = "copa_brasil"
        dropdown.on_select(EventoSimulado(dropdown))
        textos = _coletar_textos(pagina.adicionados[0].content)
        self.assertTrue(any("Finais disputadas" in t for t in textos))
        self.assertTrue(any("Coritiba" in t for t in textos))

    @mock.patch("match_day.RealMatchDay365.coletar_dados_ao_vivo",
                return_value={"placar_vasco": 3, "placar_adv": 1,
                              "adversario": "Cruzeiro", "estatisticas": {},
                              "escalacao": [], "lances": []})
    @mock.patch("banco_dados.src.obter_noticias_completas",
                return_value={"ultimas": []})
    def test_match_day_nao_quebra_sem_rede(self, *_patches):
        import main as app
        pagina = PaginaSimulada()
        app.main(pagina)

        evento_tab = EventoSimulado(ControleSimulado(selected_index=1))
        pagina.navigation_bar.on_change(evento_tab)
        textos = _coletar_textos(pagina.adicionados[0].content)
        self.assertTrue(any("PRÓXIMA PARTIDA" in t for t in textos))


if __name__ == "__main__":
    unittest.main(verbosity=2)
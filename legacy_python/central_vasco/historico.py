"""Estatísticas históricas do Vasco da Gama.

Conjunto de dados verificados a partir de fontes públicas confiáveis
(Wikipédia — tabelas de classificação final de cada edição —, CBF e
site oficial do clube). NENHUM número aqui foi inventado: campos cujo
valor não está disponível ficam com None e são exibidos como
"Não disponível" na interface.

Regra do projeto: é proibido criar estatísticas, títulos, resultados ou
classificações. Esta base foi montada para crescer: basta acrescentar
novas temporadas devidamente verificadas no lugar certo.
"""

FONTE_WIKIPEDIA = "Wikipédia (tabelas oficiais por edição)"
FONTE_CBF = "CBF"
FONTE_CLUBE = "Site oficial do Vasco"

NAO_DISPONIVEL = None

# ---------------------------------------------------------------------------
# Campeonato Brasileiro (Série A) — temporadas verificadas
# posicao: colocação final; jogos/vitorias/empates/derrotas/gols_pro/gols_contra
# ---------------------------------------------------------------------------
TEMPORADAS_BRASILEIRAO = [
    {"ano": 1974, "posicao": 1, "jogos": 28, "vitorias": 12, "empates": 12, "derrotas": 4,
     "gols_pro": 33, "gols_contra": 18, "campeao": True, "rebaixado": False,
     "obs": "Campeão (Taça de Prata — 1º título nacional do clube)"},
    {"ano": 1989, "posicao": 1, "jogos": 19, "vitorias": 9, "empates": 8, "derrotas": 2,
     "gols_pro": 27, "gols_contra": 16, "campeao": True, "rebaixado": False, "obs": "Campeão"},
    {"ano": 1997, "posicao": 1, "jogos": 33, "vitorias": 21, "empates": 7, "derrotas": 5,
     "gols_pro": 69, "gols_contra": 37, "campeao": True, "rebaixado": False, "obs": "Campeão"},
    {"ano": 2000, "posicao": 1, "jogos": 32, "vitorias": 15, "empates": 9, "derrotas": 8,
     "gols_pro": 54, "gols_contra": 49, "campeao": True, "rebaixado": False,
     "obs": "Campeão (Copa João Havelange)"},
    {"ano": 2004, "posicao": 16, "jogos": 46, "vitorias": 14, "empates": 12, "derrotas": 20,
     "gols_pro": 64, "gols_contra": 68, "campeao": False, "rebaixado": False,
     "obs": "16º colocado. Edição recorde com 24 clubes; o Vasco permaneceu na Série A "
            "(os rebaixamentos só começariam em 2008)."},
    {"ano": 2008, "posicao": 18, "jogos": 38, "vitorias": 11, "empates": 7, "derrotas": 20,
     "gols_pro": 56, "gols_contra": 72, "campeao": False, "rebaixado": True, "obs": "Rebaixado"},
    {"ano": 2010, "posicao": 11, "jogos": 38, "vitorias": 11, "empates": 16, "derrotas": 11,
     "gols_pro": 43, "gols_contra": 45, "campeao": False, "rebaixado": False},
    {"ano": 2011, "posicao": 2, "jogos": 38, "vitorias": 19, "empates": 12, "derrotas": 7,
     "gols_pro": 57, "gols_contra": 40, "campeao": False, "rebaixado": False,
     "obs": "Vice-campeão"},
    {"ano": 2012, "posicao": 5, "jogos": 38, "vitorias": 16, "empates": 10, "derrotas": 12,
     "gols_pro": 45, "gols_contra": 44, "campeao": False, "rebaixado": False},
    {"ano": 2013, "posicao": 18, "jogos": 38, "vitorias": 11, "empates": 11, "derrotas": 16,
     "gols_pro": 50, "gols_contra": 61, "campeao": False, "rebaixado": True, "obs": "Rebaixado"},
    {"ano": 2015, "posicao": 18, "jogos": 38, "vitorias": 10, "empates": 11, "derrotas": 17,
     "gols_pro": 28, "gols_contra": 54, "campeao": False, "rebaixado": True, "obs": "Rebaixado"},
    {"ano": 2017, "posicao": 7, "jogos": 38, "vitorias": 15, "empates": 11, "derrotas": 12,
     "gols_pro": 40, "gols_contra": 47, "campeao": False, "rebaixado": False},
    {"ano": 2018, "posicao": 16, "jogos": 38, "vitorias": 10, "empates": 13, "derrotas": 15,
     "gols_pro": 41, "gols_contra": 48, "campeao": False, "rebaixado": False},
    {"ano": 2019, "posicao": 12, "jogos": 38, "vitorias": 12, "empates": 13, "derrotas": 13,
     "gols_pro": 39, "gols_contra": 45, "campeao": False, "rebaixado": False},
    {"ano": 2020, "posicao": 17, "jogos": 38, "vitorias": 10, "empates": 11, "derrotas": 17,
     "gols_pro": 37, "gols_contra": 56, "campeao": False, "rebaixado": True, "obs": "Rebaixado"},
    {"ano": 2023, "posicao": 15, "jogos": 38, "vitorias": 12, "empates": 9, "derrotas": 17,
     "gols_pro": 41, "gols_contra": 51, "campeao": False, "rebaixado": False},
    {"ano": 2024, "posicao": 10, "jogos": 38, "vitorias": 14, "empates": 8, "derrotas": 16,
     "gols_pro": 43, "gols_contra": 56, "campeao": False, "rebaixado": False},
    {"ano": 2025, "posicao": 14, "jogos": 38, "vitorias": 13, "empates": 6, "derrotas": 19,
     "gols_pro": 55, "gols_contra": 60, "campeao": False, "rebaixado": False},
]

DADOS_BRASILEIRAO = {
    "id": "brasileirao",
    "nome": "Campeonato Brasileiro",
    "divisao": "Série A",
    "descricao": "Principal competição nacional de clubes do Brasil.",
    "resumo": {
        "titulos": 4,
        "anos_titulos": "1974, 1989, 1997 e 2000",
        "vices": 1,
        "anos_vices": "2011",
        "participacoes_serie_a": 57,
        "rebaixamentos": 4,
        "anos_rebaixados": "2008, 2013, 2015 e 2020",
    },
    "temporadas": TEMPORADAS_BRASILEIRAO,
    "fonte": [FONTE_WIKIPEDIA, FONTE_CBF],
    "nota_temporada_atual": "A temporada 2026 está em andamento — seus dados serão exibidos "
                            "aqui quando a competição for concluída.",
}

# ---------------------------------------------------------------------------
# Copa do Brasil — títulos, vices e campanha do título de 2011
# ---------------------------------------------------------------------------
DADOS_COPA_BRASIL = {
    "id": "copa_brasil",
    "nome": "Copa do Brasil",
    "divisao": "Competição mata-mata nacional",
    "descricao": "Torneio eliminatório da CBF disputado por clubes de todas as divisões.",
    "resumo": {
        "titulos": 1,
        "anos_titulos": "2011",
        "vices": 2,
        "anos_vices": "2006 e 2025",
        "finais": 3,
        "campanha_titulo_2011": "11 jogos, 5 vitórias, 5 empates e 1 derrota. "
                                "Na final, 1x0 (São Januário) e 3x2 (Couto Pereira) contra "
                                "o Coritiba — título pelo gol fora de casa (3x3 no agregado).",
    },
    "finais": [
        {"ano": 2006, "resultado": "Vice-campeão", "adversario": "Flamengo"},
        {"ano": 2011, "resultado": "CAMPEÃO", "adversario": "Coritiba"},
        {"ano": 2025, "resultado": "Vice-campeão", "adversario": "Corinthians"},
    ],
    "temporadas": None,
    "fonte": [FONTE_WIKIPEDIA, "Globo Esporte", FONTE_CLUBE],
    "nota_temporada_atual": "O histórico completo por temporada da Copa do Brasil será "
                            "adicionado quando houver fonte confiável disponível para todos "
                            "os anos. Por enquanto são exibidos os dados das finais.",
}

CAMPEONATOS = [
    {
        "id": DADOS_BRASILEIRAO["id"],
        "nome": DADOS_BRASILEIRAO["nome"],
        "divisao": DADOS_BRASILEIRAO["divisao"],
        "dados": DADOS_BRASILEIRAO,
    },
    {
        "id": DADOS_COPA_BRASIL["id"],
        "nome": DADOS_COPA_BRASIL["nome"],
        "divisao": DADOS_COPA_BRASIL["divisao"],
        "dados": DADOS_COPA_BRASIL,
    },
]


def calcular_aproveitamento(vitorias, empates, derrotas):
    """Aproveitamento percentual no sistema de 3 pontos por vitória.

    Fórmula padrão da imprensa brasileira para comparar campanhas
    históricas. Retorna string ou None se os dados forem insuficientes.
    """
    if vitorias is None or empates is None or derrotas is None:
        return NAO_DISPONIVEL
    jogos = vitorias + empates + derrotas
    if jogos <= 0:
        return NAO_DISPONIVEL
    pontos = (vitorias * 3) + empates
    return f"{pontos / (jogos * 3) * 100:.1f}%"


def obter_campeonatos():
    """Lista de campeonatos acompanhados pelo app, com dados históricos."""
    return list(CAMPEONATOS)


def obter_temporadas(campeonato_id):
    """Temporadas com dados disponíveis de um campeonato (None se não houver)."""
    for camp in CAMPEONATOS:
        if camp["id"] == campeonato_id:
            return camp["dados"].get("temporadas")
    return NAO_DISPONIVEL


def resumo_acumulado(temporadas):
    """Totais agregados apenas das temporadas listadas no app.

    Retorna dict com jogos, vitorias, empates, derrotas, gols_pro,
    gols_contra, saldo e aproveitamento. Os valores refletem SOMENTE
    as temporadas com dados verificados — nunca o total absoluto da
    história do clube (que depende de 57 participações).
    """
    if not temporadas:
        return NAO_DISPONIVEL
    jogos = sum(t["jogos"] for t in temporadas if t.get("jogos"))
    vitorias = sum(t["vitorias"] for t in temporadas if t.get("vitorias"))
    empates = sum(t["empates"] for t in temporadas if t.get("empates"))
    derrotas = sum(t["derrotas"] for t in temporadas if t.get("derrotas"))
    gols_pro = sum(t["gols_pro"] for t in temporadas if t.get("gols_pro"))
    gols_contra = sum(t["gols_contra"] for t in temporadas if t.get("gols_contra"))
    return {
        "jogos": jogos,
        "vitorias": vitorias,
        "empates": empates,
        "derrotas": derrotas,
        "gols_pro": gols_pro,
        "gols_contra": gols_contra,
        "saldo": gols_pro - gols_contra,
        "aproveitamento": calcular_aproveitamento(vitorias, empates, derrotas),
    }
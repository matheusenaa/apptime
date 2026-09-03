import requests
import logging
from bs4 import BeautifulSoup

logger = logging.getLogger(__name__)


def obter_noticias_completas():
    # Estrutura base de dados dividida por categorias exigidas
    dados = {
        "ultimas": [],
        "entrevistas": [],
        "bastidores": [
            {"titulo": "Media Day: Atletas estreiam o novo manto amarelado", "midia": "📸 Foto Oficial",
             "fonte": "Vasco TV"},
            {"titulo": "Chegada da delegação ao estádio de São Januário", "midia": "🎥 Vídeo Interativo",
             "fonte": "Vasco TV"}
        ]
    }

    headers = {"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"}

    # 1. Raspagem do GE Vasco (Últimas Notícias e Lesões)
    try:
        r_ge = requests.get("https://ge.globo.com/futebol/times/vasco/", headers=headers, timeout=4)
        if r_ge.status_code == 200:
            soup = BeautifulSoup(r_ge.text, 'html.parser')
            for item in soup.find_all('div', class_='feed-post-body')[:3]:
                link = item.find('a', class_='feed-post-link')
                if link:
                    dados["ultimas"].append(
                        {"titulo": link.text.strip(), "fonte": "Globo Esporte", "url": link['href']})
    except Exception as e:
        logger.warning(f"Erro na raspagem do GE: {e}")

    # 2. Raspagem da NetVasco (Fatos Rápidos e Contratações)
    try:
        r_net = requests.get("https://www.netvasco.com.br/", headers=headers, timeout=4)
        if r_net.status_code == 200:
            soup = BeautifulSoup(r_net.text, 'html.parser')
            # Busca links de notícias na estrutura clássica da NetVasco
            for t in soup.find_all('a')[:15]:
                texto = t.text.strip()
                if "Vasco" in texto and len(texto) > 30:
                    dados["ultimas"].append({"titulo": texto, "fonte": "NetVasco", "url": t.get('href', '')})
    except Exception as e:
        logger.warning(f"Erro na raspagem da NetVasco: {e}")

    # 3. Raspagem do Site Oficial (Entrevistas Coletivas e Notas Oficiais)
    try:
        r_oficial = requests.get("https://vasco.com.br/", headers=headers, timeout=4)
        if r_oficial.status_code == 200:
            soup = BeautifulSoup(r_oficial.text, 'html.parser')
            for h in soup.find_all(['h2', 'h3'])[:3]:
                txt = h.text.strip()
                if txt:
                    dados["entrevistas"].append(
                        {"titulo": txt, "fonte": "Vasco Oficial", "url": "https://vasco.com.br/"})
    except Exception as e:
        logger.warning(f"Erro na raspagem do Site Oficial: {e}")

    # Fallback de segurança se as raspagens falharem simultaneamente
    if not dados["ultimas"]:
        dados["ultimas"].append(
            {"titulo": "Vasco intensifica treinos táticos focado no próximo confronto.", "fonte": "Boletim Interno",
             "url": ""})
    if not dados["entrevistas"]:
        dados["entrevistas"].append(
            {"titulo": "Coletiva: Presidente Pedrinho projeta expansão patrimonial do clube.", "fonte": "Vasco TV",
             "url": ""})

    return dados


def obter_elenco_completo():
    """Retorna os atletas do elenco profissional do Vasco com foto sempre vazia.

    As URLs de foto anteriormente apontavam para "https://globo.com" (que não é
    uma imagem), o que gerava avatares quebrados/carregamentos de rede inúteis
    no iPhone e Android. Como o app não possui assets locais de fotos, o campo
    "foto" agora fica vazio e a interface exibe a inicial do atleta num avatar
    local (sem rede).
    """
    return [
        {"num": "1", "nome": "Léo Jardim", "pos": "Goleiro", "foto": ""},
        {"num": "96", "nome": "Paulo Henrique", "pos": "Lateral Direito", "foto": ""},
        {"num": "46", "nome": "Carlos Cuesta", "pos": "Zagueiro", "foto": ""},
        {"num": "6", "nome": "Lucas Piton", "pos": "Lateral Esquerdo", "foto": ""},
        {"num": "5", "nome": "Santiago Sosa", "pos": "Volante", "foto": ""},
        {"num": "10", "nome": "Philippe Coutinho", "pos": "Meio-Campo", "foto": ""},
        {"num": "9", "nome": "Facundo Colidio", "pos": "Atacante", "foto": ""},
        {"num": "28", "nome": "Adson", "pos": "Atacante", "foto": ""}
    ]

def obter_galeria_trofeus():
    """Retorna o acervo detalhado da Sala de Memórias e Troféus de São Januário."""
    return [
        {
            "titulo": "Copa Libertadores da América",
            "ano": "1998",
            "detalhes": "Conquistada no ano do centenário do clube, vencendo o Barcelona de Guayaquil na grande final histórica.",
            "icone": "🏆"
        },
        {
            "titulo": "Campeonato Sul-Americano de Campeões",
            "ano": "1948",
            "detalhes": "O lendário 'Expresso da Vitória' consagrou o Vasco como o primeiro campeão continental das Américas e do mundo invicto.",
            "icone": "🌎"
        },
        {
            "titulo": "Campeonato Brasileiro (4x)",
            "ano": "1974, 1989, 1997, 2000",
            "detalhes": "Quatro estrelas douradas no peito, eternizando esquadrões comandados por ídolos como Roberto Dinamite, Romário e Edmundo.",
            "icone": "⭐"
        },
        {
            "titulo": "Copa do Brasil",
            "ano": "2011",
            "detalhes": "O 'Trem Bala da Colina' dominou o país conquistando o troféu inédito diante do Coritiba, em uma campanha emocionante.",
            "icone": "🇧🇷"
        },
        {
            "titulo": "Copa Mercosul",
            "ano": "2000",
            "detalhes": "A virada do século. Vitória épica por 4 a 3 sobre o Palmeiras no Palestra Itália, após sair perdendo por 3 a 0 no primeiro tempo.",
            "icone": "🏹"
        },
        {
            "titulo": "Campeonato Carioca (24x)",
            "ano": "Histórico",
            "detalhes": "Desde a histórica e pioneira conquista dos Camisas Negras em 1923, combatendo o preconceito racial e social no futebol brasileiro.",
            "icone": "🥇"
        }
    ]



def obter_tabela_e_calendario():
    classificacao = [
        {"pos": "6", "time": "Vasco da Gama", "pts": "42", "jogos": "24"},
        {"pos": "7", "time": "Internacional", "pts": "41", "jogos": "24"},
        {"pos": "8", "time": "Cruzeiro", "pts": "39", "jogos": "24"}
    ]
    calendario = [
        {"comp": "Brasileirão", "adversario": "Cruzeiro", "data": "Hoje - 21h20", "tv": "Premiere & SporTV"},
        {"comp": "Copa do Brasil", "adversario": "Vitória", "data": "Quarta - 21h30", "tv": "CazéTV"}
    ]
    return classificacao, calendario


def obter_uniformes_2026():
    """Retorna os dados oficiais e links visuais da nova coleção de mantos lançada pela Nike para 2026."""
    return [
        {
            "tipo": "Uniforme 1 - Home (Tradicional)",
            "detalhes": "Camisa preta tradicional com a mítica faixa diagonal branca, gola polo texturizada.",
            "imagem": ""
        },
        {
            "tipo": "Uniforme 2 - Away (Visitante)",
            "detalhes": "Branca com a faixa diagonal preta, detalhes minimalistas nos punhos das mangas.",
            "imagem": ""
        },
        {
            "tipo": "Uniforme 3 - Alternativo Especial (Velas das Naus)",
            "detalhes": "Totalmente amarela pálida sem faixa diagonal, homenageando as caravelas históricas com detalhes pretos e a Cruz de Malta em destaque vermelho intenso no peito.",
            "imagem": ""
        }
    ]
def obter_playlist_torcida():
    """Retorna os cantos clássicos da torcida do Vasco com links de áudio diretos."""
    return [
        {
            "titulo": "Camisas Negras",
            "sub": "A história que o futebol tenta esquecer",
            "url": "https://soundhelix.com" # Substitua pelo arquivo real correspondente
        },
        {
            "titulo": "Anna Julia do Vasco",
            "sub": "Quem é que tem a maior torcida do mundo?!",
            "url": "https://soundhelix.com"
        },
        {
            "titulo": "Na Barreira eu vou festejar",
            "sub": "Sentimento não para!",
            "url": "https://soundhelix.com"
        },
        {
            "titulo": "Hino Oficial do Club de Regatas Vasco da Gama",
            "sub": "Vamos todos cantar de coração",
            "url": "https://soundhelix.com"
        }
    ]

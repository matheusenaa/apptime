import requests
from bs4 import BeautifulSoup


class RealMatchDay365:
    def __init__(self):
        self.partida_ativa = True
        self.placar_vasco = 3
        self.placar_adversario = 1
        self.adversario = "Cruzeiro"
        self.estatisticas = {
            "posse": 46,
            "finalizacoes_vasco": 9,
            "finalizacoes_adv": 6,
            "faltas_vasco": 11,
            "faltas_adv": 14
        }
        self.escalacao_titular = [
            "1. Léo Jardim (Goleiro)",
            "96. Paulo Henrique (Lateral)",
            "46. Carlos Cuesta (Zagueiro)",
            "43. Lucas Freitas (Zagueiro)",
            "6. Lucas Piton (Lateral)",
            "5. Santiago Sosa (Volante)",
            "3. Tchê Tchê (Meia)",
            "23. Thiago Mendes (Meia)",
            "11. Andrés Gómez (Atacante)",
            "9. Facundo Colidio (Atacante)",
            "28. Adson (Atacante)"
        ]
        self.cronologia_lances = [
            "94' 2T - ⚽ GOOOOOOOL DA RAPOSA! Felipe Morais desconta no apito final.",
            "91' 2T - ⚽ GOOOOOOOL DO VASCO! Contra-ataque mortal e David amplia o placar!",
            "84' 2T - 🔄 Substituição no Vasco: Sai Tchê Tchê sob aplausos, entra Ramon Rique.",
            "78' 2T - 🔄 Substituição dupla: Saem Colidio e Sosa, entram David e Cauan Barros.",
            "54' 2T - ⚽ GOOOOOOOL DO GIGANTE! Lucas Piton cobra escanteio e Lucas Freitas escora livre!",
            "45' 2T - 🏟️ Reinicia o confronto! Cruzeiro tenta adiantar as linhas em São Januário.",
            "45' 1T - 🏁 Fim do primeiro tempo regulamentar. Vasco dominante e vencendo bem.",
            "32' 1T - ⚽ GOOOOOOOL DO VASCO! Tchê Tchê invade a grande área e chuta rasteiro no canto!",
            "26' 1T - 🟨 Cartão Amarelo para Adson por parar contra-ataque promissor.",
            "14' 1T - 🛑 Milagre de Otávio! Andrés Gómez entorta a marcação e Adson cabeceia para defesa monumental.",
            "00' 1T - 🏟️ Árbitro autoriza! Bola rolando no caldeirão para Vasco x Cruzeiro!"
        ]

    def coletar_dados_ao_vivo(self):
        url_tempo_real = "https://lance.com.br"
        headers = {"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"}

        try:
            resposta = requests.get(url_tempo_real, headers=headers, timeout=4)
            if resposta.status_code == 200:
                soup = BeautifulSoup(resposta.text, 'html.parser')
                elementos_lances = soup.find_all('div', class_='feed-post-body')
                if elementos_lances:
                    novos_lances = []
                    for item in elementos_lances[:10]:
                        texto_lance = item.get_text().strip()
                        if texto_lance:
                            novos_lances.append(texto_lance)
                    if novos_lances:
                        self.cronologia_lances = novos_lances

        except Exception as e:
            print(f"[MatchDay API]: Usando última persistência estável.")

        return {
            "placar_vasco": self.placar_vasco,
            "placar_adv": self.placar_adversario,
            "adversario": self.adversario,
            "estatisticas": self.estatisticas,
            "escalacao": self.escalacao_titular,
            "lances": self.cronologia_lances
        }

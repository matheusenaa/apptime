import os
import sqlite3
import time

import scraping as src


class DBManager365:
    """Gerenciador híbrido de dados: internet + cache SQLite persistente.

    Em dispositivos, o banco fica no diretório de dados persistente do app
    (variável FLET_APP_STORAGE_DATA), preservando o cache entre execuções.
    """

    def __init__(self):
        self.db_path = self._definir_caminho_banco()
        self._cache = {}
        self._cache_ttl = 60
        self.inicializar_banco()

    @staticmethod
    def _definir_caminho_banco():
        pasta_dados = os.environ.get("FLET_APP_STORAGE_DATA")
        if pasta_dados:
            return os.path.join(pasta_dados, "vasco_cache.db")
        return "vasco_cache.db"

    def inicializar_banco(self):
        with sqlite3.connect(self.db_path) as conn:
            cursor = conn.cursor()
            cursor.execute('''
                CREATE TABLE IF NOT EXISTS noticias (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    titulo TEXT UNIQUE,
                    fonte TEXT,
                    url TEXT,
                    categoria TEXT,
                    timestamp REAL
                )
            ''')
            conn.commit()

    def _ultimas_do_banco(self, limite=15):
        with sqlite3.connect(self.db_path) as conn:
            conn.row_factory = sqlite3.Row
            cursor = conn.cursor()
            cursor.execute(
                "SELECT titulo, fonte, url, categoria FROM noticias ORDER BY id DESC LIMIT ?",
                (limite,))
            return [dict(r) for r in cursor.fetchall()]

    def obter_noticias_hibrido(self):
        """Retorna notícias com prioridade para cache em RAM, depois internet
        e só então o banco SQLite (quando a rede estiver indisponível)."""
        agora = time.time()

        # 1. Cache rápido em memória
        if "noticias" in self._cache:
            if agora - self._cache["noticias"]["timestamp"] < self._cache_ttl:
                return self._cache["noticias"]["dados"]

        # 2. Internet (com fallback automático em caso de falha de rede)
        novas_noticias, online = self._buscar_da_internet()

        # 3. Persistência no SQLite quando a rede respondeu
        if online:
            with sqlite3.connect(self.db_path) as conn:
                cursor = conn.cursor()
                for n in novas_noticias:
                    try:
                        cursor.execute('''
                            INSERT OR REPLACE INTO noticias (titulo, fonte, url, categoria, timestamp)
                            VALUES (?, ?, ?, ?, ?)
                        ''', (n["titulo"], n["fonte"], n["url"], n["categoria"], agora))
                    except Exception:
                        # Notícia duplicada ou campo inválido: ignora sem quebrar o app
                        pass
                conn.commit()

        # 4. Resgata do banco para montar a lista do celular
        linhas = self._ultimas_do_banco()
        dados_finais = {
            "ultimas": linhas,
            "entrevistas": [],
            "bastidores": [],
            "online": online,
        }

        # 5. Se o banco estiver vazio por falha de rede, usa manchetes locais
        if not dados_finais["ultimas"]:
            dados_finais["ultimas"] = [
                {"titulo": "Vasco inicia preparação para enfrentar o Vitória na Copa do Brasil.",
                 "fonte": "VascoTV", "url": "https://vasco.com.br", "categoria": "ultimas"},
                {"titulo": "Notícias atualizadas não disponíveis sem conexão no momento.",
                 "fonte": "Boletim", "url": "", "categoria": "ultimas"},
            ]

        self._cache["noticias"] = {"timestamp": agora, "dados": dados_finais}
        return dados_finais

    def _buscar_da_internet(self):
        """Coleta notícias das fontes específicas do Vasco (scraping.py),
        com degradação graciosa quando a rede falha."""
        try:
            dados = src.obter_noticias_completas()
            ultimas = dados.get("ultimas") or []

            # Normaliza as fontes e remove links vazios
            lista = []
            for n in ultimas[:15]:
                if n.get("titulo"):
                    lista.append({
                        "titulo": n["titulo"],
                        "fonte": n.get("fonte") or "Internet",
                        "url": n.get("url") or "",
                        "categoria": "ultimas",
                    })
            if lista:
                return lista, True
        except Exception:
            pass

        # Sem rede ou sem fontes disponíveis: usa o que já está no banco
        return [], False
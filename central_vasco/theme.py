"""Identidade visual do Vasco Hub 2026.

Paleta inspirada no Club de Regatas Vasco da Gama (preto, branco e tons
neutros), com uso pontual de vermelho apenas em elementos de destaque.
"""

import flet as ft

# Cores principais da identidade
COR_FUNDO = ft.Colors.BLACK          # Fundo principal
COR_CARD = "#161616"                 # Cards (cinza muito escuro)
COR_CARD_2 = "#1F1F1F"               # Cards secundários / chips
COR_BORDA = ft.Colors.WHITE_10        # Divisórias e bordas sutis
COR_TEXTO = ft.Colors.WHITE          # Texto principal
COR_TEXTO_FORTE = ft.Colors.GREY_300 # Texto de destaque
COR_TEXTO_SEC = ft.Colors.GREY_400   # Texto secundário
COR_VERMELHO_VASCO = "#E30613"       # Vermelho usado de forma pontual (Cruz de Malta)
COR_OK = ft.Colors.GREEN_400         # Indicadores positivos (bateria/conexão)
COR_ERRO_FUNDO = "#2A0A0A"
COR_ERRO_TEXTO = "#FF8A80"


def card(conteudo, cor=COR_CARD, raio=12, padding=12, borda=True, expand=False):
    """Contêiner no padrão visual do app (cinza muito escuro com borda sutil)."""
    return ft.Container(
        content=conteudo,
        bgcolor=cor,
        border_radius=raio,
        padding=padding,
        border=ft.Border.all(1, COR_BORDA) if borda else None,
        expand=expand,
    )


def titulo_secao(texto, icone=None, cor=COR_TEXTO):
    """Título de seção com ícone opcional."""
    controles = []
    if icone is not None:
        controles.append(ft.Icon(icone, size=18, color=cor))
    controles.append(ft.Text(texto, size=16, weight=ft.FontWeight.BOLD, color=cor))
    return ft.Row(controles, spacing=8)


def linha_estatistica(rotulo, valor, cor_valor=COR_TEXTO, negrito=False):
    """Linha rótulo + valor (usada nos resumos e históricos)."""
    return ft.Row(
        controls=[
            ft.Text(str(rotulo), size=13, color=COR_TEXTO_SEC, expand=True),
            ft.Text(
                str(valor),
                size=13,
                color=cor_valor,
                weight=ft.FontWeight.BOLD if negrito else ft.FontWeight.NORMAL,
            ),
        ],
        spacing=8,
    )


def chip_estatistica(rotulo, valor, cor_valor=COR_TEXTO):
    """Cartão compacto para estatística (grade de indicadores)."""
    return ft.Container(
        content=ft.Column(
            controls=[
                ft.Text(str(rotulo).upper(), size=10, color=COR_TEXTO_SEC),
                ft.Text(str(valor), size=16, weight=ft.FontWeight.BOLD, color=cor_valor),
            ],
            spacing=2,
            horizontal_alignment=ft.CrossAxisAlignment.CENTER,
        ),
        bgcolor=COR_CARD_2,
        border_radius=10,
        padding=10,
        border=ft.Border.all(1, COR_BORDA),
    )


def divisoria():
    return ft.Divider(height=1, color=COR_BORDA)


def estado_vazio(mensagem, icone=ft.Icons.INFO_OUTLINE):
    """Estado sem dados ou com dados indisponíveis."""
    return ft.Container(
        content=ft.Column(
            controls=[
                ft.Icon(icone, size=32, color=COR_TEXTO_SEC),
                ft.Text(mensagem, size=13, color=COR_TEXTO_SEC, text_align=ft.TextAlign.CENTER),
            ],
            horizontal_alignment=ft.CrossAxisAlignment.CENTER,
            spacing=8,
        ),
        padding=20,
        bgcolor=COR_CARD,
        border_radius=12,
        border=ft.Border.all(1, COR_BORDA),
    )


def mensagem_erro(mensagem):
    """Mensagem amigável de erro (sem traceback técnico para o usuário)."""
    return ft.Container(
        content=ft.Row(
            controls=[
                ft.Icon(ft.Icons.ERROR_OUTLINE, size=18, color=COR_ERRO_TEXTO),
                ft.Text(mensagem, size=13, color=COR_ERRO_TEXTO, expand=True),
            ],
            spacing=8,
        ),
        padding=12,
        bgcolor=COR_ERRO_FUNDO,
        border_radius=10,
        border=ft.Border.all(1, COR_ERRO_TEXTO),
    )
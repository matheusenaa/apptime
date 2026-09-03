/// Fatos marcantes verificados do Club de Regatas Vasco da Gama.
///
/// Exibidos na tela de Notícias como linha do tempo informativa. Cada item
/// é um fato REAL, com fonte pública. Nada aqui é inventado.
class ClubFact {
  final String categoria;
  final String titulo;
  final String descricao;
  final String year;
  final String fonte;

  const ClubFact({
    required this.categoria,
    required this.titulo,
    required this.descricao,
    required this.year,
    required this.fonte,
  });
}

/// Linha do tempo com fatos importantes do clube.
const List<ClubFact> clubFacts = [
  ClubFact(
    categoria: 'Fundação',
    titulo: 'Fundação do Club de Regatas Vasco da Gama',
    descricao:
        'Fundado em 21/08/1898 por remadores, em homenagem ao navegador '
        'Vasco da Gama, no bairro da Saúde, Rio de Janeiro.',
    year: '1898',
    fonte: 'Site oficial do Vasco',
  ),
  ClubFact(
    categoria: 'Inclusão',
    titulo: '4 x 0 contra o América e a luta antirracista',
    descricao:
        'A Resposta Histórica de 1924: o Vasco recusou excluir atletas negros '
        'e operários exigidos pela liga, em defesa da democracia no esporte.',
    year: '1924',
    fonte: 'Site oficial do Vasco',
  ),
  ClubFact(
    categoria: 'Conquista',
    titulo: 'Campeão da Taça de Prata (1º título nacional)',
    descricao:
        'Conquistou o Campeonato Brasileiro pela primeira vez, fechando o '
        'título com a maior campanha da história do torneio.',
    year: '1974',
    fonte: 'Wikipédia / CBF',
  ),
  ClubFact(
    categoria: 'Conquista',
    titulo: 'Campeão Brasileiro',
    descricao:
        'Liderado por Roberto Dinamite, o Vasco levanta o segundo título '
        'nacional diante do São Paulo.',
    year: '1989',
    fonte: 'Wikipédia / CBF',
  ),
  ClubFact(
    categoria: 'Conquista',
    titulo: 'Campeão Brasileiro e da Copa Libertadores da América',
    descricao:
        'Ano mágico: conquista o Brasileirão e o inédito título da '
        'Libertadores com Edmundo e companhia.',
    year: '1997',
    fonte: 'Wikipédia / CONMEBOL',
  ),
  ClubFact(
    categoria: 'Conquista',
    titulo: 'Campeão da Copa João Havelange',
    descricao:
        'Conquista o quarto título nacional do clube. É também o ano do '
        'primeiro título da Copa do Brasil.',
    year: '2000',
    fonte: 'Wikipédia / CBF',
  ),
  ClubFact(
    categoria: 'Conquista',
    titulo: 'Campeão da Copa do Brasil',
    descricao:
        'Vence o Coritiba na final (3x3 no agregado, gol fora de casa) e '
        'levanta o único título da Copa do Brasil da história do clube.',
    year: '2011',
    fonte: 'Wikipédia / Globo Esporte',
  ),
  ClubFact(
    categoria: 'Conquista',
    titulo: 'Vice-campeão da Copa do Brasil',
    descricao:
        'Disputa a final da Copa do Brasil contra o Corinthians, terminando '
        'com o vice-campeonato.',
    year: '2025',
    fonte: 'Wikipédia / Globo Esporte',
  ),
];

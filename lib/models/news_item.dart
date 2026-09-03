/// Modelo de uma notícia exibida no feed.
class NewsItem {
  final String title;
  final String source;
  final String url;
  final String? imageUrl;
  final DateTime? date;
  final String summary;

  const NewsItem({
    required this.title,
    required this.source,
    required this.url,
    this.imageUrl,
    this.date,
    this.summary = '',
  });

  factory NewsItem.fromMap(Map<String, dynamic> json) => NewsItem(
        title: json['titulo']?.toString() ?? json['title']?.toString() ?? 'Sem título',
        source: json['fonte']?.toString() ?? json['source']?.toString() ?? 'Desconhecida',
        url: json['url']?.toString() ?? '',
        imageUrl: json['imagem']?.toString(),
        date: DateTime.tryParse(json['data']?.toString() ?? ''),
        summary: json['resumo']?.toString() ?? json['summary']?.toString() ?? '',
      );

  Map<String, dynamic> toMap() => {
        'titulo': title,
        'fonte': source,
        'url': url,
        'imagem': imageUrl,
        'data': date?.toIso8601String(),
        'resumo': summary,
      };
}

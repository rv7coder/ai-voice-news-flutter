class NewsModel {
  final String title;
  final String description;
  final String field;
  final String image;
  final String url;
  final String source;
  final String publishedAt;
  final String? bookmarkId;

  NewsModel({
    required this.title,
    required this.description,
    required this.field,
    required this.image,
    required this.url,
    required this.source,
    required this.publishedAt,
    required this.bookmarkId,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      title: json["title"] ?? "",
      description: json["description"] ?? "",
      field: json["field"] ?? "",
      image: json["image"] ?? "",
      url: json["url"] ?? "",
      source: json["source"] ?? "",
      publishedAt: json["publishedAt"] ?? "",
      bookmarkId: json["bookmark_id"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "description": description,
      "field": field,
      "image": image,
      "url": url,
      "source": source,
      "publishedAt": publishedAt,
    };
  }
}
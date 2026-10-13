class SearchRequest {
  final String query;

  SearchRequest({
    required this.query,
  });

  Map<String, dynamic> toJson() {
    return {
      "query": query,
    };
  }
}
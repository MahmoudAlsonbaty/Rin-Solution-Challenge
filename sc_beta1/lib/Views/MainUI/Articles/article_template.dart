class Article {
  final String text;
  final String Author;
  final String Title;
  final bool verified;
  final String image_url;
  final String tags;

  Article(
      {required this.tags,
      required this.text,
      required this.Title,
      required this.Author,
      required this.verified,
      required this.image_url});
}

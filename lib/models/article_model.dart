class ArticleModel {
  final String id;
  final String title;
  final String content;
  final String category;
  final DateTime createdAt;
  final String? authorId;
  final String? authorName;
  final List<String> tags;
  final List<String> audience;
  final String? imageUrl;

  ArticleModel({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.createdAt,
    this.authorId,
    this.authorName,
    this.tags = const [],
    this.audience = const [],
    this.imageUrl,
  });

  factory ArticleModel.fromMap(Map<String, dynamic> map, String id) {
    // Handle the tags which should be a List<String>
    List<String> parsedTags = [];
    if (map['tags'] != null) {
      if (map['tags'] is List) {
        parsedTags = List<String>.from(map['tags']);
      } else if (map['tags'] is Map) {
        parsedTags = (map['tags'] as Map).values.map((e) => e.toString()).toList();
      }
    }

    // Handle the audience which should be a List<String>
    List<String> parsedAudience = [];
    if (map['audience'] != null) {
      if (map['audience'] is List) {
        parsedAudience = List<String>.from(map['audience']);
      } else if (map['audience'] is Map) {
        parsedAudience = (map['audience'] as Map).values.map((e) => e.toString()).toList();
      }
    }

    return ArticleModel(
      id: id,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      category: map['category'] ?? 'uncategorized',
      createdAt: map['createdAt'] != null
         ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
        : DateTime.now(),
      authorId: map['authorId'],
      authorName: map['authorName'],
      tags: parsedTags,
      audience: parsedAudience,
      imageUrl: map['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'category': category,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'authorId': authorId,
      'authorName': authorName,
      'tags': tags,
      'audience': audience,
      'imageUrl': imageUrl,
    };
  }
}
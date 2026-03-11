class FavoriteConversion {
  const FavoriteConversion({
    required this.categoryName,
    required this.fromSymbol,
    required this.toSymbol,
    required this.title,
    required this.createdAt,
  });

  final String categoryName;
  final String fromSymbol;
  final String toSymbol;
  final String title;
  final DateTime createdAt;

  String get id => '$categoryName:$fromSymbol:$toSymbol';

  Map<String, dynamic> toJson() {
    return {
      'categoryName': categoryName,
      'fromSymbol': fromSymbol,
      'toSymbol': toSymbol,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory FavoriteConversion.fromJson(Map<String, dynamic> json) {
    return FavoriteConversion(
      categoryName: json['categoryName'] as String,
      fromSymbol: json['fromSymbol'] as String,
      toSymbol: json['toSymbol'] as String,
      title: json['title'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
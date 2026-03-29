class Comment {
  final String id;
  final String artistId;
  final String text;

  Comment({
    required this.id,
    required this.artistId,
    required this.text,
  });

  static Comment fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      artistId: json['artistId'],
      text: json['text'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'artistId': artistId,
      'text': text,
    };
  }
}

class Artist {
  final String id;
  final String name;
  final String genre;
  final Uri imageUrl;
  final List<String> songs;
  final List<String> comments;

  Artist({
    required this.id,
    required this.name,
    required this.genre,
    required this.imageUrl,
    this.songs = const [],
    this.comments = const [],
  });

  @override
  String toString() {
    return 'Artist(id: $id, name: $name, genre: $genre, imageUrl: $imageUrl, songs: $songs, comments: $comments)';
  }
}

 import '../../model/artist/artist.dart';

class ArtistDto {
  static const String nameKey = 'name';
  static const String genreKey = 'genre';
  static const String imageUrlKey = 'imageUrl';
  static const String songIdsKey = 'songs';
  static const String commentIdsKey = 'comments';

  static Artist fromJson(String id, Map<String, dynamic> json) {
    assert(json[nameKey] is String);
    assert(json[genreKey] is String);
    assert(json[imageUrlKey] is String);

    // Handle songs - could be a List or Map of IDs
    final List<String> songIds = _extractIds(json[songIdsKey]);
    final List<String> commentIds = _extractIds(json[commentIdsKey]);
    
    return Artist(
      id: id,
      name: json[nameKey],
      genre: json[genreKey],
      imageUrl: Uri.parse(json[imageUrlKey]),
      songs: songIds,
      comments: commentIds,
    );
  }

  static List<String> _extractIds(dynamic value) {
    if (value == null) {
      return [];
    }
    
    // If it's a List, cast to List<String>
    if (value is List) {
      return (value as List).map((e) => e.toString()).toList();
    }
    
    // If it's a Map (object with IDs as keys), extract the keys
    if (value is Map) {
      return (value as Map).keys.map((e) => e.toString()).toList();
    }
    
    return [];
  }

  /// Convert Artist to JSON
  Map<String, dynamic> toJson(Artist artist) {
    return {
      nameKey: artist.name,
      genreKey: artist.genre,
      imageUrlKey: artist.imageUrl.toString(),
      songIdsKey: artist.songs,
      commentIdsKey: artist.comments,
    };
  }
}

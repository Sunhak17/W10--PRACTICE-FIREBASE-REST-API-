import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:w10_practice/model/artist/comment.dart';
import 'package:w10_practice/model/songs/song.dart';
 
import '../../../model/artist/artist.dart';
import '../../dtos/artist_dto.dart';
import '../../dtos/song_dto.dart';
import 'artist_repository.dart';

class ArtistRepositoryFirebase implements ArtistRepository {
  final Uri artistsUri = Uri.https(
    'w10-practice-4996f-default-rtdb.asia-southeast1.firebasedatabase.app',
    '/artists.json',
  );

  final Uri songsUri = Uri.https(
    'w10-practice-4996f-default-rtdb.asia-southeast1.firebasedatabase.app',
    '/songs.json',
  );

  final Uri commentsUri = Uri.https(
    'w10-practice-4996f-default-rtdb.asia-southeast1.firebasedatabase.app',
    '/comments.json',
  );

  List<Artist>? _cachedArtists;

  @override
  
  Future<List<Artist>> fetchArtists() async {
    // 1. Return cache if Artist available
    if (_cachedArtists != null) {
      return _cachedArtists!;
    }

    // 2. Otherwise fetch from API
    final http.Response response = await http.get(artistsUri);

    if (response.statusCode == 200) {
      // 1 - Send the retrieved list of songs
      Map<String, dynamic> songJson = json.decode(response.body);

      List<Artist> result = [];
      for (final entry in songJson.entries) {
        result.add(ArtistDto.fromJson(entry.key, entry.value));
      }

    // 3. Store in memory
      _cachedArtists = result;
      return result;
    } else {
      throw Exception('Failed to load posts');
    }
  }

  @override
  Future<Artist?> fetchArtistById(String id) async {
    final response = await http.get(artistsUri);
    if (response.statusCode == 200) {
      Map<String, dynamic> artistJson = json.decode(response.body);
      if (artistJson.containsKey(id)) {
        return ArtistDto.fromJson(id, artistJson[id]);
      }
    }
    return null;
  }

  @override
  Future<List<Comment>> fetchArtistComments(String artistId) async {
    try {
      final response = await http.get(commentsUri);

      if (response.statusCode == 200) {
        final body = response.body;        
        Map<String, dynamic> commentJson = json.decode(body);
        List<Comment> result = [];
        for (final entry in commentJson.entries) {
          final comment = Comment.fromJson(entry.value);
          if (comment.artistId == artistId) {
            result.add(comment);
          }
        }
        return result;
      } else if (response.statusCode == 404) {
        return [];
      }
      throw Exception('Failed to load artist comments: ${response.statusCode}');
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<Song>> fetchArtistSongs(String artistId) async {
    try {
      final response = await http.get(songsUri);

      if (response.statusCode == 200) {
        final body = response.body;        
        Map<String, dynamic> songJson = json.decode(body);
        List<Song> result = [];
        for (final entry in songJson.entries) {
          final song = SongDto.fromJson(entry.key, entry.value);
          if (song.artistId == artistId) {
            result.add(song);
          }
        }
        return result;
      } else if (response.statusCode == 404) {
        return [];
      }
      throw Exception('Failed to load artist songs: ${response.statusCode}');
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> postArtistComment(String artistId, String text) async {
    final response = await http.post(
      commentsUri,
      body: json.encode({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'text': text, 
        'artistId': artistId,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to post artist comment: ${response.statusCode}');
    }
  }
}

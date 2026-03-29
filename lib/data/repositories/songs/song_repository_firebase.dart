import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../model/songs/song.dart';
import '../../dtos/song_dto.dart';
import 'song_repository.dart';

class SongRepositoryFirebase extends SongRepository {
  final Uri songsUri = Uri.https(
    'w10-practice-4996f-default-rtdb.asia-southeast1.firebasedatabase.app',
    '/songs.json',
  );

  List<Song>? _cachedSongs;
  

  @override
  Future<List<Song>> fetchSongs({bool forceFetch = false}) async {
    // 1. Return cache if Song available
    if (!forceFetch && _cachedSongs != null) {
      return _cachedSongs!;
    }

    // 2. Otherwise fetch from API
    final http.Response response = await http.get(songsUri);

    if (response.statusCode == 200) {
      // 1 - Send the retrieved list of songs
      Map<String, dynamic> songJson = json.decode(response.body);

      List<Song> result = [];
      for (final entry in songJson.entries) {
        result.add(SongDto.fromJson(entry.key, entry.value));
      }

      //3. Store in memory
      _cachedSongs = result;
      return result;
    } else {
      throw Exception('Failed to load posts');
    }
  }

  void clearCache() {
    _cachedSongs = null;
  }

  @override
  Future<Song?> fetchSongById(String id) async {
    final songs = await fetchSongs();
    try{
      return songs.firstWhere((song) => song.id == id);
    } catch (error) {
      return null;
    }
  }

  @override
  Future<void> likeSong(String id, int likeCount) async {
    final Uri songUri = songsUri.replace(path: '/songs/$id.json');

    final http.Response response = await http.patch(
      songUri,
      body: json.encode({'likeCount': likeCount}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update song like count');
    }
  }
}

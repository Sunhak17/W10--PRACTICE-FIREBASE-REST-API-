import '../../../model/songs/song.dart';

abstract class SongRepository {
  Future<List<Song>> fetchSongs({required bool forceFetch});
  
  Future<Song?> fetchSongById(String id);

  Future<void> likeSong(String id, int likeCount);
}

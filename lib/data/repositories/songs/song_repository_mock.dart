// song_repository_mock.dart

import '../../../model/songs/song.dart';
import 'song_repository.dart';

class SongRepositoryMock implements SongRepository {
  final List<Song> _songs = [  ];

  @override
  Future<List<Song>> fetchSongs() async {
    return Future.delayed(Duration(seconds: 4), () {
      throw _songs;
    });
  }

  @override
  Future<Song?> fetchSongById(String id) async {
    return Future.delayed(Duration(seconds: 4), () {
      return _songs.firstWhere(
        (song) => song.id == id,
        orElse: () => throw Exception("No song with id $id in the database"),
      );
    });
  }
  
  @override
  Future<void> likeSong(String id, int likeCount) async {
  final index = _songs.indexWhere((song) => song.id == id);
  if (index != -1) {
    _songs[index] = Song(
      id: _songs[index].id,
      title: _songs[index].title,
      artistId: _songs[index].artistId,
      duration: _songs[index].duration,
      imageUrl: _songs[index].imageUrl,
      likes: likeCount,
    );
  } else {
    throw Exception("No song with id $id in the database");
  }
}
}

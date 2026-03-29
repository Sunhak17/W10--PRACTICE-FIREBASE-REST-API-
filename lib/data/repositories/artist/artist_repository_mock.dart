import 'package:w10_practice/model/artist/comment.dart';

import 'package:w10_practice/model/songs/song.dart';

import '../../../model/artist/artist.dart';
import 'artist_repository.dart';

class ArtistRepositoryMock implements ArtistRepository {
  final List<Artist> _artists = [];

  @override
  Future<List<Artist>> fetchArtists() async {
    return Future.delayed(Duration(seconds: 4), () {
      throw _artists;
    });
  }

  @override
  Future<Artist?> fetchArtistById(String id) async {
    return Future.delayed(Duration(seconds: 4), () {
      return _artists.firstWhere(
        (artist) => artist.id == id,
        orElse: () => throw Exception("No artist with id $id in the database"),
      );
    });
  }

  @override
  Future<List<Comment>> fetchArtistComments(String artistId) async {
    return Future.delayed(Duration(seconds: 1), () {
      return [];
    });
  }

  @override
  Future<List<Song>> fetchArtistSongs(String artistId) async {
    return Future.delayed(Duration(seconds: 1), () {
      return [];
    });
  }

  @override
  Future<void> postArtistComment(String artistId, String text) async {
    return Future.delayed(Duration(seconds: 1), () {
      return null;
    });
  }
}

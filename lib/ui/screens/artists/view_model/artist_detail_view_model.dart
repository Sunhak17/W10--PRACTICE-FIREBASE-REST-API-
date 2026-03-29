import 'package:flutter/material.dart';
import '../../../../data/repositories/artist/artist_repository.dart';
import '../../../../data/repositories/songs/song_repository.dart';
import '../../../../model/artist/comment.dart';
import '../../../../model/songs/song.dart';
import '../../../utils/async_value.dart';

class ArtistDetailViewModel extends ChangeNotifier {
  final ArtistRepository artistRepository;
  final SongRepository songRepository;
  final String artistId;

  AsyncValue<List<Song>> songsValue = AsyncValue.loading();
  AsyncValue<List<Comment>> commentsValue = AsyncValue.loading();

  ArtistDetailViewModel({
    required this.artistRepository,
    required this.songRepository,
    required this.artistId,
  }) {
    _init();
  }

  void _init() async {
    fetchData();
  }

  Future<void> fetchData() async {
    songsValue = AsyncValue.loading();
    commentsValue = AsyncValue.loading();
    notifyListeners();

    try {
      final songsResult = await artistRepository.fetchArtistSongs(artistId);
      final commentsResult = await artistRepository.fetchArtistComments(artistId);

      songsValue = AsyncValue.success(songsResult);
      commentsValue = AsyncValue.success(commentsResult);
    } catch (e) {
      songsValue = AsyncValue.error(e);
      commentsValue = AsyncValue.error(e);
    }
    notifyListeners();
  }

  Future<void> addComment(String text) async {
    if (text.isEmpty) {
      throw Exception('Comment cannot be empty');
    }

    try {
      await artistRepository.postArtistComment(artistId, text);

      if (commentsValue.state == AsyncValueState.success) {
        final newComment = Comment(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          artistId: artistId,
          text: text,
        );
        final updatedComments = [...commentsValue.data!, newComment];
        commentsValue = AsyncValue.success(updatedComments);
      }
    } catch (e) {
      throw Exception('Failed to post comment: $e');
    }
    notifyListeners();
  }
}

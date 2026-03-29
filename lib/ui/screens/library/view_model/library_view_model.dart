import 'package:flutter/material.dart';
import '../../../../data/repositories/artist/artist_repository.dart';
import '../../../../data/repositories/songs/song_repository.dart';
import '../../../../model/artist/artist.dart';
import '../../../states/player_state.dart';
import '../../../../model/songs/song.dart';
import '../../../utils/async_value.dart';
import 'library_item_data.dart';

class LibraryViewModel extends ChangeNotifier {
  final SongRepository songRepository;
  final ArtistRepository artistRepository;

  final PlayerState playerState;

  AsyncValue<List<LibraryItemData>> data = AsyncValue.loading();

  LibraryViewModel({
    required this.songRepository,
    required this.playerState,
    required this.artistRepository,
  }) {
    playerState.addListener(notifyListeners);

    // init
    _init();
  }

  @override
  void dispose() {
    playerState.removeListener(notifyListeners);
    super.dispose();
  }

  void _init() async {
    fetchSong();
  }

  Future<void> fetchSong({bool forceFetch = false}) async {
    // 1- Loading state
    data = AsyncValue.loading();
    notifyListeners();

    try {
      // 1- Fetch songs
      List<Song> songs = await songRepository.fetchSongs(forceFetch: forceFetch);

      // 2- Fetch artist
      List<Artist> artists = await artistRepository.fetchArtists();

      // 3- Create the mapping artistid-> artist
      Map<String, Artist> mapArtist = {};
      for (Artist artist in artists) {
        mapArtist[artist.id] = artist;
      }

      List<LibraryItemData> data = songs
          .map(
            (song) =>
                LibraryItemData(song: song, artist: mapArtist[song.artistId]!),
          )
          .toList();

      this.data = AsyncValue.success(data);

    } catch (e) {
      data = AsyncValue.error(e);
    }
    notifyListeners();
  }

  bool isSongPlaying(Song song) => playerState.currentSong == song;

  void start(Song song) => playerState.start(song);
  void stop(Song song) => playerState.stop();

  Future<void> likeSong(Song song) async {
    if (data.state == AsyncValueState.success) {
    final updatedList = data.data!.map((item) {
      if (item.song.id == song.id) {
        return LibraryItemData(
          song: Song(
            id: item.song.id,
            title: item.song.title,
            artistId: item.song.artistId,
            duration: item.song.duration,
            imageUrl: item.song.imageUrl,
            likes: item.song.likes + 1,
          ),
          artist: item.artist,
        );
      }
      return item;
    }).toList();
    data = AsyncValue.success(updatedList);
    notifyListeners();
  }

  await songRepository.likeSong(song.id, song.likes + 1);
  }
}

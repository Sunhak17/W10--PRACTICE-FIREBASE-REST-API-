import 'package:flutter/material.dart';
import '../../../../data/repositories/artist/artist_repository.dart';
import '../../../../model/artist/artist.dart';
import '../../../utils/async_value.dart';

class ArtistsViewModel extends ChangeNotifier {
  final ArtistRepository artistRepository;

  AsyncValue<List<Artist>> artistsValue = AsyncValue.loading();

  ArtistsViewModel({required this.artistRepository}) {
    _init();
  }

  void _init() async {
    fetchArtists();
  }

  Future<void> fetchArtists() async {
    artistsValue = AsyncValue.loading();
    notifyListeners();

    try {
      final result = await artistRepository.fetchArtists();
      artistsValue = AsyncValue.success(result);
    } catch (error) {
      artistsValue = AsyncValue.error(error);
    }
    notifyListeners();
  }
}

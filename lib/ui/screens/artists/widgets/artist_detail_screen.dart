import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/repositories/artist/artist_repository.dart';
import '../../../../data/repositories/songs/song_repository.dart';
import '../../../../model/artist/artist.dart';
import '../../../theme/theme.dart';
import '../../../utils/async_value.dart';
import '../../../widgets/comment/comment_tile.dart';
import '../view_model/artist_detail_view_model.dart';

class ArtistDetailScreen extends StatefulWidget {
  final Artist artist;

  const ArtistDetailScreen({super.key, required this.artist});

  @override
  State<ArtistDetailScreen> createState() => _ArtistDetailScreenState();
}

class _ArtistDetailScreenState extends State<ArtistDetailScreen> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _showCommentBottomSheet(ArtistDetailViewModel vm) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Add a Comment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: _commentController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Write your comment...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () async {
                  final text = _commentController.text.trim();
                  final nav = Navigator.of(context);
                  final messenger = ScaffoldMessenger.of(context);
                  
                  if (text.isEmpty) {
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Comment cannot be empty')),
                    );
                    return;
                  }
                  try {
                    await vm.addComment(text);
                    _commentController.clear();
                    nav.pop();
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Comment posted successfully')),
                    );
                  } catch (e) {
                    messenger.showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                },
                child: const Text('Post Comment'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ArtistDetailViewModel(
        artistRepository: context.read<ArtistRepository>(),
        songRepository: context.read<SongRepository>(),
        artistId: widget.artist.id,
      ),
      child: Scaffold(
        appBar: AppBar(title: Text(widget.artist.name)),
        body: Consumer<ArtistDetailViewModel>(
          builder: (context, vm, _) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Songs Section
                    Text('Songs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _buildSongsSection(vm),
                    const SizedBox(height: 24),

                    // Comments Section
                    Text('Comments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _buildCommentsSection(vm),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        ),
        floatingActionButton: Consumer<ArtistDetailViewModel>(
          builder: (context, vm, _) {
            return FloatingActionButton(
              onPressed: () => _showCommentBottomSheet(vm),
              child: const Icon(Icons.add),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSongsSection(ArtistDetailViewModel vm) {
    final songsValue = vm.songsValue;

    switch (songsValue.state) {
      case AsyncValueState.loading:
        return const Center(child: CircularProgressIndicator());
      case AsyncValueState.error:
        return Center(
          child: Text('Error loading songs', style: TextStyle(color: Colors.red)),
        );
      case AsyncValueState.success:
        final songs = songsValue.data ?? [];
        if (songs.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No songs found for this artist'),
            ),
          );
        }
        return ListView.builder(
          shrinkWrap: true,
          itemCount: songs.length,
          itemBuilder: (context, index) {
            final song = songs[index];
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(song.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text('${song.duration.inMinutes} mins • ${song.likes} likes', 
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            );
          },
        );
    }
  }

  Widget _buildCommentsSection(ArtistDetailViewModel vm) {
    final commentsValue = vm.commentsValue;

    switch (commentsValue.state) {
      case AsyncValueState.loading:
        return const Center(child: CircularProgressIndicator());
      case AsyncValueState.error:
        return Center(
          child: Text('Error loading comments', style: TextStyle(color: Colors.red)),
        );
      case AsyncValueState.success:
        final comments = commentsValue.data ?? [];
        if (comments.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No comments yet. Be the first to comment!'),
            ),
          );
        }
        return ListView.builder(
          shrinkWrap: true,
          itemCount: comments.length,
          itemBuilder: (context, index) => CommentTile(comment: comments[index]),
        );
    }
  }
}

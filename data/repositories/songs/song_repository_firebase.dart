import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../model/songs/song.dart';
import '../../dtos/song_dto.dart';
import 'song_repository.dart';

class SongRepositoryFirebase extends SongRepository {
  List<Song>? _cachedSongs;
  final Uri songsUri = Uri.https(
    'week-8-practice-5d28b-default-rtdb.asia-southeast1.firebasedatabase.app',
    '/projects/songs.json',
  );

  @override
  Future<List<Song>> fetchSongs({bool forceFetch = false}) async {
    if (forceFetch) {
      _cachedSongs = null;
    }
    if (_cachedSongs != null) {
      print("Returning Songs from Cache");
      return _cachedSongs!;
    }
    final http.Response response = await http.get(songsUri);

    if (response.statusCode == 200) {
      // 1 - Send the retrieved list of songs
      Map<String, dynamic> songJson = json.decode(response.body);

      List<Song> result = [];
      for (final entry in songJson.entries) {
        result.add(SongDto.fromJson(entry.key, entry.value));
      }
      _cachedSongs = result;
      return result;
    } else {
      // 2- Throw expcetion if any issue
      throw Exception('Failed to load posts');
    }
  }

  @override
  Future<Song?> fetchSongById(String id) async {}

  @override
  Future<void> updateSongLikes(String songId, int newLikeCount) async {
    final Uri individualSongUri = Uri.https(
      'week-8-practice-5d28b-default-rtdb.asia-southeast1.firebasedatabase.app',
      '/projects/songs/$songId.json',
    );
    final http.Response response = await http.patch(
      individualSongUri,
      body: json.encode({'likes': newLikeCount}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update likes for song $songId');
    }
    final songIndex = _cachedSongs?.indexWhere((s) => s.id == songId);
    if (songIndex != null && songIndex != -1) {
      _cachedSongs![songIndex].likes = newLikeCount;
    }
  }
}

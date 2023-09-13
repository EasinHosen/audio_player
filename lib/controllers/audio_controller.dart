import 'package:audio_player/utils/global_helpers.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';

class AudioController extends GetxController {
  static AudioController get to => Get.find();

  RxList<SongModel> songList = <SongModel>[].obs;
  RxList<AudioSource> audioSourceList = <AudioSource>[].obs;
  Rx<SongModel?> nowPlaying = Rx<SongModel?>(null);
  RxBool hasPermission = false.obs;
  RxBool songListLoading = false.obs;
  RxBool isPlaying = false.obs;
  // Rx<AudioPlayer> player = AudioPlayer().obs;
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  onInit() {
    checkAndReqPermission();
    super.onInit();
  }

  getSongs() async {
    songListLoading(true);
    final audioList = await _audioQuery.querySongs(
        /*orderType: OrderType.ASC_OR_SMALLER,
      ignoreCase: true,
      uriType: UriType.EXTERNAL,*/
        );
    songList.value = audioList;
    songListLoading(false);
    readySongs();
    loggerDebug(songList.length, 'number of audio');
  }

  playSelectedSong(String? uri) {
    try {
      _audioPlayer.setAudioSource(
        AudioSource.uri(Uri.parse(uri!)),
      );
      _audioPlayer.play();
      isPlaying(true);
    } catch (e) {
      loggerDebug(e, 'error on playSelectedSong');
    }
  }

  void playAndPause() {
    if (isPlaying.value) {
      _audioPlayer.pause();
      isPlaying(false);
    } else {
      _audioPlayer.play();
      isPlaying(true);
    }
  }

  void playNext() {
    if (_audioPlayer.hasNext) {
      _audioPlayer.seekToNext();
    } else {
      loggerDebug('nothing to play next');
    }
  }

  void playPrevious() {
    if (_audioPlayer.hasPrevious) {
      _audioPlayer.seekToPrevious();
    } else {
      loggerDebug('nothing to play');
    }
  }

  readySongs() async {
    if (songList.isNotEmpty) {
      audioSourceList.clear();
      songList.map((e) {
        final path = e.data.toString();
        audioSourceList.add(AudioSource.uri(Uri.parse(path)));
      }).toList();
      /*_audioPlayer.setAudioSource(ConcatenatingAudioSource(children: audioSourceList))
          .catchError((err) {
        loggerDebug(err, 'error on setAudioSource');
      });*/
      loggerDebug(songList[0].toString(), 'first song of songList');
      loggerDebug(
          audioSourceList[0].toString(), 'first song of audioSourceList');
    } else {
      loggerDebug('list empty', 'error on ready songs');
    }
    loggerDebug(audioSourceList.length, 'AudioSource list length');
  }

  checkAndReqPermission({bool retry = false}) async {
    hasPermission(await _audioQuery.checkAndRequest(
      retryRequest: retry,
    ));
    if (hasPermission.value) {
      getSongs();
    } else {
      loggerDebug(hasPermission.value, 'Permission');
    }
  }
}

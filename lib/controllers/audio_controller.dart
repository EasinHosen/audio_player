import 'package:audio_player/utils/global_helpers.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';

class AudioController extends GetxController {
  static AudioController get to => Get.find();

  RxList<SongModel> songList = <SongModel>[].obs;
  // RxList<AudioSource> audioSourceList = <AudioSource>[].obs;
  Rx<SongModel?> nowPlaying = Rx<SongModel?>(null);
  RxBool hasPermission = false.obs;
  RxBool songListLoading = false.obs;
  RxBool isPlaying = false.obs;
  RxString duration = '∞'.obs;
  RxString position = '0.00'.obs;
  RxDouble max = 0.0.obs;
  RxDouble current = 0.0.obs;
  RxInt currentIndex = 0.obs;

  final OnAudioQuery _audioQuery = OnAudioQuery();
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  onInit() {
    checkAndReqPermission();
    super.onInit();
  }

  @override
  onClose() {
    loggerDebug('controller closed');
    super.onClose();
  }

  updatePosition() {
    _audioPlayer.durationStream.listen((d) {
      duration.value = d.toString().split('.')[0];
      max.value = d!.inSeconds.toDouble();
    });
    _audioPlayer.positionStream.listen((p) {
      position.value = p.toString().split('.')[0];
      current.value = p.inSeconds.toDouble();
      /*if (position.value == duration.value) {
        playNext();
      }*/
    });
    _audioPlayer.processingStateStream.listen((event) {
      if (event == ProcessingState.completed) {
        playNext();
      }
    });
  }

  changeDurationToSeconds(seconds) {
    var duration = Duration(seconds: seconds);
    _audioPlayer.seek(duration);
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
    if (songList.isNotEmpty) {
      nowPlaying.value = songList[currentIndex.value];
      _audioPlayer
          .setAudioSource(AudioSource.uri(Uri.parse(nowPlaying.value!.uri!)));
      updatePosition();
    }
  }

  playSelectedSong(String? uri) {
    try {
      /*loggerDebug(
          songList[currentIndex.value].displayNameWOExt, 'current index song');*/
      _audioPlayer.setAudioSource(
        AudioSource.uri(Uri.parse(uri!)),
      );
      _audioPlayer.play();
      nowPlaying.value = songList[currentIndex.value];
      updatePosition();
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
    /*if (_audioPlayer.hasNext) {
      _audioPlayer.seekToNext();
    } else {
      loggerDebug('nothing to play next');
    }*/
    loggerDebug(currentIndex.value, 'last index in playNext');

    if (currentIndex.value + 1 <= songList.length) {
      currentIndex.value++;
      // _audioPlayer.stop();
      final uri = songList[currentIndex.value].uri;
      loggerDebug(currentIndex.value, 'present index in playNext');
      playSelectedSong(uri);
    } else {
      loggerDebug('Reached end');
    }
  }

  void playPrevious() {
    /*if (_audioPlayer.hasPrevious) {
      _audioPlayer.seekToPrevious();
    } else {
      loggerDebug('nothing to play');
    }*/
    if (currentIndex.value - 1 >= 0) {
      currentIndex.value--;
      // _audioPlayer.stop();
      final uri = songList[currentIndex.value].uri;
      playSelectedSong(uri);
    } else {
      loggerDebug('Reached first');
    }
  }

  /*readySongs() async {
    if (songList.isNotEmpty) {
      audioSourceList.clear();
      songList.map((e) {
        final path = e.data.toString();
        audioSourceList.add(AudioSource.uri(Uri.parse(path)));
      }).toList();
      */ /*_audioPlayer.setAudioSource(ConcatenatingAudioSource(children: audioSourceList))
          .catchError((err) {
        loggerDebug(err, 'error on setAudioSource');
      });*/ /*
      loggerDebug(songList[0].toString(), 'first song of songList');
      loggerDebug(
          audioSourceList[0].toString(), 'first song of audioSourceList');
    } else {
      loggerDebug('list empty', 'error on ready songs');
    }
    loggerDebug(audioSourceList.length, 'AudioSource list length');
  }*/

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

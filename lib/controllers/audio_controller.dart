import 'package:audio_player/utils/global_helpers.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';

class AudioController extends GetxController {
  static AudioController get to => Get.find();

  RxList<SongModel> songList = <SongModel>[].obs;
  // RxList<AudioSource> audioSourceList = <AudioSource>[].obs;
  Rx<SongModel?> nowPlaying = Rx<SongModel?>(null);
  Rx<LoopMode> loopMode = LoopMode.off.obs;
  RxBool hasPermission = false.obs;
  RxBool songListLoading = false.obs;
  RxBool isPlaying = false.obs;
  RxBool isShuffleOn = false.obs;
  RxString duration = '∞'.obs;
  RxString position = '0.00'.obs;
  RxDouble max = 0.0.obs;
  RxDouble current = 0.0.obs;
  RxInt currentIndex = 0.obs;
  RxInt previousIndex = 0.obs;

  static final OnAudioQuery _audioQuery = OnAudioQuery();
  static final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  onInit() {
    checkAndReqPermission();
    getLocalValues();
    super.onInit();
  }

  getLocalValues() async {}

  updatePosition() {
    /*_audioPlayer.durationStream.listen((d) {
      duration.value = d == null ? 'Buffering' : d.toString().split('.')[0];
      d == null ? max.value = 0.0 : max.value = d.inSeconds.toDouble();
    });*/
    getDuration();

    _audioPlayer.positionStream.listen((p) {
      position.value = /*p.toString().split('.')[0]*/ formatDuration(p);
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
    _audioPlayer.currentIndexStream.listen((ind) {
      currentIndex.value = ind!;
      nowPlaying.value = songList[currentIndex.value];
    });
  }

  changeDurationToSeconds(seconds) {
    var duration = Duration(seconds: seconds);
    _audioPlayer.seek(duration);
  }

  getDuration() {
    final Duration? audioDuration = _audioPlayer.duration;
    // loggerDebug(audioDuration, 'audio duration in update');
    if (audioDuration != null) {
      final String formattedDuration = formatDuration(audioDuration);
      // loggerDebug(formattedDuration, 'formatted duration in update');

      duration.value = formattedDuration;
      max.value = audioDuration.inSeconds.toDouble();
    } else {
      duration.value = 'Buffering';
      max.value = 0.0;
    }
  }

  String formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return duration.toString().split('.').first.padLeft(8, '0');
    } else {
      return duration.toString().substring(
          2, 7); // Remove the leading "0:" for durations less than an hour
    }
  }

  getSongs() async {
    songListLoading(true);
    final audioList = await _audioQuery.querySongs(
      orderType: OrderType.ASC_OR_SMALLER,
      ignoreCase: true,
      uriType: UriType.EXTERNAL,
    );
    final filteredList = filterAudioList(audioList);
    songList.value = filteredList;
    songListLoading(false);
    if (songList.isNotEmpty) {
      ///manual method
      /*nowPlaying.value = songList[currentIndex.value];
      _audioPlayer
          .setAudioSource(AudioSource.uri(Uri.parse(nowPlaying.value!.uri!)));
      updatePosition();*/

      ///auto method
      readyPlayer();
    }
  }

  List<SongModel> filterAudioList(List<SongModel> audioList) {
    // Define your filter criteria here.
    const minDurationInSeconds = 60; // Minimum duration in seconds
    const minFileSizeInBytes = 2 * 1024 * 1024; // Minimum file size in bytes

    return audioList.where((audio) {
      // Check if the audio file meets your filter criteria.
      final durationInSeconds = audio.duration! ~/ 1000; // Convert to seconds
      return durationInSeconds >= minDurationInSeconds &&
          audio.size >= minFileSizeInBytes;
    }).toList();
  }

  playSelectedSong(int index) {
    ///old way
    /*try {
      loggerDebug(
          songList[currentIndex.value].displayNameWOExt, 'current index song');
      _audioPlayer.setAudioSource(
        AudioSource.uri(Uri.parse(uri!)),
      );
      _audioPlayer.skipSilenceEnabled;
      _audioPlayer.play();
      nowPlaying.value = songList[currentIndex.value];
      updatePosition();
      isPlaying(true);
    } catch (e) {
      loggerDebug(e, 'error on playSelectedSong');
    }*/
    ///new way
    _audioPlayer.seek(Duration.zero, index: index);
    getDuration();
    _audioPlayer.play();
    isPlaying(true);
    // updatePosition();
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
    ///old way
    /*if (isShuffleOn.value) {
      int rand;
      rand = Random().nextInt(songList.length - 1);
      while (currentIndex.value == rand) {
        rand = Random().nextInt(songList.length - 1);
        loggerDebug(rand, 'same value came up as current index');
      }
      currentIndex.value = rand;
    } else {
      if (currentIndex.value + 1 <= songList.length) {
        currentIndex.value++;
        // _audioPlayer.stop();
        // loggerDebug(currentIndex.value, 'present index in playNext');
      } else {
        loggerDebug('Reached end');
      }
    }

    final uri = songList[currentIndex.value].uri;
    playSelectedSong(uri);*/

    if (_audioPlayer.hasNext) {
      _audioPlayer.seekToNext();
      getDuration();
    } else {
      loggerDebug('nothing to play next');
    }
  }

  void playPrevious() {
    /// old way
    /*if (currentIndex.value - 1 >= 0) {
      currentIndex.value--;
      // _audioPlayer.stop();
      final uri = songList[currentIndex.value].uri;
      playSelectedSong(uri);
    } else {
      loggerDebug('Reached first');
    }*/

    /// new way
    if (_audioPlayer.hasPrevious) {
      _audioPlayer.seekToPrevious();
      getDuration();
    } else {
      loggerDebug('nothing to play');
    }
  }

  readyPlayer() async {
    ///old way
    /*if (songList.isNotEmpty) {
      audioSourceList.clear();
      songList.map((e) {
        final path = e.data.toString();
        audioSourceList.add(AudioSource.uri(Uri.parse(path)));
      }).toList();
       _audioPlayer.setAudioSource(ConcatenatingAudioSource(children: audioSourceList))
          .catchError((err) {
        loggerDebug(err, 'error on setAudioSource');
      });
      loggerDebug(songList[0].toString(), 'first song of songList');
      loggerDebug(
          audioSourceList[0].toString(), 'first song of audioSourceList');
    } else {
      loggerDebug('list empty', 'error on ready songs');
    }
    loggerDebug(audioSourceList.length, 'AudioSource list length');*/

    ///new way
    await _audioPlayer
        .setAudioSource(
            ConcatenatingAudioSource(
                children: songList
                    .map((e) => AudioSource.uri(Uri.parse(e.uri!)))
                    .toList()),
            initialIndex: currentIndex.value,
            initialPosition: Duration.zero)
        .catchError((err) {
      loggerDebug(err, 'error on readyPlayer');
      return err;
    });
    updatePosition();
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

  void shuffle() async {
    isShuffleOn.value = !isShuffleOn.value;
    await _audioPlayer.setShuffleModeEnabled(isShuffleOn.value);
  }

  void toggleLoopMode() async {
    switch (loopMode.value) {
      case LoopMode.off:
        loopMode.value = LoopMode.all;
        break;
      case LoopMode.all:
        loopMode.value = LoopMode.one;
        break;
      case LoopMode.one:
        loopMode.value = LoopMode.off;
        break;
    }

    await _audioPlayer.setLoopMode(loopMode.value);
  }
}

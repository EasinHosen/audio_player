import 'package:audio_player/utils/global_helpers.dart';
import 'package:audio_player/utils/toast.dart';
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

  bool get isFirstTime => getLocalData('isFirstTime') ?? true;

  @override
  onInit() async {
    if (isFirstTime) {
      // loggerDebug('', 'first time if block');
      checkAndReqPermission();
    } else {
      // loggerDebug(currentIndex.value, 'first time else block current index');
      hasPermission(true);
      await getSongs();
    }
    syncLocalValues();
    // loggerDebug(currentIndex.value, 'after sync current index');
    if (songList.isNotEmpty) {
      ///manual method
      /*nowPlaying.value = songList[currentIndex.value];
      _audioPlayer
          .setAudioSource(AudioSource.uri(Uri.parse(nowPlaying.value!.uri!)));
      updatePosition();*/

      ///auto method
      await readyPlayer();
    }

    super.onInit();
  }

  syncLocalValues() async {
    currentIndex(getLocalData('lastIndex'));
    // loggerDebug(lastIndex, 'inside sync last index');
    nowPlaying.value = songList[currentIndex.value];
    isShuffleOn.value = getLocalData('isShuffleTurnedOn');
    loopMode.value = getLocalData('loopMode') == null
        ? LoopMode.off
        : LoopMode.values.firstWhere(
            (element) => element.toString() == getLocalData('loopMode'));
    await _audioPlayer.setShuffleModeEnabled(isShuffleOn.value);
    await _audioPlayer.setLoopMode(loopMode.value);
    // loggerDebug(lastIndex, 'last index local');
    // loggerDebug(getLocalData('isShuffleTurnedOn'), 'shuffle value local');
    // loggerDebug(getLocalData('loopMode'), 'loop mode local');
  }

  updatePosition() {
    bool isPlayingNext = false;
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
        if (!isPlayingNext) {
          isPlayingNext = true;
          playNext();
          // loggerDebug(event, 'song process state');
        }
      } else {
        isPlayingNext = false;
      }
    });
    /*_audioPlayer.processingStateStream.listen((event) {
      switch (event) {
        case ProcessingState.completed:
          playNext();
          loggerDebug(event, 'song process state');
          break;
        case ProcessingState.idle:
          break;
        case ProcessingState.loading:
          break;
        case ProcessingState.buffering:
          break;
        case ProcessingState.ready:
          break;
      }
      */
    /*if (event == ProcessingState.completed) {
        playNext();
        loggerDebug(event, 'song process state');
      }*/
    /*
    });*/
    /*_audioPlayer.currentIndexStream.listen((ind) {
      currentIndex.value = ind!;
      // setLocalData('lastIndex', ind);
      loggerDebug(getLocalData('lastIndex'), 'last index local');
      nowPlaying.value = songList[currentIndex.value];
    });*/
  }

  changeDurationToSeconds(seconds) {
    var duration = Duration(seconds: seconds);
    _audioPlayer.seek(duration);
  }

  getDuration() {
    /*final Duration? audioDuration = _audioPlayer.duration;
    // loggerDebug(audioDuration, 'audio duration in update');
    if (audioDuration != null) {
      final String formattedDuration = formatDuration(audioDuration);
      // loggerDebug(formattedDuration, 'formatted duration in update');

      duration.value = formattedDuration;
      max.value = audioDuration.inSeconds.toDouble();
    } else {
      duration.value = 'Buffering';
      max.value = 0.0;
    }*/

    final Duration audioDuration =
        Duration(milliseconds: nowPlaying.value!.duration!);
    // loggerDebug(audioDuration, 'audio duration in update');

    final String formattedDuration = formatDuration(audioDuration);
    duration.value = formattedDuration;
    max.value = audioDuration.inSeconds.toDouble();
  }

  // listenToIndex() {
  //   currentIndex.value = _audioPlayer.currentIndex!;
  //   setLocalData('lastIndex', _audioPlayer.currentIndex!);
  //   nowPlaying.value = songList[_audioPlayer.currentIndex!];
  //   /*_audioPlayer.currentIndexStream.listen((ind) {
  //     // currentIndex.value = ind!;
  //     // setLocalData('lastIndex', ind);
  //     // loggerDebug(getLocalData('lastIndex'), 'last index local');
  //     loggerDebug(ind, 'current index listen stream');
  //   });*/
  //   // loggerDebug(_audioPlayer.currentIndex!, 'current index of audio player');
  //
  //   // nowPlaying.value = songList[currentIndex.value];
  //   // loggerDebug(currentIndex.value, 'current index of controller');
  // }

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
    /*if (songList.isNotEmpty) {
      ///manual method
      */ /*nowPlaying.value = songList[currentIndex.value];
      _audioPlayer
          .setAudioSource(AudioSource.uri(Uri.parse(nowPlaying.value!.uri!)));
      updatePosition();*/ /*

      ///auto method
      await readyPlayer();
    }*/
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

  playSelectedSong(int index) async {
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
    currentIndex(index);
    setLocalData('lastIndex', index);
    nowPlaying.value = songList[currentIndex.value];
    getDuration();
    isPlaying(true);
    await _audioPlayer.seek(Duration.zero, index: index);
    await _audioPlayer.play();
    // updatePosition();
  }

  void playAndPause() async {
    if (isPlaying.value) {
      isPlaying(false);
      await _audioPlayer.pause();
    } else {
      isPlaying(true);
      await _audioPlayer.play();
    }
  }

  void playNext() async {
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
      currentIndex.value = _audioPlayer.nextIndex!;
      setLocalData('lastIndex', _audioPlayer.nextIndex!);
      nowPlaying.value = songList[_audioPlayer.nextIndex!];
      getDuration();
      await _audioPlayer.seekToNext();
      // loggerDebug(currentIndex.value, 'current index of controller');
    } else {
      ToastManager.show('Reached the end of list');
      isPlaying(false);
      await _audioPlayer.seek(Duration.zero);
      await _audioPlayer.stop();
      // loggerDebug('nothing to play next');
    }
  }

  void playPrevious() async {
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
      currentIndex.value = _audioPlayer.previousIndex!;
      setLocalData('lastIndex', _audioPlayer.previousIndex!);
      nowPlaying.value = songList[_audioPlayer.previousIndex!];
      await _audioPlayer.seekToPrevious();
      getDuration();
    } else {
      ToastManager.show('Reached start index');
      // loggerDebug('nothing to play');
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
    // loggerDebug(currentIndex.value, 'current index in ready player');
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
      setLocalData('isFirstTime', false);
    } else {
      loggerDebug(hasPermission.value, 'Permission');
    }
  }

  void shuffle() async {
    isShuffleOn.value = !isShuffleOn.value;
    await _audioPlayer.setShuffleModeEnabled(isShuffleOn.value);
    await setLocalData('isShuffleTurnedOn', isShuffleOn.value);
    isShuffleOn.value == true
        ? ToastManager.show('Shuffle On')
        : ToastManager.show('Shuffle Off');
  }

  void toggleLoopMode() async {
    switch (loopMode.value) {
      case LoopMode.off:
        loopMode.value = LoopMode.all;
        ToastManager.show('Repeat: All');
        break;
      case LoopMode.all:
        loopMode.value = LoopMode.one;
        ToastManager.show('Repeat: One');
        break;
      case LoopMode.one:
        loopMode.value = LoopMode.off;
        ToastManager.show('Repeat: Off');
        break;
    }

    setLocalData('loopMode', loopMode.value.toString());
    await _audioPlayer.setLoopMode(loopMode.value);
    // loggerDebug(loopMode.value, 'loop mode controller value set');
    // loggerDebug(getLocalData('loopMode'), 'loop mode local');
  }
}

import 'package:audio_player/utils/global_helpers.dart';
import 'package:audio_player/utils/toast.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioController extends GetxController {
  static AudioController get to => Get.find();

  RxList<SongModel> songList = <SongModel>[].obs;
  RxList<AudioSource> audioSourceList = <AudioSource>[].obs;
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
      await checkAndReqPermission();
    } else {
      hasPermission(true);
      await getSongs();
    }
    if (songList.isNotEmpty) {
      await syncLocalValues();
      await readyPlayer();
    }
    super.onInit();
  }

  ///player and query related methods
  syncLocalValues() async {
    currentIndex.value = getLocalData('lastIndex') ?? 0;
    nowPlaying.value = songList[currentIndex.value];
    isShuffleOn.value = getLocalData('isShuffleTurnedOn') ?? false;
    loopMode.value = getLocalData('loopMode') == null
        ? LoopMode.off
        : LoopMode.values.firstWhere(
            (element) => element.toString() == getLocalData('loopMode'));
    await _audioPlayer.setShuffleModeEnabled(isShuffleOn.value);
    await _audioPlayer.setLoopMode(loopMode.value);
  }

  updatePosition() {
    _audioPlayer.positionStream.listen((p) async {
      position.value = formatDuration(p);
      current.value = p.inSeconds.toDouble();
      // loggerDebug(p, 'position stream');
      if (position.value == duration.value &&
          currentIndex.value == songList.length - 1 &&
          loopMode.value == LoopMode.off) {
        ToastManager.show('Reached the end of list');
        isPlaying(false);
        await _audioPlayer.seek(Duration.zero);
        await _audioPlayer.stop();
      }
    });

    _audioPlayer.durationStream.listen((event) {
      if (event != null) {
        duration.value = formatDuration(event);
        max.value = event.inSeconds.toDouble();
      }
      // loggerDebug(event, 'duration stream');
    });

    _audioPlayer.currentIndexStream.listen((event) async {
      if (event! != currentIndex.value) {
        updateCurrent(event);
      }
    });
  }

  playSelectedSong(int index) async {
    updateCurrent(index);

    isPlaying(true);
    await _audioPlayer.seek(Duration.zero, index: index);
    await _audioPlayer.play();
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
    if (_audioPlayer.hasNext) {
      updateCurrent(_audioPlayer.nextIndex!);
      // loggerDebug(nowPlaying.value!.displayName, 'now playing');
      loggerDebug(audioSourceList[currentIndex.value].sequence,
          'audio source value of current index');

      await _audioPlayer.seekToNext();
    } else {
      ToastManager.show('Reached the end of list');
      if (position.value == duration.value) {
        isPlaying(false);
        await _audioPlayer.seek(Duration.zero);
        await _audioPlayer.stop();
      }
    }
  }

  void playPrevious() async {
    if (_audioPlayer.hasPrevious) {
      updateCurrent(_audioPlayer.previousIndex!);

      await _audioPlayer.seekToPrevious();
    } else {
      ToastManager.show('Reached start index');
      // loggerDebug('nothing to play');
    }
  }

  readyPlayer() async {
    await _audioPlayer
        .setAudioSource(
            ConcatenatingAudioSource(
              children: audioSourceList,
            ),
            initialIndex: currentIndex.value,
            initialPosition: Duration.zero)
        .catchError((err) {
      loggerDebug(err, 'error on readyPlayer');
      return err;
    });
    updatePosition();
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
  }

  changeDurationToSeconds(seconds) {
    var duration = Duration(seconds: seconds);
    _audioPlayer.seek(duration);
  }

  getSongs() async {
    songListLoading(true);
    songList.clear();
    audioSourceList.clear();
    final audioList = await _audioQuery.querySongs(
      orderType: OrderType.ASC_OR_SMALLER,
      ignoreCase: true,
      uriType: UriType.EXTERNAL,
    );
    final filteredList = filterAudioList(audioList);
    songList.value = filteredList;
    songList
        .map((e) => audioSourceList.add(
              AudioSource.uri(Uri.parse(e.uri!)),
            ))
        .toList();
    songListLoading(false);
  }

  ///helper methods
  String formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return duration.toString().split('.').first.padLeft(8, '0');
    } else {
      return duration.toString().substring(
          2, 7); // Remove the leading "0:" for durations less than an hour
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

  updateCurrent(int indexValue) {
    currentIndex.value = indexValue;
    setLocalData('lastIndex', currentIndex.value);
    nowPlaying.value = songList[currentIndex.value];
  }

  ///Permission related methods
  checkAndReqPermission({bool retry = false}) async {
    final permissionStatus = await Permission.storage.request();

    if (permissionStatus.isGranted) {
      hasPermission(true);
      await getSongs();
      setLocalData('isFirstTime', false);
    } else {
      ToastManager.show('Permission is not granted!');
    }
  }
}

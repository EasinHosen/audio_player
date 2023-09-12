import 'package:audio_player/utils/global_helpers.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';

class AudioController extends GetxController {
  static AudioController get to => Get.find();

  RxList<SongModel> audios = <SongModel>[].obs;
  // Rx<SongModel> nowPlaying = SongModel(_info).obs;
  RxBool hasPermission = false.obs;
  RxBool songListLoading = false.obs;
  final OnAudioQuery _audioQuery = OnAudioQuery();

  @override
  onInit() {
    checkAndReqPermission();
    super.onInit();
  }

  getSongs() async {
    songListLoading(true);
    final audioList = await _audioQuery.querySongs();
    audios.value = audioList;
    songListLoading(false);

    loggerDebug(audios.length, 'number of audio');
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

import 'package:audio_player/utils/global_helpers.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';

class AudioController extends GetxController {
  RxList<SongModel> audios = <SongModel>[].obs;
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

  checkAndReqPermission() async {
    hasPermission(await _audioQuery.checkAndRequest());
    if (hasPermission.value) {
      getSongs();
    } else {
      loggerDebug(hasPermission.value, 'Permission');
    }
  }
}

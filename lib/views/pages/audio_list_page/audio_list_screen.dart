import 'package:audio_player/controllers/audio_controller.dart';
import 'package:audio_player/utils/global_helpers.dart';
import 'package:audio_player/views/pages/audio_list_page/widgets/permission_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';

class AudioListPage extends StatelessWidget {
  const AudioListPage({super.key});
  static const String routeName = '/audio_list_page';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Songs'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: Column(
        children: [
          if (!AudioController.to.hasPermission.value) const PermissionWidget(),
          if (AudioController.to.songListLoading.value)
            const Center(
              child: CircularProgressIndicator(),
            ),
          if (AudioController.to.hasPermission.value &&
              !AudioController.to.songListLoading.value &&
              AudioController.to.songList.isNotEmpty)
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                primary: false,
                itemCount: AudioController.to.songList.length,
                itemBuilder: (context, index) {
                  final audio = AudioController.to.songList[index];
                  return Obx(
                    () => ListTile(
                      leading: QueryArtworkWidget(
                        // controller: _audioQuery,
                        id: audio.id,
                        type: ArtworkType.AUDIO,
                        nullArtworkWidget: Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: Colors.grey.withOpacity(0.2),
                            ),
                            child: const Icon(
                              Icons.music_note,
                            )),
                      ),
                      title: Text(
                        audio.displayNameWOExt,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: AudioController.to.currentIndex.value == index
                          ? IconButton(
                              icon: AudioController.to.isPlaying.value
                                  ? const Icon(Icons.pause_outlined)
                                  : const Icon(Icons.play_arrow_outlined),
                              onPressed: () {
                                AudioController.to.playAndPause();
                              },
                            )
                          : null,
                      onTap: () {
                        loggerDebug(audio, 'song model');
                        loggerDebug(index, 'index');
                        AudioController.to.currentIndex.value = index;
                        AudioController.to.playSelectedSong(audio.uri);
                      },
                    ),
                  );
                },
              ),
            ),
          if (!AudioController.to.songListLoading.value &&
              AudioController.to.songList.isEmpty)
            const Center(
              child: Text('No data found'),
            ),
        ],
      ),
    );
  }
}

import 'package:audio_player/controllers/audio_controller.dart';
import 'package:audio_player/utils/global_helpers.dart';
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
      body: ListView.builder(
        itemCount: AudioController.to.audios.length,
        itemBuilder: (context, index) {
          final audio = AudioController.to.audios[index];
          return ListTile(
            leading: QueryArtworkWidget(
              // controller: _audioQuery,
              id: audio.id,
              type: ArtworkType.AUDIO,
            ),
            title: Text(audio.displayName),
            onTap: () {
              loggerDebug(audio, 'song model');
            },
          );
        },
      ),
    );
  }
}

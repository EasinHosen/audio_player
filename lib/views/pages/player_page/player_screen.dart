import 'package:audio_player/views/pages/audio_list_page/audio_list_screen.dart';
import 'package:audio_player/views/shared_widgets/cusotm_circular_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';

import '../../../controllers/audio_controller.dart';

class PlayerPage extends StatelessWidget {
  const PlayerPage({super.key});
  static const String routeName = '/player_page';

  @override
  Widget build(BuildContext context) {
    int sVal = 0;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Now Playing'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.list_rounded),
          onPressed: () {
            Get.toNamed(AudioListPage.routeName);
          },
        ),
      ),
      body: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Obx(
            () => Container(
              height: Get.height * .5,
              width: Get.width,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(50),
              ),
              alignment: Alignment.center,
              child: AudioController.to.nowPlaying.value != null
                  ? QueryArtworkWidget(
                      id: AudioController.to.nowPlaying.value!.id,
                      type: ArtworkType.AUDIO,
                      artworkHeight: double.infinity,
                      artworkWidth: double.infinity,
                    )
                  : null,
            ),
          ),
          const SizedBox(
            height: 4,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Obx(
              () => Text(
                AudioController.to.nowPlaying.value?.displayNameWOExt ??
                    'Music',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Obx(
            () => Text(
              AudioController.to.nowPlaying.value?.artist ?? 'Artist',
            ),
          ),
          Slider(
            value: sVal.toDouble(),
            onChanged: (val) {
              sVal = val.round();
            },
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('0.00'),
                Text('3.15'),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.shuffle_rounded,
                  size: 20,
                ),
              ),
              CustomCircularButton(
                icon: Icons.skip_previous_outlined,
                onPressed: () {
                  AudioController.to.playPrevious();
                },
              ),
              Obx(
                () => CustomCircularButton(
                  icon: AudioController.to.isPlaying.value
                      ? Icons.pause_outlined
                      : Icons.play_arrow_outlined,
                  iconSize: 40,
                  onPressed: () {
                    AudioController.to.playAndPause();
                  },
                ),
              ),
              CustomCircularButton(
                icon: Icons.skip_next_outlined,
                onPressed: () {
                  AudioController.to.playNext();
                },
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.repeat_rounded,
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

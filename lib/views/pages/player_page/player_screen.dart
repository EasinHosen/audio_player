import 'package:audio_player/utils/global_helpers.dart';
import 'package:audio_player/views/pages/audio_list_page/audio_list_screen.dart';
import 'package:audio_player/views/shared_widgets/cusotm_circular_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';

import '../../../controllers/audio_controller.dart';

class PlayerPage extends StatelessWidget {
  const PlayerPage({super.key});
  static const String routeName = '/player_page';

  @override
  Widget build(BuildContext context) {
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
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Obx(
            () => Text(
              AudioController.to.nowPlaying.value?.artist ?? 'Artist',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Obx(
            () => Slider(
              min: 0.0,
              max: AudioController.to.max.value,
              value: AudioController.to.current.value,
              onChanged: (val) {
                AudioController.to.changeDurationToSeconds(val.toInt());
                val = val;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() => Text(AudioController.to.position.value)),
                Obx(() => Text(AudioController.to.duration.value)),
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
                onPressed: () {
                  AudioController.to.shuffle();
                  loggerDebug(
                      AudioController.to.isShuffleOn.value, 'shuffle value');
                },
                icon: Obx(
                  () => Icon(
                    Icons.shuffle_rounded,
                    size: 20,
                    color: AudioController.to.isShuffleOn.value
                        ? Theme.of(context).primaryColor
                        : null,
                  ),
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
                onPressed: () {
                  AudioController.to.toggleLoopMode();
                },
                icon: Obx(
                  () => Icon(
                    AudioController.to.loopMode.value == LoopMode.one
                        ? Icons.repeat_one_outlined
                        : Icons.repeat_outlined,
                    size: 20,
                    color: AudioController.to.loopMode.value == LoopMode.off
                        ? null
                        : Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

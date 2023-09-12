import 'package:audio_player/views/pages/audio_list_page/audio_list_screen.dart';
import 'package:audio_player/views/shared_widgets/cusotm_circular_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
          Container(
            height: Get.height * .5,
            width: Get.width,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(10)),
          ),
          const SizedBox(
            height: 10,
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
                onPressed: () {},
              ),
              CustomCircularButton(
                icon: Icons.play_arrow_outlined,
                iconSize: 40,
                onPressed: () {},
              ),
              CustomCircularButton(
                icon: Icons.skip_next_outlined,
                onPressed: () {},
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

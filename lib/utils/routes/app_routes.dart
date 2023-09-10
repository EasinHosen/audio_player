import 'package:audio_player/views/pages/audio_list_page/audio_list_screen.dart';
import 'package:audio_player/views/pages/player_page/player_screen.dart';
import 'package:get/get.dart';

import '../../bindings/audio_binding.dart';

class AppRoutes {
  static routes() => [
        GetPage(
          name: PlayerPage.routeName,
          page: () => const PlayerPage(),
          binding: AudioBinding(),
        ),
        GetPage(
          name: AudioListPage.routeName,
          page: () => const AudioListPage(),
        ),
      ];
}

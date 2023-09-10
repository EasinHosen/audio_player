import 'package:flutter/material.dart';

class PlayerPage extends StatelessWidget {
  const PlayerPage({super.key});
  static const String routeName = '/player_page';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
            onPressed: () {},
            child: /*AnimatedIcon(
              icon: AnimatedIcons.play_pause,
              progress: ,
            )*/
                const Icon(Icons.play_arrow_outlined)),
      ),
    );
  }
}

import 'package:audio_player/controllers/audio_controller.dart';
import 'package:flutter/material.dart';

class PermissionWidget extends StatelessWidget {
  const PermissionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.redAccent.withOpacity(0.5),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Application doesn't have access to the library"),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () =>
                AudioController.to.checkAndReqPermission(retry: true),
            child: const Text("Allow"),
          ),
        ],
      ),
    );
  }
}

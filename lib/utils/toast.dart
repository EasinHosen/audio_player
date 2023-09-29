import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'global_helpers.dart';

///determines the position of the toast
enum ToastPosition {
  top,
  center,
  bottom,
}

class ToastManager {
  static OverlayState? _overlayState;
  static final List<OverlayEntry> _activeEntries = [];

  static void initialize() {
    _overlayState = navigatorKey.currentState?.overlay;
  }

  ///shows context less toast
  ///
  ///tested in android only for now
  static void show(
    ///the message that is to be shown
    String message, {
    ///determines the position of the toast
    ToastPosition toastPosition = ToastPosition.bottom,

    ///duration of toast, default is 2
    Duration? duration,

    ///border radius of the toast
    BorderRadius? borderRadius,

    ///background of the toast
    Color? backgroundColor,

    ///message text color
    Color? textColor,

    ///message text alignment default is center
    TextAlign? messageAlignment,

    ///message font size
    double messageFontSize = 14,
  }) {
    _overlayState ??= navigatorKey.currentState?.overlay;
    if (_overlayState == null) {
      if (kDebugMode) {
        print('OverlayState is null. Toast cannot be shown.');
      }
      return;
    }
    cancelAllToasts();

    final double yOffset = toastPosition == ToastPosition.top ? 0.15 : 0.1;

    final OverlayEntry overlayEntry = OverlayEntry(
      builder: (BuildContext context) => toastPosition == ToastPosition.center
          ? ToastWidget(
              topMargin: MediaQuery.of(context).padding.top + kToolbarHeight,
              message: message,
              backgroundColor: backgroundColor,
              borderRadius: borderRadius,
              messageAlignment: messageAlignment,
              messageFontSize: messageFontSize,
              textColor: textColor,
            )
          : Positioned(
              top: toastPosition == ToastPosition.top
                  ? MediaQuery.of(context).size.height * yOffset
                  // : toastPosition == ToastPosition.center
                  //     ? (MediaQuery.of(context).size.height * yOffset) -
                  //         (constraints.maxHeight / 2)
                  : null,
              bottom: toastPosition == ToastPosition.bottom
                  ? MediaQuery.of(context).size.height * yOffset
                  : null,
              width: MediaQuery.of(context).size.width,
              child: ToastWidget(
                message: message,
                backgroundColor: backgroundColor,
                borderRadius: borderRadius,
                messageAlignment: messageAlignment,
                messageFontSize: messageFontSize,
                textColor: textColor,
              ),
            ),
    );

    _overlayState!.insert(overlayEntry);
    _activeEntries.add(overlayEntry);

    // Remove the overlay after a certain duration
    Future.delayed(duration ?? const Duration(seconds: 2), () {
      if (_activeEntries.contains(overlayEntry)) {
        overlayEntry.remove();
        _activeEntries.remove(overlayEntry);
      }
    });
  }

  ///cancels all toasts
  static void cancelAllToasts() {
    for (var entry in _activeEntries) {
      entry.remove();
    }
    _activeEntries.clear();
    /*if (kDebugMode) {
      print('All toasts canceled');
    }*/
  }
}

class ToastWidget extends StatelessWidget {
  const ToastWidget(
      {super.key,
      this.backgroundColor,
      this.textColor,
      required this.message,
      this.messageAlignment,
      this.borderRadius,
      this.messageFontSize = 14,
      this.topMargin});

  ///background of the toast
  final Color? backgroundColor;

  ///message text color
  final Color? textColor;
  final String message;

  ///message text alignment default is center
  final TextAlign? messageAlignment;

  ///border radius of the toast
  final BorderRadius? borderRadius;

  ///message font size
  final double messageFontSize;

  ///message font size
  final double? topMargin;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16)
          .copyWith(top: topMargin ?? 0),
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.grey[800],
          borderRadius: borderRadius ??
              const BorderRadius.all(
                Radius.circular(50),
              ),
        ),
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: textColor ?? Colors.white,
                fontSize: messageFontSize,
              ),
          textAlign: messageAlignment ?? TextAlign.center,
        ),
      ),
    );
  }
}

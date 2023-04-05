import 'dart:async';
import 'package:flutter/material.dart';
import 'overlayController.dart';

typedef CloseOverlayScreen = bool Function();
typedef UpdateOverlayScreen = bool Function(String text);

@immutable
class OverLayScreenController {
  final CloseOverlayScreen close;
  final UpdateOverlayScreen update;

  const OverLayScreenController({
    required this.close,
    required this.update,
  });
}

class OverLayScreen {
  factory OverLayScreen() => _shared;
  static final OverLayScreen _shared = OverLayScreen._sharedInstance();
  OverLayScreen._sharedInstance();

  OverLayScreenController? controller;
  var _text = StreamController<String>();

  void show(
      {required BuildContext context,
      required Widget display,
      Color foregroundColor = Colors.white}) {
    controller = showOverlay(
        context: context, display: display, foregroundColor: foregroundColor);
  }

  void showLoading(
      {required BuildContext context,
      required String text,
      Color foregroundColor = Colors.white}) {
    if (controller?.update(text) ?? false) {
      return;
    } else {
      try {
        _text.add(text);
      } catch (e) {
        _text = StreamController<String>();
        _text.add(text);
      }
      controller = showOverlay(
          foregroundColor: foregroundColor,
          context: context,
          display: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  StreamBuilder(
                    stream: _text.stream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Text(
                          snapshot.data as String,
                          textAlign: TextAlign.center,
                        );
                      } else {
                        return Container();
                      }
                    },
                  ),
                ],
              ),
            ),
          ));
    }
  }

  void hide() {
    controller?.close();
    controller = null;
  }

  OverLayScreenController showOverlay(
      {required BuildContext context,
      required Widget display,
      Color foregroundColor = Colors.white}) {
    final state = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    final overlay = OverlayEntry(
      builder: (context) {
        return Material(
            color: Colors.black.withAlpha(150),
            child: Center(
              child: Container(
                  constraints: BoxConstraints(
                    maxWidth: size.width * 0.8,
                    maxHeight: size.height * 0.8,
                    minWidth: size.width * 0.5,
                  ),
                  decoration: BoxDecoration(
                    color: foregroundColor,
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: SingleChildScrollView(child: display)),
            ));
      },
    );

    state.insert(overlay);

    return OverLayScreenController(
      close: () {
        _text.close();
        overlay.remove();
        return true;
      },
      update: (text) {
        _text.add(text);
        return true;
      },
    );
  }
}

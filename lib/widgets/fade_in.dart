import 'dart:async';

import 'package:flutter/material.dart';

///FadeIn widget
class FadeIn extends StatefulWidget {
  final FadeInController? controller;

  final Widget child;

  final Duration duration;
  final Curve curve;

  const FadeIn({
    Key? key,
    this.controller,
    required this.child,
    this.duration = const Duration(milliseconds: 250),
    this.curve = Curves.easeIn,
  }) : super(key: key);

  @override
  _FadeInState createState() => _FadeInState();
}

enum FadeInAction {
  fadeIn,
  fadeOut,
}

class FadeInController {
  final _streamController = StreamController<FadeInAction>();

  final bool autoStart;

  FadeInController({this.autoStart = false});

  void dispose() => _streamController.close();

  void fadeIn() => run(FadeInAction.fadeIn);

  void fadeOut() => run(FadeInAction.fadeOut);

  void run(FadeInAction action) => _streamController.add(action);

  Stream<FadeInAction> get stream => _streamController.stream;
}

class _FadeInState extends State<FadeIn> with TickerProviderStateMixin {
  late AnimationController _controller;

  // ignore: cancel_subscriptions
  StreamSubscription<FadeInAction>? _listener;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _setupCurve();

    if (widget.controller?.autoStart != false) {
      _controller.forward();
    }

    _listen();
  }

  void _setupCurve() {
    final curve = CurvedAnimation(parent: _controller, curve: widget.curve);

    Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(curve);
  }

  void _listen() {
    if (_listener != null) {
      _listener!.cancel();
      _listener = null;
    }

    if (widget.controller != null) {
      _listener = widget.controller!.stream.listen(_onAction);
    }
  }

  void _onAction(FadeInAction action) {
    _controller.forward();
  }

  @override
  void didUpdateWidget(FadeIn oldWidget) {
    if (oldWidget.controller != widget.controller) {
      _listen();
    }

    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }

    if (oldWidget.curve != widget.curve) {
      _setupCurve();
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: widget.child,
    );
  }
}

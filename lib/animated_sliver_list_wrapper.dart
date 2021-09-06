import 'package:flutter/material.dart';

typedef SliverListBuilder = Widget Function({ValueKey key, int animatedIndex, double animatedExtent});

class AnimatedSliverListWrapper extends StatefulWidget {
  AnimatedSliverListWrapper(
      {Key? key,
      required this.animatedIndex,
      required this.isAdding,
      required this.sliverListBuilder,
      required this.itemExtents})
    : 
    maxAnimatedExtent = itemExtents[animatedIndex],
    super(key: key);
  final int animatedIndex;
  final List<double> itemExtents;
  final bool isAdding;
  final SliverListBuilder sliverListBuilder;
  late double maxAnimatedExtent;
  @override
  _AnimatedSliverListWrapperState createState() =>
      _AnimatedSliverListWrapperState();
}

class _AnimatedSliverListWrapperState extends State<AnimatedSliverListWrapper> { 
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
        tween: Tween<double>(begin: 0, end: widget.maxAnimatedExtent),
        duration: Duration(milliseconds: 8000),
        builder: (BuildContext context, double animatedExtent, Widget? child) {
          ValueKey sliverListKey = ValueKey("${widget.itemExtents.hashCode}-${widget.animatedIndex}-$animatedExtent");
          return widget.sliverListBuilder(key: sliverListKey, animatedIndex: widget.animatedIndex, animatedExtent: animatedExtent);
        });
  }
}

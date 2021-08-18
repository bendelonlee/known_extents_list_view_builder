// Bandaid package created largely by copying Flutter code and modifying it.
// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:known_extents_list_view_builder/sliver_known_extents_list.dart';

/// A sliver list that allows the user to interactively reorder the list items.
///
/// It is up to the application to wrap each child (or an internal part of the
/// child) with a drag listener that will recognize the start of an item drag
/// and then start the reorder by calling
/// [SliverKnownExtentsReorderableListState.startItemDragReorder]. This is most easily
/// achieved by wrapping each child in a [ReorderableDragStartListener] or
/// a [ReorderableDelayedDragStartListener]. These will take care of
/// recognizing the start of a drag gesture and call the list state's start
/// item drag method.
///
/// This widget's [SliverKnownExtentsReorderableListState] can be used to manually start an item
/// reorder, or cancel a current drag that's already underway. To refer to the
/// [SliverKnownExtentsReorderableListState] either provide a [GlobalKey] or use the static
/// [SliverKnownExtentsReorderableList.of] method from an item's build method.
///
/// See also:
///
///  * [KnownExtentsReorderableList], a regular widget list that allows the user to reorder
///    its items.
///  * [ReorderableListView], a material design list that allows the user to
///    reorder its items.
class SliverKnownExtentsReorderableList extends StatefulWidget {
  /// Creates a sliver list that allows the user to interactively reorder its
  /// items.
  ///
  /// The [itemCount] must be greater than or equal to zero.
  const SliverKnownExtentsReorderableList({
    Key? key,
    required this.itemExtents,
    this.overlayScale = 1,
    required this.overlayOffset,
    required this.itemBuilder,
    required this.itemCount,
    required this.onReorder,
    this.proxyDecorator,
  })  : assert(itemCount >= 0),
        super(key: key);
  final List<double> itemExtents;
  final double overlayScale;
  final Offset overlayOffset;

  /// {@macro flutter.widgets.reorderable_list.itemBuilder}
  final IndexedWidgetBuilder itemBuilder;

  /// {@macro flutter.widgets.reorderable_list.itemCount}
  final int itemCount;

  /// {@macro flutter.widgets.reorderable_list.onReorder}
  final ReorderCallback onReorder;

  /// {@macro flutter.widgets.reorderable_list.proxyDecorator}
  final ReorderItemProxyDecorator? proxyDecorator;

  @override
  SliverKnownExtentsReorderableListState createState() =>
      SliverKnownExtentsReorderableListState();

  /// The state from the closest instance of this class that encloses the given
  /// context.
  ///
  /// This method is typically used by [SliverKnownExtentsReorderableList] item widgets to
  /// start or cancel an item drag operation.
  ///
  /// If no [SliverKnownExtentsReorderableList] surrounds the context given, this function
  /// will assert in debug mode and throw an exception in release mode.
  ///
  /// See also:
  ///
  ///  * [maybeOf], a similar function that will return null if no
  ///    [SliverKnownExtentsReorderableList] ancestor is found.
  static SliverKnownExtentsReorderableListState of(BuildContext context) {
    final SliverKnownExtentsReorderableListState? result = context
        .findAncestorStateOfType<SliverKnownExtentsReorderableListState>();
    assert(() {
      if (result == null) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary(
            'SliverKnownExtentsReorderableList.of() called with a context that does not contain a SliverKnownExtentsReorderableList.',
          ),
          ErrorDescription(
            'No SliverKnownExtentsReorderableList ancestor could be found starting from the context that was passed to SliverKnownExtentsReorderableList.of().',
          ),
          ErrorHint(
            'This can happen when the context provided is from the same StatefulWidget that '
            'built the SliverKnownExtentsReorderableList. Please see the SliverKnownExtentsReorderableList documentation for examples '
            'of how to refer to an SliverKnownExtentsReorderableList object:\n'
            '  https://api.flutter.dev/flutter/widgets/SliverKnownExtentsReorderableListState-class.html',
          ),
          context.describeElement('The context used was'),
        ]);
      }
      return true;
    }());
    return result!;
  }

  /// The state from the closest instance of this class that encloses the given
  /// context.
  ///
  /// This method is typically used by [SliverKnownExtentsReorderableList] item widgets that
  /// insert or remove items in response to user input.
  ///
  /// If no [SliverKnownExtentsReorderableList] surrounds the context given, this function
  /// will return null.
  ///
  /// See also:
  ///
  ///  * [of], a similar function that will throw if no [SliverKnownExtentsReorderableList]
  ///    ancestor is found.
  static SliverKnownExtentsReorderableListState? maybeOf(BuildContext context) {
    return context
        .findAncestorStateOfType<SliverKnownExtentsReorderableListState>();
  }
}

/// The state for a sliver list that allows the user to interactively reorder
/// the list items.
///
/// An app that needs to start a new item drag or cancel an existing one
/// can refer to the [SliverKnownExtentsReorderableList]'s state with a global key:
///
/// ```dart
/// GlobalKey<SliverKnownExtentsReorderableListState> listKey = GlobalKey<SliverKnownExtentsReorderableListState>();
/// ...
/// SliverKnownExtentsReorderableList(key: listKey, ...);
/// ...
/// listKey.currentState.cancelReorder();
/// ```
///
/// [ReorderableDragStartListener] and [ReorderableDelayedDragStartListener]
/// refer to their [SliverKnownExtentsReorderableList] with the static
/// [SliverKnownExtentsReorderableList.of] method.
class SliverKnownExtentsReorderableListState
    extends State<SliverKnownExtentsReorderableList>
    with TickerProviderStateMixin {
  // Map of index -> child state used manage where the dragging item will need
  // to be inserted.
  final Map<int, _ReorderableItemState> _items = <int, _ReorderableItemState>{};

  OverlayEntry? _overlayEntry;
  int? _dragIndex;
  _DragInfo? _dragInfo;
  int? _insertIndex;
  Offset? _finalDropPosition;
  MultiDragGestureRecognizer<MultiDragPointerState>? _recognizer;
  bool _autoScrolling = false;

  late ScrollableState _scrollable;
  Axis get _scrollDirection => axisDirectionToAxis(_scrollable.axisDirection);
  bool get _reverse =>
      _scrollable.axisDirection == AxisDirection.up ||
      _scrollable.axisDirection == AxisDirection.left;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scrollable = Scrollable.of(context)!;
  }

  @override
  void didUpdateWidget(covariant SliverKnownExtentsReorderableList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.itemCount != oldWidget.itemCount) {
      cancelReorder();
    }
  }

  @override
  void dispose() {
    _dragInfo?.dispose();
    super.dispose();
  }

  /// Initiate the dragging of the item at [index] that was started with
  /// the pointer down [event].
  ///
  /// The given [recognizer] will be used to recognize and start the drag
  /// item tracking and lead to either an item reorder, or a cancelled drag.
  ///
  /// Most applications will not use this directly, but will wrap the item
  /// (or part of the item, like a drag handle) in either a
  /// [ReorderableDragStartListener] or [ReorderableDelayedDragStartListener]
  /// which call this method when they detect the gesture that triggers a drag
  /// start.
  void startItemDragReorder({
    required int index,
    required PointerDownEvent event,
    required MultiDragGestureRecognizer<MultiDragPointerState> recognizer,
  }) {
    assert(0 <= index && index < widget.itemCount);
    setState(() {
      if (_dragInfo != null) {
        cancelReorder();
      }
      if (_items.containsKey(index)) {
        _dragIndex = index;
        _recognizer = recognizer
          ..onStart = _dragStart
          ..addPointer(event);
      } else {
        // TODO(darrenaustin): Can we handle this better, maybe scroll to the item?
        throw Exception('Attempting to start a drag on a non-visible item');
      }
    });
  }

  /// Cancel any item drag in progress.
  ///
  /// This should be called before any major changes to the item list
  /// occur so that any item drags will not get confused by
  /// changes to the underlying list.
  ///
  /// If a drag operation is in progress, this will immediately reset
  /// the list to back to its pre-drag state.
  ///
  /// If no drag is active, this will do nothing.
  void cancelReorder() {
    _dragReset();
  }

  void _registerItem(_ReorderableItemState item) {
    _items[item.index] = item;
    if (item.index == _dragInfo?.index) {
      item.dragging = true;
      item.rebuild();
    }
  }

  void _unregisterItem(int index, _ReorderableItemState item) {
    final _ReorderableItemState? currentItem = _items[index];
    if (currentItem == item) {
      _items.remove(index);
    }
  }

  Drag? _dragStart(Offset position) {
    assert(_dragInfo == null);
    final _ReorderableItemState item = _items[_dragIndex!]!;
    item.dragging = true;
    item.rebuild();

    _insertIndex = item.index;
    _dragInfo = _DragInfo(
      item: item,
      overlayScale: widget.overlayScale,
      overlayOffset: widget.overlayOffset,
      initialPosition: position,
      scrollDirection: _scrollDirection,
      onUpdate: _dragUpdate,
      onCancel: _dragCancel,
      onEnd: _dragEnd,
      onDropCompleted: _dropCompleted,
      proxyDecorator: widget.proxyDecorator,
      tickerProvider: this,
    );
    _dragInfo!.startDrag();

    final OverlayState overlay = Overlay.of(context)!;
    assert(_overlayEntry == null);
    _overlayEntry = OverlayEntry(builder: _dragInfo!.createProxy);
    overlay.insert(_overlayEntry!);
    for (final _ReorderableItemState childItem in _items.values) {
      if (childItem == item || !childItem.mounted) continue;
      // if (item.index == _insertIndex) continue;
      // childItem.updateForGap(
      //     _insertIndex!, _dragInfo!.itemExtent, false, _reverse);
      // no longer need because the gap is intrinsicly already in place.
    }
    return _dragInfo;
  }

  void _dragUpdate(_DragInfo item, Offset position, Offset delta) {
    setState(() {
      _overlayEntry?.markNeedsBuild();
      _dragUpdateItems();
      _autoScrollIfNecessary();
    });
  }

  void _dragCancel(_DragInfo item) {
    _dragReset();
  }

  void _dragEnd(_DragInfo item) {
    setState(() {
      if (_insertIndex! < widget.itemCount - 1) {
        // Find the location of the item we want to insert before
        _finalDropPosition = _itemOffsetAt(_insertIndex!);
        if (_insertIndex! > item.index) {
          _finalDropPosition = _finalDropPosition!.translate(
              0.0, -item.itemExtent * widget.overlayScale); //TODO: Make work for horizontal
        }
      } else {
        // Inserting into the last spot on the list. If it's the only spot, put
        // it back where it was. Otherwise, grab the second to last and move
        // down by the gap.
        final int itemIndex =
            _items.length > 1 ? _insertIndex! - 1 : _insertIndex!;
        if (_reverse) {
          _finalDropPosition = _itemOffsetAt(itemIndex) -
              _extentOffset(item.itemExtent, _scrollDirection);
        } else {
          _finalDropPosition = _itemOffsetAt(itemIndex) +
              _extentOffset(item.itemExtent * widget.overlayScale, _scrollDirection);
        }
      }
    });
  }

  void _dropCompleted() {
    final int fromIndex = _dragIndex!;
    final int toIndex = _insertIndex!;
    if (fromIndex != toIndex) {
      widget.onReorder.call(fromIndex, toIndex);
    }
    _dragReset();
  }

  void _dragReset() {
    setState(() {
      if (_dragInfo != null) {
        if (_dragIndex != null && _items.containsKey(_dragIndex)) {
          final _ReorderableItemState dragItem = _items[_dragIndex!]!;
          dragItem._dragging = false;
          dragItem.rebuild();
          _dragIndex = null;
        }
        _dragInfo?.dispose();
        _dragInfo = null;
        _resetItemGap();
        _recognizer?.dispose();
        _recognizer = null;
        _overlayEntry?.remove();
        _overlayEntry = null;
        _finalDropPosition = null;
      }
    });
  }

  void _resetItemGap() {
    for (final _ReorderableItemState item in _items.values) {
      item.resetGap();
    }
  }

  void _dragUpdateItems() {
    assert(_dragInfo != null);
    final double gapExtent = _dragInfo!.itemExtent;
    final double proxyItemStart = _offsetExtent(
        _dragInfo!.dragPosition - _dragInfo!.dragOffset, _scrollDirection);
    final double proxyItemEnd = proxyItemStart + gapExtent;

    // Find the new index for inserting the item being dragged.
    int newIndex = _insertIndex!;

    for (final _ReorderableItemState item in _items.values) {
      if (item.index == _dragIndex! || !item.mounted) continue;

      final Rect geometry = item.targetGeometry();
      final double itemStart =
          _scrollDirection == Axis.vertical ? geometry.top : geometry.left;
      final double itemExtent =
          (_scrollDirection == Axis.vertical ? geometry.height : geometry.width) ;
      final double itemEnd = itemStart + itemExtent;
      final double itemMiddle = itemStart + itemExtent / 2;

      if (_reverse) {
        if (itemEnd >= proxyItemEnd && proxyItemEnd >= itemMiddle) {
          // The start of the proxy is in the beginning half of the item, so
          // we should swap the item with the gap and we are done looking for
          // the new index.
          newIndex = item.index;
          break;
        } else if (itemMiddle >= proxyItemStart &&
            proxyItemStart >= itemStart) {
          // The end of the proxy is in the ending half of the item, so
          // we should swap the item with the gap and we are done looking for
          // the new index.
          newIndex = item.index + 1;
          break;
        } else if (itemStart > proxyItemEnd && newIndex < (item.index + 1)) {
          newIndex = item.index + 1;
        } else if (proxyItemStart > itemEnd && newIndex > item.index) {
          newIndex = item.index;
        }
      } else {
        if (itemStart <= proxyItemStart && proxyItemStart <= itemMiddle) {
          // The start of the proxy is in the beginning half of the item, so
          // we should swap the item with the gap and we are done looking for
          // the new index.
          newIndex = item.index;
          break;
        } else if (itemMiddle <= proxyItemEnd && proxyItemEnd <= itemEnd) {
          // The end of the proxy is in the ending half of the item, so
          // we should swap the item with the gap and we are done looking for
          // the new index.
          newIndex = item.index + 1;
          break;
        } else if (itemEnd < proxyItemStart && newIndex < (item.index + 1)) {
          newIndex = item.index + 1;
        } else if (proxyItemEnd < itemStart && newIndex > item.index) {
          newIndex = item.index;
        }
      }
    }
    if (newIndex != _insertIndex) {
      _insertIndex = newIndex;
      for (final _ReorderableItemState item in _items.values) {
        if (item.index == _dragIndex || !item.mounted) continue;
        item.updateForGap(newIndex - 1, gapExtent, true, _reverse, _dragIndex!);
      }
    }
  }

  Future<void> _autoScrollIfNecessary() async {
    if (!_autoScrolling && _dragInfo != null && _dragInfo!.scrollable != null) {
      final ScrollPosition position = _dragInfo!.scrollable!.position;
      double? newOffset;
      const Duration duration = Duration(milliseconds: 14);
      const double step = 1.0;
      const double overDragMax = 20.0;
      const double overDragCoef = 10;

      final RenderBox scrollRenderBox =
          _dragInfo!.scrollable!.context.findRenderObject()! as RenderBox;
      final Offset scrollOrigin = scrollRenderBox.localToGlobal(Offset.zero);
      final double scrollStart = _offsetExtent(scrollOrigin, _scrollDirection);
      final double scrollEnd =
          scrollStart + _sizeExtent(scrollRenderBox.size, _scrollDirection) * widget.overlayScale;

      final double proxyStart = _offsetExtent(
          _dragInfo!.dragPosition - _dragInfo!.dragOffset, _scrollDirection);
      final double proxyEnd = proxyStart + _dragInfo!.itemExtent * widget.overlayScale;

      if (_reverse) {
        if (proxyEnd > scrollEnd &&
            position.pixels > position.minScrollExtent) {
          final double overDrag = max(proxyEnd - scrollEnd, overDragMax);
          newOffset = max(position.minScrollExtent,
              position.pixels - step * overDrag / overDragCoef);
        } else if (proxyStart < scrollStart &&
            position.pixels < position.maxScrollExtent) {
          final double overDrag = max(scrollStart - proxyStart, overDragMax);
          newOffset = min(position.maxScrollExtent,
              position.pixels + step * overDrag / overDragCoef);
        }
      } else {
        if (proxyStart < scrollStart &&
            position.pixels > position.minScrollExtent) {
          final double overDrag = max(scrollStart - proxyStart, overDragMax);
          newOffset = max(position.minScrollExtent,
              position.pixels - step * overDrag / overDragCoef);
        } else if (proxyEnd > scrollEnd &&
            position.pixels < position.maxScrollExtent) {
          final double overDrag = max(proxyEnd - scrollEnd, overDragMax);
          newOffset = min(position.maxScrollExtent,
              position.pixels + step * overDrag / overDragCoef);
        }
      }

      if (newOffset != null && (newOffset - position.pixels).abs() >= 1.0) {
        _autoScrolling = true;
        await position.animateTo(
          newOffset,
          duration: duration,
          curve: Curves.linear,
        );
        _autoScrolling = false;
        if (_dragInfo != null) {
          _dragUpdateItems();
          _autoScrollIfNecessary();
        }
      }
    }
  }

  Offset _itemOffsetAt(int index) {
    final RenderBox itemRenderBox =
        _items[index]!.context.findRenderObject()! as RenderBox;
    return itemRenderBox.localToGlobal(Offset.zero);
  }

  Widget _itemBuilder(BuildContext context, int index) {
    if (_dragInfo != null && index >= widget.itemCount) {
      switch (_scrollDirection) {
        case Axis.horizontal:
          return SizedBox(width: _dragInfo!.itemExtent);
        case Axis.vertical:
          return SizedBox(height: _dragInfo!.itemExtent);
      }
    }
    final Widget child = widget.itemBuilder(context, index);
    assert(child.key != null, 'All list items must have a key');
    final OverlayState overlay = Overlay.of(context)!;
    return _ReorderableItem(
      key: _ReorderableItemGlobalKey(child.key!, index, this),
      index: index,
      child: child,
      capturedThemes:
          InheritedTheme.capture(from: context, to: overlay.context),
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasOverlay(context));
    return SliverKnownExtentsList(
      itemExtents: widget.itemExtents,
      // When dragging, the dragged item is still in the list but has been replaced
      // by a zero height SizedBox, so that the gap can move around. To make the
      // list extent stable we add a dummy entry to the end.
      delegate: SliverChildBuilderDelegate(
        _itemBuilder,
        childCount: widget.itemCount + (_dragInfo != null ? 1 : 0),
      ),
    );
  }
}

class _ReorderableItem extends StatefulWidget {
  const _ReorderableItem({
    required Key key,
    required this.index,
    required this.child,
    required this.capturedThemes,
  }) : super(key: key);

  final int index;
  final Widget child;
  final CapturedThemes capturedThemes;

  @override
  _ReorderableItemState createState() => _ReorderableItemState();
}

class _ReorderableItemState extends State<_ReorderableItem> {
  late SliverKnownExtentsReorderableListState _listState;

  Offset _startOffset = Offset.zero;
  Offset _targetOffset = Offset.zero;
  AnimationController? _offsetAnimation;

  Key get key => widget.key!;
  int get index => widget.index;

  bool get dragging => _dragging;
  set dragging(bool dragging) {
    if (mounted) {
      setState(() {
        _dragging = dragging;
      });
    }
  }

  bool _dragging = false;

  @override
  void initState() {
    _listState = SliverKnownExtentsReorderableList.of(context);
    _listState._registerItem(this);
    super.initState();
  }

  @override
  void dispose() {
    _offsetAnimation?.dispose();
    _listState._unregisterItem(index, this);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _ReorderableItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) {
      _listState._unregisterItem(oldWidget.index, this);
      _listState._registerItem(this);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_dragging) {
      return const SizedBox();
    }
    _listState._registerItem(this);
    return Transform(
      transform: Matrix4.translationValues(offset.dx, offset.dy, 0.0),
      child: widget.child,
    );
  }

  @override
  void deactivate() {
    _listState._unregisterItem(index, this);
    super.deactivate();
  }

  Offset get offset {
    if (_offsetAnimation != null) {
      final double animValue =
          Curves.easeInOut.transform(_offsetAnimation!.value);
      return Offset.lerp(_startOffset, _targetOffset, animValue)!;
    }
    return _targetOffset;
  }

  int _offsetMultiplier(int gapIndex, bool reverse, int dragIndex) {
    if (index > dragIndex && gapIndex >= index) {
      return -1;
    } else {
      if (gapIndex < index && dragIndex > index) {
        return 1;
      }
    }
    return 0;
  }

  void updateForGap(int gapIndex, double gapExtent, bool animate, bool reverse,
      int dragIndex) {
    final Offset newTargetOffset = _extentOffset(
        _offsetMultiplier(gapIndex, reverse, dragIndex) * gapExtent,
        _listState._scrollDirection);
    if (newTargetOffset != _targetOffset) {
      _targetOffset = newTargetOffset;
      if (animate) {
        if (_offsetAnimation == null) {
          _offsetAnimation = AnimationController(
            vsync: _listState,
            duration: const Duration(milliseconds: 250),
          )
            ..addListener(rebuild)
            ..addStatusListener((AnimationStatus status) {
              if (status == AnimationStatus.completed) {
                _startOffset = _targetOffset;
                _offsetAnimation!.dispose();
                _offsetAnimation = null;
              }
            })
            ..forward();
        } else {
          _startOffset = offset;
          _offsetAnimation!.forward(from: 0.0);
        }
      } else {
        if (_offsetAnimation != null) {
          _offsetAnimation!.dispose();
          _offsetAnimation = null;
        }
        _startOffset = _targetOffset;
      }
      rebuild();
    }
  }

  void resetGap() {
    if (_offsetAnimation != null) {
      _offsetAnimation!.dispose();
      _offsetAnimation = null;
    }
    _startOffset = Offset.zero;
    _targetOffset = Offset.zero;
    rebuild();
  }

  Rect targetGeometry() {
    final RenderBox itemRenderBox = context.findRenderObject()! as RenderBox;
    final Offset itemPosition =
        itemRenderBox.localToGlobal(Offset.zero) + _targetOffset;
    return itemPosition & itemRenderBox.size;
  }

  void rebuild() {
    if (mounted) {
      setState(() {});
    }
  }
}

/// A wrapper widget that will recognize the start of a drag on the wrapped
/// widget by a [PointerDownEvent], and immediately initiate dragging the
/// wrapped item to a new location in a reorderable list.
///
/// See also:
///
///  * [ReorderableDelayedDragStartListener], a similar wrapper that will
///    only recognize the start after a long press event.
///  * [KnownExtentsReorderableList], a widget list that allows the user to reorder
///    its items.
///  * [SliverKnownExtentsReorderableList], a sliver list that allows the user to reorder
///    its items.
///  * [ReorderableListView], a material design list that allows the user to
///    reorder its items.
class ReorderableDragStartListener extends StatelessWidget {
  /// Creates a listener for a drag immediately following a pointer down
  /// event over the given child widget.
  ///
  /// This is most commonly used to wrap part of a list item like a drag
  /// handle.
  const ReorderableDragStartListener({
    Key? key,
    required this.child,
    required this.index,
  }) : super(key: key);

  /// The widget for which the application would like to respond to a tap and
  /// drag gesture by starting a reordering drag on a reorderable list.
  final Widget child;

  /// The index of the associated item that will be dragged in the list.
  final int index;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (PointerDownEvent event) {
        _startDragging(context, event);
      },
      child: child,
    );
  }

  /// Provides the gesture recognizer used to indicate the start of a reordering
  /// drag operation.
  ///
  /// By default this returns an [ImmediateMultiDragGestureRecognizer] but
  /// subclasses can use this to customize the drag start gesture.
  @protected
  MultiDragGestureRecognizer<MultiDragPointerState> createRecognizer() {
    return ImmediateMultiDragGestureRecognizer(debugOwner: this);
  }

  void _startDragging(BuildContext context, PointerDownEvent event) {
    final SliverKnownExtentsReorderableListState? list =
        SliverKnownExtentsReorderableList.maybeOf(context);

    list?.startItemDragReorder(
      index: index,
      event: event,
      recognizer: createRecognizer(),
    );
  }
}

/// A wrapper widget that will recognize the start of a drag operation by
/// looking for a long press event. Once it is recognized, it will start
/// a drag operation on the wrapped item in the reorderable list.
///
/// See also:
///
///  * [ReorderableDragStartListener], a similar wrapper that will
///    recognize the start of the drag immediately after a pointer down event.
///  * [KnownExtentsReorderableList], a widget list that allows the user to reorder
///    its items.
///  * [SliverKnownExtentsReorderableList], a sliver list that allows the user to reorder
///    its items.
///  * [ReorderableListView], a material design list that allows the user to
///    reorder its items.
class ReorderableDelayedDragStartListener extends ReorderableDragStartListener {
  /// Creates a listener for an drag following a long press event over the
  /// given child widget.
  ///
  /// This is most commonly used to wrap an entire list item in a reorderable
  /// list.
  const ReorderableDelayedDragStartListener({
    Key? key,
    required Widget child,
    required int index,
  }) : super(key: key, child: child, index: index);

  @override
  MultiDragGestureRecognizer<MultiDragPointerState> createRecognizer() {
    return DelayedMultiDragGestureRecognizer(debugOwner: this);
  }
}

typedef _DragItemUpdate = void Function(
    _DragInfo item, Offset position, Offset delta);
typedef _DragItemCallback = void Function(_DragInfo item);

class _DragInfo extends Drag {
  _DragInfo({
    required _ReorderableItemState item,
    Offset initialPosition = Offset.zero,
    this.scrollDirection = Axis.vertical,
    this.onUpdate,
    this.onEnd,
    this.onCancel,
    this.onDropCompleted,
    this.proxyDecorator,
    required this.tickerProvider,
    required this.overlayScale,
    required this.overlayOffset,
  }) {
    final RenderBox itemRenderBox =
        item.context.findRenderObject()! as RenderBox;
    listState = item._listState;
    index = item.index;
    child = item.widget.child;
    capturedThemes = item.widget.capturedThemes;
    dragPosition = initialPosition;
    dragOffset = itemRenderBox.globalToLocal(initialPosition);
    itemSize = item.context.size!;
    itemExtent = _sizeExtent(itemSize, scrollDirection);
    scrollable = Scrollable.of(item.context);
  }

  final Axis scrollDirection;
  final _DragItemUpdate? onUpdate;
  final _DragItemCallback? onEnd;
  final _DragItemCallback? onCancel;
  final VoidCallback? onDropCompleted;
  final ReorderItemProxyDecorator? proxyDecorator;
  final TickerProvider tickerProvider;
  final double overlayScale;
  final Offset overlayOffset;

  late SliverKnownExtentsReorderableListState listState;
  late int index;
  late Widget child;
  late Offset dragPosition;
  late Offset dragOffset;
  late Size itemSize;
  late double itemExtent;
  late CapturedThemes capturedThemes;
  ScrollableState? scrollable;
  AnimationController? _proxyAnimation;

  void dispose() {
    _proxyAnimation?.dispose();
  }

  void startDrag() {
    _proxyAnimation = AnimationController(
      vsync: tickerProvider,
      duration: const Duration(milliseconds: 250),
    )
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.dismissed) {
          _dropCompleted();
        }
      })
      ..forward();
  }

  @override
  void update(DragUpdateDetails details) {
    final Offset delta = _restrictAxis(details.delta, scrollDirection);
    dragPosition += delta;
    onUpdate?.call(this, dragPosition, details.delta);
  }

  @override
  void end(DragEndDetails details) {
    _proxyAnimation!.reverse();
    onEnd?.call(this);
  }

  @override
  void cancel() {
    _proxyAnimation?.dispose();
    _proxyAnimation = null;
    onCancel?.call(this);
  }

  void _dropCompleted() {
    _proxyAnimation?.dispose();
    _proxyAnimation = null;
    onDropCompleted?.call();
  }

  Widget createProxy(BuildContext context) {
    final position = Offset(overlayOffset.dx, (dragPosition - dragOffset).dy);
    print('position: $position');
    print('dragPosition $dragPosition');
    return capturedThemes.wrap(
      _DragItemProxy(
        listState: listState,
        index: index,
        child: child,
        size:
            Size(itemSize.width * overlayScale, itemSize.height * overlayScale),
        animation: _proxyAnimation!,
        position: Offset(overlayOffset.dx, (dragPosition - dragOffset).dy),
        proxyDecorator: proxyDecorator,
      ),
    );
  }
}

Offset _overlayOrigin(BuildContext context) {
  final OverlayState overlay = Overlay.of(context)!;
  final RenderBox overlayBox = overlay.context.findRenderObject()! as RenderBox;
  return overlayBox.localToGlobal(Offset.zero);
}

class _DragItemProxy extends StatelessWidget {
  const _DragItemProxy({
    Key? key,
    required this.listState,
    required this.index,
    required this.child,
    required this.position,
    required this.size,
    required this.animation,
    required this.proxyDecorator,
  }) : super(key: key);

  final SliverKnownExtentsReorderableListState listState;
  final int index;
  final Widget child;
  final Offset position;
  final Size size;
  final AnimationController animation;
  final ReorderItemProxyDecorator? proxyDecorator;

  @override
  Widget build(BuildContext context) {
    final Widget proxyChild =
        proxyDecorator?.call(child, index, animation.view) ?? child;
    final Offset overlayOrigin = _overlayOrigin(context);

    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        Offset effectivePosition = position;
        final Offset? dropPosition = listState._finalDropPosition;
        if (dropPosition != null) {
          effectivePosition = Offset.lerp(dropPosition - overlayOrigin,
              effectivePosition, Curves.easeOut.transform(animation.value))!;
        }
        return Positioned(
          child: SizedBox(
            width: size.width,
            height: size.height,
            child: child,
          ),
          left: effectivePosition.dx,
          top: effectivePosition.dy,
        );
      },
      child: proxyChild,
    );
  }
}

double _sizeExtent(Size size, Axis scrollDirection) {
  switch (scrollDirection) {
    case Axis.horizontal:
      return size.width;
    case Axis.vertical:
      return size.height;
  }
}

double _offsetExtent(Offset offset, Axis scrollDirection) {
  switch (scrollDirection) {
    case Axis.horizontal:
      return offset.dx;
    case Axis.vertical:
      return offset.dy;
  }
}

Offset _extentOffset(double extent, Axis scrollDirection) {
  switch (scrollDirection) {
    case Axis.horizontal:
      return Offset(extent, 0.0);
    case Axis.vertical:
      return Offset(0.0, extent);
  }
}

Offset _restrictAxis(Offset offset, Axis scrollDirection) {
  switch (scrollDirection) {
    case Axis.horizontal:
      return Offset(offset.dx, 0.0);
    case Axis.vertical:
      return Offset(0.0, offset.dy);
  }
}

// A global key that takes its identity from the object and uses a value of a
// particular type to identify itself.
//
// The difference with GlobalObjectKey is that it uses [==] instead of [identical]
// of the objects used to generate widgets.
@optionalTypeArgs
class _ReorderableItemGlobalKey extends GlobalObjectKey {
  const _ReorderableItemGlobalKey(this.subKey, this.index, this.state)
      : super(subKey);

  final Key subKey;
  final int index;
  final SliverKnownExtentsReorderableListState state;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is _ReorderableItemGlobalKey &&
        other.subKey == subKey &&
        other.index == index &&
        other.state == state;
  }

  @override
  int get hashCode => hashValues(subKey, index, state);
}

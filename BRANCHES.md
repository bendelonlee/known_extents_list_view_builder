I added some more functionality to other branches, they may be useful to you. 
Let me know if you end up using one of these by commenting on [this issue](https://github.com/bendelonlee/known_extents_list_view_builder/issues/6), and I'll consider releasing a separate package.

In general, no support yet for horizontal or reverse lists.

# Branches
## [reorderable-with-sizing-fixes-and-callbacks](https://github.com/bendelonlee/known_extents_list_view_builder/tree/reorderable-with-sizing-fixes-and-callbacks)
Extends KnownExtentsReorderableListView with:
  * support for the list to be scaled inside a fitted box. Fix for [this issue](https://github.com/flutter/flutter/issues/87676) with the basic Flutter widget. See [this example](https://github.com/bendelonlee/known_extents_list_view_builder/blob/reorderable-with-sizing-fixes-and-callbacks/example/lib/reorderable_in_fitted.dart). Support for scaling, but none for altering the aspect ratio of the list. Related parameters:
    - optional `Offset overlayOffset` (defaults to (0,0). Only the x coordinate is used at this point. Specifies the x coord where you want the item as it appears while it's being dragged (aka its **drag proxy**). This may be useful in case you want dragged items to be larger than items in the list (and need them them to overflow the list's horizontal bounds).
    - optional `double overlayScale` defaults to 1. Factor by which to scale the drag proxy. Can be used either to just keep it normal inside a fitted box, or to make it appear magnified if so inclined.
    - optional `EdgetInsets` overlayMargin (defaults to EdgeInsets.zero). 
  * an onDragStart callback that's called when a drag starts and recieves an `int index` as a positional parameter.
  * an onDragReset callback that's called whenever a drag ends whether or not a reorder occurred (ie even if you place an item back where it started).
## [animated-entrances-and-exits](https://github.com/bendelonlee/known_extents_list_view_builder/tree/animated-entrances-and-exits)
Unlike https://pub.dev/packages/implicitly_animated_reorderable_list, is not implicit. 
Extends KnownExtentsReorderableListView with the added parameters:
 * optional `int animatedIndex`. The index of the list item that is either entering or exiting.
 * optional `bool isAdding`. When true, animates the item's entrance. When false, animates its exit.
If `animatedIndex` is null, `isAdding` should also be null. If they both have non-null values, the animation will play on build. In [this example](https://github.com/bendelonlee/known_extents_list_view_builder/blob/animated-entrances-and-exits/example/lib/example.dart), when you click an odd item it disappears, when you click an even item it gets an animated entrance. 
You'll want to manage the state of your list as well. 

## [fancy-list](https://github.com/bendelonlee/known_extents_list_view_builder/tree/fancy-list)
Merged version of reorderable-with-sizing-fixes-and-callbacks and animated-entrances-and-exits. 


# Disclaimers:

Consider branches to be in an alpha state, more so than the package itself.

While the package on pub.dev won't / can't be pulled down, this repo can be (not that I'm planning on it). Consider forking instead of putting my repo in your pubspec.yaml.


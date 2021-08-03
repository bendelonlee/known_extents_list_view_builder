# known_extents_list_view_builder

This package is intended to address [a performance issue in Flutter](https://github.com/flutter/flutter/issues/52207). Whereas the internal flutter list only allows you to pass in a fixed `itemExtent` to optimize for uniform lists, this allows you to pass in a list of `itemExtents`. Includes a basic list and a reorderable list.

This is not official Flutter package, nor is it put out by the flutter team. Maintainance and edges cases are not guaranteed.

To see the difference it makes when when moving through a long, variable extent list you can run `example/lib/reorderable_list_view_side_by_side.dart` or watch [this video taken in release mode](https://vimeo.com/582598514).

If you don't need your list to be reorderable, and would prefer to scroll to indexes rather than exact pixel values, consider using [scrollable_positioned_list](https://pub.dev/packages/scrollable_positioned_list).

([Hire me](https://www.linkedin.com/in/benjamin-lee-84068818/))
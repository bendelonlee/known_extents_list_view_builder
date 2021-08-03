import 'package:flutter/material.dart';
import 'package:known_extents_list_view_builder/render_sliver_known_extents_list.dart';

class SliverKnownExtentsList extends SliverMultiBoxAdaptorWidget {
  /// Creates a sliver that places box children with the same main axis extent
  /// in a linear array.
  const SliverKnownExtentsList({
    Key? key,
    required SliverChildDelegate delegate,
    required this.itemExtents,
  }) : super(key: key, delegate: delegate);

  /// The extent the children are forced to have in the main axis.
  final List<double> itemExtents;

  @override
  RenderSliverKnownExtentsList createRenderObject(BuildContext context) {
    final SliverMultiBoxAdaptorElement element =
        context as SliverMultiBoxAdaptorElement;
    return RenderSliverKnownExtentsList(
        childManager: element, itemExtents: itemExtents);
  }

  @override
  void updateRenderObject(BuildContext context, dynamic renderObject) {
    renderObject.itemExtents = itemExtents;
  }
}

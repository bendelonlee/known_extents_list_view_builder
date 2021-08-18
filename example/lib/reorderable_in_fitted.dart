import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:known_extents_list_view_builder/known_extents_reorderable_list_view_builder.dart';
// This example shows two reorderable lists side by side.
// For a basic example with a non-reorderable list see basic_list.dart

void main() {
  runApp(MyApp());
}

JsonEncoder encoder = new JsonEncoder.withIndent('  ');

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Known Extents Demo: 10,000 items side by side'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double innerWidth = 1500;
  double outerWidth = 750;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: SizedBox(
          width: outerWidth,
          height: 500,
          child: FittedBox(
            fit: BoxFit.fitWidth,
            child: SizedBox(
              height: 500,
              width: innerWidth,
              child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                return Row(
                  children: [
                    
                    ListDisplay(
                      scale: outerWidth / innerWidth,
                        constraints: constraints, useKnownExtents: true),
                  ],
                );
              }),
            ),
          ),
        ));
  }
}

class ListDisplay extends StatefulWidget {
  final bool useKnownExtents;
  final BoxConstraints constraints;
  final double scale;
  const ListDisplay(
      {Key? key,
      required this.constraints,
      required this.useKnownExtents,
      this.scale = 1})
      : super(key: key);

  @override
  _ListDisplayState createState() => _ListDisplayState();
}

class _ListDisplayState extends State<ListDisplay> {
  late ScrollController scrollController;
  @override
  void initState() {
    scrollController = ScrollController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.useKnownExtents
        ? 'Using Known Extents, fixing for being inside a fittedBox'
        : 'No Optimization / fixes';

    return Column(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              style: TextStyle(fontSize: 15),
            ),
          ),
        ),
        Padding(
            padding: const EdgeInsets.all(8.0),
            child: ScrollButtons(controller: scrollController)),
        ConstrainedBox(
          constraints: BoxConstraints(
              maxHeight: widget.constraints.maxHeight - 112,
              maxWidth: widget.constraints.maxWidth / 2),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ExampleList(
              scale: widget.scale,
              outerConstraints: widget.constraints,
              useKnownExtents: widget.useKnownExtents,
              scrollController: scrollController,
            ),
          ),
        ),
      ],
    );
  }
}

class ScrollButtons extends StatefulWidget {
  final ScrollController controller;
  const ScrollButtons({required this.controller, Key? key}) : super(key: key);

  @override
  _ScrollButtonsState createState() => _ScrollButtonsState();
}

class _ScrollButtonsState extends State<ScrollButtons> {
  final textController = TextEditingController(
    text: '500000',
  );
  bool animate = false;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Switch(
              value: animate,
              onChanged: (b) {
                setState(() {
                  animate = b;
                });
              }),
          Spacer(),
          TextButton(
              onPressed: () {
                if (animate) {
                  widget.controller.animateTo(double.parse(textController.text),
                      duration: Duration(milliseconds: 500),
                      curve: Curves.ease);
                } else {
                  widget.controller.jumpTo(double.parse(textController.text));
                }
              },
              child: animate ? Text('Animate to') : Text('Jump to')),
          Spacer(
            flex: 1,
          ),
          SizedBox(
            width: 100,
            child: TextField(
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                  border: UnderlineInputBorder(), labelText: 'pixels'),
              keyboardType: TextInputType.number,
              controller: textController,
            ),
          )
        ],
      ),
    );
  }
}

class ExampleList extends StatefulWidget {
  final ScrollController scrollController;
  final bool useKnownExtents;
  final BoxConstraints outerConstraints;
  final double scale;
  ExampleList(
      {this.useKnownExtents = true,
      this.scale = 1,
      required this.scrollController,
      required this.outerConstraints});
  @override
  _ExampleListState createState() => _ExampleListState();
}

class _ExampleListState extends State<ExampleList> {
  static List<Map<String, dynamic>> items = List.generate(
      10000,
      (index) => (index % 5 == 0)
          ? {'text': 'header', 'id': index}
          : {'text': "List Item: $index", 'id': index});

  late ScrollController scrollController;
  final double _itemHeight = 60.0;
  final double _headerHeight = 21.0;
  Widget _itemBuilder(_, index) {
    final item = items[index];
    if (item['text'] != 'header') {
      return Container(
          width: Size.infinite.width,
          height: _itemHeight,
          key: ValueKey(items[index]),
          color: Colors.blueGrey.shade100,
          child: Center(child: Text(item['text'])));
    } else {
      return Container(
          color: Colors.blueGrey.shade900,
          width: Size.infinite.width,
          key: ValueKey(items[index]),
          child: Center(
              child: Text(item['text'], style: TextStyle(color: Colors.white))),
          height: _headerHeight);
    }
  }

  List<double> makeItemExtents() {
    final _result = items.map((item) {
      if (item['text'] == 'header') {
        return _headerHeight;
      }
      return _itemHeight;
    }).toList();
    return _result;
  }

  @override
  void initState() {
    scrollController = widget.scrollController;
    super.initState();
  }

  _onReorder(int start, int end) {
    setState(() {
      items.insert(end, items[start]);
      if (start > end) {
        start += 1;
      }
      items.removeAt(start);
    });
  }

  _contents() {
    double scale = widget.scale;
    if (widget.useKnownExtents) {
      return KnownExtentsReorderableListView.builder(
          crossAxisExtent: widget.outerConstraints.maxWidth / 2 - 16,
          onReorder: _onReorder,
          itemExtents: makeItemExtents(),
          physics: ClampingScrollPhysics(),
          itemCount: items.length,
          scrollController: scrollController,
          itemBuilder: _itemBuilder,
          overlayScale: scale,
          overlayOffset: Offset(8.0 * scale, 0.0));
    } else {
      return ReorderableListView.builder(
        onReorder: _onReorder,
        physics: ClampingScrollPhysics(),
        itemCount: items.length,
        scrollController: scrollController,
        itemBuilder: _itemBuilder,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _contents();
  }
}

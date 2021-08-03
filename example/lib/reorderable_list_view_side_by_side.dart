import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:known_extents_list_view_builder/known_extents_reorderable_list_view_builder.dart';

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
  Widget listDisplay(
      {required BoxConstraints constraints, required bool useKnownExtents}) {
    final title = useKnownExtents ? 'Using Known Extents' : 'No Optimization';
    return Column(
      children: [
        Center(
          child:
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(title, style: TextStyle(fontSize: 25),),
              ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(
              maxHeight: constraints.maxHeight - 50,
              maxWidth: constraints.maxWidth / 2),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ExampleList(useKnownExtents: useKnownExtents),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          return Row(
            children: [
              listDisplay(constraints: constraints, useKnownExtents: false),
              listDisplay(constraints: constraints, useKnownExtents: true),
            ],
          );
        }));
  }
}

class ExampleList extends StatefulWidget {
  final bool useKnownExtents;
  ExampleList({this.useKnownExtents = true});
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
    print('makeItemExtents called');
    final _result = items.map((item) {
      if (item['text'] == 'header') {
        return _headerHeight;
      }
      return _itemHeight;
    }).toList();
    print('extents: ${encoder.convert(_result.sublist(0, 10))}');
    return _result;
  }

  @override
  void initState() {
    scrollController = ScrollController();
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
    if (widget.useKnownExtents) {
      return KnownExtentsReorderableListView.builder(
        onReorder: _onReorder,
        itemExtents: makeItemExtents(),
        physics: AlwaysScrollableScrollPhysics(),
        itemCount: items.length,
        scrollController: scrollController,
        itemBuilder: _itemBuilder,
      );
    } else {
      return ReorderableListView.builder(
        onReorder: _onReorder,
        physics: AlwaysScrollableScrollPhysics(),
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

import 'package:flutter/material.dart';

import 'package:known_extents_list_view_builder/known_extents_list_view_builder.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
         
          title: Text(widget.title),
        ),
        body: ExampleList());
  }
}

class ExampleList extends StatefulWidget {
  @override
  _ExampleListState createState() => _ExampleListState();
}

class _ExampleListState extends State<ExampleList> {
  static List<String> items =
      List.generate(10000, (index) => "List Item: $index");

  late ScrollController scrollController;
  final double _itemHeight = 150.0;
  final double _headerHeight = 21.0;
  Widget _itemBuilder(_, index) {
    if (index % 5 == 0) {
      return Column(children: [
        Container(
            child: Text('header'),
            color: Colors.green.shade100,
            width: Size.infinite.width,
            height: _headerHeight),
        Container(
          color: index % 2 == 0 ? Colors.blueGrey.shade100 :  Colors.grey.shade100,
          width: Size.infinite.width,
          child: Text(items[index]), height: _itemHeight)
      ]);
    }
    return Container(
      color: index % 2 == 0 ? Colors.blueGrey.shade100 :  Colors.grey.shade100,
      width: Size.infinite.width,
      child: Text(items[index]), height: _itemHeight);
  }

  List<double> get _itemExtents {
    return List.generate(10000,
        (index) => index % 5 == 0 ? _itemHeight + _headerHeight : _itemHeight);
  }

  @override
  void initState() {
    scrollController = ScrollController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        KnownExtentsListView.builder(
          itemExtents: _itemExtents,
          physics: AlwaysScrollableScrollPhysics(),
          itemCount: items.length,
          controller: scrollController,
          itemBuilder: _itemBuilder,
        )
      ],
    );
  }
}

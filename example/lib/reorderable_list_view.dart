import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:known_extents_list_view_builder/known_extents_list_view_builder.dart';
import 'package:known_extents_list_view_builder/known_extents_reorderable_list_view_builder.dart';

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
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
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
  final double _itemHeight = 40.0;
  final double _headerHeight = 21.0;
  Widget _itemBuilder(_, index) {
    if (index % 5 == 0) {
      return Column(
        key: ValueKey(items[index]),
        children: [
        Container(
            child: Text('header'),
            color: Colors.blueGrey,
            height: _headerHeight),
        Container(child: Text(items[index]), height: _itemHeight)
      ]);
    }
    return Container(
      key: ValueKey(items[index]),
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
    double scrollerWidth = 20;
    return Stack(
      children: <Widget>[
        Padding(
            padding: EdgeInsets.only(right: scrollerWidth),
            child: KnownExtentsReorderableListView.builder(
              onReorder: (int start, int end){},
              itemExtents: _itemExtents,
              physics: AlwaysScrollableScrollPhysics(),
              itemCount: items.length,
              scrollController: scrollController,
              itemBuilder: _itemBuilder,
            ))
      ],
    );
  }
}

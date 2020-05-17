import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// import 'generated/i18n.dart';
import 'kater_api.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Kater X",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en'),
        const Locale.fromSubtags(languageCode: 'zh'),
      ],
      home: MyHomePage(title: "Kater"),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Map content = new Map();
  List discussions = new List();
  List included = new List();
  GlobalKey<RefreshIndicatorState> _refreshIndicatorKey;

  @override
  void initState() {
    super.initState();
    _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _refreshIndicatorKey.currentState?.show();
    });

    this._onRefresh();
  }

  Future<dynamic> _onRefresh() async {
    content = await KaterAPI().fetchNews();
    setState(() {
      discussions = content["data"];
      included = content["included"];
    });
  }

  String _getUserAvatarUrl(String userID) {
    for (var element in included) {
      if (element["id"] == userID) {
        if (element["attributes"]["avatarUrl"] != null)
          return element["attributes"]["avatarUrl"];
        else
          return "https://fakeimg.pl/35/?text=Avatar";
      }
    }
    return "https://fakeimg.pl/35/?text=";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: RefreshIndicator(onRefresh: _onRefresh, child: _buildList()),
      floatingActionButton: FloatingActionButton(
        onPressed: _onRefresh,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildList() {
    return ListView.separated(
        itemCount: discussions.length,
        separatorBuilder: (BuildContext context, int index) =>
            Divider(height: 3, color: Colors.black26),
        itemBuilder: (context, index) {
          return ListTile(
            leading: new Container(
                width: 35.0,
                height: 35.0,
                decoration: new BoxDecoration(
                    shape: BoxShape.circle,
                    image: new DecorationImage(
                        fit: BoxFit.fill,
                        image: new NetworkImage(_getUserAvatarUrl(
                            discussions[index]["relationships"]["user"]["data"]
                                ["id"]))))),
            title: Text(discussions[index]["attributes"]["title"]),
            subtitle: Text(discussions[index]["attributes"]["createdAt"]),
          );
        });
  }
}

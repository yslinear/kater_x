import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// import 'generated/i18n.dart';
import 'kater_api.dart';
import 'package:intl/intl.dart';

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
  int pageOffset = 0;
  Map content = new Map();
  List discussions = new List();
  List included = new List();
  var formatter = new DateFormat('yyyy-MM-dd HH:mm:ss');

  GlobalKey<RefreshIndicatorState> _refreshIndicatorKey;
  ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController = new ScrollController();
    _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _refreshIndicatorKey.currentState?.show();
    });

    this._fetchData();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          (_scrollController.position.maxScrollExtent)) {
        pageOffset += 20;
        _fetchData();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<dynamic> _onRefresh() {
    this.pageOffset = 0;
    discussions.clear();
    included.clear();
    setState(() {});
    return _fetchData();
  }

  Future<dynamic> _fetchData() async {
    content = await KaterAPI().fetchNews(pageOffset);
    setState(() {
      discussions.addAll(content["data"]);
      included.addAll(content["included"]);
    });
  }

  String _getUserAvatarUrl(String userID) {
    for (var element in included) {
      if (element["id"] == userID) {
        if (element["attributes"]["avatarUrl"] != null)
          return element["attributes"]["avatarUrl"];
        else
          return "https://fakeimg.pl/45/?text=Avatar";
      }
    }
    return "https://fakeimg.pl/45/?text=Avatar";
  }

  String _getUserName(String userID) {
    for (var element in included) {
      if (element["id"] == userID) {
        if (element["attributes"]["displayName"] != null)
          return element["attributes"]["displayName"];
        else
          return "";
      }
    }
    return "";
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
        // tooltip: 'Increment',
        child: Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildList() {
    return ListView.separated(
        controller: _scrollController,
        itemCount: discussions.length,
        separatorBuilder: (BuildContext context, int index) =>
            Divider(height: 10, color: Colors.black26),
        itemBuilder: (context, index) {
          return ListTile(
              leading: new Container(
                  width: 45.0,
                  height: 45.0,
                  decoration: new BoxDecoration(
                      shape: BoxShape.circle,
                      image: new DecorationImage(
                          fit: BoxFit.fill,
                          image: new NetworkImage(_getUserAvatarUrl(
                              discussions[index]["relationships"]["user"]
                                  ["data"]["id"]))))),
              title: Text(discussions[index]["attributes"]["title"]),
              subtitle: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: _getUserName(discussions[index]["relationships"]
                          ["lastPostedUser"]["data"]["id"]),
                    ),
                    WidgetSpan(
                      child: Icon(Icons.reply, size: 14, color: Colors.black54),
                    ),
                    TextSpan(
                      text: formatter.format(DateTime.parse(
                              discussions[index]["attributes"]["lastPostedAt"])
                          .toLocal()),
                    ),
                  ],
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ));
        });
  }
}

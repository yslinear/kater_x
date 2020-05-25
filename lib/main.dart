import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kater_x/discussion_page.dart';
import 'package:kater_x/parse_api.dart';
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
      if (_scrollController.position.extentAfter < 800.0) {
        print('loading by extentafter pageOffset:$pageOffset');
        print("extentAfter:${_scrollController.position.extentAfter}");
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
    discussions.clear();
    included.clear();
    setState(() {});
    this.pageOffset = 0;
    return _fetchData();
  }

  Future<dynamic> _fetchData() async {
    content = await KaterAPI().fetchNews(pageOffset);
    setState(() {
      discussions.addAll(content["data"]);
      included.addAll(content["included"]);
    });
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
        child: Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildList() {
    return ListView.separated(
        controller: _scrollController,
        itemCount: this.discussions.length,
        separatorBuilder: (BuildContext context, int index) =>
            Divider(height: 10, color: Colors.black26),
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
                backgroundImage: new NetworkImage(
              ParseAPI().getUserAvatarUrl(
                  included,
                  this.discussions[index]["relationships"]["user"]["data"]
                      ["id"]),
            )),
            title: Text(this.discussions[index]["attributes"]["title"]),
            subtitle: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: _getUserName(this.discussions[index]["relationships"]
                        ["lastPostedUser"]["data"]["id"]),
                  ),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Icon(Icons.reply, size: 14, color: Colors.black54),
                  ),
                  TextSpan(
                    text: formatter.format(DateTime.parse(this
                            .discussions[index]["attributes"]["lastPostedAt"])
                        .toLocal()),
                  ),
                ],
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ),
            trailing: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0),
                color: Colors.blue,
              ),
              margin: EdgeInsets.symmetric(vertical: 3, horizontal: 5),
              padding: EdgeInsets.symmetric(vertical: 3, horizontal: 5),
              child: Text(
                this
                    .discussions[index]["attributes"]["lastPostNumber"]
                    .toString(),
                strutStyle: StrutStyle(
                  forceStrutHeight: true,
                ),
                style: TextStyle(fontSize: 15.0, color: Colors.white),
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DiscussionPage(
                      discussionID: this.discussions[index]["id"]),
                ),
              );
            },
          );
        });
  }
}

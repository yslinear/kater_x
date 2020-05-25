import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
// import 'package:icons_helper/icons_helper.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kater_x/kater_api.dart';
import 'package:kater_x/parse_api.dart';

class DiscussionPage extends StatefulWidget {
  final discussionID;
  DiscussionPage({Key key, @required this.discussionID}) : super(key: key);
  _DiscussionPage createState() => _DiscussionPage();
}

class _DiscussionPage extends State<DiscussionPage> {
  Future future;
  String discussionTitle;
  List discussionTags = [];
  Color mainColor = Colors.blue;
  List<String> postsID = [];
  int postOffset = 0;
  List postsData = [];
  List postsIncluded = [];
  ScrollController _scrollController = new ScrollController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    future = _initDiscussion();
    _scrollController = new ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.offset >=
              _scrollController.position.maxScrollExtent - 400.0 &&
          !this.isLoading) {
        print("extentAfter:${_scrollController.position.extentAfter}");
        if (postOffset <= postsID.length) {
          this.isLoading = true;
          this.postOffset += 30;
          this._fetchPosts();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: buildFutureBuilder(),
    );
  }

  FutureBuilder<List> buildFutureBuilder() {
    return new FutureBuilder<List>(
      builder: (context, AsyncSnapshot<List> async) {
        if (async.connectionState == ConnectionState.active ||
            async.connectionState == ConnectionState.waiting) {
          return new Scaffold(
              appBar: new AppBar(
                title: Text("Loading ..."),
                backgroundColor: this.mainColor,
              ),
              body: Center(
                child: new CircularProgressIndicator(),
              ));
        }
        if (async.connectionState == ConnectionState.done) {
          debugPrint("done");
          if (async.hasError) {
            return new Center(
              child: new Text("ERROR"),
            );
          } else if (async.hasData) {
            return buildPostsView();
          }
        }
        return new Center(
          child: Text("ERROR"),
        );
      },
      future: future,
    );
  }

  buildPostsView() {
    return new Scaffold(
        appBar: new AppBar(
            title: new Text(discussionTitle), backgroundColor: this.mainColor),
        floatingActionButton: new FloatingActionButton(
            child: Icon(Icons.edit),
            onPressed: () {
              _refresh();
            }),
        body: RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(color: this.mainColor),
                    child: Center(
                        child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 40.0),
                            child: Column(
                              children: <Widget>[
                                Container(
                                  child: _buildTags(),
                                ),
                                Container(
                                  child: Text(
                                    discussionTitle,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 20.0,
                                        color: Colors.white),
                                  ),
                                ),
                              ],
                            ))),
                  ),
                  _buildComments()
                ])));
  }

  Future<List> _initDiscussion() async {
    debugPrint("initDiscussion: " + widget.discussionID);
    final response = await KaterAPI().fetchDiscussion(widget.discussionID);
    this.discussionTitle = response["data"]["attributes"]["title"];

    this.postsID.clear();
    for (var element in response["data"]["relationships"]["posts"]["data"]) {
      this.postsID.add(element["id"]);
    }
    this.discussionTags.clear();
    for (var element in response["included"]) {
      if ("tags" == element["type"]) {
        this.discussionTags.add(element["attributes"]);
      }
    }
    this.mainColor = ParseAPI().parseColor(this.discussionTags[0]["color"]);
    this.postsData.clear();
    this.postsIncluded.clear();
    this.postOffset = 0;
    await _fetchPosts();
    return this.postsID;
  }

  Widget _buildTags() {
    List<WidgetSpan> tags = new List<WidgetSpan>();
    for (var element in discussionTags) {
      tags.add(
        new WidgetSpan(
            child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            color: Colors.white,
          ),
          margin: EdgeInsets.symmetric(vertical: 3, horizontal: 5),
          padding: EdgeInsets.symmetric(vertical: 3, horizontal: 5),
          child: RichText(
            text: TextSpan(
              children: [
                // WidgetSpan(
                //   alignment: PlaceholderAlignment.middle,
                //   child: Icon(
                //       getIconGuessFavorFA(
                //           name: element["icon"].replaceAll("fas fa-", "")),
                //       size: 15,
                //       color: ParseAPI().parseColor(element["color"])),
                // ),
                WidgetSpan(
                    child: Text(
                  element["name"],
                  strutStyle: StrutStyle(
                    forceStrutHeight: true,
                  ),
                  style: TextStyle(
                      fontSize: 15.0,
                      color: ParseAPI().parseColor(element["color"])),
                ))
              ],
            ),
          ),
        )),
      );
    }
    return RichText(
      text: TextSpan(
        children: tags,
      ),
    );
  }

  Widget _buildComments() {
    var formatter = new DateFormat('yyyy-MM-dd HH:mm:ss');
    return ListView.separated(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: postsData.length,
        separatorBuilder: (BuildContext context, int index) =>
            Divider(height: 10, color: Colors.black26),
        itemBuilder: (context, index) {
          if ("comment" == postsData[index]["attributes"]["contentType"])
            return Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: ListTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Row(children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(right: 10.0),
                          child: CircleAvatar(
                              backgroundImage: new NetworkImage(
                            ParseAPI().getUserAvatarUrl(
                                postsIncluded,
                                postsData[index]["relationships"]["user"]
                                    ["data"]["id"]),
                          )),
                        ),
                        Expanded(
                            child: Text(
                          ParseAPI().getUserName(
                              postsIncluded,
                              postsData[index]["relationships"]["user"]["data"]
                                  ["id"]),
                          style: TextStyle(fontSize: 15.0),
                        )),
                        Spacer(),
                        _floorIndex(postsData[index]["attributes"]["number"]),
                      ]),
                      Html(
                        data: postsData[index]["attributes"]["contentHtml"],
                        style: {},
                      )
                    ],
                  ),
                  subtitle: Row(
                    children: <Widget>[
                      Text(
                        formatter.format(DateTime.parse(
                                postsData[index]["attributes"]["createdAt"])
                            .toLocal()),
                      ),
                      Spacer(),
                      Icon(Icons.thumb_up, size: 14, color: Colors.black54),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        child: _calVotes(
                            postsData[index]["relationships"]["upvotes"],
                            postsData[index]["relationships"]["downvotes"]),
                      ),
                      Icon(Icons.thumb_down, size: 14, color: Colors.black54),
                    ],
                  ),
                ));
          else {
            return ListTile(
              title: Text(postsData[index]["attributes"]["contentType"]),
              subtitle: Row(
                children: <Widget>[
                  Text(
                    formatter.format(DateTime.parse(
                            postsData[index]["attributes"]["createdAt"])
                        .toLocal()),
                  ),
                ],
              ),
            );
          }
        });
  }

  Container _floorIndex(var number) {
    String floorIndex = '$number';
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        color: Colors.grey,
      ),
      margin: EdgeInsets.symmetric(vertical: 3, horizontal: 5),
      padding: EdgeInsets.symmetric(vertical: 3, horizontal: 10),
      child: Text(
        floorIndex,
        strutStyle: StrutStyle(
          forceStrutHeight: true,
        ),
        style: TextStyle(fontSize: 15.0, color: Colors.white),
      ),
    );
  }

  Text _calVotes(upvotes, downvotes) {
    int votes;
    try {
      votes = upvotes["data"].length - downvotes["data"].length;
    } catch (e) {
      votes = 0;
    }
    return Text(
      '$votes',
    );
  }

  Future<dynamic> _fetchPosts() async {
    print('loading by extentafter pageOffset: $postOffset');
    print('loading by extentafter postsData.length: ' +
        postsData.length.toString());
    String postsIDstring = postsID.skip(this.postOffset).take(30).join(',');
    var response;
    if ("" != postsIDstring) {
      response = await KaterAPI().fetchPosts(postsIDstring);
      postsData.addAll(response["data"]);
      postsIncluded.addAll(response["included"]);
      postsIncluded = postsIncluded.toSet().toList();
      setState(() {
        this.isLoading = false;
      });
    }
  }

  Future _refresh() async {
    setState(() {
      future = _initDiscussion();
    });
  }
}

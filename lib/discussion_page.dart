import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import 'kater_api.dart';
import 'parse_api.dart';

class DiscussionPage extends StatefulWidget {
  final discussionID;
  DiscussionPage({Key key, @required this.discussionID}) : super(key: key);

  @override
  _DiscussionPage createState() => new _DiscussionPage();
}

class _DiscussionPage extends State<DiscussionPage> {
  var data;
  var included;
  Color mainColor;

  Color _parseColor(String colorHexString) {
    if ('' == colorHexString) colorHexString = '#000000';
    return Color(int.parse(colorHexString.replaceAll('#', '0xff')));
  }

  Future _loadAsset(BuildContext context) async {
    print("Enter: " + widget.discussionID);
    var value = await KaterAPI().fetchDiscussion(widget.discussionID);
    data = value["data"];
    included = value["included"];
    mainColor = Color(int.parse(ParseAPI().getTagColor(included)));
  }

  @override
  initState() {
    super.initState();
    _loadAsset(context).then((result) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (data == null) {
      return new Scaffold(
        appBar: new AppBar(
          title: new Text("Loading..."),
        ),
      );
    } else {
      return new Scaffold(
          appBar: new AppBar(
            title: new Text(data["attributes"]["title"]),
            backgroundColor: Color(int.parse(ParseAPI().getTagColor(included))),
          ),
          body: ListView(children: <Widget>[
            Container(
              decoration: BoxDecoration(
                  color: Color(int.parse(ParseAPI().getTagColor(included)))),
              child: Center(
                  child: Padding(
                      padding: EdgeInsets.only(top: 40.0, bottom: 40.0),
                      child: Column(
                        children: <Widget>[
                          Container(
                            child: _buildTags(),
                          ),
                          Container(
                            child: Text(
                              data["attributes"]["title"],
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
          ]));
    }
  }

  Widget _buildTags() {
    List<WidgetSpan> list = new List<WidgetSpan>();
    for (var element in included) {
      if ("tags" == element["type"])
        list.add(
          new WidgetSpan(
              child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              color: Colors.white,
            ),
            margin: EdgeInsets.symmetric(vertical: 3, horizontal: 5),
            padding: EdgeInsets.symmetric(vertical: 3, horizontal: 5),
            child: Text(
              element["attributes"]["name"],
              strutStyle: StrutStyle(
                forceStrutHeight: true,
              ),
              style: TextStyle(
                  fontSize: 15.0,
                  color: _parseColor(element["attributes"]["color"])),
            ),
          )),
        );
    }
    return RichText(
      text: TextSpan(
        children: list,
      ),
    );
  }

  Widget _buildComments() {
    List comments = ParseAPI().getComments(included);
    var formatter = new DateFormat('yyyy-MM-dd HH:mm:ss');
    return ListView.separated(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: comments.length,
        separatorBuilder: (BuildContext context, int index) =>
            Divider(height: 10, color: Colors.black26),
        itemBuilder: (context, index) {
          return ListTile(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Row(children: <Widget>[
                  Container(
                      margin: EdgeInsets.only(right: 15.0),
                      width: 45.0,
                      height: 45.0,
                      decoration: new BoxDecoration(
                          shape: BoxShape.circle,
                          image: new DecorationImage(
                              fit: BoxFit.fill,
                              image: new NetworkImage(ParseAPI()
                                  .getUserAvatarUrl(
                                      included,
                                      comments[index]["relationships"]["user"]
                                          ["data"]["id"]))))),
                  Container(
                    child: Flexible(
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new Text(
                            ParseAPI().getUserName(
                                included,
                                comments[index]["relationships"]["user"]["data"]
                                    ["id"]),
                            style: TextStyle(fontSize: 15.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _floorIndex(comments[index]["attributes"]["number"]),
                ]),
                Html(
                  data: comments[index]["attributes"]["contentHtml"],
                  style: {},
                )
              ],
            ),
            subtitle: Row(
              children: <Widget>[
                Text(
                  formatter.format(
                      DateTime.parse(comments[index]["attributes"]["createdAt"])
                          .toLocal()),
                ),
                Spacer(),
                Icon(Icons.thumb_up, size: 14, color: Colors.black54),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  child: _calVotes(comments[index]["relationships"]["upvotes"],
                      comments[index]["relationships"]["downvotes"]),
                ),
                Icon(Icons.thumb_down, size: 14, color: Colors.black54),
              ],
            ),
          );
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
}

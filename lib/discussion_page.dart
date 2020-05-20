import 'package:flutter/material.dart';
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
  var postUser;
  Color mainColor;

  Color _parseColor(String colorHexString) {
    if ('' == colorHexString) colorHexString = '#000000';
    return Color(int.parse(colorHexString.replaceAll('#', '0xff')));
  }

  Future _loadAsset(BuildContext context) async {
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
          body: Column(children: <Widget>[
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
}

import 'package:flutter/material.dart';

class ParseAPI {
  String getUserAvatarUrl(var included, var userID) {
    for (var element in included) {
      if ("users" != element["type"]) continue;
      if (element["id"] == userID) {
        if (element["attributes"]["avatarUrl"] != null)
          return element["attributes"]["avatarUrl"];
        else
          return "https://fakeimg.pl/45/?text=Avatar";
      }
    }
    return "https://fakeimg.pl/45/?text=Avatar";
  }

  String getUserName(var included, var userID) {
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

  Color parseColor(String colorHexString) {
    if ('' == colorHexString) colorHexString = '#000000';
    return Color(int.parse(colorHexString.replaceAll('#', '0xff')));
  }

  List getComments(List included) {
    List posts = new List();
    for (var element in included) {
      if ("comment" == element["attributes"]["contentType"]) posts.add(element);
    }
    return posts;
  }
}

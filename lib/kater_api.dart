import 'const.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';

class KaterAPI {
  fetchNews(int pageOffset) async {
    String params = "";
    params += "page[offset]=" + "$pageOffset";
    var response =
        await http.get(kater_host + api_path + "discussions?" + params);
    var responseList = json.decode(response.body);
    return responseList;
  }

  fetchDiscussion(String discussionID) async {
    var response = await http
        .get(kater_host + api_path + "discussions/" + "$discussionID");
    var responseList = json.decode(response.body);
    return responseList;
  }

  fetchUser(int userID) async {
    var response = await http.get(kater_host + api_path + "users/" + "$userID");
    return json.decode(response.body);
  }

  fetchNotifications() async {
    var response = await http.get(kater_host + api_path + "notifications?");
    return json.decode(response.body);
  }
}

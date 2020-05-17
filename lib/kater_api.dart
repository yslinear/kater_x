import 'const.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';

class KaterAPI {
  fetchNews() async {
    var response = await http.get(kater_host + api_path + "discussions");
    var responseList = json.decode(response.body);
    return responseList;
  }

  fetchNotifications() async {
    var response = await http.get(kater_host + api_path + "notifications");
    return json.decode(response.body);
  }
}

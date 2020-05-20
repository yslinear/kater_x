class ParseAPI {
  String getUserAvatarUrl(var included, String userID) {
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

  String getTagColor(List included) {
    for (var element in included) {
      if ("tags" != element["type"]) continue;
      if (element["attributes"]["color"] != null)
        return element["attributes"]["color"].replaceAll('#', '0xff');
      else
        return '0xffBCBCBC';
    }
    return '0xffBCBCBC';
  }
}

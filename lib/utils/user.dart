class UserData {
  String uid;
  String photoUrl;
  String like;
  String name;

  UserData({this.photoUrl, this.name, this.uid, this.like});

  UserData.fromMap(Map<String, dynamic> data, String uid)
      : uid = data['uid'],
        photoUrl = data["photoUrl"],
        name = data["name"];

  Map<String, dynamic> toMap() {
    return {
      "photoUrl": photoUrl,
      "uid": uid,
      "name": name,
    };
  }
}

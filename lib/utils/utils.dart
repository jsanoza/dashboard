class Product {
  String created;
  String dUrl;
  String description;
  String creatordUrl;
  int like;
  String createdby;
  String createdbyuid;
  List<dynamic> likedby;
  String docid;

  Product({this.createdbyuid, this.docid, this.likedby, this.creatordUrl, this.description, this.createdby, this.dUrl, this.created, this.like});

  Product.fromMap(Map<String, dynamic> data, String createdby)
      : description = data['description'] ?? '',
        createdby = data['createdby'] ?? '',
        createdbyuid = data['createdbyuid'] ?? '',
        dUrl = data['dUrl'] ?? '',
        like = data['like'] ?? '',
        created = data['created'] ?? '',
        likedby = data['likedby'] ?? '',
        docid = data['docid'] ?? '',
        creatordUrl = data['creatordUrl'];

  Map<String, dynamic> toMap() {
    return {"createdbyuid": createdbyuid, "docid": docid, "likedby": likedby, "description": description, "createdby": createdby, "dUrl": dUrl, "like": like, "created": created, "creatordUrl": creatordUrl};
  }
}

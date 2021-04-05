import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dev_try/main.dart';
import 'package:dev_try/utils/api.dart';
import 'package:dev_try/utils/comments.dart';
import 'package:dev_try/utils/utils.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:dev_try/utils/samplemodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:uuid/uuid.dart';

class DetailsPage extends StatefulWidget {
  final Productx posts;
  final User user;
  const DetailsPage({Key key, this.posts, this.user}) : super(key: key);

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  bool _isCreated = false;
  File _image;
  final picker = ImagePicker();
  TextEditingController _notesTextController;
  RoundedLoadingButtonController _btnController;
  TextEditingController _commentController = TextEditingController();
  var uuid = Uuid();
  var dUrl;
  List<Comment> fetchedComments = [];
  bool didFetchComments = false;
  bool _isShown = false;
  bool _isPostsEmpty = false;

  showAlertDialog(BuildContext context) {
    // String email = _emailTextController.text;
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed: () {
        // Get.back();
        Navigator.pop(context);
      },
    );
    Widget continueButton = FlatButton(
      child: Text("Continue"),
      onPressed: () {
        // sendReqChange();
        // Get.back();
        deleteNews();
        _isPostsEmpty = false;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
          (Route<dynamic> route) => false,
        );
      },
    );
    AlertDialog alert = AlertDialog(
      title: Text("Confirm"),
      content: Text(
        '''
Are you sure to delete this post?
''',
        maxLines: 20,
        style: TextStyle(fontSize: 16.0, color: Colors.black),
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<String> uploadImage(File image) async {
    String unique = uuid.v1();
    final userid = widget.user.uid;
    Reference storageRef = FirebaseStorage.instance.ref().child('news').child(unique);
    await storageRef.putFile(_image);
    return await storageRef.getDownloadURL();
  }

  Future uploadPic() async {
    String notes = _notesTextController.text;
    var now2 = new DateTime.now();
    var dateLocal = now2.toLocal();
    var formatter2 = new DateFormat('MM/dd/yyyy hh:mm:ss');
    String formatted2 = formatter2.format(dateLocal);
    FocusScope.of(context).requestFocus(new FocusNode());
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    try {
      if (_image == null) {
        dUrl = widget.posts.dUrl;
        List<String> hello = [];
        Product product = Product(createdbyuid: widget.user.uid, docid: widget.posts.docid, creatordUrl: widget.user.photoURL, createdby: widget.user.displayName, dUrl: dUrl, description: notes, created: formatted2, like: hello.length, likedby: hello);
        await Api("news").editNews(product, widget.posts.docid);
        print("im here");
        setState(() {
          _btnController.reset();
          _notesTextController.clear();
          _image = null;
          Navigator.pop(context);
        });
      }
      if (_image != null) {
        dUrl = await uploadImage(_image);
        List<String> hello = [];
        Product product = Product(createdbyuid: widget.user.uid, docid: widget.posts.docid, creatordUrl: widget.user.photoURL, createdby: widget.user.displayName, dUrl: dUrl, description: notes, created: formatted2, like: hello.length, likedby: hello);
        await Api("news").editNews(product, widget.posts.docid);
        print("im here");
        setState(() {
          _btnController.reset();
          _notesTextController.clear();
          _image = null;
          Navigator.pop(context);
        });
      }
    } catch (e) {}
  }

  Future<void> _openImagePicker() async {
    final pickedImage = await picker.getImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
    }
    String hello;
    return hello;
  }

  editNews(BuildContext context) {
    _notesTextController.text = widget.posts.description;
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (builder) {
        return WillPopScope(
          onWillPop: () {
            return null;
          },
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter mystate) {
              return Stack(
                children: [
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 58.0, right: 180),
                            child: Text(
                              "Edit News",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 30.0,
                                fontFamily: 'Nunito-Bold',
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 10.0,
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Container(
                                  alignment: Alignment.center,
                                  width: 150,
                                  height: 150,
                                  color: Colors.grey[300],
                                  child: _image != null
                                      ? Image.file(_image, fit: BoxFit.cover)
                                      : Image.network(
                                          widget.posts.dUrl,
                                        ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.greenAccent,
                            onPrimary: Colors.white,
                          ),
                          child: Text('Select An Image'),
                          onPressed: () async {
                            _openImagePicker().then((news) {
                              mystate(() {});
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 18.0, right: 250),
                        child: Text(
                          "Description",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15.0,
                            fontFamily: 'Nunito-Bold',
                          ),
                        ),
                      ),
                      new Expanded(
                          child: Padding(
                        padding: const EdgeInsets.only(left: 30.0, right: 30, bottom: 20),
                        child: TextField(
                          controller: _notesTextController,
                          maxLines: null,
                          expands: true,
                          keyboardType: TextInputType.multiline,
                          decoration: InputDecoration(hintText: "Tap to write..."),
                        ),
                      )),
                      RoundedLoadingButton(
                        color: Colors.greenAccent,
                        controller: _btnController,
                        child: Text('Edit News', style: TextStyle(color: Colors.white, fontFamily: 'Nunito-Regular', fontSize: 18)),
                        onPressed: () {
                          uploadPic();
                        },
                      ),
                      Container(
                        height: 200,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  deleteNews() {
    Api("news").removeDocument(widget.posts.docid);
  }

  @override
  Widget build(BuildContext context) {
    ErrorWidget.builder = (FlutterErrorDetails details) => Container();
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.white),
        title: Text("Details", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.greenAccent,
        actions: _isCreated
            ? <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 0.0),
                  child: IconButton(
                    icon: Icon(
                      Icons.edit,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      editNews(context);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      showAlertDialog(context);
                    },
                  ),
                )
              ]
            : <Widget>[Container()],
      ),
      body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('news').doc(widget.posts.docid).snapshots(),
          builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.hasError) {
              Text("error");
              _isPostsEmpty = false;
            }
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Center(
                    child: CircularProgressIndicator(
                  backgroundColor: Colors.white,
                  valueColor: new AlwaysStoppedAnimation<Color>(Colors.green),
                ));
              case ConnectionState.none:
                return Center(
                    child: CircularProgressIndicator(
                  backgroundColor: Colors.white,
                  valueColor: new AlwaysStoppedAnimation<Color>(Colors.green),
                ));
              case ConnectionState.done:
                return Text("done");
              default:
                _isPostsEmpty = true;
                var userDocument = snapshot.data;
                return Container(
                  child: _isPostsEmpty
                      ? ListView.builder(
                          itemCount: 1,
                          itemBuilder: (_, index) {
                            return Container(
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(18.0),
                                      child: Card(
                                        elevation: 5,
                                        child: Container(
                                          width: MediaQuery.of(context).size.width * 0.9,
                                          child: Column(
                                            children: <Widget>[
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.only(right: 0.0, top: 20),
                                                    child: CircleAvatar(
                                                      radius: 30.0,
                                                      backgroundImage: NetworkImage(widget.posts.creatordUrl),
                                                      backgroundColor: Colors.transparent,
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.only(right: 0.0, top: 20),
                                                    child: Text(
                                                      '${userDocument['createdby']}',
                                                      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 22, color: Colors.black),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.only(right: 0.0, top: 20),
                                                    child: Container(
                                                      width: 180,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Container(
                                                height: 10,
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(top: 8.0, left: 8, right: 8, bottom: 8),
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      '${userDocument['created']}',
                                                      style: TextStyle(fontWeight: FontWeight.w300, fontSize: 14, color: Colors.black),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Hero(
                                                tag: userDocument['docid'],
                                                child: Image.network(
                                                  userDocument['dUrl'],
                                                  height: MediaQuery.of(context).size.height * 0.35,
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(top: 16, right: 0),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.only(left: 8.0, bottom: 8),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            'Full Description:',
                                                            style: TextStyle(fontWeight: FontWeight.w300, fontSize: 14, color: Colors.black),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(left: 8.0, top: 8, bottom: 8),
                                                child: Row(
                                                  children: [
                                                    Flexible(
                                                      child: Container(
                                                        child: Text(
                                                          '${userDocument['description']}',
                                                          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 22, fontStyle: FontStyle.italic, color: Colors.greenAccent),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(top: 16, right: 0),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.only(left: 8.0, bottom: 8),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            'Comments:',
                                                            style: TextStyle(fontWeight: FontWeight.w300, fontSize: 14, color: Colors.black),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                height: 200,
                                                child: Column(
                                                  children: [
                                                    Expanded(
                                                      child: buildComments(),
                                                    ),
                                                    Divider(),
                                                    Padding(
                                                      padding: const EdgeInsets.only(bottom: 20.0),
                                                      child: ListTile(
                                                        title: TextFormField(
                                                          controller: _commentController,
                                                          decoration: InputDecoration(labelText: 'Write a comment...'),
                                                          onFieldSubmitted: addComment,
                                                        ),
                                                        trailing: OutlineButton(
                                                          onPressed: () {
                                                            addComment(_commentController.text);
                                                          },
                                                          borderSide: BorderSide.none,
                                                          child: Text("Post"),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        )
                      : CircularProgressIndicator(),
                );
            }
          }),
    );
  }

  @override
  void initState() {
    _notesTextController = TextEditingController();
    _btnController = RoundedLoadingButtonController();
    if (widget.posts.createdbyuid == widget.user.uid) {
      _isCreated = true;
      print("You created this post" + _isCreated.toString());
    } else {
      _isCreated = false;
      print("You did not create this post" + _isCreated.toString());
    }
    super.initState();
  }

  Widget buildComments() {
    if (didFetchComments == false) {
      return FutureBuilder<List<Comment>>(
          future: getComments(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return Container(alignment: FractionalOffset.center, child: CircularProgressIndicator());
            _isShown = true;
            didFetchComments = true;
            fetchedComments = snapshot.data;

            return _isShown
                ? ListView(
                    children: snapshot.data,
                  )
                : Container(
                    height: 10,
                  );
          });
    } else {
      _isShown = false;
      return ListView(children: fetchedComments);
    }
  }

  Future<List<Comment>> getComments() async {
    List<Comment> comments = [];
    QuerySnapshot data = await FirebaseFirestore.instance.collection("comments").doc(widget.posts.docid).collection("comments").get();
    data.docs.forEach((DocumentSnapshot doc) {
      comments.add(Comment.fromDocument(doc));
    });
    return comments;
  }

  addComment(String comment) {
    _commentController.clear();
    FirebaseFirestore.instance.collection("comments").doc(widget.posts.docid).collection("comments").add({"name": widget.user.displayName, "comment": comment, "timestamp": Timestamp.now(), "photoUrl": widget.user.photoURL, "uid": widget.user.uid});

    setState(() {
      fetchedComments = List.from(fetchedComments)..add(Comment(name: widget.user.displayName, comment: comment, timestamp: Timestamp.now(), photoUrl: widget.user.photoURL, uid: widget.user.uid));
    });
  }
}

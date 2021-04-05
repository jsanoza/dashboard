import 'dart:io';
import 'package:dev_try/details.dart';
import 'package:dev_try/utils/api.dart';
import 'package:dev_try/utils/samplemodel.dart';
import 'package:dev_try/utils/utils.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dev_try/utils/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:uuid/uuid.dart';

class Dashboard extends StatefulWidget {
  final User user;

  const Dashboard({Key key, this.user}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

File _image;
final picker = ImagePicker();
String downloadUrl;
bool _isLiked = false;
List<Product> products;
var uuid = Uuid();
bool descTextShowFlag = false;
String trimmed;
bool _isPostsEmpty = false;

TextEditingController _notesTextController;
RoundedLoadingButtonController _btnController;

class _DashboardState extends State<Dashboard> {
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
      String unique2 = uuid.v1();
      var dUrl = await uploadImage(_image);
      List<String> hello = [];
      Product product = Product(createdbyuid: widget.user.uid, docid: unique2, creatordUrl: widget.user.photoURL, createdby: widget.user.displayName, dUrl: dUrl, description: notes, created: formatted2, like: hello.length, likedby: hello);
      await Api("news").addNews(product, unique2);
      print("im here");
      setState(() {
        _btnController.reset();
        _notesTextController.clear();
        _image = null;
        Navigator.pop(context);
      });
    } catch (e) {}
  }

  createNews(BuildContext context) {
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
                              "Add News",
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
                                  child: _image != null ? Image.file(_image, fit: BoxFit.cover) : Text('Please select an image'),
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
                        child: Text('Post News', style: TextStyle(color: Colors.white, fontFamily: 'Nunito-Regular', fontSize: 18)),
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

  void handleClick(String value, BuildContext context) {
    switch (value) {
      case 'Sign Out':
        Provider.of<UserRepository>(context, listen: false).signOut();
        print("Sign Out");
        break;
    }
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

  @override
  void initState() {
    _notesTextController = TextEditingController();
    _btnController = RoundedLoadingButtonController();
    _image = null;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var posts = Provider.of<List<Productx>>(context);
    var user = Provider.of<UserRepository>(context);
    if (posts == null) {
      _isPostsEmpty = false;
    } else {
      _isPostsEmpty = true;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard"),
        backgroundColor: Colors.greenAccent,
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: (choice) => handleClick(choice, context),
            itemBuilder: (BuildContext context) {
              return {'Sign Out'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: _isPostsEmpty
          ? ListView.builder(
              itemCount: posts.length,
              itemBuilder: (buildContext, index) {
                List<String> hellox = [];
                hellox.add(widget.user.uid.toString());
                if (posts[index].likedby.toString() == hellox.toString()) {
                  _isLiked = true;
                } else {
                  _isLiked = false;
                  print("wala");
                }
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DetailsPage(posts: posts[index], user: user.user)),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.only(top: 8, right: 8, left: 8, bottom: 8),
                    child: Card(
                      elevation: 5,
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.70,
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
                                    backgroundImage: NetworkImage(posts[index].creatordUrl),
                                    backgroundColor: Colors.transparent,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 0.0, top: 20),
                                  child: Text(
                                    '${posts[index].createdby}',
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
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Text(
                                    '${posts[index].created}',
                                    style: TextStyle(fontWeight: FontWeight.w300, fontSize: 14, color: Colors.black),
                                  ),
                                ],
                              ),
                            ),
                            Hero(
                              tag: posts[index].docid,
                              child: Image.network(
                                posts[index].dUrl,
                                height: MediaQuery.of(context).size.height * 0.35,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 16, right: 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      IconButton(
                                          icon: Icon(Icons.favorite),
                                          color: _isLiked ? Colors.red : Colors.black12,
                                          onPressed: () {
                                            List<String> hello = [];
                                            hello.add(widget.user.uid.toString());
                                            if (_isLiked == true) {
                                              FirebaseFirestore.instance.collection('news').doc(posts[index].docid).update({'likedby': FieldValue.arrayRemove(hello)}).then((value) => print("hello"));
                                              setState(() {
                                                print("meron na");
                                                _isLiked = true;
                                              });
                                            }
                                            if (_isLiked == false) {
                                              FirebaseFirestore.instance.collection('news').doc(posts[index].docid).update({'likedby': FieldValue.arrayUnion(hello)});
                                              setState(() {
                                                _isLiked = false;
                                              });
                                            }
                                          }),
                                      Text(
                                        ' ${posts[index].likedby.length} people like this',
                                        style: TextStyle(fontWeight: FontWeight.w300, fontSize: 14, color: Colors.black),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0, bottom: 2),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    'Description:',
                                    style: TextStyle(fontWeight: FontWeight.w300, fontSize: 14, color: Colors.black),
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
                                      padding: new EdgeInsets.all(8.0),
                                      child: Text(
                                        '${posts[index].description}',
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 22, fontStyle: FontStyle.italic, color: Colors.greenAccent),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              })
          : CircularProgressIndicator(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        elevation: 20.0,
        child: Icon(Icons.add),
        backgroundColor: Colors.greenAccent,
        onPressed: () {
          createNews(context);
        },
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Comment extends StatelessWidget {
  final String name;
  final String uid;
  final String photoUrl;
  final String comment;
  final Timestamp timestamp;

  Comment({this.name, this.uid, this.photoUrl, this.comment, this.timestamp});

  factory Comment.fromDocument(DocumentSnapshot document) {
    return Comment(
      name: document['name'],
      uid: document['uid'],
      comment: document["comment"],
      timestamp: document["timestamp"],
      photoUrl: document["photoUrl"],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          title: Text(comment),
          leading: CircleAvatar(
            backgroundImage: NetworkImage(photoUrl),
          ),
        ),
        Divider(),
      ],
    );
  }
}

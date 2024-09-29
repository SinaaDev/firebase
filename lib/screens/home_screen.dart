import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fire/upload_file.dart';
import 'package:flutter/material.dart';

import '../models/post_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Stream<List<Post>> readPosts() => FirebaseFirestore.instance
      .collection('posts')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map(
              (doc) => Post.fromJson(doc.data()),
            )
            .toList(),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(title: Text('Posts Feed'),centerTitle: true,),

      body: StreamBuilder<List<Post>>(
        stream: readPosts(),
        builder: (context, snapshot) {
          if(snapshot.hasData){
            final posts = snapshot.data!;
            return ListView.separated(
                itemCount: posts.length,
                separatorBuilder: (context, index) => SizedBox(height: 24,),
                itemBuilder: (context, i) => Container(
                  color: Colors.white,
                  padding: EdgeInsets.all(12),
                  margin: EdgeInsets.all(12),
                  child: Column(children: [
                    Image.network(
                      posts[i].imageUrl
                    ),
                    SizedBox(height: 24,),
                    Text(posts[i].content,style: TextStyle(fontSize: 32),),

                  ],),
                ),
            );
          }else{
            return SizedBox.shrink();
          }
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UploadFile(),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

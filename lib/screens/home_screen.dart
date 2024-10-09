import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:fire/upload_file.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
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

  Future downloadImage(String url) async {
    final tempDir = await getTemporaryDirectory();
    final fileName = url.split('files%').last.split('?').first;
    final path = '${tempDir.path}/$fileName';

    await Dio().download(url, path);

    if (url.contains('.mp4')) {
      await GallerySaver.saveVideo(path, toDcim: true);
    } else if (url.contains('.jpg')) {
      await GallerySaver.saveImage(path, toDcim: true);
    }
  }

  String getDate(Timestamp timeStamp){
    final format = DateFormat('d MMMM y');
    return format.format(timeStamp.toDate());
  }

  String getTime(Timestamp timeStamp){
    final format = DateFormat('jm');
    return format.format(timeStamp.toDate());
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('Posts Feed'),
        centerTitle: true,
        actions: [
          IconButton(onPressed: ()=>FirebaseAuth.instance.signOut(), icon: Icon(Icons.logout))
        ],
      ),
      body: StreamBuilder<List<Post>>(
        stream: readPosts(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final posts = snapshot.data!;
            return ListView.separated(
              itemCount: posts.length,
              separatorBuilder: (context, index) => SizedBox(
                height: 24,
              ),
              itemBuilder: (context, i) => InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UploadFile(
                          isEditMode: true,
                          post: posts[i],
                        ),
                      ));
                },
                child: Container(
                  color: Colors.white,
                  padding: EdgeInsets.all(12),
                  margin: EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom:  8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.grey[200],
                              child: Icon(Icons.person),
                            ),
                            Gap(8),
                            Text(posts[i].createdBy,style: TextStyle(fontSize: 20),),
                            Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(getDate(posts[i].createdAt)),
                                Text(getTime(posts[i].createdAt)),
                              ],
                            )
                          ],
                        ),
                      ),
                      Stack(children: [
                        Image.network(posts[i].imageUrl),
                        Align(
                            alignment: Alignment.topRight,
                            child: Container(
                              color: Colors.amber,
                              child: IconButton(
                                onPressed: () {
                                  downloadImage(posts[i].imageUrl);
                                },
                                icon: Icon(
                                  Icons.download,
                                  size: 32,
                                ),
                              ),
                            )),
                      ]),
                      SizedBox(
                        height: 24,
                      ),
                      Text(
                        posts[i].content,
                        style: TextStyle(fontSize: 32),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return SizedBox.shrink();
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UploadFile(
                isEditMode: false,
              ),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

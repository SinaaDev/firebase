import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:fire/main.dart';
import 'package:fire/upload_file.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import '../models/post_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late String userId;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userId = FirebaseAuth.instance.currentUser!.uid;
  }

  Future<void> _firebaseMessagingForegroundHandler(message) async {
    final notification = message.notification;
    final android = message.notification?.android;
    if (notification != null && android != null) {
      flutterLocalNotificationsPanel.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
          ),
        ),
      );
    }
  }

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

  String getDate(Timestamp timeStamp) {
    final format = DateFormat('d MMMM y');
    return format.format(timeStamp.toDate());
  }

  String getTime(Timestamp timeStamp) {
    final format = DateFormat('jm');
    return format.format(timeStamp.toDate());
  }

  handlePostLikes(Post post) {
    final isLiked = post.likes?[userId] ?? false;

    if (isLiked) {
      final postRef =
          FirebaseFirestore.instance.collection('posts').doc(post.id);
      postRef.update({'likes.$userId': false});
    } else if (!isLiked) {
      final postRef =
          FirebaseFirestore.instance.collection('posts').doc(post.id);
      postRef.update({'likes.$userId': true});
    }
  }

  int getLikeCount(dynamic likes) {
    if (likes == null) {
      return 0;
    }
    int count = 0;
    likes.values.forEach((val) {
      if (val == true) {
        count += 1;
      }
    });
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('Posts Feed'),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () => FirebaseAuth.instance.signOut(),
              icon: Icon(Icons.logout))
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.grey[200],
                              child: Icon(Icons.person),
                            ),
                            Gap(8),
                            Text(
                              posts[i].createdBy,
                              style: TextStyle(fontSize: 20),
                            ),
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
                      Gap(12),
                      TextButton.icon(
                          onPressed: () {
                            handlePostLikes(posts[i]);
                          },
                          icon: Icon(
                            posts[i].likes?[userId] ?? false
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 28,
                            color: Colors.red,
                          ),
                          label: getLikeCount(posts[i].likes) == 1
                              ? Text(
                                  '1 like',
                                  style: TextStyle(fontSize: 16),
                                )
                              : Text(
                                  '${getLikeCount(posts[i].likes).toString()} likes',
                                  style: TextStyle(fontSize: 16),
                                )),
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

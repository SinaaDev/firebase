import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fire/models/post_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class UploadFile extends StatefulWidget {
  final bool isEditMode;
  final Post? post;

  const UploadFile({super.key,required this.isEditMode,this.post});

  @override
  State<UploadFile> createState() => _UploadFileState();
}

class _UploadFileState extends State<UploadFile> {
  File? imageFile;
  UploadTask? uploadTask;
  String imageUrl = '';

  final bodyTextController = TextEditingController();


  Future _getFromCamera()async{
    XFile? result = await ImagePicker().pickImage(source: ImageSource.camera);

    if(result == null) return;

    setState(() {
      imageFile = File(result.path);
    });

  }

  Future _getFromGallery()async{
    XFile? result = await ImagePicker().pickImage(source: ImageSource.gallery);

  }

  Future uploadFile ()async{
    final imageFileName = imageFile!.path.split('/').last;
    final path = 'images/$imageFileName';
    final ref = FirebaseStorage.instance.ref().child(path);

    setState(() {
      uploadTask = ref.putFile(imageFile!);
    });

    // Wait for the upload to complete
    final snapshot = await uploadTask!.whenComplete(() {});

    // Get the download URL of the uploaded file
    final downloadUrl = await snapshot.ref.getDownloadURL();

    setState(() {
      imageUrl = downloadUrl;
    });

  }

  Future createPost()async{
    if(bodyTextController.text.isEmpty || bodyTextController.text.length > 80) return;
    if(imageUrl == '') return;

    String postId = widget.isEditMode? widget.post!.id : getId();
   final postRef = FirebaseFirestore.instance.collection('posts').doc(postId);
    
    final post = Post(
        id: postId,
        createdAt: Timestamp.now(),
        imageUrl: imageUrl,
        content: bodyTextController.text,
    );
    final postJson = post.toJson();

    if(widget.isEditMode){
      postRef.update(postJson).whenComplete(() {
        Navigator.pop(context);
      },);
    }else{
      postRef.set(postJson).whenComplete(() {
        Navigator.pop(context);
      },);
    }
  }

  String getId(){
    DateTime now = DateTime.now();
    String timeStamp = DateFormat('yyyyMMddHHmmss').format(now);
    return timeStamp;
  }

  Widget buildProgress()=>StreamBuilder(
      stream: uploadTask!.snapshotEvents,
      builder: (context, snapshot) {
        if(snapshot.hasData){
          final data = snapshot.data!;
          double progress = data.bytesTransferred / data.totalBytes;

          if(data.bytesTransferred == data.totalBytes){
            return Text('Upload Completed');
          }else{
          return Text('Uploading: ${(100 * progress).roundToDouble()} %');
          }

        }else{
          return SizedBox.shrink();
        }
      },
  );


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.isEditMode){
      bodyTextController.text = widget.post!.content;
      imageUrl = widget.post!.imageUrl;
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 250,
              height: 250,
              color: Colors.grey[200],
              child: imageUrl == ''?  IconButton(onPressed: (){
                showDialog(context: context, builder: (context) => AlertDialog(
                  title: Text('From where do you want to take photo from'),
                  actions: [
                    TextButton(onPressed: (){
                      _getFromCamera();
                      Navigator.pop(context);
                    }, child: Text('Camera')),
                    TextButton(onPressed: (){
                      _getFromGallery();
                      Navigator.pop(context);
                    }, child: Text('Gallary')),
                  ],
                ),);
              },icon: Icon(Icons.camera_alt,size: 100,),)
              :
              Image.network(imageUrl,fit: BoxFit.cover,),
            ),
            SizedBox(height: 20,),

            Padding(
              padding: const EdgeInsets.all(40),
              child: TextFormField(
                onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
                controller: bodyTextController,
                maxLines: 5,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Write Something here....'
                ),
              ),
            ),

            ElevatedButton(
                onPressed: ()async{
                  if(!widget.isEditMode)
                  await uploadFile();
                  createPost();
            }, child: widget.isEditMode? Text('Update') : Text('Post')),

            SizedBox(height: 30,),

            if(uploadTask != null)
            buildProgress()
          ],
        ),
      ),
    );
  }
}

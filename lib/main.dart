import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart'; // For File Upload To Firestore
import 'package:cloud_firestore/cloud_firestore.dart';    
import 'package:image_picker/image_picker.dart'; // For Image Picker    
import 'package:path/path.dart' as Path;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firestore File Upload',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Firestore File Upload Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  
  File _image;    
  String _uploadedFileURL;
  
  final databaseReference = Firestore.instance;

  Future chooseFile() async {    
   await ImagePicker.pickImage(source: ImageSource.gallery).then((image) {    
     setState(() {    
       _image = image;    
     });    
   });    
 }  

 Future uploadFile() async {    
   StorageReference storageReference = FirebaseStorage.instance    
       .ref()    
       .child('images/${Path.basename(_image.path)}}');    
   StorageUploadTask uploadTask = storageReference.putFile(_image);    
   await uploadTask.onComplete;    
   print('File Uploaded');    
   storageReference.getDownloadURL().then((fileURL) {  
     setState(() {    
       _uploadedFileURL = fileURL;    
     });    
   });
   print('File Uploaded and UPLOADED FILE URL'); 
   
 }  

 Future linkOfUploadedFile() async {
  await databaseReference.collection("images")
      .document("A")
      .setData({
        'link_setdata': _uploadedFileURL
      });
      print(_uploadedFileURL);
      print('LINK UPLOAD DONE');
}

void getData() {
  databaseReference
      .collection("images")
      .getDocuments()
      .then((QuerySnapshot snapshot) {
    snapshot.documents.forEach((f) { 
      setState((){
     _uploadedFileURL = f.data["link_setdata"];
      });
    } );
  });
}

  @override    
 Widget build(BuildContext context) {    
   return Scaffold(    
     appBar: AppBar(    
       title: Text('Firestore File Upload'),    
     ),    
     body: Center(    
       child: Column(    
         children: <Widget>[
           _image == null    
               ? RaisedButton(    
                   child: Text('Choose File'),    
                   onPressed: chooseFile,    
                   color: Colors.cyan,    
                 )    
               : Container(),     
           _image != null    
               ? RaisedButton(    
                   child: Text('Upload File'),    
                   onPressed: () {
                      uploadFile();
                      linkOfUploadedFile();
                      getData();
                    },    
                   color: Colors.cyan,    
                 )    
               : Container(),    
           _uploadedFileURL != null    
               ? Text(    
                   _uploadedFileURL,     
                 )    
               : Container(),    
         ],    
       ),    
     ),    
   );  
  }
}

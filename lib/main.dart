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

  String _imagesA = 'Images A';
  String _imagesB = 'Images B';

  String dropdownValue = 'Images A';

  
  // String _uploadedFileURL;
  // var data;

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
        .child("$dropdownValue/${Path.basename(_image.path)}");

    await storageReference.putFile(_image).onComplete;
    await print('File Uploaded');
    await storageReference.getDownloadURL().then((fileURL) async {
      DocumentReference ref = await databaseReference
          .collection("$dropdownValue")
          .add({'link_setdata': fileURL});

      await print(ref.documentID);

      // setState(() {
      //   _uploadedFileURL = fileURL;
      // });
    });
    await print('File Uploaded and UPLOADED FILE URL');
  }

  // Future linkOfUploadedFile() async {
  //   await databaseReference
  //       .collection("images")
  //       .document("A")
  //       .setData({'link_setdata': _uploadedFileURL});
  //   await print(_uploadedFileURL);
  //   await print('LINK UPLOAD DONE');
  // }

  void displayDataInConsole() async {
    await databaseReference
        .collection("$dropdownValue")
        .getDocuments()
        .then((QuerySnapshot snapshot) {
      snapshot.documents.forEach((f) {
        print('Backend $dropdownValue = ${f.data["link_setdata"]}');
      });
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
            RaisedButton(
              child: Text('Choose File'),
              onPressed: chooseFile,
              color: Colors.cyan,
            ),
            RaisedButton(
              child: Text('Upload File'),
              onPressed: () async {
                await uploadFile();
                // await linkOfUploadedFile();
                displayDataInConsole();
              },
              color: Colors.cyan,
            ),
            DropdownButton<String>(
              value: dropdownValue,
              icon: Icon(Icons.arrow_downward),
              iconSize: 24,
              elevation: 16,
              style: TextStyle(color: Colors.deepPurple),
              underline: Container(
                height: 2,
                color: Colors.deepPurpleAccent,
              ),
              onChanged: (String newValue) {
                setState(() {
                  dropdownValue = newValue;
                  
                SizedBox(
                height: 500.0,
                child: StreamBuilder<QuerySnapshot>(
                  stream: Firestore.instance.collection(dropdownValue).snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError)
                      return new Text('Error: ${snapshot.error}');
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return new Text('Loading...');
                      default:
                        return new ListView(
                          children: snapshot.data.documents
                              .map((DocumentSnapshot document) {
                            return Text(
                              document.data["link_setdata"],
                            );
                          }).toList(),
                        );
                    }
                  },
                ));

                });
              },
              items: <String>['$_imagesA', '$_imagesB']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(
                height: 500.0,
                child: StreamBuilder<QuerySnapshot>(
                  stream: Firestore.instance.collection('$dropdownValue').snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError)
                      return new Text('Error: ${snapshot.error}');
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return new Text('Loading...');
                      default:
                        return new ListView(
                          children: snapshot.data.documents
                              .map((DocumentSnapshot document) {
                            return Text(
                              'Backend $dropdownValue = ${document.data["link_setdata"]}',
                            );
                          }).toList(),
                        );
                    }
                  },
                )),
          ],
        ),
      ),
    );
  }
}

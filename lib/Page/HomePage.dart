// ignore_for_file: prefer_const_constructors, file_names, deprecated_member_use

import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final picker = ImagePicker();
  final pdf = pw.Document();
  List<File> image = [];

  final fileNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Image to PDF"),
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: () {
              createPDF();
              addName();
            },
          ),
        ],
      ),
      body: image.isEmpty
          ? SizedBox()
          : ListView.builder(
              itemCount: image.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  width: double.infinity,
                  margin: EdgeInsets.all(8),
                  child: Image.file(
                    image[index],
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: getImageFromGallary,
      ),
    );
  }

  createPDF() async {
    for (var img in image) {
      final _image = pw.MemoryImage(img.readAsBytesSync());

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Center(child: pw.Image(_image));
          },
        ),
      );
    }
  }

  addName() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Add File Name"),
        content: TextField(
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: "Enter the name",
            fillColor: Colors.grey.withOpacity(0.3),
            filled: true,
          ),
          controller: fileNameController,
        ),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              savePDF(fileNameController.text);
              Navigator.of(ctx).pop();
            },
            child: Text("Save"),
          ),
          FlatButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text("Cancel"),
          ),
        ],
      ),
    );
  }

  savePDF(String name) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File("${dir!.path}/file.pdf");
      await file.writeAsBytes(await pdf.save());

      showMessage("Success", "Pdf is saved in Storage");
    } catch (e) {
      showMessage("Error", e.toString());
    }
  }

  showMessage(String title, String msg) {
    Flushbar(
      title: title,
      message: msg,
      duration: Duration(seconds: 1),
      icon: Icon(
        Icons.info,
        color: Colors.blue,
      ),
    ).show(context);
  }

  getImageFromGallary() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile == null) {
        showMessage("Error", "Image is not Selected");
      } else {
        image.add(File(pickedFile.path));
      }
    });
  }
}

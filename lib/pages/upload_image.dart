import 'dart:io';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meetingzilla/constants/strings.dart';
import 'package:meetingzilla/providers/auth_provider.dart';
import 'package:meetingzilla/repository/firebase_functions.dart';
import 'package:meetingzilla/widgets/bottom_sheet_button.dart';
import 'package:meetingzilla/widgets/custom_app_bar.dart';
import 'package:meetingzilla/widgets/custom_rounded_btn.dart';
import 'package:meetingzilla/widgets/rounded_linear_progress_bar.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class UploadImagePage extends StatefulWidget {
  final String userId;

  const UploadImagePage({@required this.userId});

  @override
  _UploadImagePageState createState() => _UploadImagePageState();
}

class _UploadImagePageState extends State<UploadImagePage>
    with TickerProviderStateMixin {
  AuthProvider _authProvider;
  File _imageFile;
  bool _isLoading;
  UploadTask _task;
  double _progress;
  double _percent;
  AnimationController animationController;

  @override
  void initState() {
    super.initState();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _imageFile = null;
    _isLoading = false;
    _progress = 0;
    _percent = 0;
    animationController =
        AnimationController(duration: Duration(milliseconds: 500), vsync: this);
    animationController.repeat();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bodyHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).viewInsets.bottom;
    final bodyWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? Center(child: _uploadStatusScreen(bodyWidth))
            : Column(
                children: [
                  CustomAppBar(
                    title: UPLOAD,
                    trailing: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: FaIcon(
                        FontAwesomeIcons.solidArrowAltCircleLeft,
                        color: Theme.of(context).accentColor,
                        size: 32.0,
                      ),
                    ),
                  ),
                  Expanded(child: _bottomBodyArea(bodyHeight)),
                ],
              ),
      ),
    );
  }

  Widget _uploadStatusScreen(width) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Uploading...",
            style: TextStyle(
              fontSize: 18.0,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20.0),
          Stack(
            children: [
              RoundedLinearProgressBar(
                progress: _progress,
              ),
              Positioned(
                left: width * 0.5 - 24.0,
                child: Text(
                  "${_percent.toStringAsFixed(0)} %",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Container _bottomBodyArea(height) => Container(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  _showImageBottomSheet(context);
                },
                child: _imageArea(),
              ),
              if (_imageFile != null) SizedBox(height: 40.0),
              if (_imageFile != null)
                CustomRoundedButton(
                  title: UPLOAD.toUpperCase(),
                  onTap: _uploadImage,
                ),
            ],
          ),
        ),
      );

  void _uploadImage() async {
    setState(() {
      _isLoading = true;
    });

    var uuid = Uuid().v4();
    String filename = "$uuid.jpg";
    _task = FirebaseFunctions.imageRef
        .child(widget.userId)
        .child(filename)
        .putFile(_imageFile);

    _task.snapshotEvents.listen((TaskSnapshot snapshot) {
      print('TASK STATE: ${snapshot.state}');
      print(
          'PROGRESS: ${(snapshot.bytesTransferred / snapshot.totalBytes) * 100} %');
      setState(() {
        _progress = (snapshot.bytesTransferred / snapshot.totalBytes);
        _percent = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        print(_progress);
      });
    }, onError: (e) {
      print(_task.snapshot);
    });

    await _task;
    _task.whenComplete(() async {
      try {
        String downloadUrl;
        downloadUrl = await FirebaseFunctions.imageRef
            .child(widget.userId)
            .child(filename)
            .getDownloadURL();
        await FirebaseFunctions.userCollection.doc(widget.userId).update({
          IMAGE_URL: downloadUrl,
        }).then((_) async {
          await _authProvider.getUserInfo(widget.userId);
          Fluttertoast.showToast(
            msg: "Image Uploaded Successfully.",
          );
          setState(() {
            _imageFile = null;
            _isLoading = false;
          });
          Navigator.pop(context);
        });
      } catch (exc) {
        print(exc.toString());
      }
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final _pickedImage = await picker.getImage(
      source: source,
      imageQuality: 50,
    );

    if (_pickedImage != null) {
      try {
        File _croppedFile = await ImageCropper.cropImage(
          sourcePath: _pickedImage.path,
          aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
          compressFormat: ImageCompressFormat.jpg,
          androidUiSettings: AndroidUiSettings(
            toolbarColor: Theme.of(context).scaffoldBackgroundColor,
            toolbarTitle: "Crop Image",
            toolbarWidgetColor: Theme.of(context).accentColor,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          ),
          iosUiSettings: IOSUiSettings(
            title: "Crop Image",
            minimumAspectRatio: 1.0,
          ),
        );
        setState(() {
          _imageFile = _croppedFile;
        });
      } catch (e) {
        print(e.toString());
      }
    }
  }

  void _showImageBottomSheet(BuildContext context) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
        ),
        context: context,
        builder: (ctx) => Container(
              padding: const EdgeInsets.symmetric(
                vertical: 16.0,
                horizontal: 16.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  BottomSheetButton(
                    title: "Camera",
                    icon: Icons.camera,
                    onTap: () async {
                      await _pickImage(ImageSource.camera);
                    },
                  ),
                  BottomSheetButton(
                    title: "Gallery",
                    icon: Icons.photo,
                    onTap: () async {
                      await _pickImage(ImageSource.gallery);
                    },
                  ),
                ],
              ),
            ));
  }

  Widget _imageArea() {
    if (_imageFile != null) {
      return AvatarGlow(
        startDelay: Duration(milliseconds: 1000),
        glowColor: Colors.grey.shade900,
        endRadius: 120.0,
        duration: Duration(milliseconds: 2000),
        repeat: true,
        repeatPauseDuration: Duration(milliseconds: 5000),
        child: CircleAvatar(
          radius: 100.0,
          backgroundImage: FileImage(_imageFile),
          backgroundColor: Colors.transparent,
        ),
        shape: BoxShape.circle,
        animate: true,
        curve: Curves.fastOutSlowIn,
      );
    }
    return AvatarGlow(
      startDelay: Duration(milliseconds: 1000),
      glowColor: Colors.grey.shade900,
      endRadius: 120.0,
      duration: Duration(milliseconds: 2000),
      repeat: true,
      repeatPauseDuration: Duration(milliseconds: 5000),
      shape: BoxShape.circle,
      animate: true,
      curve: Curves.fastOutSlowIn,
      child: CircleAvatar(
        radius: 100.0,
        backgroundColor: Colors.grey.shade300,
        child: Text(
          "Add Image",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18.0,
            color: Theme.of(context).accentColor,
          ),
        ),
      ),
    );
  }
}

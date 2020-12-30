import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:meetingzilla/constants/colors.dart';
import 'package:meetingzilla/constants/strings.dart';
import 'package:meetingzilla/pages/login_page.dart';
import 'package:meetingzilla/repository/firebase_functions.dart';
import 'package:meetingzilla/utils/random_string.dart';
import 'package:meetingzilla/utils/validators.dart';
import 'package:meetingzilla/widgets/custom_circular_progress.dart';
import 'package:meetingzilla/widgets/custom_rounded_btn.dart';

class WelcomePage extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  bool _isLoading = false;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _password2Controller = TextEditingController();
  bool _obscurePassword;
  final _formKey = GlobalKey<FormState>();

  void _validateAndSave() async {
    FocusScope.of(context).unfocus();
    final _isValid = _formKey.currentState.validate();
    if (_isValid) {
      _formKey.currentState.save();
      setState(() {
        _isLoading = true;
      });

      var userId;

      userId = await FirebaseFunctions.registerUser(
        _emailController.text,
        _passwordController.text,
      ).catchError((e) {
        var err = e.toString();
        print('$ERROR_OCCUR $err.');
        setState(() {
          _isLoading = false;
        });
        Fluttertoast.showToast(
          msg: '$err',
        );
      });

      if (userId != null) {
        var channelId = randomNumeric(10);
        var uid = randomIntNumeric(8).toUnsigned(32);

        await FirebaseFunctions.sendEmailVerification().then((_) async {
          await FirebaseFunctions.userCollection.doc(userId).set({
            UID: userId,
            NAME: _nameController.text,
            USER_ID: uid,
            CHANNEL_ID: channelId,
            EMAIL: _emailController.text,
            TIMESTAMP: DateTime.now(),
          }).then((_) async {
            print("$REGISTER_SUCCESS");
            Fluttertoast.showToast(msg: '$REGISTER_SUCCESS');
            setState(() {
              _isLoading = false;
            });
            _showVerifyEmailSentDialog();
          });
        });
      }
    } else {
      Fluttertoast.showToast(
        msg: FIELD_WARNING,
      );
    }
  }

  _showVerifyEmailSentDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(
            "$VERIFY_ACCOUNT",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text("$LINK_SENT_WARNING"),
          actions: <Widget>[
            FlatButton(
              child: Text(
                "$DISMISS".toUpperCase(),
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).accentColor,
                ),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                _moveToLogin(ctx);
              },
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        );
      },
    );
  }

  _moveToLogin(BuildContext ctx) {
    Navigator.pushReplacement(
        ctx, MaterialPageRoute(builder: (_) => LoginPage()));
  }

  @override
  void initState() {
    super.initState();
    _obscurePassword = true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _password2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bodyHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).viewInsets.bottom;
    final bodyWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: _isLoading
          ? Center(
              child: CustomCircularProgressIndicator(
                color: Theme.of(context).accentColor,
              ),
            )
          : SafeArea(
              child: Center(
                child: SingleChildScrollView(
                    child: _bottomBodyArea(bodyWidth, bodyHeight)),
              ),
            ),
    );
  }

  Container _bottomBodyArea(width, height) => Container(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                WELCOME.toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: width * 0.12,
                  fontWeight: FontWeight.w900,
                  color: Theme.of(context).accentColor,
                ),
              ),
              SizedBox(height: 16.0),
              Image.asset(
                '$IMAGE_DIR/login.png',
              ),
              SizedBox(height: 40.0),
              TextFormField(
                key: ValueKey(NAME),
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.words,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: NAME.toUpperCase(),
                  prefixIcon: Icon(Icons.person_rounded),
                  errorMaxLines: 2,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.0),
                      topRight: Radius.zero,
                      bottomLeft: Radius.zero,
                      bottomRight: Radius.circular(16.0),
                    ),
                  ),
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return "Name can't be empty.";
                  } else if (value.length <= 3) {
                    return "Name is invalid. It must be more than 3 characters.";
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.0),
              TextFormField(
                key: ValueKey(EMAIL),
                keyboardType: TextInputType.emailAddress,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: EMAIL.toUpperCase(),
                  prefixIcon: Icon(Icons.mail_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.0),
                      topRight: Radius.zero,
                      bottomLeft: Radius.zero,
                      bottomRight: Radius.circular(16.0),
                    ),
                  ),
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return "Email can't be empty.";
                  } else if (!Validators.isValidEmail(value)) {
                    return "Email is invalid.";
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.0),
              TextFormField(
                key: ValueKey(PASSWORD),
                keyboardType: TextInputType.visiblePassword,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: PASSWORD.toUpperCase(),
                  prefixIcon: Icon(Icons.lock_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.0),
                      topRight: Radius.zero,
                      bottomLeft: Radius.zero,
                      bottomRight: Radius.circular(16.0),
                    ),
                  ),
                  suffix: GestureDetector(
                    onTap: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    child: Text(_obscurePassword ? 'SHOW' : 'HIDE'),
                  ),
                  suffixStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: secondColor,
                  ),
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return "Password can't be empty.";
                  } else if (value.length <= 7) {
                    return "Password is invalid. It must be more than 8 characters.";
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.0),
              TextFormField(
                key: ValueKey(CONFIRM_PASSWORD),
                keyboardType: TextInputType.visiblePassword,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                controller: _password2Controller,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: CONFIRM_PASSWORD.toUpperCase(),
                  prefixIcon: Icon(Icons.lock_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.0),
                      topRight: Radius.zero,
                      bottomLeft: Radius.zero,
                      bottomRight: Radius.circular(16.0),
                    ),
                  ),
                  suffix: GestureDetector(
                    onTap: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    child: Text(_obscurePassword ? 'SHOW' : 'HIDE'),
                  ),
                  suffixStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: secondColor,
                  ),
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return "Password can't be empty.";
                  } else if (value.length <= 7) {
                    return "Password is invalid. It must be more than 8 characters.";
                  } else if (value.trim() != _passwordController.text) {
                    return "Password doesn't match.";
                  }
                  return null;
                },
              ),
              SizedBox(height: 40.0),
              CustomRoundedButton(
                title: NEXT,
                onTap: _validateAndSave,
              ),
              SizedBox(height: 20.0),
              FlatButton(
                onPressed: () => _moveToLogin(context),
                child: Text(
                  '$LOGIN_ACCOUNT'.toUpperCase(),
                  style: TextStyle(
                    color: Theme.of(context).accentColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
        ),
      );
}

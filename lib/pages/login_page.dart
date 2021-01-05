import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:meetingzilla/constants/colors.dart';
import 'package:meetingzilla/constants/strings.dart';
import 'package:meetingzilla/pages/index_page.dart';
import 'package:meetingzilla/pages/welcome_page.dart';
import 'package:meetingzilla/providers/auth_provider.dart';
import 'package:meetingzilla/repository/firebase_functions.dart';
import 'package:meetingzilla/utils/validators.dart';
import 'package:meetingzilla/widgets/custom_circular_progress.dart';
import 'package:meetingzilla/widgets/custom_rounded_btn.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  AuthProvider _authProvider;
  bool _obscurePassword;
  final _formKey = GlobalKey<FormState>();

  _validateAndLogin() async {
    FocusScope.of(context).unfocus();
    final _isValid = _formKey.currentState.validate();

    if (_isValid) {
      _formKey.currentState.save();
      setState(() {
        _isLoading = true;
      });

      var userId;

      userId = await FirebaseFunctions.signInUser(
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
          timeInSecForIosWeb: 5,
        );
      });

      if (userId != null) {
        bool isVerified = await _checkEmailVerification();
        if (isVerified) {
          await _authProvider.getUserInfo(userId);
          if (_authProvider.userSnapshot.exists) {
            await _authProvider
                .saveLocalUserData(
              _authProvider.userSnapshot.data()[CHANNEL_ID],
              _authProvider.userSnapshot.data()[USER_ID],
            )
                .then((_) async {
              Fluttertoast.showToast(msg: '$LOGIN_SUCCESS');
              await _authProvider.checkUserInfo();
              _moveToHomePage();
            });
          }
        }
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      Fluttertoast.showToast(
        msg: FIELD_WARNING,
      );
    }
  }

  _moveToHomePage() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => IndexPage()));
  }

  _moveToSignup() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => WelcomePage()));
  }

  Future<bool> _checkEmailVerification() async {
    bool isEmailVerified = await FirebaseFunctions.isEmailVerified();
    if (!isEmailVerified) {
      await FirebaseFunctions.signOutUser();
      _showVerifyEmailDialog();
    }
    return isEmailVerified;
  }

  _showVerifyEmailDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        // return object of type Dialog
        return AlertDialog(
          title: Text(
            "$VERIFY_ACCOUNT",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text("$LINK_VERIFY_WARNING"),
          actions: <Widget>[
            FlatButton(
              child: Text(
                "$RESENT".toUpperCase(),
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).accentColor,
                ),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                _resentVerifyEmail();
              },
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
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
              },
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        );
      },
    );
  }

  _resentVerifyEmail() {
    FirebaseFunctions.sendEmailVerification()
        .then((_) => _showVerifyEmailSentDialog());
  }

  _showVerifyEmailSentDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        // return object of type Dialog
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
              },
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _obscurePassword = true;
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
                    child: _bottomBodyArea(
                  bodyWidth,
                  bodyHeight,
                )),
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
                LOGIN.toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: width * 0.12,
                  fontWeight: FontWeight.w900,
                  color: Theme.of(context).accentColor,
                ),
              ),
              SizedBox(height: 16.0),
              Image.asset(LOGIN_IMAGE_PATH),
              SizedBox(height: 40.0),
              TextFormField(
                key: ValueKey(EMAIL),
                keyboardType: TextInputType.emailAddress,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: EMAIL.toUpperCase(),
                  prefixIcon: Icon(Icons.mail_rounded),
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
                  errorMaxLines: 2,
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
              SizedBox(height: 10.0),
              Align(
                alignment: Alignment.centerRight,
                child: FlatButton(
                  onPressed: () {
                    _showPasswordResetDialog();
                  },
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  child: Text(
                    "Forgot Password?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.0,
                      color: secondColor,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 40.0),
              CustomRoundedBtn(
                title: NEXT,
                onTap: _validateAndLogin,
              ),
              SizedBox(height: 20.0),
              FlatButton(
                onPressed: _moveToSignup,
                child: Text(
                  '$CREATE_ACCOUNT'.toUpperCase(),
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

  _showPasswordResetDialog() => showDialog(
        context: context,
        builder: (ctx) => SimpleDialog(
          title: Text(
            "Reset Password",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          titlePadding: const EdgeInsets.only(
            top: 20.0,
            bottom: 20.0,
            left: 10.0,
            right: 10.0,
          ),
          contentPadding: const EdgeInsets.only(
            top: 0.0,
            bottom: 20.0,
            left: 10.0,
            right: 10.0,
          ),
          children: [
            TextField(
              keyboardType: TextInputType.emailAddress,
              controller: _emailController,
              decoration: InputDecoration(
                hintText: EMAIL.toUpperCase(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    topRight: Radius.zero,
                    bottomLeft: Radius.zero,
                    bottomRight: Radius.circular(16.0),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.0),
            GestureDetector(
              onTap: () async {
                if (_emailController.text.isNotEmpty &&
                    _emailController.text != null) {
                  await FirebaseFunctions.auth
                      .sendPasswordResetEmail(
                    email: _emailController.text,
                  )
                      .then((value) {
                    Fluttertoast.showToast(
                      msg: 'Password reset link has been sent to your email.',
                      gravity: ToastGravity.SNACKBAR,
                    );
                    _emailController.clear();
                  }).catchError((e) {
                    Fluttertoast.showToast(
                      msg: e.toString(),
                      gravity: ToastGravity.SNACKBAR,
                    );
                    print(e.toString());
                  });
                }
                Navigator.pop(ctx);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.all(Radius.circular(16.0)),
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(context).accentColor,
                    ),
                    bottom: BorderSide(
                      color: Theme.of(context).accentColor,
                    ),
                    left: BorderSide(
                      color: Theme.of(context).accentColor,
                    ),
                    right: BorderSide(
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                ),
                child: Text(
                  NEXT,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).accentColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                ),
              ),
            )
          ],
        ),
      );
}

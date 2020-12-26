import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:meetingzilla/constants/strings.dart';

class FirebaseFunctions {
  static final firestore = FirebaseFirestore.instance;
  static final storage = FirebaseStorage.instance;
  static final auth = FirebaseAuth.instance;
  static final appInfoCollection = firestore.collection(APP_INFO_REF);
  static final userCollection = firestore.collection(USER_REF);
  static final meetingCollection = firestore.collection(MEETING_REF);
  static final trashCollection = firestore.collection(TRASH_REF);
  static final imageRef = storage.ref().child(IMAGE_REF);

  static Future<DocumentSnapshot> getAppInfo() async {
    DocumentSnapshot appInfoSnapshot =
        await appInfoCollection.doc(APP_INFO).get();

    return appInfoSnapshot;
  }

  static Future<String> registerUser(String email, String password) async {
    final result = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    User firebaseUser = result.user;
    return firebaseUser.uid;
  }

  static Future<String> signinUser(String email, String password) async {
    final result = await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    User firebaseUser = result.user;
    return firebaseUser.uid;
  }

  static Future<User> getCurrentUser() async {
    User firebaseUser = auth.currentUser;
    return firebaseUser;
  }

  static Future<void> signoutUser() async {
    return auth.signOut();
  }

  static Future<void> sendEmailVerification() async {
    User user = auth.currentUser;
    user.sendEmailVerification();
  }

  static Future<bool> isEmailVerified() async {
    User user = auth.currentUser;
    return user.emailVerified;
  }
}

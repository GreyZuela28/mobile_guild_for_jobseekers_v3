import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_guild_for_jobseekers_v3/users/jobseeker.dart';

import '../users/employer.dart';
import '../users/user_model.dart';

class FirebaseApi {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  String get userUid => auth.currentUser!.uid;

  sigIn(UserModel user, String password) async {
    await auth
        .createUserWithEmailAndPassword(
            email: user.getEmail, password: password)
        .then((value) => db
            .collection("users")
            .doc(auth.currentUser!.uid)
            .set(user.toFirestore()));
  }

  login(String email, String password) async {
    auth.signInWithEmailAndPassword(email: email, password: password);
  }

  logout() async {
    await auth.signOut();
  }

  updateEmployee(UserModel user) async {
    await db.collection("users").doc(userUid).update(user.toFirestore());
  }

  Future<void> deleteEmployee(String id) async {
    await db.collection("users").doc(id).delete();
  }

  Future<List<UserModel>> retrieveJobsekeer(String userType) async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await db
        .collection("users")
        .where('userType', isEqualTo: "jobseeker")
        .get();
    return snapshot.docs
        .map((docSnapshot) => Jobseeker.fromFirestore(docSnapshot, null))
        .toList();
  }

  Future<List<UserModel>> retrieveEmployer(String userType) async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await db
        .collection("users")
        .where('userType', isEqualTo: "employer")
        .get();
    return snapshot.docs
        .map((docSnapshot) => Employer.fromFirestore(docSnapshot, null))
        .toList();
  }

  String getUserType() {
    late String userType;
    final dbRef = db.collection("users").doc(userUid);

    dbRef.get().then((value) {
      final user = value.data();

      userType = user!['userType'];
    });
    return userType;
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/members_model_class.dart';


class MemberProvider with ChangeNotifier {
  List<Member> _members = [];
  List<Member> get members => _members;

  Future<void> fetchMembers() async {

    User? user = FirebaseAuth.instance.currentUser;

    try {
      QuerySnapshot membersSnapshot = await FirebaseFirestore.instance
          .collection('membersList')
          .doc(user?.uid)
          .collection('members')
          .get();

      _members = membersSnapshot.docs.map((memberDoc) {
        String name = memberDoc['name'];
        String relation = memberDoc['relation'];
        return Member(name: name, relation: relation);
      }).toList();

      notifyListeners();
    } catch (error) {
      print("Error fetching members: $error");
    }
  }
}

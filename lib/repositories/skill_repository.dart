import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skillsync/models/skill_model.dart';

class SkillRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<SkillModel>> getSkills() {
    return _firestore
        .collection('skills')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => SkillModel.fromMap(doc.data(), doc.id))
                  .toList(),
        );
  }

  Future<void> addSkill(SkillModel skill) async {
    await _firestore.collection('skills').add(skill.toMap());
  }

  Future<void> deleteSkill(String skillId) async {
    await _firestore.collection('skills').doc(skillId).delete();
  }

  Stream<List<SkillModel>> getUserSkills(String userId) {
    return _firestore
        .collection('skills')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => SkillModel.fromMap(doc.data(), doc.id))
                  .toList(),
        );
  }
}

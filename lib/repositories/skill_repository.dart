import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skillsync/models/skill_model.dart';

class FirebaseSkillRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'skills';

  // ✅ Real-time stream of all skills
  Stream<List<SkillModel>> getSkillsStream() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return SkillModel(
              id: doc.id,
              name: data['name'] ?? '',
              description: data['description'] ?? '',
              category: data['category'] ?? '',
              userId: data['userId'] ?? '',
              userName: data['userName'] ?? '',
              createdAt:
                  (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            );
          }).toList();
        });
  }

  // ✅ Optional: Alias for getSkillsStream() (if used in bloc as getSkills())
  Stream<List<SkillModel>> getSkills() => getSkillsStream();

  // ✅ Stream filtered by category
  Stream<List<SkillModel>> getSkillsByCategoryStream(String category) {
    return _firestore
        .collection(_collection)
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return SkillModel(
              id: doc.id,
              name: data['name'] ?? '',
              description: data['description'] ?? '',
              category: data['category'] ?? '',
              userId: data['userId'] ?? '',
              userName: data['userName'] ?? '',
              createdAt:
                  (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            );
          }).toList();
        });
  }

  // ✅ Add new skill
  Future<void> addSkill(SkillModel skill) async {
    await _firestore.collection(_collection).add({
      'name': skill.name,
      'description': skill.description,
      'category': skill.category,
      'userId': skill.userId,
      'userName': skill.userName,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ✅ Search skill stream by name prefix
  Stream<List<SkillModel>> searchSkillsStream(String query) {
    return _firestore
        .collection(_collection)
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThan: query + 'z')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return SkillModel(
              id: doc.id,
              name: data['name'] ?? '',
              description: data['description'] ?? '',
              category: data['category'] ?? '',
              userId: data['userId'] ?? '',
              userName: data['userName'] ?? '',
              createdAt:
                  (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            );
          }).toList();
        });
  }

  // ✅ Delete skill
  Future<void> deleteSkill(String skillId) async {
    await _firestore.collection(_collection).doc(skillId).delete();
  }

  // ✅ Update skill
  Future<void> updateSkill(String skillId, SkillModel skill) async {
    await _firestore.collection(_collection).doc(skillId).update({
      'name': skill.name,
      'description': skill.description,
      'category': skill.category,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}

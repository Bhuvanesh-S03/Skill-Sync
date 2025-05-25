import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skillsync/models/skill_model.dart';

class SkillRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all skills with real-time updates
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

  // Get top skills by category with real-time updates
  Stream<List<SkillModel>> getTopSkillsByCategory() {
    return _firestore
        .collection('skills')
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) {
          final skills =
              snapshot.docs
                  .map((doc) => SkillModel.fromMap(doc.data(), doc.id))
                  .toList();

          // Group by category and get top skills from each
          final Map<String, List<SkillModel>> skillsByCategory = {};
          for (final skill in skills) {
            if (!skillsByCategory.containsKey(skill.category)) {
              skillsByCategory[skill.category] = [];
            }
            if (skillsByCategory[skill.category]!.length < 3) {
              skillsByCategory[skill.category]!.add(skill);
            }
          }

          // Flatten and return
          final topSkills = <SkillModel>[];
          skillsByCategory.values.forEach((categorySkills) {
            topSkills.addAll(categorySkills);
          });

          return topSkills;
        });
  }

  // Get skills by category with real-time updates
  Stream<List<SkillModel>> getSkillsByCategory(String category) {
    return _firestore
        .collection('skills')
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => SkillModel.fromMap(doc.data(), doc.id))
                  .toList(),
        );
  }

  // Search skills with real-time updates
  Stream<List<SkillModel>> searchSkills({String? query, String? category}) {
    Query<Map<String, dynamic>> skillsQuery = _firestore.collection('skills');

    if (category != null && category.isNotEmpty) {
      skillsQuery = skillsQuery.where('category', isEqualTo: category);
    }

    return skillsQuery.orderBy('createdAt', descending: true).snapshots().map((
      snapshot,
    ) {
      List<SkillModel> skills =
          snapshot.docs
              .map((doc) => SkillModel.fromMap(doc.data(), doc.id))
              .toList();

      if (query != null && query.isNotEmpty) {
        final lowercaseQuery = query.toLowerCase();
        skills =
            skills.where((skill) {
              return skill.name.toLowerCase().contains(lowercaseQuery) ||
                  skill.description.toLowerCase().contains(lowercaseQuery) ||
                  skill.userName.toLowerCase().contains(lowercaseQuery);
            }).toList();
      }

      return skills;
    });
  }

  // Get trending skills (most recently added)
  Stream<List<SkillModel>> getTrendingSkills({int limit = 10}) {
    return _firestore
        .collection('skills')
        .orderBy('createdAt', descending: true)
        .limit(limit)
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

  // Get skill statistics
  Future<Map<String, int>> getSkillStatistics() async {
    final snapshot = await _firestore.collection('skills').get();
    final skills =
        snapshot.docs
            .map((doc) => SkillModel.fromMap(doc.data(), doc.id))
            .toList();

    final Map<String, int> stats = {};
    for (final skill in skills) {
      stats[skill.category] = (stats[skill.category] ?? 0) + 1;
    }

    return stats;
  }
}

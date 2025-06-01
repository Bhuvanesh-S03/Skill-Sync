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

  // ✅ Get skills by user ID
  Stream<List<SkillModel>> getUserSkillsStream(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
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

  // ✅ Get single skill by ID
  Future<SkillModel?> getSkillById(String skillId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(skillId).get();
      if (doc.exists) {
        final data = doc.data()!;
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
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get skill: $e');
    }
  }

  // ✅ Add new skill
  Future<String> addSkill(SkillModel skill) async {
    try {
      final docRef = await _firestore.collection(_collection).add({
        'name': skill.name,
        'description': skill.description,
        'category': skill.category,
        'userId': skill.userId,
        'userName': skill.userName,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add skill: $e');
    }
  }

  // ✅ Update skill
  Future<void> updateSkill(String skillId, SkillModel skill) async {
    try {
      await _firestore.collection(_collection).doc(skillId).update({
        'name': skill.name,
        'description': skill.description,
        'category': skill.category,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update skill: $e');
    }
  }

  // ✅ Delete skill (Enhanced with validation)
  Future<void> deleteSkill(String skillId) async {
    try {
      // Check if skill exists first
      final doc = await _firestore.collection(_collection).doc(skillId).get();
      if (!doc.exists) {
        throw Exception('Skill not found');
      }

      // Delete the skill
      await _firestore.collection(_collection).doc(skillId).delete();
    } catch (e) {
      throw Exception('Failed to delete skill: $e');
    }
  }

  // ✅ Delete skill with user validation
  Future<void> deleteSkillByUser(String skillId, String userId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(skillId).get();

      if (!doc.exists) {
        throw Exception('Skill not found');
      }

      final data = doc.data()!;
      if (data['userId'] != userId) {
        throw Exception('You can only delete your own skills');
      }

      await _firestore.collection(_collection).doc(skillId).delete();
    } catch (e) {
      throw Exception('Failed to delete skill: $e');
    }
  }

  // ✅ Batch delete multiple skills
  Future<void> deleteMultipleSkills(List<String> skillIds) async {
    try {
      final batch = _firestore.batch();

      for (String skillId in skillIds) {
        final docRef = _firestore.collection(_collection).doc(skillId);
        batch.delete(docRef);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete multiple skills: $e');
    }
  }

  // ✅ Delete all skills by user
  Future<void> deleteAllUserSkills(String userId) async {
    try {
      final querySnapshot =
          await _firestore
              .collection(_collection)
              .where('userId', isEqualTo: userId)
              .get();

      final batch = _firestore.batch();

      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete user skills: $e');
    }
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

  // ✅ Soft delete (mark as deleted instead of actual deletion)
  Future<void> softDeleteSkill(String skillId, String userId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(skillId).get();

      if (!doc.exists) {
        throw Exception('Skill not found');
      }

      final data = doc.data()!;
      if (data['userId'] != userId) {
        throw Exception('You can only delete your own skills');
      }

      await _firestore.collection(_collection).doc(skillId).update({
        'isDeleted': true,
        'deletedAt': FieldValue.serverTimestamp(),
        'deletedBy': userId,
      });
    } catch (e) {
      throw Exception('Failed to soft delete skill: $e');
    }
  }

  // ✅ Restore soft deleted skill
  Future<void> restoreSkill(String skillId, String userId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(skillId).get();

      if (!doc.exists) {
        throw Exception('Skill not found');
      }

      final data = doc.data()!;
      if (data['userId'] != userId) {
        throw Exception('You can only restore your own skills');
      }

      await _firestore.collection(_collection).doc(skillId).update({
        'isDeleted': FieldValue.delete(),
        'deletedAt': FieldValue.delete(),
        'deletedBy': FieldValue.delete(),
        'restoredAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to restore skill: $e');
    }
  }

  // ✅ Get skills excluding soft deleted ones
  Stream<List<SkillModel>> getActiveSkillsStream() {
    return _firestore
        .collection(_collection)
        .where('isDeleted', isNotEqualTo: true)
        .orderBy('isDeleted')
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
}

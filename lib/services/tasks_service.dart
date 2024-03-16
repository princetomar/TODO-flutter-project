import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_app/models/todo_model.dart';

class TodoService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addTodo(Todo todo, String userId) async {
    try {
      final userRef = _db.collection('users').doc(userId);
      final TodoRef = userRef.collection('ownedTodo').doc();

      await _db.runTransaction((transaction) async {
        await transaction.set(TodoRef, {
          'title': todo.title,
          'taskId': todo.id,
          'ownerId': todo.ownerId,
          'completed': todo.completed,
          'sharedWith': todo.sharedWith,
          'createdtedAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        });

        // Add shared Todo to other users' sharedTodo collection
        for (String sharedUserId in todo.sharedWith) {
          final sharedUserRef = _db.collection('users').doc(sharedUserId);
          final sharedTodoRef =
              sharedUserRef.collection('sharedTodo').doc(TodoRef.id);

          await transaction.set(sharedTodoRef, {
            'title': todo.title,
            'completed': todo.completed,
            'ownerId': userId, // Changed from 'owner' to 'ownerId'
          });
        }
      });
    } catch (error) {
      print(error);
    }
  }

  Stream<List<Todo>> getOwnedTodos(String userId) {
    final userRef = _db.collection('users').doc(userId);
    return userRef
        .collection('ownedTodo')
        .orderBy('createdtedAt',
            descending: false) // Sort by createdAt in descending order
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Todo.fromSnapshot(doc)).toList());
  }

  Stream<List<Todo>> getSharedTodos(String userId) {
    final userRef = _db.collection('users').doc(userId);
    return userRef
        .collection('sharedTodos')
        .orderBy('createdtedAt',
            descending: false) // Sort by createdAt in descending order
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Todo.fromSnapshot(doc)).toList());
  }

  // Function to update the shared todo
  Future<void> updateSharedTodo(
      Todo todo, String sharedTodoId, String userId) async {
    final sharedTodoRef = _db
        .collection('users')
        .doc(userId)
        .collection('sharedTodos')
        .doc(sharedTodoId);

    final ownerTodoRef = _db
        .collection("users")
        .doc(todo.ownerId)
        .collection("ownedTodo")
        .doc(todo.id);

    await sharedTodoRef.update({
      'title': todo.title,
      'completed': todo.completed,
      'createdtedAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
      'updatedBy': userId,
      // Add any other fields you want to update
    });
    await ownerTodoRef.update({
      'title': todo.title,
      'completed': todo.completed,
      'createdtedAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
      'updatedBy': userId,
      // Add any other fields you want to update
    });
  }

  // Function to share a todo with different user, via mentioning their email id
  Future<void> shareTodo(
      String userId, String todoId, String sharedWithEmail) async {
    final userTodoRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('ownedTodo')
        .doc(todoId);

    // Check if user with provided email exists
    final sharedUserQuery = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: sharedWithEmail)
        .limit(1)
        .get();

    if (sharedUserQuery.docs.isEmpty) {
      throw Exception('User with email $sharedWithEmail not found');
    }

    final sharedUserId = sharedUserQuery.docs.first.id;

    // Update the 'sharedWith' field in the owner's Todo document
    await userTodoRef.update({
      'sharedWith': FieldValue.arrayUnion([sharedUserId]),
    });

    // Create a shared copy of the todo in the shared user's collection
    final sharedTodoData = (await userTodoRef.get()).data();
    final sharedUserTodosRef = FirebaseFirestore.instance
        .collection('users')
        .doc(sharedUserId)
        .collection('sharedTodos')
        .doc(todoId);

    // Check if sharedTodos collection exists for shared user
    final sharedUserDoc = await sharedUserTodosRef.get();
    if (!sharedUserDoc.exists) {
      // If sharedTodos collection does not exist, create it
      await sharedUserTodosRef.set({
        'todos': {},
      });
    }

    // Add the todo to the sharedTodos collection
    await sharedUserTodosRef.set({
      'title': sharedTodoData!['title'],
      'ownerId': sharedTodoData['ownerId'],
      'completed': sharedTodoData['completed'],
      'createdtedAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
      'updatedBy': userId,
    });
  }

  Future<void> deleteOwnedTodo(String userId, String todoId) async {
    final userTodoRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('todos')
        .doc('ownedTodos')
        .collection('todos')
        .doc(todoId);

    await userTodoRef.delete();
  }

  Future<void> updateTodo(Todo Todo, String userId) async {
    try {
      final userRef = _db.collection('users').doc(userId);
      final TodoRef = userRef.collection('ownedTodo').doc(Todo.id);

      await TodoRef.set({
        'title': Todo.title,
        'completed': Todo.completed,
        'sharedWith': Todo.sharedWith,
      }, SetOptions(merge: true));
    } catch (error) {
      print(error);
    }
  }

  Future<bool> checkUserExists(String email) async {
    // Reference to the users collection
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    // Query for documents where the email field matches the provided email
    QuerySnapshot querySnapshot =
        await users.where('email', isEqualTo: email).get();

    // Check if any documents were found with the provided email
    return querySnapshot.docs.isNotEmpty;
  }
}

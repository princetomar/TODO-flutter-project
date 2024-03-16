import 'package:cloud_firestore/cloud_firestore.dart';

class Todo {
  final String id;
  final String ownerId;
  final String title;
  final bool completed;
  final List<String> sharedWith;

  Todo({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.completed,
    required this.sharedWith,
  });

  factory Todo.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Todo(
      id: snapshot.id,
      ownerId: data['ownerId'],
      title: data['title'],
      completed: data['completed'],
      sharedWith: List<String>.from(data['sharedWith'] ?? []),
    );
  }
}

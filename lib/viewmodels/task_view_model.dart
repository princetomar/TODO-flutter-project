import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:task_app/models/todo_model.dart';
import 'package:task_app/services/tasks_service.dart';

class TodoViewModel extends ChangeNotifier {
  final TodoService _taskService = TodoService();
  late List<Todo> _ownedTodos = [];
  late List<Todo> _sharedTodos = [];
  late String userId;

  void setUserId(String id) {
    userId = id;
    fetchOwnedTodos();
    fetchSharedTodos();
  }

  Stream<List<Todo>> get ownedTodosStream => _taskService.getOwnedTodos(userId);

  Stream<List<Todo>> get sharedTodosStream =>
      _taskService.getSharedTodos(userId);

  Future<void> addTodo(Todo todo) async {
    await _taskService.addTodo(todo, userId);
  }

  Future<void> shareTodoWithUser(String todoId, String sharedWithEmail) async {
    try {
      // Call the service method with the userId
      await _taskService.shareTodo(userId, todoId, sharedWithEmail);
    } catch (e) {
      print("Error sharing todo with user: $e");
      throw Exception("Error sharing todo with user: $e");
    }
  }

  Future<void> updateTodo(Todo todo) async {
    await _taskService.updateTodo(todo, userId);
  }

  Future<void> updateSharedTodo(Todo todo, String sharedTodoId) async {
    await _taskService.updateSharedTodo(todo, sharedTodoId, userId);
  }

  void fetchOwnedTodos() {
    _ownedTodos = [];
    _taskService.getOwnedTodos(userId).listen((todos) {
      _ownedTodos = todos;
      notifyListeners();
    });
  }

  void fetchSharedTodos() {
    _sharedTodos = [];
    _taskService.getSharedTodos(userId).listen((todos) {
      _sharedTodos = todos;
      notifyListeners();
    });
  }

  void shareTask(Todo task) {
    final String text = 'Task Title: ${task.title}\n'
        'Owner: ${task.ownerId}\n'
        'Status: ${task.completed ? 'Completed' : 'Pending'}';

    Share.share(text, subject: 'Shared Task Details');
  }
}

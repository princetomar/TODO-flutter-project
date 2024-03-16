import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_app/models/todo_model.dart';
import 'package:task_app/viewmodels/auth_view_model.dart';
import 'package:task_app/viewmodels/task_view_model.dart';

class TodoListView extends StatefulWidget {
  String userId;
  TodoListView({required this.userId});
  @override
  State<TodoListView> createState() => _TodoListViewState();
}

class _TodoListViewState extends State<TodoListView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        return _buildTaskList(context, widget.userId);
      },
    );
  }

  Widget _buildTaskList(BuildContext context, String userId) {
    final taskViewModel = Provider.of<TodoViewModel>(context, listen: false);
    taskViewModel.setUserId(userId);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Your Notes',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await Provider.of<AuthViewModel>(context, listen: false)
                  .signOut(context);
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        color: Colors.white,
        alignment: Alignment.center,
        child: DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              toolbarHeight: 10,
              automaticallyImplyLeading: false,
              bottom: const TabBar(
                unselectedLabelColor: Colors.black38,
                unselectedLabelStyle: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                labelColor: Colors.blue,
                labelStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                isScrollable: true,
                tabs: [
                  Tab(
                    text: "YOUR TODOs",
                  ),
                  Tab(
                    text: "SHARED TODOs",
                  ),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                Container(
                  padding: const EdgeInsets.only(top: 20),
                  color: Colors.white,
                  child: _buildOwnedTasks(context, taskViewModel),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 20),
                  color: Colors.white,
                  child: _buildSharedTasks(context, taskViewModel),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          _showAddTaskDialog(context, taskViewModel);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildOwnedTasks(BuildContext context, TodoViewModel taskViewModel) {
    return StreamBuilder<List<Todo>>(
      stream: taskViewModel.ownedTodosStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No owned tasks yet!'));
        }
        return ListView.builder(
          itemCount: snapshot.data!.length,
          physics: BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            Todo task = snapshot.data![index];
            Color tileColor = generateRandomLightColor();
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: tileColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Text(
                  "${index + 1}",
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                ),
                title: Text(task.title),
                subtitle: Text(
                    'Owner: ${task.ownerId == widget.userId ? 'true' : 'false'}'),
                // Implement other UI for tasks

                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.share),
                      onPressed: () {
                        taskViewModel.shareTask(task);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.person_add),
                      onPressed: () {
                        _showShareDialog(context, task, taskViewModel);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSharedTasks(BuildContext context, TodoViewModel taskViewModel) {
    return StreamBuilder<List<Todo>>(
      stream: taskViewModel.sharedTodosStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No shared tasks yet!'));
        }
        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            Todo task = snapshot.data![index];
            Color tileColor = generateRandomLightColor();
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: tileColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Text(
                  "${index + 1}",
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                ),
                title: Text(task.title),
                subtitle: Text(
                    'Owner: ${task.ownerId == widget.userId ? 'true' : 'false'}'),
                // Implement other UI for tasks

                trailing: IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    _updateSharedTodoDialog(context, task, taskViewModel);
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAddTaskDialog(BuildContext context, TodoViewModel taskViewModel) {
    String newTaskTitle = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Task'),
          content: TextField(
            onChanged: (value) {
              newTaskTitle = value;
            },
            decoration: const InputDecoration(hintText: 'Enter task title'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (newTaskTitle.isNotEmpty) {
                  String taskId = generateRandomString(15);

                  print("TASK ID : $taskId");
                  print("USER ID : ${widget.userId}");
                  Todo newTask = Todo(
                    id: taskId,
                    ownerId: widget.userId,
                    title: newTaskTitle,
                    completed: false,
                    sharedWith: [], // Initialize with an empty list
                  );
                  await taskViewModel.addTodo(newTask);
                  Navigator.of(context).pop();
                } else {
                  // Show error message if task title is empty
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a task title'),
                    ),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  String generateRandomString(int length) {
    const chars = '0123456789';
    final random = Random();
    return String.fromCharCodes(Iterable.generate(
        length, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
  }

  void _showShareDialog(
      BuildContext context, Todo task, TodoViewModel taskViewModel) {
    TextEditingController emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Share Todo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Enter User Email',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String userEmail = emailController.text.trim();
                _shareTodoWithUser(task, userEmail, taskViewModel);
                Navigator.pop(context);
              },
              child: Text('Share'),
            ),
          ],
        );
      },
    );
  }

  void _shareTodoWithUser(
      Todo task, String userEmail, TodoViewModel taskViewModel) {
    FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: userEmail)
        .limit(1)
        .get()
        .then((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        final sharedUserId = querySnapshot.docs.first.id;
        taskViewModel.shareTodoWithUser(task.id, userEmail);
      } else {
        // Notify user1 that user with userEmail does not exist
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User with email $userEmail does not exist.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }).catchError((error) {
      print("Error checking user existence: $error");
      // Handle error, show message, etc.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error checking user existence.'),
          duration: Duration(seconds: 3),
        ),
      );
    });
  }

  // update shared todo
  void _updateSharedTodoDialog(
      BuildContext context, Todo task, TodoViewModel taskViewModel) {
    TextEditingController titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update shared Todo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: task.title,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String newTitle = titleController.text.trim();
                Todo updateTodo = Todo(
                    id: task.id,
                    ownerId: task.ownerId,
                    title: newTitle,
                    completed: task.completed,
                    sharedWith: task.sharedWith);
                taskViewModel.updateSharedTodo(updateTodo, task.id);
                Navigator.pop(context);
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  Color generateRandomLightColor() {
    Random random = Random();
    int red = 180 + random.nextInt(55); // Random value between 200 and 255
    int green = 180 + random.nextInt(55); // Random value between 200 and 255
    int blue = 180 + random.nextInt(55); // Random value between 200 and 255
    return Color.fromRGBO(red, green, blue, 1.0);
  }
//
}

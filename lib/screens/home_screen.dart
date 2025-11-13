import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import '../widgets/task_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Task> tasks = [];
  String filter = "all"; // all / completed / pending
  final TextEditingController taskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  // ------------------------------
  // SAVE TASKS
  // ------------------------------
  Future<void> saveTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String> taskList = tasks.map((task) {
      return jsonEncode(task.toMap());
    }).toList();

    await prefs.setStringList("tasks", taskList);
  }

  // ------------------------------
  // LOAD TASKS
  // ------------------------------
  Future<void> loadTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? taskList = prefs.getStringList("tasks");

    if (taskList != null) {
      setState(() {
        tasks = taskList.map((str) {
          Map<String, dynamic> map = jsonDecode(str);
          return Task.fromMap(map);
        }).toList();
      });
    }
  }

  // ------------------------------
  // ADD TASK
  // ------------------------------
  void addTask() {
    if (taskController.text.isNotEmpty) {
      setState(() {
        tasks.add(Task(title: taskController.text));
        taskController.clear();
      });
      saveTasks();
    }
  }

  // ------------------------------
  // DELETE TASK
  // ------------------------------
  void removeTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
    saveTasks();
  }

  // ------------------------------
  // EDIT TASK
  // ------------------------------
  void editTask(int index) {
    final controller =
        TextEditingController(text: tasks[index].title);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Task"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: "Edit task"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  tasks[index].title = controller.text;
                });
                saveTasks();
                Navigator.pop(context);
              },
              child: const Text("Save"),
            )
          ],
        );
      },
    );
  }

  // ------------------------------
  // FILTER TASKS
  // ------------------------------
  List<Task> get filteredTasks {
    if (filter == "completed") {
      return tasks.where((t) => t.isDone).toList();
    } else if (filter == "pending") {
      return tasks.where((t) => !t.isDone).toList();
    }
    return tasks;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My To-Do App"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ------------------------------
            // ADD TASK INPUT
            // ------------------------------
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: taskController,
                    decoration: const InputDecoration(
                      hintText: "Enter task...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: addTask,
                  child: const Text("Add"),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ------------------------------
            // FILTER BUTTONS
            // ------------------------------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                FilterChip(
                  label: const Text("All"),
                  selected: filter == "all",
                  onSelected: (_) => setState(() => filter = "all"),
                ),
                FilterChip(
                  label: const Text("Completed"),
                  selected: filter == "completed",
                  onSelected: (_) =>
                      setState(() => filter = "completed"),
                ),
                FilterChip(
                  label: const Text("Pending"),
                  selected: filter == "pending",
                  onSelected: (_) =>
                      setState(() => filter = "pending"),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ------------------------------
            // TASK LIST
            // ------------------------------
            Expanded(
              child: ListView.builder(
                itemCount: filteredTasks.length,
                itemBuilder: (context, index) {
                  final task = filteredTasks[index];
                  final realIndex = tasks.indexOf(task);

                  return TaskTile(
                    task: task,
                    onToggleDone: () {
                      setState(() {
                        tasks[realIndex].isDone =
                            !tasks[realIndex].isDone;
                      });
                      saveTasks();
                    },
                    onDelete: () => removeTask(realIndex),
                    onEdit: () => editTask(realIndex),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

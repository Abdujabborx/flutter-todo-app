import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ToDoScreen extends StatefulWidget {
  @override
  _ToDoScreenState createState() => _ToDoScreenState();
}

class _ToDoScreenState extends State<ToDoScreen> {
  List<String> tasks = []; // List to hold all tasks
  List<String> filteredTasks = []; // List to hold tasks filtered by search
  TextEditingController taskController = TextEditingController(); // Controller for adding/editing tasks
  TextEditingController searchController = TextEditingController(); // Controller for search input
  bool isSearching = false; // Flag to determine if search mode is active

  @override
  void initState() {
    super.initState();
    loadTasks(); // Load tasks from SharedPreferences when the screen is initialized
  }

  void loadTasks() async {
    // Load tasks from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance(); // Get SharedPreferences instance
    setState(() {
      tasks = prefs.getStringList('tasks') ?? []; // Retrieve tasks list or initialize as empty if null
      filteredTasks = List.from(tasks); // Initialize filteredTasks with all tasks
    });
  }

  void saveTasks() async {
    // Save tasks to SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance(); // Get SharedPreferences instance
    prefs.setStringList('tasks', tasks); // Save the updated tasks list
  }

  void addOrEditTask({String? initialText, int? index}) {
    // Open a dialog to add a new task or edit an existing one
    taskController.text = initialText ?? ''; // Populate the text field with the initial task if editing
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(index == null ? 'Add Task' : 'Edit Task'), // Title depends on whether adding or editing
        content: TextField(
          controller: taskController, // Text controller for input
          decoration: InputDecoration(hintText: 'Enter task'), // Placeholder for the input
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (taskController.text.isNotEmpty) {
                // Check if input is not empty
                setState(() {
                  if (index == null) {
                    tasks.add(taskController.text); // Add new task
                  } else {
                    tasks[index] = taskController.text; // Edit existing task
                  }
                  filteredTasks = List.from(tasks); // Update filteredTasks to reflect changes
                });
                saveTasks(); // Save updated tasks to SharedPreferences
                Navigator.pop(context); // Close the dialog
              }
            },
            child: Text('Save'), // Save button
          ),
          TextButton(
            onPressed: () => Navigator.pop(context), // Close the dialog
            child: Text('Cancel'), // Cancel button
          ),
        ],
      ),
    );
  }

  void deleteTask(int index) {
    // Delete a task by index
    setState(() {
      tasks.removeAt(index); // Remove task from the list
      filteredTasks = List.from(tasks); // Update filteredTasks to reflect changes
    });
    saveTasks(); // Save updated tasks to SharedPreferences
  }

  void filterTasks(String query) {
    // Filter tasks based on search query
    setState(() {
      filteredTasks = tasks
          .where((task) => task.toLowerCase().contains(query.toLowerCase())) // Filter tasks that match the query
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Build the UI of the To-Do app
    return Scaffold(
      appBar: AppBar(
        title: isSearching
            ? TextField(
          controller: searchController, // Controller for search input
          decoration: InputDecoration(
            hintText: 'Search tasks...', // Placeholder for search input
            border: InputBorder.none, // Remove border
          ),
          onChanged: filterTasks, // Call filterTasks whenever input changes
        )
            : Text('To-Do List'), // Default title
        centerTitle: true, // Center the title
        elevation: 3, // Add shadow to the app bar
        backgroundColor: Colors.deepPurpleAccent, // App bar color
        actions: [
          IconButton(
            icon: Icon(isSearching ? Icons.close : Icons.search), // Toggle search icon
            onPressed: () {
              setState(() {
                isSearching = !isSearching; // Toggle search mode
                if (!isSearching) {
                  // Reset search if closing search mode
                  searchController.clear(); // Clear the search input
                  filteredTasks = List.from(tasks); // Reset filteredTasks
                }
              });
            },
          ),
        ],
      ),
      body: ListView.builder(
        // List of tasks
        itemCount: filteredTasks.length, // Number of tasks to display
        itemBuilder: (context, index) => Dismissible(
          key: UniqueKey(), // Unique key for dismissible items
          background: Container(
            // Background for swiping to the right (edit)
            color: Colors.green,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: 20), // Add padding for the icon
            child: Icon(Icons.edit, color: Colors.white), // Edit icon
          ),
          secondaryBackground: Container(
            // Background for swiping to the left (delete)
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 20), // Add padding for the icon
            child: Icon(Icons.delete, color: Colors.white), // Delete icon
          ),
          onDismissed: (direction) {
            // Handle swipe actions
            if (direction == DismissDirection.startToEnd) {
              // Swipe to the right (edit)
              addOrEditTask(initialText: filteredTasks[index], index: tasks.indexOf(filteredTasks[index]));
            } else if (direction == DismissDirection.endToStart) {
              // Swipe to the left (delete)
              deleteTask(tasks.indexOf(filteredTasks[index]));
            }
          },
          child: Card(
            // Task card
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10), // Card margin
            color: Colors.deepPurple[50], // Card background color
            child: ListTile(
              title: Text(filteredTasks[index]), // Task text
            ),
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        // Floating action button for adding tasks
        onPressed: () => addOrEditTask(), // Open dialog to add task
        child: Icon(Icons.add), // Add icon
        backgroundColor: Colors.deepPurpleAccent, // Button color
      ),

    );
  }
}

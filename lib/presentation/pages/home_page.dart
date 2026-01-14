import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/todo_model.dart';
import '../../data/databases/todo_database.dart';
//import '../components/todo_item.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState(); 

}

  enum TodoPriority { low, medium, high }

class _HomePageState extends State<HomePage>{

  TodoPriority _selectedPriority = TodoPriority.medium;

  final titleController = TextEditingController();
  final descController = TextEditingController();
  final priorityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    //readTodos();
  }

  void createTodo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min, // important for dialogs
            children: [
              Row(
                children: <Widget>[
                  Expanded(child: 
                    TextField(
                        controller: titleController,
                        decoration: const InputDecoration(labelText: 'Title'),
                    ),
                  ),
                  const SizedBox(width: 1.0),
                  Expanded(child: 
                    DropdownButtonFormField<TodoPriority>(
                      initialValue: _selectedPriority,
                      decoration: const InputDecoration(
                        labelText: 'Priority',
                      ),
                      items: TodoPriority.values.map((priority) {
                        return DropdownMenuItem(
                          value: priority,
                          child: Text(priority.name.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedPriority = value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 1.0),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),

              const SizedBox(height: 12),
            ]
          ),
        ),
        
        
        /**/
        actions: [
          MaterialButton(
            onPressed: () {
              // add to db
              context.read<TodoDatabase>().addTodo(titleController.text, descController.text, _selectedPriority.name);

              // clear controller
              titleController.clear();

              Navigator.pop(context);
            },
            child: const Text("Create"),
          )
        ],
      ),
    );
  }

  void readTodos() {context.read<TodoDatabase>().fetchTodos();}

  void deleteTodo(int id) {context.read<TodoDatabase>().deleteNote(id);}


  @override
  Widget build(BuildContext context) {
    final todoDatabase = context.watch<TodoDatabase>();

    // current notes
    List<Todo> currentTodos = todoDatabase.currentTodos;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: createTodo,
          child: const Icon(Icons.add),
        ),
      body: ListView.builder(
          itemCount: currentTodos.length,
          itemBuilder: (context, index) {
            // get individual note
            final todo = currentTodos[index];

            // list tile UI
            return ListTile(
              title: Text(todo.title),
            );
          },
        )
    );
  }
}
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
  bool showIsFinished = false;
  bool showIsUnfinished = false;

  @override
  void initState() {
    super.initState();
    //readTodos();
  }

  void setFilter() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              content: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    CheckboxListTile(
                      value: showIsFinished,
                      title: const Text("Finished"),
                      onChanged: (bool? value) {
                        setDialogState(() {
                          showIsFinished = value ?? true;
                        });

                        setState(() {});
                      },
                    ),
                    CheckboxListTile(
                      value: showIsUnfinished,
                      title: const Text("Unfinished"),
                      onChanged: (bool? value) {
                        setDialogState(() {
                          showIsUnfinished = value ?? true;
                        });

                        setState(() {});
                      },
                    ),
                  ],
                )
              ),
            );
          },
        );
      },
    );
  }


  void createTodo() {
    TodoPriority selectedPriority = TodoPriority.medium;

    final titleController = TextEditingController();
    final descController = TextEditingController();

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
                      initialValue: selectedPriority,
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
                          selectedPriority = value!;
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
              context.read<TodoDatabase>().addTodo(titleController.text, descController.text, selectedPriority.name);

              // clear controller
              titleController.clear();
              descController.clear();

              Navigator.pop(context);
            },
            child: const Text("Create"),
          )
        ],
      ),
    );
  }

  void updateTodo(Todo todo) {
    TodoPriority selectedPriority = TodoPriority.values.byName(todo.priority);

    final titleController = TextEditingController(text: todo.title);
    final descController = TextEditingController(text: todo.description);

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
                      initialValue: selectedPriority,
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
                          selectedPriority = value!;
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
        
        actions: [
          MaterialButton(
            onPressed: () {
              // add to db
              context.read<TodoDatabase>().updateTodo(todo.id ,titleController.text, descController.text, selectedPriority.name);

              // clear controller
              titleController.clear();
              descController.clear();

              Navigator.pop(context);
            },
            child: const Text("Update"),
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
    List<Todo> filteredTodos = [];

    showIsFinished ? filteredTodos.addAll(currentTodos.where((todo) => todo.isFinished).toList()) : filteredTodos.removeWhere((todo) => todo.isFinished);
    showIsUnfinished ? filteredTodos.addAll(currentTodos.where((todo) => !todo.isFinished).toList()) : filteredTodos.removeWhere((todo) => !todo.isFinished);

    List<Todo> showedTodos = /*currentTodos;*/(filteredTodos.isEmpty && (!showIsFinished && !showIsUnfinished)) || (showIsFinished && showIsUnfinished)? 
    currentTodos : filteredTodos; 

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(onPressed: () => setFilter(), 
          icon: const Icon(Icons.filter_list))
        ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: createTodo,
          child: const Icon(Icons.add),
        ),
      body: (!showIsFinished && !showIsUnfinished)
        ? ReorderableListView.builder(
          itemCount: showedTodos.length,
          onReorder: (oldIndex, newIndex) {
            context.read<TodoDatabase>().reorderTodos(oldIndex, newIndex);
          },
          itemBuilder: (context, index) {
            // get individual note
            final todo = showedTodos[index];

            final isChecked = todo.isFinished;

            // list tile UI
            return ListTile(
              key: ValueKey(todo.id),
              title: Text(todo.title),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(todo.priority),
                  IconButton(
                    onPressed: () => updateTodo(todo),
                    icon: const Icon(Icons.edit),
                  ),
                  IconButton(
                    onPressed: () => deleteTodo(todo.id),
                    icon: const Icon(Icons.delete),
                  ),
                  Checkbox(
                    value: isChecked, 
                    onChanged: (bool? value) {
                      setState(() {
                        final isChecked = value ?? false;
                        context.read<TodoDatabase>().updateIsFinished(todo.id, isChecked);
                      });
                    }
                  )
                ],
              ),
            );
          },
        )
        : ListView.builder(
          itemCount: showedTodos.length,
          itemBuilder: (context, index) {
            // get individual note
            final todo = showedTodos[index];

            final isChecked = todo.isFinished;

            // list tile UI
            return ListTile(
              title: Text(todo.title),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(todo.priority),
                  IconButton(
                    onPressed: () => updateTodo(todo),
                    icon: const Icon(Icons.edit),
                  ),
                  IconButton(
                    onPressed: () => deleteTodo(todo.id),
                    icon: const Icon(Icons.delete),
                  ),
                  Checkbox(
                    value: isChecked, 
                    onChanged: (bool? value) {
                      setState(() {
                        final isChecked = value ?? false;
                        context.read<TodoDatabase>().updateIsFinished(todo.id, isChecked);
                      });
                    }
                  )
                ],
              ),
            );
          },
          //onReorder: ,
        )
    );
  }
}
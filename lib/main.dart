import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/databases/todo_database.dart';
import 'presentation/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TodoDatabase.initialize();

  runApp(ChangeNotifierProvider(
      create: (context) => TodoDatabase(),
      child: const ToDoApp(),
    ));
}

class ToDoApp extends StatelessWidget {
  const ToDoApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: HomePage(title: "To Do App"),
    );
  }
}

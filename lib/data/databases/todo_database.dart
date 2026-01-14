// models/note_database.dart
import '../models/todo_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class TodoDatabase extends ChangeNotifier {
    static late Isar isar;

    static Future<void> initialize() async {
        if(Platform.isAndroid) {
            final dir = await getApplicationDocumentsDirectory();
            isar = await Isar.open([TodoSchema], directory: (dir.path));
        }
    }

    final List<Todo> currentTodos = [];

    Future<void> addTodo (String titleIp, String descIp, String priorityIp) async {
      final newTodo = Todo(titleIp, descIp, priorityIp, false);
      await isar.writeTxn(() => isar.todos.put(newTodo));
      await fetchTodos();

    }

    Future<void> fetchTodos()async{
      List<Todo> fetchedTodos = await isar.todos.where().findAll();
      currentTodos.clear();
      currentTodos.addAll(fetchedTodos);
      notifyListeners();
    }

    Future<void> updateTodos(int id, String newTitle, String newDesc, String newPriority) async {
      final existingTodo = await isar.todos.get(id);
      if (existingTodo != null) {
        existingTodo.title = newTitle;
        existingTodo.description = newDesc;
        existingTodo.priority = newPriority;
        await isar.writeTxn(() => isar.todos.put(existingTodo));
        await fetchTodos();
      }
    }

    Future<void> updateIsFinished(int id, bool newIsFin) async {
      final existingTodo = await isar.todos.get(id);
      if (existingTodo != null){
        existingTodo.isFinished = newIsFin;
        await isar.writeTxn(() => isar.todos.put(existingTodo));
        await fetchTodos();
      }
    }

    Future<void> deleteNote(int id) async {
      await isar.writeTxn(() => isar.todos.delete(id));
      await fetchTodos();
    }
}
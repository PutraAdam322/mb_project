import 'package:isar/isar.dart';

part 'todo_model.g.dart';
@Collection()
class Todo {
  Todo(this.title, this.description, this.priority, this.isFinished);

  Id id = Isar.autoIncrement;
  late String title;
  late String description;
  late String priority;
  late bool isFinished;

}
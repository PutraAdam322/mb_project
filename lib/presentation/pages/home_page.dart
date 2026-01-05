import 'package:flutter/material.dart';
import '../components/todo_item.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState(); 

}

class Temp {
  Temp(this.id, this.orderId, this.title);

  String id;
  int orderId;
  String title;
}

class _HomePageState extends State<HomePage>{

  List<Temp> toDosBuilder(){
    List<Temp> toDos = [];
    for (int i = 0; i < 10; i++){
      int tid = i+1;
      Temp temp = Temp(tid.toString(), i+1, 'Task $i');
      toDos.add(temp);
    }

    return toDos;
  }

  @override
  Widget build(BuildContext context) {
    List<Temp> toDos = toDosBuilder();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child:
            ReorderableListView(
              onReorder: (int oldIndex, int newIndex){
                setState(() {
                  if(oldIndex < newIndex) newIndex--;
                  final Temp tmp = toDos.removeAt(oldIndex);
                  toDos.insert(newIndex, tmp);
                });
              },
              children: <Widget>[
                for (var toDo in toDos)
                  ListTile(
                    key: Key(toDo.id),
                    title: Text(toDo.title),
                  ),
              ], )
      )
    );
  }
}
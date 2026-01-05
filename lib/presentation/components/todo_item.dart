import 'package:flutter/material.dart';

class TodoItem extends StatelessWidget{
  const TodoItem({super.key, required this.title, required this.orderId, required this.id});

  final String title;
  final String id;
  final int orderId;

  @override
  Widget build(BuildContext context){
    return ListTile(
      key: Key(id),
      title: Text(title),
    );
  }
}
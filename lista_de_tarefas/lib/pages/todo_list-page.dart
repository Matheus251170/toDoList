import 'package:flutter/material.dart';
import 'package:lista_de_tarefas/models/todo.dart';
import 'package:lista_de_tarefas/pages/TodoListItem.dart';
import 'package:lista_de_tarefas/repositories/TodoRepository.dart';

class todoListPage extends StatefulWidget {
  const todoListPage({Key? key}) : super(key: key);

  @override
  _todoListPageState createState() => _todoListPageState();
}

class _todoListPageState extends State<todoListPage> {
  final TextEditingController todoController = TextEditingController();
  final TodoRepository todoRepository = TodoRepository();

  List<Todo> todos = [];
  List<Todo> allDeleted = [];
  Todo? deletedTodo;
  int? positionDeleted;
  String? errorText;

  @override
  void initState() {
    super.initState();

    todoRepository.getTodoList().then((value) {
      setState(() {
        todos = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: todoController,
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.pink,
                              width: 2,
                            ),
                          ),
                          border: OutlineInputBorder(),
                          labelStyle: TextStyle(
                            color: Colors.pink,
                          ),
                          labelText: 'Adicione uma tarefa',
                          hintText: 'Ex.: tomar remédio',
                          errorText: errorText,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    ElevatedButton(
                        onPressed: () {
                          String text = todoController.text;

                          if (text.isEmpty) {
                            setState(() {
                              errorText = 'Insira uma tarefa!';
                            });
                            return;
                          }

                          setState(() {
                            Todo newTodo = Todo(
                              title: text,
                              dateTime: DateTime.now(),
                            );
                            todos.add(newTodo);
                            errorText = null;
                          });
                          todoController.clear();
                          todoRepository.saveTodoList(todos);
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.pink.shade300,
                          padding: EdgeInsets.all(14),
                        ),
                        child: Icon(
                          Icons.add,
                          size: 30,
                        )),
                  ],
                ),
                SizedBox(
                  height: 16,
                ),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (Todo todo in todos)
                        TodoListItem(
                          todo: todo,
                          onDelete: onDelete,
                        ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 26,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                          'Você possui ${todos.length} tarefas pendentes!'),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        showDialogConfirm();
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.pink.shade300,
                        padding: EdgeInsets.all(14),
                      ),
                      child: Text('Limpar tudo'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void onDelete(Todo todo) {
    deletedTodo = todo;
    positionDeleted = todos.indexOf(todo);

    setState(() {
      todos.remove(todo);
    });
    todoRepository.saveTodoList(todos);

    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Tarefa ${todo.title} foi removida com sucesso!',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'Desfazer',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              todos.insert(positionDeleted!, deletedTodo!);
            });
            todoRepository.saveTodoList(todos);
          },
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void onDeleteAll() {
    setState(() {
      allDeleted = todos;
      todos.clear();
    });
    todoRepository.saveTodoList(todos);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Todas as tarefas foram removidas com sucesso!',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void showDialogConfirm() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Limpar tudo?'),
        content: Text('Você tem certeza que deseja apagar todas as tarefas?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
                // primary: Colors.white,
                ),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              onDeleteAll();
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              primary: Colors.white,
              backgroundColor: Colors.pinkAccent,
            ),
            child: Text('Limpar'),
          ),
        ],
      ),
    );
  }
}

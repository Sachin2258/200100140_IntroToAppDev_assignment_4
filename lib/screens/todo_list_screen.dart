import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:todo_app_with_flutter_and_firebase/models/todo.dart';
import 'package:todo_app_with_flutter_and_firebase/screens/add_todo.dart';
import 'package:todo_app_with_flutter_and_firebase/screens/login_screen.dart';
import 'package:todo_app_with_flutter_and_firebase/service/auth_service.dart';
import 'package:todo_app_with_flutter_and_firebase/service/todo_service.dart';

class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  int backPressCounter = 0;
  int selectedExpansionTile = -1;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        child: Scaffold(
          appBar: AppBar(
            title: Text("Todo list"),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.login,
                  color: Colors.redAccent,
                ),
                onPressed: () {
                  AuthService.logout();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginScreen(),
                      settings: RouteSettings(name: '/login'),
                    ),
                    (Route<dynamic> route) => false,
                  );
                },
              )
            ],
          ),
          body: getTodoListBody(context),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: Colors.blue,
            label: Text("Add Todo"),
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddTodo(),
                  settings: RouteSettings(name: '/add_todo'),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget getTodoListBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: TodoService().getTodoListOfCurrentUser(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        Widget child;
        if (snapshot.hasError) {
          child = Center(
            child: Text(
              'Something went wrong',
              style: TextStyle(color: Colors.white),
            ),
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          child = Center(
            child: Text(
              "Loading",
              style: TextStyle(color: Colors.white),
            ),
          );
        } else if (snapshot.data.size == 0) {
          child = Center(
            child: Text("No todos added"),
          );
        } else if (snapshot.hasData && snapshot.data.size > 0) {
          child = Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: ListView.builder(
              itemCount: snapshot.data.docs.length,
              itemBuilder: (context, index) {
                Todo todo = Todo.fromJson(snapshot.data.docs[index].data());
                return Slidable(
                  actionPane: SlidableDrawerActionPane(),
                  actionExtentRatio: 0.25,
                  actions: [
                    IconButton(
                        icon: Icon(
                          Icons.delete,
                          size: 35,
                        ),
                        color: Colors.redAccent,
                        onPressed: () => TodoService().deleteByID(todo.uuid),
                        )
                  ],
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child:
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                      SizedBox(
                      height: 20,
                      ),
                      Card(
                        elevation: 10,
                        child: Padding(
                          padding: const EdgeInsets.all(25),
                          child: Text(todo.todoTitle,
                              style: TextStyle(color: Colors.black, fontSize: 20),
                              maxLines: 2,
                          ),
                        ),
                      ),
                    ]
                    ),
                  )
                );
              },
            ),
          );
        }
        return child;
      },
    );
  }
}
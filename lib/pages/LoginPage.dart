// ignore_for_file: file_names

import 'dart:developer';

import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(
              height: 100,
            ),
            TextField(
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(hintText: "input login"),
            ),
            SizedBox(
              height: 20,
            ),
            TextField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(hintText: "input password"),
                obscureText: true),
            SizedBox(
              height: 20,
            ),
            MaterialButton(
                onPressed: () {
                  print("object");
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    width: 400,
                    height: 40,
                    color: Colors.red,
                    child: Center(
                      child: Text(
                        "Login",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

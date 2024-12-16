// ignore_for_file: use_super_parameters, prefer_const_constructors

import 'package:flutter/material.dart';

class CustomListTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color backgroundColor;
  final VoidCallback? onTap;

  const CustomListTile({
    Key? key,
    required this.title,
    this.icon = Icons.arrow_forward,
    this.backgroundColor = Colors.blueGrey, 
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}

class AlertMessage extends StatelessWidget {
  final String title;
  final String message;

  const AlertMessage({
    Key? key,
    required this.title,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Text(message),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green, // Fundo verde
            foregroundColor: Colors.white, // Texto branco
          ),
          onPressed: () {
            Navigator.of(context).pop(); // Fecha o AlertDialog
          },
          child: const Text("OK"),
        ),
      ],
    );
  }
}

class NotFound extends StatelessWidget {
  final String message;

  const NotFound({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        color: Colors.green,
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 100),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

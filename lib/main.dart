import 'package:flutter/material.dart';
import 'package:socket_app/screen/home_screen.dart';

void main() {
  runApp(
    const MaterialApp(
      title: 'SocketApp',
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    ),
  );
}

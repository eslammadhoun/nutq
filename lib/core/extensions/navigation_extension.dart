import 'package:flutter/material.dart';

extension Navigation on BuildContext {
  Future<dynamic> pushNamed(String roueName, {Object? argumants}) {
    return Navigator.of(this).pushNamed(roueName, arguments: argumants);
  }

  Future<dynamic> push(Widget page) {
    return Navigator.of(
      this,
    ).push(MaterialPageRoute(builder: (context) => page));
  }

  void pop() => Navigator.of(this).pop();

  Future<dynamic> pushReplacement(Widget page) {
    return Navigator.of(
      this,
    ).pushReplacement(MaterialPageRoute(builder: (context) => page));
  }

  Future<dynamic> pushReplacementNamed(String routeName, {Object? argumants}) {
    return Navigator.of(
      this,
    ).pushReplacementNamed(routeName, arguments: argumants);
  }

  Future<dynamic> pushNamedAndRemoveUntil(
    String routeName, {
    Object? argumants,
  }) {
    return Navigator.of(this).pushNamedAndRemoveUntil(
      routeName,
      (route) => false,
      arguments: argumants,
    );
  }
}

import "package:flutter/material.dart";

extension ShowSnackbarText on ScaffoldState {
  void showMessageAsSnackBar(String message) {
    final text = Text(message);
    final snackBar = SnackBar(content: text);
    showSnackBar(snackBar);
  }
}

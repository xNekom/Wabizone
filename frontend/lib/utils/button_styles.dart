import 'package:flutter/material.dart';

ButtonStyle estiloBoton() {
  return ElevatedButton.styleFrom(
    backgroundColor: Colors.orange,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );
}

import 'dart:io';
import 'package:flutter/material.dart';
import '../models/usuario.dart';

class UsuarioCard extends StatelessWidget {
  final Usuario user;
  final VoidCallback onEdit;
  final VoidCallback onToggleBlock;
  final VoidCallback onDelete;

  const UsuarioCard({
    super.key,
    required this.user,
    required this.onEdit,
    required this.onToggleBlock,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        leading: user.imagen.isNotEmpty
            ? (user.imagen.startsWith('assets')
                ? Image.asset(user.imagen,
                    width: 40, height: 40, fit: BoxFit.cover)
                : Image.file(File(user.imagen),
                    width: 40, height: 40, fit: BoxFit.cover))
            : (user.esAdmin
                ? Image.asset('assets/imagenes/logo.png', width: 40)
                : const Icon(Icons.person)),
        title: Text(user.usuario),
        subtitle: Text("Edad: ${user.edad} - ${user.lugarNacimiento}"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.orange),
              onPressed: onEdit,
            ),
            IconButton(
              icon: Icon(user.bloqueado ? Icons.lock : Icons.lock_open,
                  color: user.bloqueado ? Colors.red : Colors.green),
              onPressed: onToggleBlock,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

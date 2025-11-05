import 'package:flutter/material.dart';
import '../models/user.dart';

class UserField extends StatelessWidget {
  final User user;

  const UserField({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _buildInfoField(label: "Nome", value: user.name),
        const SizedBox(height: 10),
        _buildInfoField(label: "E-Mail", value: user.email),
        const SizedBox(height: 10),
        _buildInfoField(label: "CPF", value: user.cpf),
      ],
    );
  }

  Widget _buildInfoField({required String label, required String value}) {
    return Container(
      width: 400,
      height: 80,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsetsGeometry.only(left: 10, top: 7),
              child: Text(label, style: TextStyle(fontSize: 21)),
            ),
            Padding(
              padding: EdgeInsetsGeometry.only(left: 10, top: 2.5),
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 17,
                  color: const Color.fromARGB(255, 83, 83, 83),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

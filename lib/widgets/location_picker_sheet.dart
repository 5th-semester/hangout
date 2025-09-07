import 'package:flutter/material.dart';
import '../models/local.dart';

class LocationPickerSheet extends StatelessWidget {
  final List<Local> locals;

  const LocationPickerSheet({super.key, required this.locals});

  @override
  Widget build(BuildContext context) {
    if (locals.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text(
            'Nenhum local encontrado nas proximidades.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: locals.length,
      itemBuilder: (context, index) {
        final local = locals[index];
        return ListTile(
          leading: const Icon(Icons.location_city_outlined),
          title: Text(local.name),
          subtitle: Text(local.description),
          onTap: () {
            Navigator.of(context).pop(local);
          },
        );
      },
    );
  }
}

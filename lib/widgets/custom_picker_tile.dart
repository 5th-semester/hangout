import 'package:flutter/material.dart';

class CustomPickerTile extends StatelessWidget {
  final String label;
  final String valueText;
  final IconData icon;
  final VoidCallback onTap;

  const CustomPickerTile({
    super.key,
    required this.label,
    required this.valueText,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(valueText.isEmpty ? label : valueText),
      trailing: const Icon(Icons.keyboard_arrow_right),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade400),
      ),
    );
  }
}

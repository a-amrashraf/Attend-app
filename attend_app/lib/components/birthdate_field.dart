import 'package:flutter/material.dart';

class BirthdateEntryField extends StatefulWidget {
  @override
  _BirthdateEntryFieldState createState() => _BirthdateEntryFieldState();
}

class _BirthdateEntryFieldState extends State<BirthdateEntryField> {
  TextEditingController _controller = TextEditingController();
  DateTime? _selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = _selectedDate ?? DateTime.now();
    DateTime firstDate = DateTime(1900);
    DateTime lastDate = DateTime.now();

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _controller.text = "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}"; // Format the date
      });
    }
  }
  

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: AbsorbPointer( // Prevents keyboard from showing when tapping on TextField
        child: TextField(
          controller: _controller,
          readOnly: true, // Makes the TextField read-only
          decoration: InputDecoration(
            labelText: 'Birthdate',
            hintText: 'Tap to select your birthdate',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            suffixIcon: Icon(Icons.calendar_today),
          ),
        ),
      ),
    );
  }
}
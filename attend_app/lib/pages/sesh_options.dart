import 'package:flutter/material.dart';

class CustomDropdown extends StatefulWidget {
  final List<String> options;
  final String initialSelection;
  final void Function(String)? onChanged;

  CustomDropdown({
    super.key,
    required this.options,
    required this.initialSelection,
    required this.onChanged,
  });

  @override
  _CustomDropdownState createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  late String _selectedValue;
  final GlobalKey _key = GlobalKey(); // Key for widget positioning

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialSelection;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showDropdownMenu();
      },
      child: Container(
        key: _key, // Attach the GlobalKey here
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _selectedValue,
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            Icon(Icons.arrow_drop_down, color: Colors.black),
          ],
        ),
      ),
    );
  }

  void _showDropdownMenu() async {
    final RenderBox renderBox = _key.currentContext!.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero); // Get position on screen

    final selectedOption = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,  // X position of the widget
        position.dy + renderBox.size.height, // Y position, just below the widget
        position.dx + renderBox.size.width, // X position for the right side of the widget
        position.dy + renderBox.size.height + 200, // Y position for the dropdown height (you can adjust)
      ),
      items: widget.options.map((String value) {
        return PopupMenuItem<String>(
          value: value,
          child: Text(
            value,
            style: TextStyle(color: Colors.black),
          ),
        );
      }).toList(),
      elevation: 8.0,
    );

    if (selectedOption != null) {
      setState(() {
        _selectedValue = selectedOption;
      });
      if (widget.onChanged != null) {
        widget.onChanged!(selectedOption);
      }
    }
  }
}

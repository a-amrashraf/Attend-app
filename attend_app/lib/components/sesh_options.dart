import 'package:flutter/material.dart';

class CustomDropdown extends StatefulWidget {
  final List<String> options;
  final String initialSelection;
  final void Function(String)? onChanged;

  const CustomDropdown({
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
  final GlobalKey _key = GlobalKey();

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialSelection;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showDropdownMenu,
      child: Container(
        key: _key,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "$_selectedValue Sessions",
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.black),
          ],
        ),
      ),
    );
  }

  void _showDropdownMenu() async {
    final RenderBox renderBox = _key.currentContext!.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);

    final selectedOption = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy + renderBox.size.height,
        position.dx + renderBox.size.width,
        position.dy + renderBox.size.height + 200,
      ),
      items: widget.options.map((String value) {
        return PopupMenuItem<String>(
          value: value,
          child: Text(
            "$value Sessions",
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
      elevation: 8.0,
    );

    if (selectedOption != null) {
      setState(() {
        _selectedValue = selectedOption;
      });
      widget.onChanged?.call(selectedOption);
    }
  }
}

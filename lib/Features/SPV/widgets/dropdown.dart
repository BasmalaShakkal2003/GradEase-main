import 'package:flutter/material.dart';

class CustomDropdownField extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;
  final double scaleFactor;
  final GlobalKey _dropdownKey = GlobalKey();

  CustomDropdownField({
    Key? key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.scaleFactor = 1.0,
  }) : super(key: key);

  void _showCustomDropdown(BuildContext context) {
    final RenderBox? renderBox = _dropdownKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final mediaQuery = MediaQuery.of(context);
    final position = renderBox.localToGlobal(Offset.zero);
    final screenHeight = mediaQuery.size.height;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      barrierLabel: 'Dismiss dropdown',
      pageBuilder: (context, _, __) {
        return Stack(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              behavior: HitTestBehavior.translucent,
            ),
            Positioned(
              top: position.dy + renderBox.size.height + 8 * scaleFactor,
              left: position.dx,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: renderBox.size.width,
                  constraints: BoxConstraints(
                    maxHeight: screenHeight * 0.3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 214, 211, 211),
                    borderRadius: BorderRadius.circular(10 * scaleFactor),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 2 * scaleFactor,
                        blurRadius: 8 * scaleFactor,
                        offset: const Offset(0, 4),),
                    ],
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    itemCount: items.length,
                    padding: EdgeInsets.symmetric(vertical: 8 * scaleFactor),
                    separatorBuilder: (_, __) => Divider(
                      color: Colors.black26,
                      height: 1 * scaleFactor,
                    ),
                    itemBuilder: (_, index) {
                      final item = items[index];
                      return GestureDetector(
                        onTap: () {
                          onChanged(item);
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16 * scaleFactor,
                            vertical: 12 * scaleFactor,
                          ),
                          child: Text(
                            item,
                            style: TextStyle(
                              fontSize: 16 * scaleFactor,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF041C40),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20 * scaleFactor,
            color: const Color(0xFF041C40),
          ),
        ),
        SizedBox(height: 5 * scaleFactor),
        GestureDetector(
          key: _dropdownKey,
          onTap: () => _showCustomDropdown(context),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 12 * scaleFactor,
              vertical: 16 * scaleFactor,
            ),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 214, 211, 211),
              borderRadius: BorderRadius.circular(10 * scaleFactor),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(255, 137, 136, 136)
                      .withOpacity(0.3),
                  spreadRadius: 2 * scaleFactor,
                  blurRadius: 8 * scaleFactor,
                  offset: const Offset(0, 4),),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: const Color(0xFF041C40),
                    fontSize: 18 * scaleFactor,
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: const Color(0xFF041C40),
                  size: 24 * scaleFactor,
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 10 * scaleFactor),
      ],
    );
  }
}
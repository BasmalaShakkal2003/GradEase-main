import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthPicker extends StatefulWidget {
  final DateTime selectedDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTime> onChanged;

  const MonthPicker({
    Key? key,
    required this.selectedDate,
    required this.firstDate,
    required this.lastDate,
    required this.onChanged,
  }) : super(key: key);

  @override
  _MonthPickerState createState() => _MonthPickerState();
}

class _MonthPickerState extends State<MonthPicker> {
  late DateTime _currentDate;

  @override
  void initState() {
    super.initState();
    _currentDate = widget.selectedDate;
  } 

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Month/year header
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  if (_canGoToPreviousMonth()) {
                    setState(() {
                      _currentDate = DateTime(
                          _currentDate.year, _currentDate.month - 1);
                    });
                  }
                },
              ),
              Text(
                DateFormat('MMM yyyy').format(_currentDate),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  if (_canGoToNextMonth()) {
                    setState(() {
                      _currentDate = DateTime(
                          _currentDate.year, _currentDate.month + 1);
                    });
                  }
                },
              ),
            ],
          ),
        ),
        
        // Weekday headers
         Row(
          children: [
            SizedBox(width: 8),
            ...['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa']
                .map((day) => Expanded(
                      child: Center(
                        child: Text(
                          day,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                    ))
                .toList(),
            SizedBox(width: 8),
          ],
        ),
        
        // Days grid
        _buildCalendarGrid(),
      ],
    );
  }

  bool _canGoToPreviousMonth() {
    return DateTime(_currentDate.year, _currentDate.month - 1)
        .isAfter(widget.firstDate) ||
        DateTime(_currentDate.year, _currentDate.month - 1)
            .isAtSameMomentAs(widget.firstDate);
  }

  bool _canGoToNextMonth() {
    return DateTime(_currentDate.year, _currentDate.month + 1)
        .isBefore(widget.lastDate) ||
        DateTime(_currentDate.year, _currentDate.month + 1)
            .isAtSameMomentAs(widget.lastDate);
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(_currentDate.year, _currentDate.month, 1);
    final daysInMonth = DateTime(_currentDate.year, _currentDate.month + 1, 0)
        .day;
    final startingWeekday = firstDayOfMonth.weekday % 7;  

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.0,
      ),
      itemCount: 42, // 6 weeks to ensure full month display
      itemBuilder: (context, index) {
        final day = index - startingWeekday + 1;
        
        if (day < 1 || day > daysInMonth) {
          return const SizedBox.shrink();
        }
        
        final date = DateTime(_currentDate.year, _currentDate.month, day);
        final isSelected = date.year == widget.selectedDate.year &&
            date.month == widget.selectedDate.month &&
            date.day == widget.selectedDate.day;
        
        return GestureDetector(
          onTap: () {
            widget.onChanged(date);
          },
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF041C40) : null,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$day',
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ResponsiveCalendar extends StatelessWidget {
  final Size screenSize;
  const ResponsiveCalendar({super.key, required this.screenSize});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: screenSize.height * 0.01),
      padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.03),
      alignment: Alignment.centerLeft,
      child: Container(
        width: screenSize.width * 0.52,
        height: screenSize.height * 0.06,
        padding: EdgeInsets.symmetric(
          horizontal: screenSize.width * 0.01,
          vertical: screenSize.height * 0.005,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF011226),
          borderRadius: BorderRadius.circular(screenSize.width * 0.06),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: Colors.white,
                    size: screenSize.width * 0.06,
                  ),
                  SizedBox(width: screenSize.width * 0.02),
                  Expanded(
                    child: Text(
                      DateFormat('E, d MMM').format(DateTime.now()),
                      style: TextStyle(
                        fontSize: screenSize.width * 0.04,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: screenSize.width * 0.09),
            Container(
              width: screenSize.width * 0.1,
              height: screenSize.width * 0.1,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(screenSize.width * 0.04),
              ),
              child: Center(
                child: Text(
                  DateTime.now().year.toString(),
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: screenSize.width * 0.04,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

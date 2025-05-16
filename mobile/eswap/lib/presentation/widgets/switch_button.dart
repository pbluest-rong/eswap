import 'package:flutter/material.dart';

class SwitchButton extends StatefulWidget {
  final String onLabel;
  final String offLabel;
  final Function(bool) onChanged;

  const SwitchButton({
    super.key,
    required this.onLabel,
    required this.offLabel,
    required this.onChanged,
  });

  @override
  _SwitchButtonState createState() => _SwitchButtonState();
}

class _SwitchButtonState extends State<SwitchButton> {
  bool isSwitched = true;

  void _handleSwitch(bool value) {
    setState(() {
      isSwitched = value;
    });
    widget.onChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 500),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: isSwitched ? Colors.green[200] : Colors.blue[200],
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(2, 4),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  isSwitched ? Icons.recommend : Icons.remove_circle_outlined,
                  color: Colors.white,
                  size: 30,
                ),
                SizedBox(width: 10),
                Text(
                  isSwitched ? widget.onLabel : widget.offLabel,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(width: 10),
            Switch(
              value: isSwitched,
              onChanged: _handleSwitch,
              activeColor: Colors.white,
              activeTrackColor: Colors.green,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }
}

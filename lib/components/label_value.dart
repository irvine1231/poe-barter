import 'package:flutter/material.dart';

class LabelValue extends StatelessWidget {
  const LabelValue({
    super.key,
    required this.label,
    this.value = "",
    this.valueWidget,
    this.valueExtendWidth = false,
  });

  final String label;
  final String value;
  final Widget? valueWidget;
  final bool valueExtendWidth;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(
            label.isNotEmpty ? "$label:" : "",
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        if (valueWidget != null)
          SizedBox(
            width: valueExtendWidth ? 320 : 120,
            child: valueWidget!,
          )
        else
          SizedBox(
            width: valueExtendWidth ? 320 : 120,
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }
}

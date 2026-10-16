import 'package:flutter/material.dart';

/// A consistent section heading with an optional, accessible trailing action.
class SkillLoopSectionTitle extends StatelessWidget {
  const SkillLoopSectionTitle({
    super.key,
    required this.title,
    required this.titleStyle,
    this.actionLabel,
    this.actionStyle,
    this.onAction,
    this.trailingPadding = 0,
  });

  final String title;
  final TextStyle titleStyle;
  final String? actionLabel;
  final TextStyle? actionStyle;
  final VoidCallback? onAction;
  final double trailingPadding;

  @override
  Widget build(BuildContext context) {
    final showAction = actionLabel != null && onAction != null;
    return Padding(
      padding: EdgeInsets.only(right: trailingPadding),
      child: Row(
        children: [
          Expanded(child: Text(title, style: titleStyle)),
          if (showAction)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                minimumSize: Size.zero,
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(actionLabel!, style: actionStyle),
            ),
        ],
      ),
    );
  }
}

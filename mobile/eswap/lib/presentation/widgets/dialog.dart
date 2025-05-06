import 'package:easy_localization/easy_localization.dart';
import 'package:eswap/core/theme/themeTest.dart';
import 'package:flutter/material.dart';

void showErrorDialog(BuildContext context, String message) {
  AppAlert.show(
    context: context,
    title: message,
    buttonLayout: AlertButtonLayout.single,
    actions: [AlertAction(text: 'OK', handler: () {})],
  );
}

void showErrorSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.red,
    ),
  );
}

enum AlertButtonLayout {
  single, // Single button
  dual, // Two buttons
  triple, // Three buttons
  stacked, // Vertical buttons
}

enum AlertStyle {
  basic, // Simple text
  emphasized, // Highlighted title
  bordered, // With border
  filled, // Background color
  icon, // With icon
}

class AlertAction {
  final String text;
  final VoidCallback? handler;
  final bool isDestructive;

  AlertAction({
    required this.text,
    this.handler,
    this.isDestructive = false,
  });
}

class AppAlert {
  static void show({
    Widget? centerWidget,
    required BuildContext context,
    required String title,
    String? description,
    AlertStyle style = AlertStyle.basic,
    AlertButtonLayout buttonLayout = AlertButtonLayout.dual,
    List<AlertAction> actions = const [],
    Color? primaryColor,
    Widget? icon,
    bool dismissible = true,
    double borderRadius = 12.0,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
  }) {
    final brightness = Theme.of(context).brightness;
    final isDarkMode = brightness == Brightness.dark;

    // Colors adapt to theme
    final fbBlue = primaryColor ?? const Color(0xFF1877F2);
    final fbGrey =
        isDarkMode ? const Color(0xFF242526) : const Color(0xFFF0F2F5);
    final fbTextGrey =
        isDarkMode ? const Color(0xFFB0B3B8) : const Color(0xFF65676B);
    final fbDarkGrey =
        isDarkMode ? const Color(0xFF3E4042) : const Color(0xFFD8DADF);
    final bgColor = isDarkMode ? const Color(0xFF242526) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    showDialog(
      context: context,
      barrierDismissible: dismissible,
      builder: (context) {
        return PopScope(
          canPop: dismissible,
          child: Dialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            backgroundColor: bgColor,
            elevation: isDarkMode ? 4.0 : 0.0,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              padding: padding,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with optional icon
                  if (style == AlertStyle.icon && icon != null)
                    Center(child: icon),

                  if (style == AlertStyle.icon && icon != null)
                    const SizedBox(height: 16),

                  // Title
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: style == AlertStyle.emphasized
                            ? FontWeight.bold
                            : FontWeight.w600,
                        color:
                            style == AlertStyle.emphasized ? fbBlue : textColor,
                      ),
                    ),
                  ),

                  // Description
                  if (description != null) ...[
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        description,
                        style: TextStyle(
                          fontSize: 15,
                          color: fbTextGrey,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                  Container(child: centerWidget),
                  // Buttons area
                  const SizedBox(height: 20),
                  _buildButtons(
                    context: context,
                    layout: buttonLayout,
                    actions: actions,
                    fbBlue: fbBlue,
                    fbGrey: fbGrey,
                    fbDarkGrey: fbDarkGrey,
                    isDarkMode: isDarkMode,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget _buildButtons({
    required BuildContext context,
    required AlertButtonLayout layout,
    required List<AlertAction> actions,
    required Color fbBlue,
    required Color fbGrey,
    required Color fbDarkGrey,
    required bool isDarkMode,
  }) {
    final buttonStyle = (bool isPrimary, bool isDestructive) {
      return TextButton.styleFrom(
        foregroundColor: isDestructive
            ? Colors.red
            : isPrimary
                ? fbBlue
                : isDarkMode
                    ? Colors.white
                    : Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ),
      );
    };

    switch (layout) {
      case AlertButtonLayout.single:
        return Container(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: fbDarkGrey, width: 0.5)),
          ),
          padding: const EdgeInsets.only(top: 8),
          child: SizedBox(
            width: double.infinity,
            child: TextButton(
              style: buttonStyle(true, false),
              onPressed: () {
                Navigator.of(context).pop();
                actions.first.handler?.call();
              },
              child: Text(
                actions.first.text,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      case AlertButtonLayout.dual:
        return Container(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: fbDarkGrey, width: 0.5)),
          ),
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              if (actions.length > 1)
                Expanded(
                  child: TextButton(
                    style: buttonStyle(false, actions[0].isDestructive),
                    onPressed: () {
                      Navigator.of(context).pop();
                      actions[0].handler?.call();
                    },
                    child: Text(
                      actions[0].text,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              if (actions.length > 1)
                Container(
                  width: 1,
                  height: 40,
                  color: fbDarkGrey,
                ),
              Expanded(
                child: TextButton(
                  style: buttonStyle(true,
                      actions.length > 1 ? actions[1].isDestructive : false),
                  onPressed: () {
                    Navigator.of(context).pop();
                    actions.length > 1
                        ? actions[1].handler?.call()
                        : actions[0].handler?.call();
                  },
                  child: Text(
                    actions.length > 1 ? actions[1].text : actions[0].text,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      case AlertButtonLayout.triple:
        return Container(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: fbDarkGrey, width: 0.5)),
          ),
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              if (actions.length > 2)
                Expanded(
                  child: TextButton(
                    style: buttonStyle(false, false),
                    onPressed: () {
                      Navigator.of(context).pop();
                      actions[0].handler?.call();
                    },
                    child: Text(
                      actions[0].text,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              if (actions.length > 2)
                Container(
                  width: 1,
                  height: 40,
                  color: fbDarkGrey,
                ),
              if (actions.length > 1)
                Expanded(
                  child: TextButton(
                    style: buttonStyle(false, false),
                    onPressed: () {
                      Navigator.of(context).pop();
                      actions[1].handler?.call();
                    },
                    child: Text(
                      actions[1].text,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              if (actions.length > 1)
                Container(
                  width: 1,
                  height: 40,
                  color: fbDarkGrey,
                ),
              Expanded(
                child: TextButton(
                  style: buttonStyle(true, false),
                  onPressed: () {
                    Navigator.of(context).pop();
                    actions.last.handler?.call();
                  },
                  child: Text(
                    actions.last.text,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      case AlertButtonLayout.stacked:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < actions.length; i++) ...[
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  style: buttonStyle(
                      i == actions.length - 1, actions[i].isDestructive),
                  onPressed: () {
                    Navigator.of(context).pop();
                    actions[i].handler?.call();
                  },
                  child: Text(
                    actions[i].text,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: i == actions.length - 1
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ),
              if (i < actions.length - 1)
                Divider(height: 1, color: fbDarkGrey, thickness: 0.5),
            ],
          ],
        );
    }
  }
}

class TestAlert extends StatelessWidget {
  const TestAlert({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Facebook Style Alerts'),
        backgroundColor: const Color(0xFF1877F2),
      ),
      body: SafeArea(
          child: Center(
              child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ThemeTest()));
              },
              child: Text("set theme")),
          TextButton(
              onPressed: () {
                AppAlert.show(
                  context: context,
                  title: 'Title Here',
                  buttonLayout: AlertButtonLayout.single,
                  actions: [AlertAction(text: 'OK', handler: () {})],
                );
              },
              child: const Text("Simple alert with title and single button")),
          TextButton(
              onPressed: () {
                AppAlert.show(
                  context: context,
                  title: 'Title Here',
                  description: 'Alert description with auto layout!',
                  buttonLayout: AlertButtonLayout.single,
                  actions: [AlertAction(text: 'Action', handler: () {})],
                );
              },
              child: const Text("Alert with description and single button")),
          TextButton(
              onPressed: () {
                AppAlert.show(
                  context: context,
                  title: 'Title Here',
                  buttonLayout: AlertButtonLayout.dual,
                  actions: [
                    AlertAction(text: 'Cancel', handler: () {}),
                    AlertAction(text: 'Confirm', handler: () {}),
                  ],
                );
              },
              child: const Text("Alert with two buttons")),
          TextButton(
              onPressed: () {
                AppAlert.show(
                  context: context,
                  title: 'Title Here',
                  description: 'Alert description with auto layout!',
                  buttonLayout: AlertButtonLayout.dual,
                  actions: [
                    AlertAction(text: 'Cancel', handler: () {}),
                    AlertAction(text: 'Confirm', handler: () {}),
                  ],
                );
              },
              child: const Text("Alert with description and two buttons")),
          TextButton(
              onPressed: () {
                AppAlert.show(
                  context: context,
                  title: 'Delete item?',
                  description: 'This action cannot be undone',
                  actions: [
                    AlertAction(text: 'Cancel', handler: () {}),
                    AlertAction(
                        text: 'Delete', isDestructive: true, handler: () {}),
                  ],
                );
              },
              child: const Text("Destructive action alert")),
          TextButton(
              onPressed: () {
                AppAlert.show(
                  context: context,
                  title: 'Title Here',
                  buttonLayout: AlertButtonLayout.stacked,
                  actions: [
                    AlertAction(text: 'First Action', handler: () {}),
                    AlertAction(text: 'Second Action', handler: () {}),
                    AlertAction(text: 'Third Action', handler: () {}),
                  ],
                );
              },
              child: const Text("Stacked (vertical) buttons")),
        ],
      ))),
    );
  }
}

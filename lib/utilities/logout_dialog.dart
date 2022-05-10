import 'package:flutter/material.dart';
import 'package:meranotes/constants/messages.dart';
import 'package:meranotes/utilities/generic_dialog.dart';

Future<bool> showLogoutDialog(
  BuildContext context,
) {
  return showGenericDialog(
    context: context,
    title: logoutButtonText,
    content: confirmLogoutMessage,
    optionsBuilder: () => {
      'Cancel': false,
      'Logout': true,
    },
  ).then(
    (value) => value ?? false,
  );
}

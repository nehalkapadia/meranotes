import 'package:flutter/material.dart';
import 'package:meranotes/extenions/buildcontext/loc.dart';
import 'package:meranotes/utilities/dialog/generic_dialog.dart';

Future<void> showPasswordResetSentDialog(BuildContext context) {
  return showGenericDialog<void>(
    context: context,
    title: context.loc.password_reset,
    content: context.loc.password_reset_dialog_prompt,
    optionsBuilder: () => {
      context.loc.ok: null,
    },
  );
}

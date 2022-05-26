import 'package:flutter/material.dart';
import 'package:meranotes/extenions/buildcontext/loc.dart';
import 'package:meranotes/utilities/dialog/generic_dialog.dart';

Future<bool> showDeleteDialog(
  BuildContext context,
) {
  return showGenericDialog(
    context: context,
    title: context.loc.delete,
    content: context.loc.delete_note_prompt,
    optionsBuilder: () => {
      context.loc.cancel: false,
      context.loc.yes: true,
    },
  ).then(
    (value) => value ?? false,
  );
}

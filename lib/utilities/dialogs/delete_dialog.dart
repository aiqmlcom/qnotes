import 'package:flutter/cupertino.dart';
import 'package:qnotes/extensions/list/buildcontext/loc.dart';
import 'package:qnotes/utilities/dialogs/generic_dialog.dart';

Future<bool> showDeleteDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: context.loc.delete,
    content: context.loc.delete_note_prompt,
    optionBuilder: () => {
      context.loc.cancel: false,
      context.loc.ok: true,
    },
  ).then((value) => value ?? false);
}

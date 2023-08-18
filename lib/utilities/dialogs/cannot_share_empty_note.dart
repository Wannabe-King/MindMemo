import 'package:flutter/material.dart';
import 'package:learning/utilities/dialogs/generic_dialog.dart';

Future<void> showCannotShareEmptyNoteDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: 'Sharing',
    content: 'You Cannot Share Empty Note!',
    optionsBuilder: () => {
      'OK': null,
    },
  );
}

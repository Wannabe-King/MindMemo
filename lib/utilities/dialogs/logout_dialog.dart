import 'package:flutter/material.dart';
import 'package:learning/utilities/dialogs/generic_dialog.dart';

Future<bool> showLogOutDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: "Log Out",
    content: 'Are you sure you want to logout?',
    optionsBuilder: () => {
      'Cancle': false,
      'Logout': true,
    },
  ).then(
    (value) => value ?? false,
  );
}

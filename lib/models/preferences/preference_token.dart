import 'package:flutter/material.dart';
import 'package:flutter_hole/models/api.dart';
import 'package:flutter_hole/models/app_state.dart';
import 'package:flutter_hole/models/preferences/preference.dart';
import 'package:fluttertoast/fluttertoast.dart';

/// A [Preference] for storing the Pi-hole® API token.
class PreferenceToken extends Preference {
  PreferenceToken()
      : super(
            key: 'token',
            title: 'API token',
      description: 'Enabling/disabling Pi-hole',
      help: RichText(
        text: TextSpan(
            style: Preference.helpStyle,
            text:
            'To enable and disable Pi-hole® from your device, you need to request an API token. \n\nIn a browser, visit the token generator (usually the \'Show API token \' button at ',
            children: [
              Api.hyperLink('http://pi.hole/admin/settings.php?tab=api'),
              TextSpan(
                  text:
                  ') and either select the \'Scan QR code\' button during editing, or copy it manually.\n\nNote that the token is stored on your device storage, and is not sent outside your device\'s network.')
            ]),
      ),
      iconData: Icons.vpn_key,
      onSet: (bool didSet, BuildContext context) {
        AppState.of(context).updateAuthorized().then((bool isAuthorized) {
          String msg = isAuthorized
              ? 'Authorization succesful'
              : 'Cannot authorize - is your API token correct?';
          Fluttertoast.instance.showToast(msg: msg);
        });
      },
      addScanButton: true);
}
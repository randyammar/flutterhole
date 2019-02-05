import 'dart:async';
import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hole/models/preferences/preference_hostname.dart';
import 'package:flutter_hole/models/preferences/preference_port.dart';
import 'package:flutter_hole/models/preferences/preference_token.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

/// The relative path to the Pi-hole® API
const String apiPath = 'admin/api.php';

/// The timeout duration for API requests.
const Duration timeout = Duration(seconds: 2);

/// A convenient wrapper for the Pi-hole® PHP API.
class Api {
  /// Returns a bool depending on the Pi-hole® status string
  static _statusToBool(dynamic json) {
    switch (json['status']) {
      case 'enabled':
        return true;
      case 'disabled':
        return false;
      default:
        throw Exception('invalid status response');
    }
  }

  /// Returns the domain based on the [PreferenceHostname] and [PreferencePort].
  static _domain() async {
    final String hostname = await PreferenceHostname().get();
    String port = await PreferencePort().get();
    if (port == '80') {
      port = '';
    } else {
      port = ':' + port;
    }

    return 'http://' + hostname + port + '/' + apiPath;
  }

  /// Returns the result of an API request based on the [params]. Set [authorization] to true when performing administrative tasks.
  ///
  /// Throws an [Exception] if the request times out.
  ///
  /// ```dart
  /// Api.fetch('summaryRaw')
  /// Api.fetch('enabled', authorization: true)
  /// ```
  static Future<http.Response> fetch(String params,
      {bool authorization = false}) async {
    if (authorization) {
      String _token = await PreferenceToken().get();
      params = params + '&auth=$_token';
    }
    String _uriString = (await _domain()) + '?' + params;
    final _result = await http.get(_uriString).timeout(timeout,
        onTimeout: () =>
        throw Exception(
            'Request timed out after ${timeout.inSeconds
                .toString()} seconds - is your port correct?'));
    return _result;
  }

  /// Returns true if the Pi-hole® is enabled, or false when disabled.
  ///
  /// Throws an [Exception] when the request fails.
  static Future<bool> fetchEnabled() async {
    http.Response response;
    try {
      response = await fetch('status');
    } catch (e) {
      print('fetchStatus: _fetch exception');
      rethrow;
    }
    if (response.statusCode == 200) {
      final bool status = _statusToBool(json.decode(response.body));
      return status;
    } else {
      throw Exception('Failed to fetch status');
    }
  }

  /// Sets the status of the Pi-hole® to 'enabled' or 'disabled' based on [newStatus].
  ///
  /// Returns the new status after performing the request.
  ///
  /// Shows a toast when any request fails.
  static Future<bool> setStatus(bool newStatus) async {
    final String activity = newStatus ? 'enable' : 'disable';
    http.Response response;
    try {
      response = await fetch(activity, authorization: true);
    } catch (e) {
      Fluttertoast.instance.showToast(msg: 'Cannot connect to your Pi-hole');
      return false;
    }
    if (response.statusCode == 200 && response.contentLength > 2) {
      final bool status = _statusToBool(json.decode(response.body));
      return status;
    } else {
      Fluttertoast.instance.showToast(msg: 'Cannot $activity Pi-hole');
      return false;
    }
  }

  /// Returns true if the request is authorized, or false when unauthorized.
  static Future<bool> isAuthorized() async {
    http.Response response;
    try {
      response = await fetch('topItems', authorization: true);
    } catch (e) {
      print('isAuthorized: _fetch exception');
      rethrow;
    }
    if (response.statusCode == 200 && response.contentLength > 2) {
      return true;
    }

    return false;
  }

  /// Returns the summary of the Pi-hole.
  ///
  /// Throws an [Exception when the request fails.
  static Future<Map<String, String>> fetchSummary() async {
    const Map<String, String> _prettySummary = {
      'dns_queries_today': 'Total Queries',
      'ads_blocked_today': 'Queries Blocked',
      'ads_percentage_today': 'Percent Blocked',
      'domains_being_blocked': 'Domains on Blocklist',
    };

    http.Response response;

    try {
      response = await fetch('summary');
    } catch (e) {
      print('fetchSummary: _fetch exception');
      rethrow;
    }

    if (response.statusCode == 200) {
      Map<String, dynamic> map = jsonDecode(response.body);
      Map<String, String> finalMap = {};
      if (map.isNotEmpty) {
        _prettySummary.forEach((String oldKey, String newKey) {
          if (newKey.contains('Percent')) {
            map[oldKey] += '%';
          }
          finalMap[newKey] = map[oldKey];
        });
        return finalMap;
      }
    } else {
      throw Exception(
          'Failed to fetch summary data, status code: ${response.statusCode}');
    }

    throw Exception('Failed to fetch summary');
  }

  /// Returns the most recently blocked domain.
  ///
  /// The PHP API is limited to only the single most recently blocked domain, so unfortunately batching is not possible without frequently sending the same request.
  ///
  /// Throws an [Exception] when the request fails.
  static Future<String> recentlyBlocked() async {
    http.Response response;
    try {
      response = await fetch('recentBlocked', authorization: false);
    } catch (e) {
      rethrow;
    }

    return response.body;
  }

  /// Launches the [url] in the default browser.
  ///
  /// Shows a toast if the url can not be launched.
  static void launchURL(String url) async {
    try {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        Fluttertoast.instance.showToast(msg: 'URL could not be launched');
      }
    } catch (e) {
      Fluttertoast.instance.showToast(msg: 'URL could not be launched');
    }
  }

  /// Returns a widget with a hyperlink that can be tapped to launch using [launchURL].
  static TextSpan hyperLink(String urlString) {
    return TextSpan(
        text: urlString,
        style: TextStyle(
          color: Colors.blue,
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () => Api.launchURL(urlString));
  }
}

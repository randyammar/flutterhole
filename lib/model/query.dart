// For example queries, see https://github.com/pi-hole/AdminLTE/blob/44aff727e59d129e6201341caa1d74c8b2954bd2/scripts/pi-hole/js/queries.js.

import 'package:equatable/equatable.dart';

enum QueryType {
  A,
  AAAA,
  ANY,
  SRV,
  SOA,
  PTR,
  TXT,
  UNKN,
}

enum QueryStatus {
  BlockedWithGravity,
  Forwarded,
  Cached,
  BlockedWithRegexWildcard,
  BlockedWithBlacklist,
  BlockedWithExternalIP,
  BlockedWithExternalNull,
  BlockedWithExternalNXRA,
  Unknown,
}

enum DnsSecStatus {
  Secure,
  Insecure,
  Bogus,
  Abandoned,
  Unknown,
  Empty,
}

class Query extends Equatable {
  final DateTime time;
  final QueryType queryType;
  final String entry;
  final String client;
  final QueryStatus queryStatus;
  final DnsSecStatus dnsSecStatus;

  Query(List<dynamic> json)
      : time = DateTime.fromMillisecondsSinceEpoch(int.parse(json[0] + '000')),
        queryType = _stringToQueryType(json[1]),
        entry = json[2],
        client = json[3],
        queryStatus = _stringToQueryStatus(json[4]),
        dnsSecStatus = _stringToDnsSecStatus(json[5]);

  // https://github.com/pi-hole/AdminLTE/blob/44aff727e59d129e6201341caa1d74c8b2954bd2/scripts/pi-hole/js/queries.js#L158
  static DnsSecStatus _stringToDnsSecStatus(String json) {
    final int index = int.parse(json);

    if (index > DnsSecStatus.values.length || index == 0)
      return DnsSecStatus.values.last;

    return DnsSecStatus.values[index - 1];
  }

  static QueryType _stringToQueryType(String json) {
    for (QueryType type in QueryType.values) {
      if (type.toString().contains(json)) return type;
    }

    return QueryType.values.last;
  }

  // https://github.com/pi-hole/AdminLTE/blob/44aff727e59d129e6201341caa1d74c8b2954bd2/scripts/pi-hole/js/queries.js#L181
  static QueryStatus _stringToQueryStatus(String json) {
    final int index = int.parse(json);

    if (index > QueryStatus.values.length || index == 0)
      return QueryStatus.values.last;

    return QueryStatus.values[index - 1];
  }
}
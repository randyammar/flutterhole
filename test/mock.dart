import 'package:flutterhole/model/api/blacklist.dart';
import 'package:flutterhole/model/api/forward_destinations.dart';
import 'package:flutterhole/model/api/queries_over_time.dart';
import 'package:flutterhole/model/api/query.dart';
import 'package:flutterhole/model/api/status.dart';
import 'package:flutterhole/model/api/summary.dart';
import 'package:flutterhole/model/api/top_items.dart';
import 'package:flutterhole/model/api/top_sources.dart';
import 'package:flutterhole/model/api/versions.dart';
import 'package:flutterhole/model/api/whitelist.dart';
import 'package:flutterhole/model/pihole.dart';
import 'package:flutterhole/service/pihole_client.dart';
import 'package:flutterhole/service/secure_store.dart';
import 'package:mockito/mockito.dart';

final mockPiholes = [
  Pihole(),
  Pihole(title: 'second', host: '2.com'),
  Pihole(title: 'third', host: '3.net'),
];

class MockPiholeClient extends Mock implements PiholeClient {}

class MockSecureStore extends Mock implements SecureStore {
  @override
  Pihole active;

  @override
  Map<String, Pihole> piholes;
}

final mockStatusEnabled = Status(enabled: true);
final mockStatusDisabled = Status(enabled: false);

final mockWhitelist = Whitelist(['a.com', 'b.org', 'c.net']);
final mockBlacklist = Blacklist(exact: [
  BlacklistItem.exact(entry: 'exact.com'),
  BlacklistItem.exact(entry: 'pi-hole.net'),
], wildcard: [
  BlacklistItem.wildcard(entry: '${wildcardPrefix}wildcard.com$wildcardSuffix'),
  BlacklistItem.regex(entry: 'regex'),
]);

final mockSummary = Summary(
    domainsBeingBlocked: 0,
    dnsQueriesToday: 1,
    adsBlockedToday: 2,
    adsPercentageToday: 2.345,
    uniqueDomains: 3,
    queriesForwarded: 4,
    queriesCached: 5,
    clientsEverSeen: 6,
    uniqueClients: 7,
    dnsQueriesAllTypes: 8,
    replyNodata: 9,
    replyNxdomain: 10,
    replyCname: 11,
    replyIp: 12,
    privacyLevel: 13,
    status: 'enabled',
    gravityLastUpdated: GravityLastUpdated(
        fileExists: true,
        absolute: 14,
        relative: Relative(days: '15', hours: '16', minutes: '17')));

final TopSources mockTopSources = TopSources({
  '10.0.1.1': 55,
  '10.0.1.2': 42,
  'windows|10.0.1.3': 33,
  'osx|10.0.1.4': 24,
});

final Versions mockVersions = Versions(
    coreUpdate: true,
    webUpdate: false,
    ftlUpdate: false,
    coreCurrent: 'v1.2.3',
    webCurrent: 'v1.2.3',
    ftlCurrent: 'v1.2.6',
    coreLatest: "",
    webLatest: "",
    ftlLatest: "",
    coreBranch: 'master',
    webBranch: 'master',
    ftlBranch: 'master');

final QueryTypes mockQueryTypes = QueryTypes({
  "A (IPv4)": 58.46,
  "AAAA (IPv6)": 10.12,
  "ANY": 10.50,
  "SRV": 0.45,
  "SOA": 9.50,
  "PTR": 2.97,
  "TXT": 8.0,
});

final TopItems mockTopItems = TopItems(
  topQueries: {
    "a.com": 1,
    "b.org": 2,
    "c.net": 3,
  },
  topAds: {
    "ad1.com": 1,
    "ad2.org": 2,
    "ad3.net": 3,
  },
);

final ForwardDestinations mockForwardDestinations = ForwardDestinations({
  "blocklist|blocklist": 9.7,
  "cache|cache": 14.37,
  "dns.google|8.8.4.4": 40.41,
  "dns.google|8.8.8.8": 35.53
});

final List<Query> mockQueries = [
  Query(
      time: DateTime.fromMillisecondsSinceEpoch(1563995000000),
      queryType: QueryType.A,
      entry: 'test.com',
      client: 'localhost',
      queryStatus: QueryStatus.Cached,
      dnsSecStatus: DnsSecStatus.Secure),
  Query(
      time: DateTime(1),
      queryType: QueryType.PTR,
      entry: 'example.org',
      client: 'remotehost',
      queryStatus: QueryStatus.Unknown,
      dnsSecStatus: DnsSecStatus.Abandoned),
];

final mockQueriesOverTime = QueriesOverTime(adsOverTime: {
  '1563991500000': 1,
  '1563992100000': 0,
  '1563992700000': 1,
  '1563993300000': 2,
  '1563993900000': 0,
  '1563994500000': 0,
  '1563995100000': 0,
  '1563995700000': 0,
  '1563996300000': 0,
  '1563996900000': 0,
  '1563997500000': 2,
  '1563998100000': 9,
  '1563998700000': 17,
  '1563999300000': 1,
  '1563999900000': 17,
  '1564000500000': 6,
  '1564001100000': 13,
  '1564001700000': 6,
  '1564002300000': 23,
  '1564002900000': 16,
  '1564003500000': 11,
  '1564004100000': 11,
  '1564004700000': 6,
  '1564005300000': 2,
  '1564005900000': 0,
  '1564006500000': 0,
  '1564007100000': 0,
  '1564007700000': 0,
  '1564008300000': 3,
  '1564008900000': 20,
  '1564009500000': 20,
  '1564010100000': 27,
  '1564010700000': 25,
  '1564011300000': 46,
  '1564011900000': 33,
  '1564012500000': 16,
  '1564013100000': 10,
  '1564013700000': 14,
  '1564014300000': 15,
  '1564014900000': 4,
  '1564015500000': 4,
  '1564016100000': 3,
  '1564016700000': 5,
  '1564017300000': 0,
  '1564017900000': 0,
  '1564018500000': 13,
  '1564019100000': 1,
  '1564019700000': 0,
  '1564020300000': 1,
  '1564020900000': 0,
  '1564021500000': 0,
  '1564022100000': 0,
  '1564022700000': 0,
  '1564023300000': 0,
  '1564023900000': 0,
  '1564024500000': 0,
  '1564025100000': 0,
  '1564025700000': 0,
  '1564026300000': 0,
  '1564026900000': 6,
  '1564027500000': 0,
  '1564028100000': 1,
  '1564028700000': 0,
  '1564029300000': 0,
  '1564029900000': 1,
  '1564030500000': 2,
  '1564031100000': 2,
  '1564031700000': 3,
  '1564032300000': 3,
  '1564032900000': 7,
  '1564033500000': 2,
  '1564034100000': 4,
  '1564034700000': 2,
  '1564035300000': 3,
  '1564035900000': 3,
  '1564036500000': 3,
  '1564037100000': 1,
  '1564037700000': 0,
  '1564038300000': 4,
  '1564038900000': 0,
  '1564039500000': 0,
  '1564040100000': 0,
  '1564040700000': 0,
  '1564041300000': 0,
  '1564041900000': 25,
  '1564042500000': 36,
  '1564043100000': 14,
  '1564043700000': 1,
  '1564044300000': 18,
  '1564044900000': 11,
  '1564045500000': 19,
  '1564046100000': 19,
  '1564046700000': 16,
  '1564047300000': 16,
  '1564047900000': 13,
  '1564048500000': 9,
  '1564049100000': 21,
  '1564049700000': 18,
  '1564050300000': 10,
  '1564050900000': 15,
  '1564051500000': 9,
  '1564052100000': 15,
  '1564052700000': 15,
  '1564053300000': 15,
  '1564053900000': 13,
  '1564054500000': 22,
  '1564055100000': 10,
  '1564055700000': 7,
  '1564056300000': 10,
  '1564056900000': 15,
  '1564057500000': 20,
  '1564058100000': 12,
  '1564058700000': 12,
  '1564059300000': 5,
  '1564059900000': 5,
  '1564060500000': 12,
  '1564061100000': 4,
  '1564061700000': 15,
  '1564062300000': 8,
  '1564062900000': 11,
  '1564063500000': 12,
  '1564064100000': 7,
  '1564064700000': 5,
  '1564065300000': 9,
  '1564065900000': 6,
  '1564066500000': 7,
  '1564067100000': 5,
  '1564067700000': 6,
  '1564068300000': 10,
  '1564068900000': 24,
  '1564069500000': 7,
  '1564070100000': 10,
  '1564070700000': 8,
  '1564071300000': 17,
  '1564071900000': 11,
  '1564072500000': 6,
  '1564073100000': 10,
  '1564073700000': 7,
  '1564074300000': 7,
  '1564074900000': 13
}, domainsOverTime: {
  '1563991500000': 122,
  '1563992100000': 97,
  '1563992700000': 75,
  '1563993300000': 79,
  '1563993900000': 25,
  '1563994500000': 13,
  '1563995100000': 14,
  '1563995700000': 25,
  '1563996300000': 10,
  '1563996900000': 83,
  '1563997500000': 74,
  '1563998100000': 68,
  '1563998700000': 90,
  '1563999300000': 33,
  '1563999900000': 83,
  '1564000500000': 32,
  '1564001100000': 53,
  '1564001700000': 54,
  '1564002300000': 87,
  '1564002900000': 72,
  '1564003500000': 43,
  '1564004100000': 31,
  '1564004700000': 41,
  '1564005300000': 20,
  '1564005900000': 43,
  '1564006500000': 63,
  '1564007100000': 44,
  '1564007700000': 21,
  '1564008300000': 18,
  '1564008900000': 89,
  '1564009500000': 52,
  '1564010100000': 59,
  '1564010700000': 50,
  '1564011300000': 74,
  '1564011900000': 69,
  '1564012500000': 41,
  '1564013100000': 35,
  '1564013700000': 38,
  '1564014300000': 76,
  '1564014900000': 49,
  '1564015500000': 42,
  '1564016100000': 33,
  '1564016700000': 28,
  '1564017300000': 19,
  '1564017900000': 11,
  '1564018500000': 52,
  '1564019100000': 12,
  '1564019700000': 21,
  '1564020300000': 19,
  '1564020900000': 14,
  '1564021500000': 0,
  '1564022100000': 7,
  '1564022700000': 1,
  '1564023300000': 0,
  '1564023900000': 4,
  '1564024500000': 6,
  '1564025100000': 1,
  '1564025700000': 2,
  '1564026300000': 1,
  '1564026900000': 26,
  '1564027500000': 4,
  '1564028100000': 5,
  '1564028700000': 0,
  '1564029300000': 2,
  '1564029900000': 10,
  '1564030500000': 4,
  '1564031100000': 11,
  '1564031700000': 7,
  '1564032300000': 5,
  '1564032900000': 11,
  '1564033500000': 9,
  '1564034100000': 10,
  '1564034700000': 15,
  '1564035300000': 16,
  '1564035900000': 5,
  '1564036500000': 13,
  '1564037100000': 1,
  '1564037700000': 5,
  '1564038300000': 10,
  '1564038900000': 4,
  '1564039500000': 0,
  '1564040100000': 1,
  '1564040700000': 0,
  '1564041300000': 3,
  '1564041900000': 71,
  '1564042500000': 125,
  '1564043100000': 77,
  '1564043700000': 16,
  '1564044300000': 136,
  '1564044900000': 65,
  '1564045500000': 69,
  '1564046100000': 58,
  '1564046700000': 58,
  '1564047300000': 36,
  '1564047900000': 39,
  '1564048500000': 17,
  '1564049100000': 44,
  '1564049700000': 51,
  '1564050300000': 43,
  '1564050900000': 31,
  '1564051500000': 25,
  '1564052100000': 30,
  '1564052700000': 34,
  '1564053300000': 42,
  '1564053900000': 25,
  '1564054500000': 42,
  '1564055100000': 36,
  '1564055700000': 27,
  '1564056300000': 43,
  '1564056900000': 45,
  '1564057500000': 58,
  '1564058100000': 41,
  '1564058700000': 36,
  '1564059300000': 21,
  '1564059900000': 29,
  '1564060500000': 50,
  '1564061100000': 13,
  '1564061700000': 28,
  '1564062300000': 53,
  '1564062900000': 38,
  '1564063500000': 46,
  '1564064100000': 34,
  '1564064700000': 30,
  '1564065300000': 27,
  '1564065900000': 25,
  '1564066500000': 25,
  '1564067100000': 31,
  '1564067700000': 25,
  '1564068300000': 34,
  '1564068900000': 70,
  '1564069500000': 26,
  '1564070100000': 19,
  '1564070700000': 30,
  '1564071300000': 59,
  '1564071900000': 84,
  '1564072500000': 46,
  '1564073100000': 54,
  '1564073700000': 40,
  '1564074300000': 63,
  '1564074900000': 69
});

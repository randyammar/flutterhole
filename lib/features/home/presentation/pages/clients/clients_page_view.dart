import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutterhole/core/models/failures.dart';
import 'package:flutterhole/features/api/data/models/pi_client.dart';
import 'package:flutterhole/features/api/data/models/summary.dart';
import 'package:flutterhole/features/api/data/models/top_sources.dart';
import 'package:flutterhole/features/home/blocs/home_bloc.dart';
import 'package:flutterhole/features/home/presentation/widgets/home_bloc_builder.dart';
import 'package:flutterhole/widgets/layout/failure_indicators.dart';
import 'package:flutterhole/widgets/layout/frequency_tile.dart';
import 'package:flutterhole/widgets/layout/loading_indicators.dart';

class ClientsPageView extends StatelessWidget {
  const ClientsPageView({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HomeBlocBuilder(builder: (BuildContext context, HomeState state) {
      return state.maybeWhen<Widget>(
          success: (
            Either<Failure, SummaryModel> summaryResult,
            _,
            Either<Failure, TopSourcesResult> topSourcesResult,
            __,
          ) {
            return topSourcesResult.fold<Widget>(
              (failure) => CenteredFailureIndicator(failure),
              (topSources) {
                final List<PiClient> clients =
                    topSources.topSources.keys.toList();
                final List<int> queryCounts =
                    topSources.topSources.values.toList();

                final int totalQueryCount = summaryResult.fold<int>(
                  (failure) => 1,
                  (summary) => summary.dnsQueriesToday,
                );

                return ListView.builder(
                    itemCount: topSources.topSources.length,
                    itemBuilder: (context, index) {
                      final client = clients.elementAt(index);
                      final queryCount = queryCounts.elementAt(index);

                      final String title = (client.title?.isEmpty ?? true)
                          ? client.ip
                          : '${client.ip} (${client.title})';

                      return FrequencyTile(
                        title: title,
                        requests: queryCount,
                        totalRequests: totalQueryCount,
                      );
                    });
              },
            );
          },
          orElse: () => CenteredLoadingIndicator());
    });
  }
}

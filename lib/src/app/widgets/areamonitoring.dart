import 'package:flutter/cupertino.dart';
import 'package:sample/src/app/pages/econtract/monitoring_contract.dart';

SliverPadding areaMonitoring(double heightLayout) {
  return SliverPadding(
    padding: EdgeInsets.symmetric(
      horizontal: 15,
      vertical: 10,
    ),
    sliver: SliverToBoxAdapter(
      child: MonitoringContract(heightLayout),
    ),
  );
}

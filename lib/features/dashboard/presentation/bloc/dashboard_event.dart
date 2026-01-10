import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class FetchDashboardData extends DashboardEvent {
  const FetchDashboardData();
}

class SelectChild extends DashboardEvent {
  final String childId;

  const SelectChild(this.childId);

  @override
  List<Object?> get props => [childId];
}

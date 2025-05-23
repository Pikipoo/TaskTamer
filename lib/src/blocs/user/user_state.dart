import 'package:equatable/equatable.dart';
import 'package:task_tamer/src/models/user_profile.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {
  const UserInitial();
}

class UserLoading extends UserState {
  const UserLoading();
}

class UserLoaded extends UserState {
  final UserProfile userProfile;

  const UserLoaded(this.userProfile);

  @override
  List<Object> get props => [userProfile];
}

class UserOperationSuccess extends UserState {
  final String message;
  final UserProfile userProfile;

  const UserOperationSuccess({required this.message, required this.userProfile});

  @override
  List<Object> get props => [message, userProfile];
}

class UserOperationFailure extends UserState {
  final String error;

  const UserOperationFailure(this.error);

  @override
  List<Object> get props => [error];
}

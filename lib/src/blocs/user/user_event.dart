import 'package:equatable/equatable.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserProfile extends UserEvent {
  const LoadUserProfile();
}

class UpdateUserName extends UserEvent {
  final String name;

  const UpdateUserName(this.name);

  @override
  List<Object> get props => [name];
}

class UpdateUserAvatar extends UserEvent {
  final String avatarPath;

  const UpdateUserAvatar(this.avatarPath);

  @override
  List<Object> get props => [avatarPath];
}

class AddExperiencePoints extends UserEvent {
  final int points;

  const AddExperiencePoints(this.points);

  @override
  List<Object> get props => [points];
}

class UseAvailableExperiencePoints extends UserEvent {
  final int points;

  const UseAvailableExperiencePoints(this.points);

  @override
  List<Object> get props => [points];
}

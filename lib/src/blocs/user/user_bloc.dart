import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_tamer/src/blocs/user/user_event.dart';
import 'package:task_tamer/src/blocs/user/user_state.dart';
import 'package:task_tamer/src/repositories/user_repository.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository _userRepository;

  UserBloc({required UserRepository userRepository})
      : _userRepository = userRepository,
        super(const UserInitial()) {
    on<LoadUserProfile>(_onLoadUserProfile);
    on<UpdateUserName>(_onUpdateUserName);
    on<UpdateUserAvatar>(_onUpdateUserAvatar);
    on<AddExperiencePoints>(_onAddExperiencePoints);
  }

  Future<void> _onLoadUserProfile(
    LoadUserProfile event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading());
    try {
      final userProfile = await _userRepository.getUserProfile();
      emit(UserLoaded(userProfile));
    } catch (e) {
      emit(UserOperationFailure(e.toString()));
    }
  }

  Future<void> _onUpdateUserName(
    UpdateUserName event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading());
    try {
      final userProfile = await _userRepository.updateName(event.name);
      emit(UserOperationSuccess(
        message: 'Name updated successfully',
        userProfile: userProfile,
      ));
    } catch (e) {
      emit(UserOperationFailure(e.toString()));
    }
  }

  Future<void> _onUpdateUserAvatar(
    UpdateUserAvatar event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading());
    try {
      final userProfile = await _userRepository.updateAvatar(event.avatarPath);
      emit(UserOperationSuccess(
        message: 'Avatar updated successfully',
        userProfile: userProfile,
      ));
    } catch (e) {
      emit(UserOperationFailure(e.toString()));
    }
  }

  Future<void> _onAddExperiencePoints(
    AddExperiencePoints event,
    Emitter<UserState> emit,
  ) async {
    final currentState = state;

    try {
      final userProfile = await _userRepository.addExperiencePoints(event.points);

      // Only emit loading state if we're not already in a loaded state
      // This prevents UI flicker when adding XP
      if (currentState is! UserLoaded) {
        emit(const UserLoading());
      }

      final previousLevel = currentState is UserLoaded
          ? currentState.userProfile.level
          : userProfile.level;

      if (previousLevel < userProfile.level) {
        // User leveled up
        emit(UserOperationSuccess(
          message: 'Level up! You are now level ${userProfile.level}',
          userProfile: userProfile,
        ));
      } else {
        // Regular XP gain
        emit(UserLoaded(userProfile));
      }
    } catch (e) {
      emit(UserOperationFailure(e.toString()));
    }
  }
}

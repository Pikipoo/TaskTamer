import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_tamer/src/blocs/user/user_bloc.dart';
import 'package:task_tamer/src/blocs/user/user_state.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          BlocBuilder<UserBloc, UserState>(
            builder: (context, state) {
              if (state is UserLoaded || state is UserOperationSuccess) {
                final userProfile = state is UserLoaded
                    ? state.userProfile
                    : (state as UserOperationSuccess).userProfile;

                return UserAccountsDrawerHeader(
                  accountName: Text(userProfile.name),
                  accountEmail: Text('Level ${userProfile.level}'),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    child: userProfile.avatarPath != null
                        ? Image.asset(userProfile.avatarPath!)
                        : Text(
                            userProfile.name.isNotEmpty
                                ? userProfile.name[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(fontSize: 24),
                          ),
                  ),
                );
              }

              return const UserAccountsDrawerHeader(
                accountName: Text('Loading...'),
                accountEmail: Text(''),
                currentAccountPicture: CircleAvatar(
                  child: Icon(Icons.person),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              // Navigate to settings
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help'),
            onTap: () {
              // Navigate to help
              Navigator.pop(context);
            },
          ),
          const Spacer(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'TaskTamer v1.0.0',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}

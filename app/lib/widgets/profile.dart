import 'package:flutter/material.dart';
import 'package:md_notes/blocs/user.dart';
import 'package:md_notes/models/user.dart';
import 'package:md_notes/widgets/profile_pic.dart';

class UserProfile extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _UserProfile();
}

class _UserProfile extends State<UserProfile> {
  final UserBloc bloc = UserBloc();

  @override
  void initState() {
    bloc.fetchDetails();
    super.initState();
  }

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<GoodUser>(
      stream: bloc.user,
      builder: (context, snapshot) {
        TextTheme textTheme = Theme.of(context).textTheme;

        if (snapshot.hasData) {
          GoodUser user = snapshot.data!;

          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 48.0,
              ),
              child: Column(
                children: [
                  SizedBox(height: 24),
                  ProfilePic(
                    size: 112,
                    url: user.photoUrl,
                  ),
                  SizedBox(height: 16),
                  Text(
                    user.displayName,
                    style: textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    user.description,
                    style: textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return SizedBox();
      },
    );
  }
}

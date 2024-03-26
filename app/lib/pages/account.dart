import 'package:flutter/material.dart';
import 'package:md_notes/widgets/profile_pic.dart';

class Account extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 24.0,
              horizontal: 16.0,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 800,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 24,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.end,
                    children: [
                      ProfilePic(
                        size: 172,
                      ),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: 600,
                        ),
                        child: SectionHeader(
                          title: "Public Profile",
                          description:
                              "The information you choose to include in your profile, such as your display name, bio and profile picture, may be visible to other users of this platform.",
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  _ProfileInfo(),
                  SizedBox(
                    height: 24,
                  ),
                  SectionHeader(
                    title: "Account Details",
                    description:
                        "Manage your account details, keep your login details secure or permanently delete your account and all associated data.",
                  ),
                  _AccountInfo(),
                  _DeleteAccount(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Card.filled(
      elevation: 2,
      margin: EdgeInsets.all(8),
      shadowColor: Colors.transparent,
      surfaceTintColor: theme.colorScheme.surfaceTint,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: "Display Name",
                hintText: "Your full name or an alias",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(
              height: 24.0,
            ),
            TextField(
              decoration: InputDecoration(
                labelText: "Bio",
                hintText: "Write something about yourself",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Card.filled(
      elevation: 2,
      margin: EdgeInsets.all(8),
      shadowColor: Colors.transparent,
      surfaceTintColor: theme.colorScheme.surfaceTint,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.email_outlined),
                SizedBox(width: 16),
                Expanded(child: Text("Email")),
                Text("email@example.com"),
                SizedBox(width: 16),
                Icon(Icons.chevron_right)
              ],
            ),
            Divider(
              height: 32,
            ),
            Row(
              children: [
                Icon(Icons.key),
                SizedBox(width: 16),
                Expanded(child: Text("Password")),
                Text("Change your password"),
                SizedBox(width: 16),
                Icon(Icons.chevron_right)
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DeleteAccount extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Card.filled(
      margin: EdgeInsets.all(8),
      shadowColor: Colors.transparent,
      color: theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Delete Account",
              style: theme.textTheme.titleMedium!.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
            SizedBox(
              height: 4.0,
            ),
            Text(
              "You can permanently delete your account from here. If you’re sure about this and you choose to move ahead all the data connected to this account will be deleted permanently. You will not be able to retrieve it in the future.",
              style: TextStyle(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
            SizedBox(
              height: 16.0,
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: OutlinedButton(
                onPressed: () {},
                child: Text(
                  "DELETE ACCOUNT",
                  style: TextStyle(
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  SectionHeader({
    required this.title,
    required this.description,
  });

  final String title, description;

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textTheme.titleLarge,
          ),
          SizedBox(
            height: 8.0,
          ),
          Text(
            description,
            style: textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

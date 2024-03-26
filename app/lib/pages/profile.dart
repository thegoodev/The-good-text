import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:md_notes/widgets/profile_pic.dart';

const String version = "1.8.2"; //TODO Siempre cambiar esto

class Profile extends StatefulWidget {
  Profile();

  @override
  State<StatefulWidget> createState() => ProfileState();
}

class ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Material(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NavigationHeader(),
              ListTile(
                onTap: () {},
                leading: Icon(Icons.archive_outlined),
                title: Text("Archive"),
              ),
              Divider(
                indent: 48,
                endIndent: 16,
              ),
              ListTile(
                onTap: () {},
                leading: Icon(Icons.delete_outline),
                title: Text("Trash"),
              ),
              Divider(indent: 16, endIndent: 16),
              ListTile(
                onTap: () {},
                leading: Icon(Icons.new_label_outlined),
                title: Text("Create New Label"),
              ),
              Divider(
                indent: 16,
                endIndent: 16,
              ),
              SectionTitle(title: "Support"),
              ListTile(
                onTap: () {},
                leading: Icon(Icons.help_outline),
                title: Text("Help Center"),
              ),
              ListTile(
                onTap: () {},
                leading: Icon(Icons.feedback_outlined),
                title: Text("Send Feedback"),
              ),
              Divider(indent: 16, endIndent: 16),
              SectionTitle(title: "About"),
              ListTile(
                onTap: () {},
                leading: Icon(Icons.privacy_tip_outlined),
                title: Text("Privacy Policy"),
              ),
              ListTile(
                onTap: () {},
                leading: Icon(Icons.description_outlined),
                title: Text("Term of Service"),
              ),
              Divider(indent: 16, endIndent: 16),
              ListTile(
                onTap: () {},
                leading: Icon(Icons.color_lens),
                title: Text("Theme"),
              ),
              Divider(indent: 16, endIndent: 16),
              ListTile(
                leading: Icon(Icons.exit_to_app),
                title: Text("Sign Out"),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    top: 8,
                  ),
                  child: Text("v$version"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class NavigationHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      child: Column(
        children: [
          ProfilePic(
            size: 124,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "User Name",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          SizedBox(height: 8),
          Text(
            "User description goes here",
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          OutlinedButton(
            onPressed: () {},
            child: Text("Edit Profile"),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}

class ThemeDialog extends StatelessWidget {
  final List<String> themeNames = ["System", "Light", "Dark"];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Choose theme"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Cancel"),
        ),
      ],
      actionsPadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.only(
        left: 8,
        right: 8,
        top: 16,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: themeNames
            .map((e) => Row(
                  children: [
                    Radio(
                      value: e,
                      groupValue: "System",
                      onChanged: (value) {},
                    ),
                    Text(e),
                  ],
                ))
            .toList(),
      ),
    );
  }
}

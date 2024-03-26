import 'package:flutter/material.dart';

class CoolHeader extends StatelessWidget{

  final List<Widget> children;
  final String text;

  CoolHeader({required this.children, required this.text,});

  @override
  Widget build(BuildContext context) {

    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 300,
            iconTheme: IconThemeData(
                color: Colors.white
            ),
            backgroundColor: colorScheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              title: Text("$text",style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.w900
                  ),
                  ),
              background: Image.asset("assets/background.png", fit: BoxFit.cover),
            ),
          ),
          SliverFillRemaining(
              child:  Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: children
                  ),
              ),
          ),
        ],
    );
  }
}
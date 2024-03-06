import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:md_notes/auth.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

import 'main.dart';

class Tile extends StatelessWidget{
  final Widget leading, title, trailing;
  final Function() onTap;
  final EdgeInsets margin;

  Tile({
    this.leading, 
    this.title, 
    this.onTap, 
    this.trailing, 
    this.margin = const EdgeInsets.symmetric(vertical: 12, horizontal:16)
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: margin,
        child: Row(
          children: [
            leading??SizedBox(),
            SizedBox(width: 16),
            Expanded(
              child: title??SizedBox()
            ),
            SizedBox(width: 16),
            trailing??SizedBox()
          ],
        ),
      )
    );
  }
}

class SecondaryButton extends StatelessWidget{

  final String text;
  final Widget child;
  final Function() onPressed;
  final Brightness brightness;
  final EdgeInsetsGeometry padding, margin;
  final double elevation, minWidth;

  SecondaryButton({
    this.elevation = 2,
    this.minWidth = double.infinity,
    this.brightness = Brightness.dark,
    this.margin = const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
    this.padding = const EdgeInsets.symmetric(vertical: 16),
    this.text, this.child, this.onPressed
  }):assert(child==null);

  @override
  Widget build(BuildContext context) {
    bool light = brightness == Brightness.light;
    Color mainColor = Theme.of(context).primaryColor;
    Color canvasColor = Theme.of(context).canvasColor;

    return Padding(
      padding: margin,
      child: MaterialButton(
        elevation: elevation,
        padding: padding,
        onPressed: onPressed,
        textColor: !light?mainColor:Colors.white54,
        minWidth: minWidth,
        color:  !light?canvasColor:purple,
        child: text==null?child:I18nText(text,child: Text("", style: TextStyle(color: !light?mainColor:Colors.white))),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: !light?mainColor:Colors.white),
          borderRadius: BorderRadius.circular(8)
        ),
      )
    );
  }
}

class PrimaryButton extends StatelessWidget{

  final String text;
  final Widget child;
  final Function() onPressed;
  final bool disabeled;
  final double minWidth;
  final Brightness brightness;
  final EdgeInsetsGeometry padding, margin;

  PrimaryButton({
    this.minWidth = double.infinity,
    this.brightness = Brightness.dark,
    this.disabeled = false,
    this.margin = const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
    this.padding = const EdgeInsets.symmetric(vertical: 16),
    this.text, this.child, this.onPressed
  }):assert(key==null);

  @override
  Widget build(BuildContext context) {

    bool light = brightness == Brightness.light;
    Color mainColor = Theme.of(context).colorScheme.secondary;

    return Padding(
      padding: margin,
      child: MaterialButton(
        color: disabeled?Colors.grey:!light?mainColor:Colors.white,
        padding: padding,
        onPressed: onPressed,
        textColor: Colors.white,
        minWidth: minWidth,
        child: text==null?child:I18nText(
          text, 
          child: Text(
            "",
            style: TextStyle(color: light?purple:Colors.white)
          )
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8)
        ),
      )
    );
  }
}

class ToggleGrid extends StatelessWidget{
  final bool show;
  final GoodUser user;

  ToggleGrid({this.show = true, this.user});

  @override
  Widget build(BuildContext context) {
    bool grid = user.grid??true;
    return show?IconButton(
      icon: Icon(grid?OMIcons.viewAgenda:OMIcons.dashboard),
      onPressed: (){
        user.toogleGrid();
      }
    ):SizedBox();
  }
}

class EmptySliver extends StatelessWidget{

  final bool show;
  final String title, body, name;

  EmptySliver({this.title, this.body, this.name, this.show = false});

  @override
  Widget build(BuildContext context) {
    return show?SliverFillRemaining(
      hasScrollBody: false,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          !kIsWeb?SvgPicture.asset("assets/svg/$name.svg", width: 300):SizedBox(),
          title!=null?Padding(
            padding: EdgeInsets.only(left: 16, right: 16, bottom: 8, top: 16),
            child: Text(
              title, 
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center
            ),
          ):SizedBox(),
          body!=null?Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: title==null?16:0),
            child: Text(
              body,
              textAlign: TextAlign.center,
            )
          ):SizedBox()
        ],
      ),
    ):SliverToBoxAdapter();
  }
}

class OfflineIndicator extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return kIsWeb?SizedBox():ConnectivityWidgetWrapper(
      stacked: false,
      offlineWidget:IconButton(
        onPressed: (){},
        icon: Icon(Icons.cloud_off),
      ),
      child: SizedBox(),
    );
  }
}

double kMaxWidth = 720;

class ResponsiveBox extends StatelessWidget{

  final Widget child;

  ResponsiveBox({this.child});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: kMaxWidth
        ),
        child: child,
      ),
    );
  }
  
}

class BigLayout extends StatelessWidget{

  final Widget right, left;

  BigLayout({this.left, this.right});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context); 
    return Row(
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 350
          ),
          child: left,
        ),
        Container(
          width: 1.5,
          decoration: BoxDecoration(
            color: theme.dividerColor
          ),
        ),
        Expanded(
          child: right,
        )
      ],
    );
  }
  
}

class Responsive extends StatelessWidget{

  final Widget bigChild, child;

  Responsive({this.bigChild, this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if(constraints.maxWidth >= 960){
          return bigChild??child;
        }

        return child;
      },
    );
  }

} 
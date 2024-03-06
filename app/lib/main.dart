import 'dart:async';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:md_notes/archive.dart';
import 'package:md_notes/auth.dart';
import 'package:md_notes/editor.dart';
import 'package:md_notes/labels.dart';
import 'package:md_notes/profile.dart';
import 'package:md_notes/reader.dart';
import 'package:md_notes/trash.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

//i18n
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

GlobalKey<MyAppState> appKey = GlobalKey<MyAppState>();

Future<void> main() async{

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(MyApp(key: appKey));
}

const purple = Color(0xFF440DB7);
const lightPurple = Color(0xFFad87ff);
const lighterPurple = Color(0xFFBD9EFF);

ThemeData appTheme = ThemeData(
    primaryColor: purple,
    textTheme: TextTheme(
      bodyLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      bodyMedium: TextStyle(fontSize: 16, height: 1.5)
    ),
    snackBarTheme: SnackBarThemeData(
      actionTextColor: lighterPurple
    ),
    cardColor: Color(0xFFf1f1f4),
    cardTheme: CardTheme(
      color: Color(0xFFEBEBEB)
    ),
    appBarTheme: AppBarTheme(
      iconTheme: IconThemeData(color: Colors.black),
      actionsIconTheme: IconThemeData(color: Colors.grey),
      color: Colors.grey[50], toolbarTextStyle: TextTheme(
        titleLarge: TextStyle(
          fontSize: 24, 
          fontWeight: FontWeight.w900,
          color: Colors.black
        )
      ).bodyMedium, titleTextStyle: TextTheme(
        titleLarge: TextStyle(
          fontSize: 24, 
          fontWeight: FontWeight.w900,
          color: Colors.black
        )
      ).titleLarge
    ),
    iconTheme: IconThemeData(
      color: Colors.grey
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity, textSelectionTheme: TextSelectionThemeData(cursorColor: purple, selectionHandleColor: purple,), checkboxTheme: CheckboxThemeData(
 fillColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
 if (states.contains(MaterialState.disabled)) { return null; }
 if (states.contains(MaterialState.selected)) { return purple; }
 return null;
 }),
 ), radioTheme: RadioThemeData(
 fillColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
 if (states.contains(MaterialState.disabled)) { return null; }
 if (states.contains(MaterialState.selected)) { return purple; }
 return null;
 }),
 ), switchTheme: SwitchThemeData(
 thumbColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
 if (states.contains(MaterialState.disabled)) { return null; }
 if (states.contains(MaterialState.selected)) { return purple; }
 return null;
 }),
 trackColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
 if (states.contains(MaterialState.disabled)) { return null; }
 if (states.contains(MaterialState.selected)) { return purple; }
 return null;
 }),
 ), colorScheme: ColorScheme.fromSwatch().copyWith(secondary: purple),
  );
  
Color _background = Colors.grey[900];
Color _raised = Colors.grey[850];

ThemeData dakTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: lighterPurple,
    textTheme: TextTheme(
      bodyLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      bodyMedium: TextStyle(fontSize: 16, height: 1.5)
    ),
    snackBarTheme: SnackBarThemeData(
      actionTextColor: purple
    ),
    cardColor: _raised,
    cardTheme: CardTheme(
      color: _raised
    ),
    canvasColor: _background,
    scaffoldBackgroundColor: _background,
    appBarTheme: AppBarTheme(
      iconTheme: IconThemeData(color: Colors.white),
      actionsIconTheme: IconThemeData(color: Colors.grey),
      color: _background, systemOverlayStyle: SystemUiOverlayStyle.light, toolbarTextStyle: TextTheme(
        titleLarge: TextStyle(
          fontSize: 24, 
          fontWeight: FontWeight.w900,
        )
      ).bodyMedium, titleTextStyle: TextTheme(
        titleLarge: TextStyle(
          fontSize: 24, 
          fontWeight: FontWeight.w900,
        )
      ).titleLarge
    ),
    iconTheme: IconThemeData(
      color: Colors.grey
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity, textSelectionTheme: TextSelectionThemeData(cursorColor: lightPurple, selectionHandleColor: lightPurple,), colorScheme: ColorScheme.fromSwatch().copyWith(secondary: lightPurple), checkboxTheme: CheckboxThemeData(
 fillColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
 if (states.contains(MaterialState.disabled)) { return null; }
 if (states.contains(MaterialState.selected)) { return lightPurple; }
 return null;
 }),
 ), radioTheme: RadioThemeData(
 fillColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
 if (states.contains(MaterialState.disabled)) { return null; }
 if (states.contains(MaterialState.selected)) { return lightPurple; }
 return null;
 }),
 ), switchTheme: SwitchThemeData(
 thumbColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
 if (states.contains(MaterialState.disabled)) { return null; }
 if (states.contains(MaterialState.selected)) { return lightPurple; }
 return null;
 }),
 trackColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
 if (states.contains(MaterialState.disabled)) { return null; }
 if (states.contains(MaterialState.selected)) { return lightPurple; }
 return null;
 }),
 ), bottomAppBarTheme: BottomAppBarTheme(color: _raised),
  );

Widget userProvider(ThemeMode mode){
  return ChangeNotifierProvider<GoodUser>(
    create: (context) => GoodUser(),
    child: MaterialApp(
      title: 'The Good Text',
      themeMode: mode,
      theme: appTheme,
      darkTheme: dakTheme,
      initialRoute: "/",
      routes: {
        "/": (context) => UserFinder(),

        "/labels/edit": (context) => EditLabels(),
        "/labels/select": (context) => SelectLabel(),
        "/labels/find": (context) => AllWithLabel(),

        "/archive": (context) => Archive(),
        "/trash": (context) => Trash(),

        "/profile": (context) => Profile(),
        "/profile/update": (context) => ProfileUpdate(),

        "/feedback": (context) => SendFeedBack(),

        "/welcome": (context) => Welcome(),
        "/login": (context) => Login(),
        "/signup": (context) => Signup(),

        "/editor": (context) => Editor(),
        "/reader": (context) => Reader()
      },
      //i18n Configs
      localizationsDelegates: [
        FlutterI18nDelegate(
        translationLoader: FileTranslationLoader(fallbackFile:"en",basePath:"assets/i18n",useCountryCode: false,),
        missingTranslationHandler: (key, locale) {
          print("--- Missing Key: $key, languageCode: ${locale.languageCode}");
        },
        ),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('es'),
        const Locale('en')
      ]
    )
  );
}

class MyApp extends StatefulWidget{

  MyApp({Key key}):super(key: key);

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {

  ThemeMode mode = ThemeMode.system;
  
  setMode(ThemeMode _mode){
    setState(() {
      mode = _mode;
    });
  } 

  @override
  Widget build(BuildContext context) {
    return kIsWeb?userProvider(mode):ConnectivityAppWrapper(
      app: userProvider(mode)
    );
  }
}

openLink(href)async{
  if (await canLaunch(href)) {
    await launch(href);
  } else {
    throw 'Could not launch $href';
  }
}

loadweb(String link, BuildContext context){
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context)=> WebviewScaffold(
        url: link,
        appBar: AppBar(),
      ))
    );
  }
  
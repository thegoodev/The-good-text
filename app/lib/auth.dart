import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:md_notes/home.dart';
import 'package:md_notes/labels.dart';
import 'package:md_notes/main.dart';
import 'package:md_notes/note.dart';
import 'package:md_notes/ui.dart';
import 'package:provider/provider.dart';

import 'package:flutter_i18n/flutter_i18n.dart';

enum LinkCallbackType{
  error,
  note,
  other
}

class LinkCallback{
  LinkCallbackType type;
  dynamic result;

  bool get isError => type==LinkCallbackType.error;
  bool get isNote => type==LinkCallbackType.note;
  bool get isOther => type==LinkCallbackType.other;

  LinkCallback({this.type, this.result});
}

class UserFinder extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    FirebaseAuth auth = FirebaseAuth.instance;

    return StreamBuilder<User>(
      stream: auth.authStateChanges(),
      builder: (context, snapshot){
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Container(
              color: Theme.of(context).canvasColor,
              child: CircularProgressIndicator(),
            );
          case ConnectionState.active:
            User user = snapshot.data;

            if (snapshot.hasError)
              return Text('Error: ${snapshot.error}');
            else{
              if(user != null){
                Provider.of<GoodUser>(context, listen: false).init(user: user);
                return HomePage(user: user);
              }else{
                return Welcome(); 
              }
            }

            break;
          default:
            return SizedBox();
        }
      }
    );
  }
}

class GoodUser extends ChangeNotifier{
  DocumentReference reference;
  Map<String, dynamic> data = {};
  Completer<List<Note>> _onNotesChanged = Completer();
  StreamSubscription userStream, stream, labeledStream;
  List<Note> notes, archive, trash, labeled;

  GoodUser();

  void killLists(){
    notes = null;
    archive = null;
    trash = null;
    labeled = null;
  }

  void killStreams(){
    userStream = null;
    stream = null;
    labeledStream = null;
  }

  void cancelStreams(){
    if(userStream!=null)
      userStream.cancel();

    if(stream!=null)
      stream.cancel();

    if(labeledStream!=null)
      labeledStream.cancel();
  }

  @override
  dispose(){
    cancelStreams();
    super.dispose();
  }

  void kill(){
    data = {};
    reference = null;
    cancelStreams();
    killStreams();
    killLists();
  }

  Future<void> init({User user}) async {

    String uid;

    if((data??{}).isNotEmpty)
      return;

    if(user!=null)
      uid = user.uid;
    else
      uid = (await FirebaseAuth.instance.userChanges().first).uid;

    reference = FirebaseFirestore.instance.doc("users/$uid");

    if(userStream == null){
      userStream = reference.snapshots().listen((snapshot){
        Map _data = snapshot.data();
        ThemeMode incoming = ThemeMode.values[_data["theme-mode"]??0];

        if(incoming!=themeMode){
          appKey.currentState.setMode(incoming);
        }

        data = _data;
        notifyListeners();
      });
    }

    CollectionReference notesRef = reference.collection("notes");

    if(stream == null){
      stream = notesRef
      .snapshots().listen((snapshot){
        List<Note> _notes = snapshot.docs.map((snapshot) => Note(snapshot)).toList();
        _notes.sort((a,b) => a.state.index.compareTo(b.state.index));
        notes = _notes.where((note) => note.state.index < NoteState.archived.index).toList();
        archive = _notes.where((note) => note.state == NoteState.archived).toList();
        trash = _notes.where((note) => note.state == NoteState.deleted).toList();
        notifyListeners();
        if(!_onNotesChanged.isCompleted){
          _onNotesChanged.complete(notes);
        }
      });
    }
  }

  String get uid => data["uid"];
  String get photoUrl => data["photo"];
  String get displayName => data["name"];
  String get description => data["description"];

  ThemeMode get themeMode {
    if(data["theme-mode"] != null)
      return ThemeMode.values[data["theme-mode"]];
    
    return ThemeMode.system;
  }

  set themeMode(ThemeMode mode){
    if(themeMode!=mode){
      reference.update({"theme-mode": mode.index});
    } 
  }

  bool get grid => data["grid"];

  List get labels{
    List lbs = data["labels"];
    if(lbs!=null){
      lbs.sort();
    }

    return lbs;
  }

  Future<Note> _getSharedNote(List<Note> notes, String sharedId)async{
    Note note;

    if(notes!=null){
      note = notes.firstWhere((n) => n.shareId == sharedId, orElse: () => null);
    }

    if(note == null){
      List<DocumentSnapshot> snapshots = (await FirebaseFirestore.instance.collectionGroup("notes")
      .where("is_sharing",isEqualTo: true)
      .where("share_id", isEqualTo: sharedId)
      .where("state", isLessThan: NoteState.deleted.index)
      .limit(1).get()).docs;

      if(snapshots.isEmpty){    
        return null;
      }else{
        note = Note(snapshots[0]);
        note.source.origin = NoteOrigin.link;
        return note;
      }
    }else{
      note.source.origin = NoteOrigin.app;
      return note;
    }
  }

  Future<LinkCallback> openNoteFromUrl(String data)async{

    Uri url = Uri.parse(data);
    List<String> segments = url.pathSegments;

    if(segments.isNotEmpty){
      String sharedId = segments.first;
      Note note;
      if(sharedId.length == 20){
        if(notes == null){
          note = await _getSharedNote(await _onNotesChanged.future, sharedId);
        }else{
          note = await _getSharedNote(notes, sharedId);
        }

        if(note==null){
          return LinkCallback(type: LinkCallbackType.error, result: "Not found");
        }else{
          return LinkCallback(type: LinkCallbackType.note, result: note);
        }
      }
    }

    return LinkCallback(type: LinkCallbackType.other, result: data);
  }

  update({String photoUrl, String displayName, String description, List labels})async{

    Map<String, dynamic> newData = {};

    if(photoUrl != null)
      newData["photo"] = photoUrl;

    if(displayName != null)
      newData["name"] = displayName;

    if(description != null)
      newData["description"] = description;

    if(labels != null)
      newData["labels"] = labels;

    data.addAll(newData);

    await reference.update(newData);

    notifyListeners();
  }

  getLabeled(String label){
    if(labeledStream != null)
      labeledStream.cancel();

    labeledStream = reference.collection("notes")
    .where("labels", arrayContains: label)
    .where("state", isLessThan: NoteState.deleted.index)
    .orderBy("state")
    .snapshots().listen((event){
      labeled = event.docs.map(
        (snapshot) => Note(
          snapshot, 
          source: NoteSource(
            key: labelScaffold,
            name: "/labels/find"
          )
        )
      ).toList();
      print("Labeled $label changed");
      notifyListeners();
    });
  }


  createLabel(String label) async {
    data["labels"] = labels+[label];
    notifyListeners();

    await reference.update({"labels": FieldValue.arrayUnion([label])});
  }

  deleteLabel(String label) async {
    labels.remove(label);
    data["labels"] = labels;
    notifyListeners();

    QuerySnapshot snapshot = await reference.collection("notes")
    .where("labels", arrayContains: label).get();

    WriteBatch batch = reference.firestore.batch();

    Map<String, dynamic> newData =  {"labels": FieldValue.arrayRemove([label])};

    for(DocumentSnapshot doc in snapshot.docs){
      batch.update(doc.reference, newData);
    }

    batch.update(reference,newData);

    await batch.commit();
  }

  updateLabel(String oldLabel, {String mergeWith, String newLabel}) async {
    labels.remove(oldLabel);
    if(newLabel!=null)
      labels.add(newLabel);

    data["labels"] = labels;
    notifyListeners();

    QuerySnapshot snapshot = await reference.collection("notes")
    .where("labels", arrayContains: oldLabel).get();

    WriteBatch batch = reference.firestore.batch();

    for(DocumentSnapshot doc in snapshot.docs){
      batch.update(doc.reference, {"labels": FieldValue.arrayRemove([oldLabel, mergeWith])});
      batch.update(doc.reference, {"labels": FieldValue.arrayUnion([newLabel??mergeWith])});
    }

    if(newLabel!=null)
      batch.update(reference, {"labels": FieldValue.arrayUnion([newLabel])});
    batch.update(reference, {"labels": FieldValue.arrayRemove([oldLabel])});
    
    await batch.commit();
  }

  toogleGrid(){
    data["grid"] = !grid;
    reference.update({
      "grid": grid
    }); 
  }
}

class ConnectivityButton extends StatelessWidget{
  final Widget child;

  ConnectivityButton({this.child});

  @override
  Widget build(BuildContext context){
    return kIsWeb?child:ConnectivityWidgetWrapper(
      stacked: false,
      offlineWidget: PrimaryButton(
        margin: EdgeInsets.zero,
        disabeled: true,
        text: "Offline",
        onPressed: () {},
      ),
      child: child
    );
  }
}

class Login extends StatefulWidget{
  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<Login>{

  bool obscureText = true, loading = false, remember = false;
  String error;

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  login() async {
    setState(() {
      loading = true;
    });

    User user;

    try{
      FirebaseAuth auth = FirebaseAuth.instance;

      if(kIsWeb){
        if(remember){
          await auth.setPersistence(Persistence.LOCAL);
        }else{
          await auth.setPersistence(Persistence.NONE);
        }
      }

      user = (await auth
      .signInWithEmailAndPassword(
        email: email.text.trim(), password: password.text
      )).user;
    }catch(e){
      setState(() {
        loading = false;
      });
      error = e.message;
    }

    if(user != null){
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CoolHeader(
        text: "Welcome Back",
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: error!=null?Text(error):SizedBox(),
          ),
          SizedBox(height: 16),
          TextField(
            controller: email,
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.zero,
              prefixIcon: Icon(Icons.mail_outline),
              hintText: "Email"
            ),
          ),
          SizedBox(height: 16),
          TextField(
            obscureText: obscureText,
            controller: password,
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.zero,
              prefixIcon: Icon(Icons.lock_outline),
              suffixIcon: GestureDetector(
                onTap: () => setState((){
                  obscureText = !obscureText;
                }),
                child: Icon(obscureText?Icons.visibility:Icons.visibility_off)
              ),
              hintText: "Password"
            ),
          ),
          Row(
            children: [
              kIsWeb?Expanded(
                child: Row(
                  children: [
                    Checkbox(value: remember, onChanged: (value){
                      setState(() {
                        remember = value;
                      });
                    }),
                    I18nText("Remember me", child: Text(""),)
                  ],
                ),
              ):SizedBox(),
            ],
          ),
          SizedBox(height: 24),
          ConnectivityButton(
            child: PrimaryButton(
              margin: EdgeInsets.zero,
              text: "Login",
              onPressed: login
            ),
          ),
          SizedBox(height: 16),
          loading?LinearProgressIndicator():SizedBox()
        ],
      ),
    );
  }
}

class Signup extends StatefulWidget{
  @override
  SignupState createState() => SignupState();
}

class SignupState extends State<Signup>{

  bool obscureText = true;
  bool loading = false;
  String error;

  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  signug()async{
    setState(() {
      loading = true;
    });

    User user;

    try{
      user = (await FirebaseAuth.instance
      .createUserWithEmailAndPassword(
        email: email.text.trim(), password: password.text
      )).user;
    }catch(e){
      setState(() {
        loading = false;
      });
      error = e.message;
    }

    if(user != null){
      GoodUser gUser = Provider.of<GoodUser>(context, listen: false);
      await gUser.init(user: user);
      gUser.update(displayName: name.text);
      Navigator.of(context).pop(true);
    }
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CoolHeader(
        text: "Create Account",
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: error!=null?Text(error):SizedBox(),
          ),
          TextField(
            controller: name,
            textAlignVertical: TextAlignVertical.center,
            maxLength: 30,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.zero,
              prefixIcon: Icon(Icons.person_outline),
              hintText: "Name"
            ),
          ),
          SizedBox(height: 16),
          TextField(
            controller: email,
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.zero,
              prefixIcon: Icon(Icons.mail_outline),
              hintText: "Email"
            ),
          ),
          SizedBox(height: 16),
          TextField(
            obscureText: obscureText,
            controller: password,
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.zero,
              prefixIcon: Icon(Icons.lock_outline),
              suffixIcon: GestureDetector(
                onTap: () => setState((){
                  obscureText = !obscureText;
                }),
                child: Icon(obscureText?Icons.visibility:Icons.visibility_off)
              ),
              hintText: "Password"
            ),
          ),
          SizedBox(height: 24),
          ConnectivityButton(
            child: PrimaryButton(
              margin: EdgeInsets.zero,
              text: "Sign up",
              onPressed: signug
            ),
          ),
          SizedBox(height: 6),
          loading?LinearProgressIndicator():SizedBox()
        ],
      )
    );
  }
}

class CoolHeader extends StatelessWidget{

  final List<Widget> children;
  final String text;

  CoolHeader({this.children, this.text});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: 300,
          iconTheme: IconThemeData(
            color: Colors.white
          ),
          backgroundColor: purple,
          flexibleSpace: FlexibleSpaceBar(
            title: I18nText(
              "$text", 
              child: Text("",style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900
                )
              )
            ),
            background: Image.asset("assets/background.png", fit: BoxFit.cover),
          ),
        ),
        SliverFillRemaining(
          child: ResponsiveBox(
            child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: children
              )
            )
          )
        )
      ]
    );
  }
}


class Welcome extends StatefulWidget{

  @override
  State<StatefulWidget> createState() => WelcomeState();
}

class WelcomeState extends State<Welcome>{

  bool loading = false;

  @override
  Widget build(BuildContext context) {

    Color mainColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: purple,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("assets/background.png", fit: BoxFit.fitWidth)
          ),
          Positioned.fill(
            child: SafeArea(
              child: ResponsiveBox(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: kIsWeb?SizedBox():SvgPicture.asset("assets/launcher/isotipo.svg"),
                    ),
                    SizedBox(height: 16),
                    PrimaryButton(
                      text: "Login",
                      brightness: Brightness.light,
                      onPressed: () => Navigator.of(context).pushNamed("/login"),
                    ),
                    SizedBox(height: 4),
                    SecondaryButton(
                      brightness: Brightness.light,
                      text: "Sign Up",
                      onPressed: () => Navigator.of(context).pushNamed("/signup"),
                    ),
                    SizedBox(height: 4),
                    GestureDetector(
                      onTap: (){
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: I18nText("Continue on demo mode?"),
                            content: I18nText("Demo Short Description"),
                            actions: [
                              FlatButton(
                                textColor: mainColor,
                                onPressed: () => Navigator.pop(context), 
                                child: I18nText("Cancel")
                              ),
                              FlatButton(
                                textColor: mainColor,
                                onPressed: (){
                                  Navigator.pop(context);
                                  setState(() => loading = true);
                                  FirebaseAuth.instance.signInAnonymously();
                                }, 
                                child: I18nText("Accept")
                              ),
                            ],
                          )
                        );
                      },
                      child: I18nText(
                        "Continue without an account", 
                        child: Text("", style: TextStyle(
                            color: Colors.white,
                            decoration: TextDecoration.underline,
                            fontSize: Theme.of(context).textTheme.subtitle2.fontSize,
                          )
                        )
                      ),
                    ),
                    SizedBox(height: 8),
                    Theme(
                      data: ThemeData(
                        accentColor: Colors.white
                      ),
                      child: loading?LinearProgressIndicator():SizedBox()
                    )
                  ],
                )
              )
            )
          ),
        ]
      )
    );
  }
}

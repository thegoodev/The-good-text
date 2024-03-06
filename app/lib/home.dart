import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:md_notes/auth.dart';
import 'package:md_notes/main.dart';
import 'package:md_notes/note.dart';
import 'package:md_notes/profile.dart';
import 'package:md_notes/ui.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import 'package:flutter_i18n/flutter_i18n.dart';

GlobalKey<ScaffoldState> homeScaffold = GlobalKey<ScaffoldState>();

class HomePage extends StatefulWidget {
  HomePage({Key key, this.user}) : super(key: key);

  final User user;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  static const platform = const MethodChannel('com.the-good-text');
  GoodUser user;
  String sharedId;

  homeSnackbar(Widget text, {Duration duration = const Duration(seconds: 4)}){
    homeScaffold.currentState.showSnackBar(
      SnackBar(
        content: text,
        duration: duration,
      )
    );
  }

  getShared() async {

    if(kIsWeb){
      return;
    }

    var sharedData;

    try{
      sharedData = (await platform.invokeMethod("getIntent"))??{};

      String data = sharedData["data"], type = sharedData["type"];

      Note note;
      if(type != "link"){

        var content = await platform.invokeMethod("getContent");
        note = Note.blank(context);
        note.source.origin = NoteOrigin.file;
        note.body = "$content";

        
        note.source.name = "/";
        note.source.key = homeScaffold;
        note.source.uri = data;
        return Navigator.of(context).pushNamed("/reader", arguments: note);

      }else if(type == "link"){
        homeSnackbar(I18nText("Loading"), duration: Duration(milliseconds: 1500));
        LinkCallback callback = await Provider.of<GoodUser>(context, listen: false).openNoteFromUrl(data);

        if(callback.isError){
          homeSnackbar(Text(callback.result));
        }else if(callback.isOther){
          loadweb(data, context);
        }else{
          Note note = callback.result;
          note.source.key = homeScaffold;
          note.source.name = "/";
          
          Navigator.of(context).pushNamed("/reader", arguments: note);
        }
      }
        }catch(e){
      homeSnackbar(Text("$e"));
    }
  }

  failedToUpdateProfile(){
    homeScaffold.currentState.showSnackBar(
      SnackBar(content: I18nText("Failed to Update Profile Picture", child: Text("")))
    );
  }

  Future<void> retrieveLostData(String uid) async {

    if(kIsWeb){
      return;
    }

    ImagePicker picker = ImagePicker();
    final LostData response = await picker.getLostData();
    if (response == null) {
      return;
    }
    if (response.file != null) {
      if (response.type == RetrieveType.image) {
        homeScaffold.currentState.showSnackBar(
          SnackBar(content: I18nText("Uploading Profile Picture", child: Text("")))
        );
        StorageUploadTask task = FirebaseStorage.instance.ref().child("profilepics/$uid").putFile(File(response.file.path));
        task.onComplete.then((value){
          value.ref.getDownloadURL().then((value){
            if(user!=null){
              user.update(
                photoUrl: value
              );
            }else{
              failedToUpdateProfile();
            }
          }).catchError((error){
            failedToUpdateProfile();
          });
        }).catchError((error){
          failedToUpdateProfile();
        });
      }
    } 
  }

  @override
  initState(){
    if(!kIsWeb)
      getShared();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if(!kIsWeb)
      retrieveLostData(widget.user.uid);  

    super.didChangeDependencies();
  }

  reload() async {
    user.notes = (await user.reference.collection("notes")
      .where("state", isLessThan: NoteState.archived.index)
      .orderBy("state").get(GetOptions(source: Source.server))).docs.map(
        (snapshot) => Note(
          snapshot, 
          source: NoteSource(
            key: homeScaffold,
            name: "/"
          )
        )
      ).toList();
  }

  Widget layout({bool standalone = true}){
    return Scaffold(
        key: homeScaffold,
        body:SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              if(user!=null){
                await reload();                
              }else{
                user = Provider.of(context, listen: false);
                await user.init();
                await reload();
              }
            },
            child: ResponsiveBox(
              child: Consumer<GoodUser>(
                builder: (context, value, child) {

                  user = value;

                  List<Note> notes = value.notes;

                  if(user.data==null){
                    Widget progress = Center(
                      child: CircularProgressIndicator(),
                    );

                    return kIsWeb?progress:ConnectivityWidgetWrapper(
                      stacked: false,
                      offlineWidget: CustomScrollView(
                        slivers: [
                          EmptySliver(
                            show: true,
                            name: "offline",
                            title: "You are offline",
                          )
                        ],
                      ),
                      child: progress
                    );
                  }

                  NoteSource source = NoteSource(key: homeScaffold, name: "/");
                  notes.forEach((note){note.source = source;});

                  return CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: standalone?UserHeader(user):SizedBox(),
                              ),
                              OfflineIndicator(),
                              ToggleGrid(show: notes.length>0, user: user)
                            ],
                          )
                        )
                      ),
                      EmptySliver(
                        name: "blank_canvas",
                        show: notes.length==0,
                        body: "There is nothing here... yet",
                      ),
                      NoteGridList(
                        padding: EdgeInsets.only(bottom:16, left: 16, right:16),
                        grid: user.grid,
                        notes: notes,
                      )
                    ],
                  );
                }
              )
            )
          )
        ),
        extendBody: true,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: (){
            Navigator.pushNamed(context,"/editor", arguments: Note.blank(context));
          },
          icon: Icon(Icons.add),
          label: I18nText("New Text",child:Text("")),
        ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Responsive(
      bigChild: BigLayout(
        left: Profile(standalone: false),
        right: layout(standalone: false),
      ),
      child: layout(),
    );
  }
}

class UserHeader extends StatelessWidget{
  final GoodUser user;

  UserHeader(this.user);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfilePic(
          size: 40,
          url: user.photoUrl,
          margin: EdgeInsets.zero,
          child: InkWell(
            onTap: () => Navigator.pushNamed(context,"/profile"),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child:  Padding(
            padding: EdgeInsets.only(top: 8),
            child: I18nText("Hey, _user",child: Text("", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900,  height: 1.2)), translationParams: {"user": "${(user.displayName??"").split(" ")[0]}"})
          )
        )
      ],
    );
  }
}

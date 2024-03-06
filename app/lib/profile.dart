import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:md_notes/auth.dart';
import 'package:md_notes/labels.dart';
import 'package:md_notes/main.dart';
import 'package:md_notes/ui.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:provider/provider.dart';

import 'package:flutter_i18n/flutter_i18n.dart';


const String version = "1.8.2"; //TODO Siempre cambiar esto

class PhotoUploader extends StatefulWidget{

  PhotoUploader(this.user);

  final GoodUser user;

  @override
  State<StatefulWidget> createState() => PhotoUploaderState();
}

enum PhotoState{
  idle,
  loading,
  error
}

class PhotoUploaderState extends State<PhotoUploader>{

  bool loading = false;

  double progess;
  PhotoState state = PhotoState.idle;

  updateImage(ImageSource source) async {

    PickedFile file = await ImagePicker().getImage(
      source: source, 
      preferredCameraDevice: CameraDevice.front
    );
    
    print("saving foto");

    StorageUploadTask task = FirebaseStorage.instance.ref()
    .child('profilepics/${widget.user.uid}')
    .putFile(File(file.path));

    task.events.listen((event) async {
      if(event.type == StorageTaskEventType.success){
        String url = await event.snapshot.ref.getDownloadURL();
        widget.user.update(
          photoUrl: url
        );
        state = PhotoState.idle;
      }else if (event.type == StorageTaskEventType.failure){
        state = PhotoState.error;
      }else if (event.type == StorageTaskEventType.progress){
        int bytes = event.snapshot.bytesTransferred;
        progess = bytes==0?null:bytes/event.snapshot.totalByteCount;
        state = PhotoState.loading;
      }
      print({
        "type": event.type,
        "bytes": event.snapshot.bytesTransferred,
        "total": event.snapshot.totalByteCount,
      });
      setState((){});
    });
    }

  pickImage(){
    showModalBottomSheet(
      context: context,
      builder: (context) => BottomSheet(
        onClosing: (){}, 
        builder: (c) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Tile(
              leading: Icon(Icons.camera_alt),
              title: I18nText("From Camera",child:Text("")),
              onTap: (){
                Navigator.pop(context);
                updateImage(ImageSource.camera);
              },
            ),
            Tile(
              leading: Icon(Icons.image),
              title: I18nText("From Gallery"),
              onTap: (){
                Navigator.pop(context);
                updateImage(ImageSource.gallery);
              },
            )
          ],
        )
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ProfilePic(
          url: widget.user.photoUrl,
          child: GestureDetector(
            onTap: () => state!=PhotoState.loading?pickImage():(){},
            child: Container(
              color: Colors.black38,
              child: Builder(
                builder: (context){
                  if(kIsWeb){
                    return Icon(Icons.error_outline, color: Colors.white);
                  }

                  switch (state) {
                    case PhotoState.loading:
                      return Center(
                        child: Theme(
                          data: Theme.of(context).copyWith(colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.white)),
                          child: CircularProgressIndicator(
                            value: progess,
                          ),
                        )
                      );
                    case PhotoState.error:
                      return Icon(Icons.error_outline, color: Colors.white);
                    default:
                      return Icon(Icons.camera_alt, color: Colors.white);
                  }
                },
              ),
            ),
          )
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: !kIsWeb?I18nText("Change Photo",child:Text("")):SizedBox(),
        )
      ],
    );
  }
}


class ProfileUpdate extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => ProfileUpdateState();
}

class ProfileUpdateState extends State<ProfileUpdate>{

  TextEditingController name = TextEditingController();
  TextEditingController description = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<GoodUser>(
          builder: (context, user, child) {
            name.text = user.displayName;
            description.text = user.description;

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  floating: true,
                  actions: [
                    OfflineIndicator(),
                  ],
                ),
                SliverToBoxAdapter(
                  child: PhotoUploader(user)
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: TextField(
                      controller: name,
                      maxLength: 30,
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.zero,
                        prefixIcon: Icon(Icons.person_outline),
                        hintText: "What's Your Name?"
                      ),
                    ),
                  )
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(left: 16, right: 16, top: 16),
                    child: I18nText("Description", child:Text("Description", style: Theme.of(context).textTheme.bodyLarge,))
                  )
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: description,
                      maxLength: 80,
                      maxLines: null,
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        labelStyle: Theme.of(context).textTheme.headlineSmall,
                        hintText: "Say Something About Yourself"
                      ),
                    ),
                  )
                ),
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        I18nText(kIsWeb?"* You can only change the photo from the app":"* The Photo gets Saved Sutomatically", child: Text("", style: TextStyle(fontSize: 12))),
                        SizedBox(height: 8),
                        PrimaryButton(
                          child: I18nText("Save"),
                          margin: EdgeInsets.zero,
                          onPressed: () async{
                            user.update(
                              displayName: name.text,
                              description: description.text
                            );

                            Navigator.pop(context, user);
                          },
                        ),
                      ],
                    )
                  )
                )
              ],
            );
          },
        ),
      )
    );
  }
}

class ProfilePic extends StatelessWidget{
  final double size;
  final String url;
  final Widget child;
  final EdgeInsets margin;

  ProfilePic({
    this.size = 124, 
    this.url, this.child, 
    this.margin = const EdgeInsets.all(16)
  });

  @override
  Widget build(BuildContext context) {
    return  Padding(
      padding: margin,
      child: Container(
        height: size,
        width: size,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: purple,
          borderRadius: BorderRadius.circular(size*0.25),
          image: DecorationImage(
            fit: BoxFit.cover,
            image: CachedNetworkImageProvider(
              url??"https://the-good-text.com/assets/photos/G.png",
            )
          )
        ),
        child: child
      ),
    );
  }
}

class Profile extends StatefulWidget{
  final bool standalone;

  Profile({this.standalone = true});

  @override
  State<StatefulWidget> createState() => ProfileState();
}

class ProfileState extends State<Profile>{

  List<String> themeNames = ["System", "Light", "Dark"];

  @override
  Widget build(BuildContext context) {
    bool isAnon = FirebaseAuth.instance.currentUser.isAnonymous;
    Color mainColor = Theme.of(context).primaryColor;

    return Material(
      child: SafeArea(
        child: Consumer<GoodUser>(
          builder: (context, user, child) {

            if(user.data.isEmpty){
              return Container(
                color: Theme.of(context).dividerColor,
              );
            }

            return CustomScrollView(
              slivers: [
                widget.standalone?SliverAppBar(
                  floating: true,
                ):SliverToBoxAdapter(),
                SliverToBoxAdapter(
                  child: isAnon?Container(
                    color: mainColor,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: I18nText(
                            "You are on demo mode",
                            child: Text("", style: TextStyle(
                              color: Colors.white,
                              fontSize: Theme.of(context).textTheme.titleSmall.fontSize
                            )),
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            LinkCallback callback = await user.openNoteFromUrl(FlutterI18n.translate(context, "Demo Description"));
                            if(callback.isNote){
                              Navigator.of(context).pushNamed("/reader", arguments: callback.result);
                            }
                          },
                          child: I18nText(
                            "Learn more",
                            child: Text("", style: TextStyle(
                              color: Colors.white, 
                              height: 1,
                              fontSize: Theme.of(context).textTheme.titleSmall.fontSize,
                              decoration: TextDecoration.underline
                            ))
                          ),
                        )
                      ],
                    ),
                  ):SizedBox(),
                ),
                SliverToBoxAdapter(
                  child: Align(
                    alignment: Alignment.center,
                    child:  IntrinsicWidth(
                      child: Column(
                        children: [
                          ProfilePic(
                            url: user.photoUrl,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text("${user.displayName}", style: TextStyle(fontSize: 24,fontWeight: FontWeight.w900)),
                          ),
                          SecondaryButton(
                            child: I18nText("Edit Profile",),
                            padding: EdgeInsets.all(16),
                            margin: EdgeInsets.only(bottom: 4, top: 8, left: 16, right: 16),
                            elevation: 0,
                            onPressed: (){
                              if(widget.standalone){
                                Navigator.pushNamed(context,"/profile/update");
                              }else{
                                showDialog(context: context, builder: (context) => Dialog(
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth: 540
                                    ),
                                    child: ProfileUpdate(),
                                  ),
                                ));
                              }
                            }
                          )
                        ],
                      ),
                    )
                  ),
                ),
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left:16, right:16, bottom: 16),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text("${user.description}", textAlign: TextAlign.center),
                        ),
                      ),
                      Tile(
                        onTap: () => Navigator.pushNamed(context,"/archive", arguments: user),
                        leading: Icon(OMIcons.archive),
                        title: I18nText("Archive")
                      ),
                      Divider(indent: 48,endIndent: 16, height: 5),
                      Tile(
                        onTap: ()=> Navigator.pushNamed(context,"/trash", arguments: user),
                        leading: Icon(OMIcons.delete),
                        title: I18nText("Trash")
                      ),
                      Divider(indent: 16,endIndent: 16),
                    ],
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: 8, left: 16, right: 16, bottom: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        I18nText("Labels",child:Text("", style: Theme.of(context).textTheme.bodyLarge)),
                        user.labels!=null?user.labels.length>0?GestureDetector(
                          onTap: (){
                            if(widget.standalone){
                              Navigator.pushNamed(context,"/labels/edit");
                            }else{
                              showDialog(context: context, builder: (context) => Dialog(
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: 540
                                  ),
                                  child: EditLabels(),
                                ),
                              ));
                            }
                          },
                          child: I18nText("Edit",child: Text("Edit", style: Theme.of(context).textTheme.bodyLarge))
                        ):SizedBox():SizedBox(),
                      ]
                    )
                  ),
                ),
                user.labels!=null?SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => Tile(
                      onTap: () {
                        Navigator.pushNamed(context,"/labels/find", arguments: user.labels[index]);
                      },
                      leading: Icon(Icons.label_outline),
                      title: Text("${user.labels[index]}")
                    ),
                    childCount: user.labels.length
                  )
                ):SliverToBoxAdapter(),
                SliverToBoxAdapter(
                  child: Tile(
                    onTap: (){
                      if(widget.standalone){
                        Navigator.pushNamed(context,"/labels/edit", arguments: true);
                      }else{
                        showDialog(context: context, builder: (context) => Dialog(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: 540
                            ),
                            child: EditLabels(create: true),
                          ),
                        ));
                      }
                    },
                    leading: Icon(Icons.add),
                    title: I18nText("Create New Label", child:Text(""))
                  ),
                ),
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Divider(indent: 16, endIndent: 16),
                      Padding(
                        padding: EdgeInsets.only(left: 16, top: 8, right: 16, bottom: 4),
                        child: I18nText("Support",child:Text("", style: Theme.of(context).textTheme.bodyLarge))
                      ),
                      Tile(
                        onTap: () => loadweb("https://the-good-text.com/help", context), 
                        leading: Icon(OMIcons.helpOutline),
                        title: I18nText("Help Center",child:Text(""))
                      ),
                      Tile(
                        onTap: () => Navigator.pushNamed(context, "/feedback"),
                        leading: Icon(OMIcons.feedback),
                        title: I18nText("Send Feedback",child:Text(""))
                      ),
                      Divider(indent: 16, endIndent: 16),
                      Padding(
                        padding: EdgeInsets.only(left: 16, top: 8, right: 16, bottom: 4),
                        child: I18nText("About",child:Text("", style: Theme.of(context).textTheme.bodyLarge))
                      ),
                      Tile(
                        onTap: ()=> loadweb("https://the-good-text.com/legal/privacy-policy", context),
                        leading: Icon(OMIcons.description),
                        title: I18nText("Privacy Policy",child:Text(""))
                      ),
                      Tile(
                        onTap: ()=> loadweb("https://the-good-text.com/legal/terms-of-use", context),
                        leading: Icon(OMIcons.description),
                        title: I18nText("Terms of Service",child:Text(""))
                      ),
                      Divider(indent: 16, endIndent: 16),
                      Tile(
                        onTap: (){
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: I18nText("Choose theme"),
                              actions: [
                                FlatButton(
                                  textColor: Theme.of(context).primaryColor,
                                  onPressed: () => Navigator.pop(context), 
                                  child: I18nText("Cancel")
                                )
                              ],
                              actionsPadding: EdgeInsets.zero,
                              contentPadding: EdgeInsets.only(left: 8, right: 8, top: 16),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: themeNames.map(
                                  (e) => Row(
                                    children: [
                                      Radio(
                                        value: e, 
                                        groupValue: themeNames[user.themeMode.index], 
                                        onChanged: (value){
                                          Navigator.pop(context);
                                          user.themeMode = ThemeMode.values[themeNames.indexOf(value)];
                                        },
                                      ),
                                      I18nText(e)
                                    ],
                                  )
                                ).toList(),
                              ),
                            ),
                          );
                        },
                        leading: Icon(OMIcons.colorLens),
                        title: I18nText("Theme"),
                        trailing: I18nText(themeNames[appKey.currentState.mode.index]),
                      ),
                      Divider(indent: 16, endIndent: 16),
                      !isAnon?Tile(
                        onTap: ()async{
                          user.kill();
                          await FirebaseAuth.instance.signOut();
                          Navigator.pop(context);
                        },
                        leading: Icon(Icons.exit_to_app),
                        margin: EdgeInsets.only(bottom: 16, left: 16, right: 16, top: 12),
                        title: I18nText("Sign Out", child:Text(""))
                      ):Tile(
                        onTap: (){
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: I18nText("Exit demo mode?"),
                              content: I18nText("DemoDisclaimer"),
                              actions: [
                                FlatButton(
                                textColor: mainColor,
                                  onPressed: () => Navigator.pop(context), 
                                  child: I18nText("Cancel")
                                ),
                                FlatButton(
                                textColor: mainColor,
                                  onPressed: ()async{
                                    user.kill();
                                    await FirebaseAuth.instance.currentUser.delete();
                                    Navigator.popUntil(context, (route) => route.settings.name=="/");
                                  }, 
                                  child: I18nText("Accept")
                                ),
                              ],
                            )
                          );
                        },
                        leading: Icon(Icons.exit_to_app),
                        margin: EdgeInsets.only(bottom: 16, left: 16, right: 16, top: 12),
                        title: I18nText("Exit demo mode")
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: EdgeInsets.only(bottom:16, left:16, right: 16, top:8),
                          child: Text(
                            "v$version", 
                            style: TextStyle(
                              fontSize: 12, 
                              color: Theme.of(context).textTheme.bodySmall.color
                            )
                          ),
                        )
                      )
                    ],
                  ),
                )
              ]
            );
          },
        )
      )
    );
  }
}

class SendFeedBack extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _SendFeedBackState();
}

class _SendFeedBackState extends State<SendFeedBack>{

  User user;
  bool loading = true;
  String from, kAnonymous = "anonymous@the-good-text.com", kName = "Anonymous User";
  TextEditingController controller = TextEditingController();

  @override
  void didChangeDependencies() {
    FirebaseAuth.instance.userChanges().first.then((value){
      setState(() {
        user = value;
        loading = false;
        from = value.email;
      });
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: loading?Center(
          child: CircularProgressIndicator(),
        ):CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              title: I18nText("Send Feedback",child:Text("")),//debuging now
            ),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: DropdownButton<String>(
                      value: from,
                      isExpanded: true,
                      hint: I18nText("From: _variable", child: Text(""),translationParams: {"variable": "${from==kAnonymous?kName:from}"}),
                      items: [
                        DropdownMenuItem(
                          value: kAnonymous,
                          child: I18nText("From: _variable", child: Text(""),translationParams: {"variable": "$kName"})
                        ),
                        DropdownMenuItem(
                          value: "${user.email}",
                          child: I18nText("From: _variable", child: Text(""),translationParams: {"variable": "${user.email}"})
                        )
                      ],
                      onChanged: (value) {
                        setState(() {
                          from = value;
                        });
                      },
                    )
                  ),
                  TextField(
                    maxLines: null,
                    maxLength: null,
                    autofocus: true,
                    controller: controller,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                      hintText: "Have feedback? We'd love to hear it. Have questions? Try help.",
                      hintMaxLines: 3
                    ),
                  ),
                ],
              ),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  PrimaryButton(
                    text: "Send",
                    margin: EdgeInsets.all(16),
                    onPressed: (){
                      FirebaseFirestore.instance.collection("feedback").doc().set({
                        "body": controller.text,
                        "from": from,
                        "version": version,
                        "sentAt": Timestamp.now(),
                        "recivedAt": FieldValue.serverTimestamp()
                      });
                      Navigator.pop(context);
                    },
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
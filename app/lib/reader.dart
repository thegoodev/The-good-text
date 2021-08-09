import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:md_notes/labels.dart';
import 'package:md_notes/note.dart';
import 'package:md_notes/profile.dart';
import 'package:md_notes/ui.dart';
import 'package:outline_material_icons/outline_material_icons.dart';


import 'package:flutter_i18n/flutter_i18n.dart';

class Reader extends StatefulWidget{
  @override
  State<Reader> createState() => ReaderState();
}

class ReaderState extends State<Reader>{

  Note note;
  GlobalKey<ScaffoldState> readerScaffold = GlobalKey<ScaffoldState>();

  @override
  void didChangeDependencies() {
    if(note == null){
      note = ModalRoute.of(context).settings.arguments;
    }
    super.didChangeDependencies();
  }

  import(){
    setState(() {
      note.lastEdit = Timestamp.now();
      note.source.origin = NoteOrigin.app;
    });
    note.save();
  }

  editPressed(){
    if(note.state == NoteState.deleted){
      readerScaffold.currentState.showSnackBar(
        SnackBar(
          content: I18nText("Can't Edit in Trash"), 
          action: SnackBarAction(label: "Restore", onPressed: (){
            setState(() {
              note.state = NoteState.none;
            });
            note.save(isEdit: false);
          })
        )
      );
    }else{
      Navigator.pushNamed(context,"/editor", arguments: note).then(
        (value){
          if(value != null && value.runtimeType == Note){
            setState(() {
              note = value;
            });
          }
        }
      );
    }
  }

  getDate(BuildContext context){

    Text date = Text("", style: TextStyle(color: Theme.of(context).textTheme.bodyText2.color.withOpacity(0.45)));

    if(note.lastEdit == null){
      return I18nText("Unknown Date", child: date);
    }else{
      DateTime now = DateTime.now();
      DateTime lastEdit = note.lastEdit.toDate();

      String mask = "MMM dd, yyyy";

      if(now.year == lastEdit.year){
        mask = "MMM dd";
        if(now.day == lastEdit.day){
          bool is24Hours = MediaQuery.of(context).alwaysUse24HourFormat??true;
          
          if(is24Hours){
            mask = "HH:mm";
          }else{
            mask = "hh:mm a";
          }
        }
      }

      return I18nText(
        "Edited _date",
        child: date, 
        translationParams: {
          "date": "${DateFormat(mask, Localizations.localeOf(context).toLanguageTag()).format(lastEdit)}"
        }
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    Widget layout = note!=null?Scaffold(
      key: readerScaffold,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              actions: [
                OfflineIndicator()
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: getDate(context),
              )
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              sliver: NoteMardown(
                data: note.body,
                sliver: true,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: NoteLabelList(note: note, margin: EdgeInsets.only(right: 8, bottom: 8)),
              ),
            ),
            AuthorBuilder(
              author: note.author,
              show: note.source.origin == NoteOrigin.link,
            )
          ],
        )
      ),
      floatingActionButtonLocation: note.source.origin==NoteOrigin.app?FloatingActionButtonLocation.endDocked:FloatingActionButtonLocation.endFloat,
      floatingActionButton: Builder(
        builder: (context) {
          switch (note.source.origin) {
            case NoteOrigin.file:
              return FloatingActionButton.extended(
                onPressed: import,
                icon: Icon(Icons.publish, color: Colors.white,),
                label: I18nText("Import"),
              );
            case NoteOrigin.app:
              return FloatingActionButton(
                onPressed: editPressed,
                child: Icon(Icons.edit, color: Colors.white),
              );
            default:
              return SizedBox();
          }
        },
      ),
      bottomNavigationBar: NormalBottom(
        note: note,
        onNoteChanged: (value) {
          setState(() {note = value;});
        },
      )
    ):SizedBox();

    return Responsive(
      bigChild: BigLayout(
        left: Profile(standalone: false),
        right: layout,
      ),
      child: layout,
    );
  }
}

class ReaderAction {
  final String text, hint;
  final Function() onTap;
  final IconData iconData;
  final Icon icon;

  ReaderAction({this.text, this.hint, this.onTap, this.icon, this.iconData});
}

class NormalBottom extends StatefulWidget{
  
  final Note note;
  final Function(Note note) onNoteChanged;

  NormalBottom({this.note, this.onNoteChanged});

  @override
  State<StatefulWidget> createState() => NormalBottomState();
}

class NormalBottomState extends State<NormalBottom>{

  Color mainColor;

  @override 
  void didChangeDependencies(){
    mainColor = Theme.of(context).primaryColor;

    super.didChangeDependencies();
  }

  showSnackbar({String text, String action, void Function() onAction, void Function() onClose}){
    bool hasAction = action!=null && onAction!=null;
    Scaffold.of(context).showSnackBar(
      SnackBar(
        content: I18nText(text),
        action: hasAction?SnackBarAction(label: FlutterI18n.translate(context, action), onPressed: onAction):null,
      )
    ).closed.then((value){
      if(onClose!=null)
        onClose();
    });
  }

  Map<String, List<ReaderAction>>getChildren({bool big = false}){
    List<ReaderAction> must = [];
    List<ReaderAction> optional = [];

    if(widget.note.state == NoteState.deleted){
      optional = [
        ReaderAction(
          text: "Restore",
          iconData: Icons.restore,
          onTap: () {
            setState(() {
              widget.note.state = NoteState.none;
            });
            showSnackbar(
              text: "Text Restored", 
              action: "Undo", 
              onAction: (){
                setState(() {
                  widget.note.state = NoteState.none;
                });
                widget.note.save(isEdit: false);
              },
              onClose: () => widget.note.save(isEdit: false)
            );
          },
        ),
        ReaderAction(
          text: "Delete Forever",
          iconData:  Icons.delete_forever,
          onTap: (){
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                content: I18nText("Delete Forever?"),
                contentPadding: EdgeInsets.only(left: 24, right: 24, top: 24),
                actions: [
                  FlatButton(
                    textColor: mainColor,
                    child: I18nText("Cancel"),
                    onPressed: () => Navigator.pop(context),
                  ),
                  FlatButton(
                    textColor: mainColor,
                    child: I18nText("Delete"),
                    onPressed: (){
                      Navigator.popUntil(context, (route) => route.settings.name == "/trash");
                      widget.note.delete();
                    },
                  ),
                ],
              )
            );
          }
        )];
    }else{
      optional = [
        ReaderAction(
          text: "Labels",
          iconData: Icons.label_outline,
          onTap: (){
            if(big){
              showDialog(
                context: context, 
                builder: (context) => Dialog(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 540
                    ),
                    child: SelectLabel(note: widget.note),
                  ),
                )
              ).then((value){
                if(value!=null && value.runtimeType== Note){
                  widget.onNoteChanged(value);
                }
              });
            }else{
              Navigator.pushNamed(context,"/labels/select", arguments: widget.note)
              .then((value){
                if(value!=null && value.runtimeType== Note){
                  widget.onNoteChanged(value);
                }
              });
            }
          }
        ),
      ];

      if(!kIsWeb){
        optional.add(ReaderAction(
          text: "Send Copy",
          iconData: Icons.reply,
          onTap: () => showDialog(context: context, builder: (_) => FileSharing(note: widget.note))
        ));
      }

      if(big){
        optional.add(ReaderAction(
          text: "Get Link",
          icon: Icon(
            widget.note.isSharing?Icons.link:Icons.link_off,
            color: widget.note.isSharing?mainColor:Colors.grey
          ),
          onTap: (){
            showDialog(
              context: context,
              builder: (context) => Dialog(
                child: LinkSharing(note: widget.note)
              ),
            );
          } 
        )); 
      }else{
        optional.add(ReaderAction(
          text: "Copy Link",
          iconData: Icons.content_copy,
          onTap: (){
            copyLink(widget.note);
            showSnackbar(text: "Link Copied to Clipboard");
          } 
        )); 
        optional.insert(optional.length-1, ReaderAction(
          text: widget.note.isSharing?"Link Sharing On":"Link Sharing Off",
          icon: Icon(
            widget.note.isSharing?Icons.link:Icons.link_off,
            color: widget.note.isSharing?mainColor:Colors.grey
          ),
          onTap: () async {
            if(widget.note.isSharing){
              showSnackbar(text: "Turning Link Sharing Off...");
              try{
                widget.note.isSharing = false;
                await widget.note.save(isEdit: false);
              }catch(e){
                showSnackbar(text: e.message);
              }
            }else{
              showSnackbar(text: "Turning Link Sharing On...");
              try{
                widget.note.isSharing = true;
                await widget.note.save(isEdit: false);
                copyLink(widget.note);
                showSnackbar(text: "Link Sharing On and Link Copied");
              }catch(e){
                showSnackbar(text: e.message);
              }
            }
          }
        )); 
      }

      must = [
        ReaderAction(
          text: "Favorite",
          icon: Icon(widget.note.state==NoteState.pinned?Icons.favorite:Icons.favorite_border), 
          onTap: (){
            setState(() {
              if(widget.note.state == NoteState.pinned){
                widget.note.state = NoteState.none;
              }else{
                widget.note.state = NoteState.pinned;
              }
            });
            widget.note.save();
          }
        ),
        ReaderAction(
          text: "Archive-Verb",
          icon: Icon(widget.note.state==NoteState.archived?OMIcons.unarchive:OMIcons.archive),
          onTap: (){
            setState(() {
              if(widget.note.state == NoteState.archived){
                widget.note.state = NoteState.none;

                showSnackbar(
                  text: "Text Unarchived", 
                  action: "Undo",
                  onAction: (){
                    widget.note.state = NoteState.archived;
                  },
                );
              }else{
                Navigator.popUntil(context, (route) => route.settings.name == widget.note.source.name);
                widget.note.state = NoteState.archived;
                widget.note.source.key.currentState.showSnackBar(
                  SnackBar(
                    content: I18nText("Text Archived"),
                    action: SnackBarAction(
                      label: FlutterI18n.translate(context, "Undo"),
                      onPressed: (){
                        widget.note.state = NoteState.none;
                        widget.note.save(isEdit: false);
                      }
                    ),
                  )
                );
              }
            });
            widget.note.save(isEdit: false);
          },
        )
      ];

      ReaderAction trash = ReaderAction(
        text: "Move to Trash",
        iconData: Icons.delete_outline,
        onTap: () {
          Navigator.popUntil(context, (route) => route.settings.name == widget.note.source.name);
          widget.note.state = NoteState.deleted;
          widget.note.save();
          widget.note.source.key.currentState.showSnackBar(
            SnackBar(
              content: I18nText("Text Moved to Trash"),
              action: SnackBarAction(
                label: FlutterI18n.translate(context, "Undo"),
                onPressed: (){
                  widget.note.state = NoteState.none;
                  widget.note.save();
                }
              ),
            )
          );
        },
      );

      if(big){
        must.add(trash);
      }else{
        optional.add(trash);
      }
    }

    return {"must": must, "optional": optional};
  }

  @override
  Widget build(BuildContext context) {
    if(widget.note.source.origin!=NoteOrigin.app){
      return SizedBox();
    }
    return BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: LayoutBuilder(
          builder: (context, constraints) {
            Map<String, List<ReaderAction>> children;

            if(constraints.maxWidth >= 720){
              children = getChildren(big: true);
              List<ReaderAction> all = children["optional"]+children["must"];

              return Row(
                children: all.map(
                  (child) => Tooltip(
                    message: FlutterI18n.translate(context, child.text),
                    child: IconButton(
                      icon: child.icon??Icon(
                        child.iconData
                      ),
                      onPressed: child.onTap
                    )
                  )
                ).toList(),
              );
            }

            children = getChildren();

            return Row(
              children: [
                Tooltip(
                  message: FlutterI18n.translate(context, "More"),
                  child: IconButton(
                    icon: Icon(Icons.more_vert),
                    onPressed: (){
                      showModalBottomSheet(
                        context: context, 
                        builder: (ctx) => BottomSheet(
                          onClosing: (){}, 
                          builder: (c)=> Column(
                            mainAxisSize: MainAxisSize.min,
                            children: children["optional"].map(
                              (child) => Tile(
                                leading: child.icon??Icon(child.iconData),
                                title: I18nText(child.text, child: Text("")),
                                onTap: (){
                                  Navigator.pop(context);
                                  child.onTap();
                                },
                              )
                            ).toList()
                          )
                        )
                      );
                    }
                  ) 
                )
              ]+children["must"].map(
                (child) => Tooltip(
                  message: FlutterI18n.translate(context, child.text),
                  child: IconButton(
                    icon: child.icon??Icon(
                      child.iconData
                    ),
                    onPressed: child.onTap
                  )
                )
              ).toList(),
            );
          },
        ),
    );
  }
}

class FileSharing extends StatefulWidget{

  final Note note;

  FileSharing({this.note});

  @override
  State<StatefulWidget> createState() => FileSharingState();
}

class FileSharingState extends State<FileSharing>{

  Color mainColor;

  @override
  void didChangeDependencies(){
    mainColor = Theme.of(context).primaryColor;
    super.didChangeDependencies();
  }

  NoteFile markdown = NoteFile(
    mimeType: "text/markdown",
    ending: ".md"
  );
  NoteFile plainText = NoteFile(
    mimeType: "text/plain",
    ending: ".txt"
  );

  NoteFile curr;

  setFile(NoteFile value){
    print("Curr before: $curr");
    setState(() {
      curr = value;
    });
    print("Curr after: $curr");
  }

  @override
  Widget build(BuildContext context) {

    if(curr == null)
      curr = markdown;

    TextTheme textTheme = Theme.of(context).textTheme;
    TextStyle baseline = textTheme.bodyText2;
    TextStyle accent = textTheme.bodyText1;

    return AlertDialog(
      title: I18nText("Send Copy"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: I18nText(
              "Choose Format", 
              child: Text(
                "", 
                style: accent.copyWith(
                  fontSize: baseline.fontSize*0.875
                )
              )),
          ),
          Row(
            children: [
              Radio(
                value: markdown, 
                groupValue: curr,
                onChanged: setFile
              ),
              I18nText("Markdown (.md)")
            ],
          ),
          Row(
            children: [
              Radio(
                value: plainText, 
                groupValue: curr,
                onChanged: setFile
              ),
              I18nText("Plain Text (.txt)")
            ],
          ),
        ],
      ),
      actions: [
        FlatButton(
          textColor: mainColor,
          onPressed: () => Navigator.pop(context),
          child: I18nText("Cancel")
        ),
        FlatButton(
          textColor: mainColor,
          onPressed: ()async{
            Navigator.pop(context);
            String title = widget.note.getTitle(context);
            await Share.file(
              "${FlutterI18n.translate(context,"Share")} $title", 
              '$title${curr.ending}', 
              utf8.encode(widget.note.body), 
              curr.mimeType
            );
          }, 
          child: I18nText("Accept")
        )
      ],
      contentPadding: EdgeInsets.only(left: 8, right: 8, top: 24),
    );
  }
}

class LinkSharing extends StatefulWidget{
  final Note note;

  LinkSharing({this.note});

  @override
  LinkSharingState createState() => LinkSharingState();
}

class LinkSharingState extends State<LinkSharing>{
  bool loading = false;

  @override
  Widget build(BuildContext context) {

    Color mainColor = Theme.of(context).primaryColor;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: 540
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          loading?LinearProgressIndicator():SizedBox(),
          Padding(
            padding: EdgeInsets.only(left: 24, right: 24, bottom: 16, top: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.note.isSharing?mainColor:Colors.black38
                      ),
                      child: IconButton(
                        icon: Icon(
                          widget.note.isSharing?Icons.link:Icons.link_off,
                          color: widget.note.isSharing?Colors.white:Colors.white54
                        ), 
                        onPressed: ()async{
                          try{
                            setState(() {
                              loading = true;
                            });
                            widget.note.isSharing = !widget.note.isSharing;
                            await widget.note.save(isEdit: false);
                            setState(() {
                              loading = false;
                            });
                          }catch(e){
                            Scaffold.of(context).showSnackBar(SnackBar(content: Text(e.message)));
                          }
                        }
                      )
                    ),
                    SizedBox(width: 16),
                    I18nText(widget.note.isSharing?"Link Sharing On":"Link Sharing Off", child: Text("", style: Theme.of(context).textTheme.headline6),)
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: Theme.of(context).cardTheme.color
                        ),
                        child: SelectableText("https://the-good-text.com/${widget.note.shareId}/"),
                      )
                    ),
                    SizedBox(width: 8),
                    FlatButton(
                      onPressed: (){
                        Clipboard.setData(ClipboardData(text: "https://the-good-text.com/${widget.note.shareId}/"));
                      }, 
                      child: I18nText("Copy Link"),
                      hoverColor: mainColor.withOpacity(0.05),
                      splashColor: mainColor.withOpacity(0.2),
                      textColor: mainColor,
                    )
                  ],
                ),
                /*Align(
                  alignment: Alignment.bottomRight,
                  child: PrimaryButton(
                    minWidth: 80,
                    text: "Done",
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    margin: EdgeInsets.zero,
                    onPressed: () => Navigator.pop(context),
                  ),
                )*/
              ],
            ),
          )
        ],
      ),
    );
  }
}

class AuthorBuilder extends StatelessWidget{
  final String author;
  final bool show;

  AuthorBuilder({this.author, this.show});

  @override
  Widget build(BuildContext context) {
    return show?SliverFillRemaining(
      hasScrollBody: false,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.doc("users/$author").get(),
          builder: (context, snapshot) {
            if(snapshot.hasData){
              Map user = snapshot.data.data();
              var description = user["description"];
              var name = user["name"];
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Divider(thickness: 1.5),
                  Row(children: [
                    ProfilePic(url: user["photo"], size: 88, margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),),
                    Flexible(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          I18nText(
                            "Written by",
                            child: Text(
                              "", 
                              style: TextStyle(
                                color: Theme.of(context).textTheme.bodyText2.color.withOpacity(0.45)
                              )
                            )
                          ),
                          name!=null?Text(name, style: Theme.of(context).textTheme.headline6):SizedBox(),
                          description!=null?Text(description):SizedBox()
                        ],
                      )
                    )
                  ]),
                  Divider(thickness: 1.5),
                  SizedBox(height: 16)
                ],
              );
            }
            return SizedBox();
          },
        ),
      ),
    ):SliverToBoxAdapter();
  }
}

copyLink(Note note){
  Clipboard.setData(ClipboardData(text: "https://the-good-text.com/${note.shareId}/"));
}

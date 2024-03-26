/*import 'dart:async';

import 'package:flutter/material.dart';
import 'package:md_notes/auth.dart';
import 'package:md_notes/note.dart';
import 'package:md_notes/profile.dart';
import 'package:md_notes/ui.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:provider/provider.dart';

import 'package:flutter_i18n/flutter_i18n.dart';


class SelectLabel extends StatefulWidget {
  final Note note;

  SelectLabel({Key key, this.note}) : super(key: key);

  @override
  _SelectLabelState createState() => _SelectLabelState();
}

class _SelectLabelState extends State<SelectLabel> {

  Note note;
  GoodUser user;

  @override
  void didChangeDependencies() {
    if(widget.note!=null){
      note = widget.note;
    }else{
      note = ModalRoute.of(context).settings.arguments;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async{
        note.save();
        Navigator.pop(context,note);
        return true;
      },
      child: Scaffold(
        body: SafeArea(
          child: Consumer<GoodUser>(
            builder: (context, user, child) {
            return CustomScrollView(
              slivers: [
                SliverAppBar(),
                SliverToBoxAdapter(
                  child: CreateLabel(
                    user: user,
                    onCreated: (value) {
                      setState(() {
                        note.labels.add(value);
                      });
                    },
                  )
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => Tile(
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      leading: Icon(Icons.label_outline),
                      title: Text("${user.labels[index]}"),
                      trailing: Checkbox(
                        value: note.labels.contains(user.labels[index]), 
                        onChanged: (value){
                          if(value){
                            note.labels.add(user.labels[index]);
                          }else{
                            note.labels.remove(user.labels[index]);
                          }
                          setState((){});
                        }
                      ),
                    ),
                    childCount: user.labels.length
                  ),
                )
              ],
            );
            },
          ),
        )
      ),
    );
  }
}

class CreateLabel extends StatelessWidget{
  final GoodUser user;
  final bool autofocus, extraPadding;
  final Function(String value) onCreated;
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<LabelEditorState> _globalKey = GlobalKey<LabelEditorState>();

  CreateLabel({@required this.user, this.autofocus = false, this.extraPadding = true, this.onCreated});

  @override
  Widget build(BuildContext context) {
    return LabelEditor(
      key: _globalKey,
      showEdit: false,
      autofocus: autofocus,
      extraPadding: extraPadding,
      controller: _controller,
      leading: Icon(Icons.add),
      hint: FlutterI18n.translate(context, "Create New Label"),
      onDone: (text){
        String label = text.trim();
        _globalKey.currentState.showError(null);
        if(user.labels.contains(label)){
          _globalKey.currentState.showError("Label already exists");
        }else{
          user.createLabel(label);
          _controller.clear();
          onCreated.call(text);
        }
      },
      onClose: () {
        _controller.clear();
      },
    );
  }
}

class LabelEditor extends StatefulWidget{
  final String hint;
  final bool autofocus, extraPadding, showEdit;
  final Function(String text) onDone, onChange;
  final Function() onClose;
  final TextEditingController controller;
  final Widget leading, fLeading;

  LabelEditor({
    Key key,
    this.hint,
    this.onDone,
    this.onClose,
    this.controller,
    this.autofocus = false,
    this.extraPadding = true,
    this.showEdit = true,
    this.onChange,
    this.leading = const SizedBox(),
    this.fLeading,
  }):super(key: key);

  @override
  State<StatefulWidget> createState() => LabelEditorState();
}

class LabelEditorState extends State<LabelEditor>{

  bool focused = false;
  FocusNode node = FocusNode();
  String e;

  showError(String error){
    setState(() {
      e = error!=null?FlutterI18n.translate(context, error):null;
    });
  }

  @override
  void initState() {
    node.addListener((){
      setState(() {
        focused = node.hasFocus;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    BorderSide side = BorderSide(
      color: Colors.black12,
      width: 1.5,
      style: focused?BorderStyle.solid:BorderStyle.none
    );
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: side,
          bottom: side
        )        
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Tile(
            margin: EdgeInsets.symmetric(horizontal: 16),
            leading: focused?widget.fLeading??widget.leading:widget.leading,
            title: TextField(
              focusNode: node,
              autofocus: widget.autofocus,
              controller: widget.controller??TextEditingController(),
              onSubmitted: widget.onDone,
              onChanged: widget.onChange,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: widget.hint
              ),
            ),
            trailing: focused||widget.showEdit?GestureDetector(
              onTap: focused?(){
                node.unfocus();
                widget.onClose();
              }:() => node.requestFocus(),
              child: Padding(
                padding: widget.extraPadding?EdgeInsets.symmetric(horizontal: 12):EdgeInsets.zero,
                child: Icon(focused?OMIcons.close:OMIcons.edit),
              ),
            ):SizedBox(),
          ),
          ErrorText(e)
        ],
      )
    );
  }
}

class ErrorText extends StatelessWidget{

  final String data;
  final EdgeInsets padding;

  ErrorText(this.data, {this.padding = const EdgeInsets.only(left: 16, right: 16, bottom: 4)});

  @override
  Widget build(BuildContext context) {
    return data!=null?Padding(
      padding: padding,
      child: Text("$data", style: TextStyle(height: 1, fontSize: 13, color: Colors.red)),
    ):SizedBox();
  }
}

class EditLabels extends StatefulWidget {
  final bool create;

  EditLabels({Key key, this.create = false}) : super(key: key);

  @override
  _EditLabelsState createState() => _EditLabelsState();
}

Future<String> deleteLabel(BuildContext context, GoodUser user, String label)async{

  Color mainColor = Theme.of(context).primaryColor;

  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      contentPadding: EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 16
      ),
      title: I18nText("Delete Label?",child:Text("")),
      content: I18nText("Delete Label Disclaimer",child:Text("")),
      actions: [
        FlatButton(
          textColor: mainColor,
          onPressed: (){
            Navigator.pop(context, "canceled");
          },
          child:I18nText("Cancel",child:Text(""))
        ),
        FlatButton(
          textColor: mainColor,
          onPressed: (){
            Navigator.pop(context, "deleted");
            user.deleteLabel(label);
          },
          child: I18nText("Delete",child:Text(""))
        )
      ],
    ) 
  );
}

class _EditLabelsState extends State<EditLabels> {

  bool focusCreate;

  @override
  void didChangeDependencies() {
    focusCreate = ModalRoute.of(context).settings.arguments??widget.create;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<GoodUser>(
          builder: (context, user, child) {
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  title: I18nText("Edit Labels",child:Text("")),
                ),
                SliverToBoxAdapter(
                  child: CreateLabel(
                    user: user,
                    extraPadding: false,
                    autofocus: focusCreate,
                  )
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index){
                      var label = user.labels[index];
                      TextEditingController controller = TextEditingController();
                      GlobalKey<LabelEditorState> key = GlobalKey();
                      controller.text = label;
                      bool showedError = false;

                      return LabelEditor(
                        key: key,
                        controller: controller,
                        leading: Icon(Icons.label_outline),
                        extraPadding: false,
                        onChange: (text) {
                          if(user.labels.contains(text.trim())){
                            showedError = true;
                            key.currentState.showError("Label already exists, will merge");
                          }else{
                            if(showedError){
                              print("Hide error");
                              showedError = false;
                              key.currentState.showError(null);
                            }
                          }
                        },
                        fLeading: GestureDetector(
                          child: Icon(OMIcons.delete),
                          onTap: (){
                            deleteLabel(context, user, label);
                          }
                        ),
                        onDone: (text) {
                          if(text != label){
                            if(user.labels.contains(text)){
                              user.updateLabel(label.trim(), mergeWith: text.trim());
                            }else{
                              user.updateLabel(label.trim(), newLabel: text.trim());
                            }
                          }
                        },
                        onClose: () => controller.text = label,
                      );
                    },
                    childCount: user.labels.length
                  ),
                )
              ],
            );
          },
        ),
      )
    );
  }
}

GlobalKey<ScaffoldState> labelScaffold = GlobalKey<ScaffoldState>();

class AllWithLabel extends StatefulWidget {
  AllWithLabel({Key key}) : super(key: key);

  @override
  _AllWithLabelState createState() => _AllWithLabelState();
}

class _AllWithLabelState extends State<AllWithLabel> {

  String label;
  GoodUser guser;

  @override
  void didChangeDependencies() {

    print("Changed dependencie");

    label = ModalRoute.of(context).settings.arguments;
    
    guser = Provider.of<GoodUser>(context, listen: false);

    guser.getLabeled(label);

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    Widget layout = Scaffold(
      key: labelScaffold,
      body: SafeArea(
        child: Consumer<GoodUser>(
          builder: (context, user, child) {

            List<Note> notes = user.labeled;

            if(notes==null){
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  title: Text("$label"),
                  actions: [
                    ToggleGrid(
                      user: user,
                      show: notes.length>0,
                    ),
                    notes.length>0?PopupMenuButton<int>(
                      onSelected: (value) {
                        switch (value) {
                          case 0:
                            showDialog<String>(
                              context: context,
                              builder: (context) => RenameDialog(
                                label: label,
                                user: user,
                              )
                            ).then((value){
                              if(value!=null&&value!=label){
                                label = value;
                                user.getLabeled(label);
                              }
                            });
                            break;
                          case 1:
                            deleteLabel(context, user, label).then(
                              (value){
                                if(value == "deleted"){
                                  Navigator.pop(context);
                                }
                              }
                            );
                            break;
                          default:
                        }
                      },
                      itemBuilder: (context)=>[
                        PopupMenuItem<int>(
                          value: 0,
                          child: I18nText("Rename Label",child:Text(""))
                        ),
                        PopupMenuItem<int>(
                          value: 1,
                          child: I18nText("Delete Label",child:Text(""))
                        )
                      ]
                    ):SizedBox()
                  ],
                ),
                EmptySliver(
                  show: notes.length==0,
                  name: "filling_system",
                  body: "Nothing with this label yet",
                ),
                NoteGridList(
                  padding: EdgeInsets.only(bottom: 16, left: 16, right: 16, top: 8),
                  grid: user.grid,
                  showArchived: true,
                  notes: notes,
                )
              ],
            );
          },          
        )
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: (){
          Note note = Note.blank(context);
          note.labels = [label];
          Navigator.pushNamed(context,"/editor", arguments: note);
        },
        icon: Icon(Icons.add),
        label: I18nText("New Text"),
      ),
    );
    
    return Responsive(
      bigChild: BigLayout(
        left: Profile(standalone: false),
        right: layout,
      ),
      child: layout,
    );
  }
}

class RenameDialog extends StatefulWidget{

  final String label;
  final GoodUser user;

  RenameDialog({this.label, this.user});

  @override
  State<StatefulWidget> createState() => RenameDialogState();
}

class RenameDialogState extends State<RenameDialog>{

  String error;
  String buttonText = "Rename";
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    controller.text = widget.label;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    Color mainColor = Theme.of(context).primaryColor;

    return AlertDialog(
      title: I18nText("Rename Label"),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            autofocus: true,
            controller: controller,
            onChanged: (value) {
              if(widget.user.labels.contains(value.trim())){
                setState(() {
                  error = "Label already exists, will merge";
                  buttonText = "Merge";
                });
              }else{
                setState(() {
                  error = null;
                  buttonText = "Rename";
                });
                            }
            },
          ),
          ErrorText(error, padding: EdgeInsets.only(top:8),)
        ],
      ),
      actions: [
        FlatButton(
          textColor: mainColor,
          onPressed: (){
            Navigator.pop(context);
          },
          child: I18nText("Cancel")
        ),
        RaisedButton(
          color: Theme.of(context).colorScheme.secondary,
          child: I18nText(buttonText, child: Text("", style: TextStyle(color: Colors.white))),
          onPressed: (){
            if(widget.label!=controller.text){
              if(buttonText=="Rename"){
                widget.user.updateLabel(widget.label, newLabel: controller.text);
              }else if(buttonText=="Merge"){
                widget.user.updateLabel(widget.label, mergeWith: controller.text);
              }
            }
            Navigator.pop(context, controller.text);
          },
        )
      ],
    );
  }
}*/
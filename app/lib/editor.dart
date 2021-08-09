import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:md_notes/note.dart';
import 'package:md_notes/ui.dart';
import 'dart:math' as math;
import 'package:outline_material_icons/outline_material_icons.dart';

class Editor extends StatefulWidget{
  @override
  State<Editor> createState() => EditorState();
}

class EditorState extends State<Editor>{

  Note note;
  TextEditingController controller = TextEditingController();

  @override
  void didChangeDependencies() {
    note = ModalRoute.of(context).settings.arguments;
    controller.text = note.body;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return WillPopScope(
      onWillPop: () async {
        note.body = controller.text;
        if(note.body.isNotEmpty){
          note.save();
        }
        Navigator.pop(context, note);

        return true;
      },
      child: Scaffold(
        body:SafeArea(
          child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              actions: [
                OfflineIndicator(),
              ],
            ),
            SliverPadding(
              padding: EdgeInsets.only(top: 16, bottom: 56, left: 16, right: 16),
              sliver: SliverToBoxAdapter(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: kMaxWidth,
                    ),
                    child: TextField(
                      maxLines: null,
                      maxLength: null,
                      autofocus: note.body.isEmpty,
                      style: TextStyle(
                        color: theme.textTheme.bodyText2.color.withOpacity(0.7),
                        fontSize: 16.5,
                        fontFamily: "monospace"
                      ),
                      textInputAction: TextInputAction.newline,
                      controller: controller,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: FlutterI18n.translate(context, "You can write anything")
                      ),
                    ),
                  )
                )
              ),
            )
          ],
        )),
        bottomSheet: Container(
          width: double.infinity,
          color: theme.cardColor,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                IconButton(
                  icon: Transform.rotate(
                    angle: -math.pi/4,
                    child: Icon(OMIcons.insertLink),
                  ),
                  onPressed: () => setInline(start: "[", end: "]()"),
                ),
                IconButton(
                  icon: Icon(OMIcons.image),
                  onPressed: () => setInline(start: "![", end: "]()"),
                ),
                IconButton(
                  icon: Icon(OMIcons.formatBold), 
                  onPressed: () => setInline(char: "**")
                ),
                IconButton(
                  icon: Icon(OMIcons.formatItalic), 
                  onPressed: () => setInline(char: "_")
                ),
                IconButton(
                  icon: Icon(OMIcons.formatQuote),
                  onPressed: () => setBlock(before: "> ", repeat: true),
                ),
                IconButton(
                  icon: Icon(OMIcons.title),
                  onPressed: () => setBlock(before: "# ", repeat: true),
                ),
                IconButton(
                  icon: Icon(OMIcons.formatListBulleted),
                  onPressed: () => setBlock(before: "- "),
                ),
                IconButton(
                  icon: Icon(OMIcons.checkBox), 
                  onPressed: () => setBlock(before: "- [ ] ")
                ),       
                GestureDetector(
                  onLongPress: () => setBlock(before: "```\n", after: "\n```"),
                  child: IconButton(
                    icon: Icon(OMIcons.code), 
                    onPressed: () => setInline(char: "`")
                  ),
                ),
                IconButton(
                  icon: Icon(OMIcons.keyboardTab), 
                  onPressed: () => setBlock(
                    before: "\t", 
                    repeat: true, 
                    trim: false
                  )
                ),
              ],
            ),
          ),
        )
      ),
    );
  }

  setBlock({String before, String after = "", bool repeat = false, bool trim = true}){
    int offset = before.length;

    TextSelection selection = controller.selection;

    String text = controller.text;

    int base = selection.baseOffset;
    int extent = selection.extentOffset;

    if(base!=-1){
      int place = text.substring(0,base).lastIndexOf("\n");
      int endPlace = text.substring(extent).indexOf("\n");

      if(place == -1)
        place = 0;
      else
        place += "\n".length;

      if(endPlace == -1)
        endPlace = text.length+offset;
      else
        endPlace += offset+extent;
      

      String find = trim?before.trim():before;
      
      if(text.substring(place).startsWith(find)){
        if(repeat){
          before = find;
          offset = find.length;
        }else{
          offset = 0;
        }
      }

      text = addAtPosition(text, before, place);
      text = addAtPosition(text, after, endPlace);

      controller.text = text;
      controller.selection = selection.copyWith(
        baseOffset: base+offset,
        extentOffset: extent+offset
      );
    }
  }

  setInline({String char, String start, String end}){
    int offset = (start??char).length;

    TextSelection selection = controller.selection;

    String text = controller.text;

    int base = selection.baseOffset;
    int extent = selection.extentOffset;

    if(base!=-1 && extent!=-1){
      text = addAtPosition(text, start??char, base);

      text = addAtPosition(text, end??char, extent+offset);

      controller.text = text;
      controller.selection = selection.copyWith(
        baseOffset: base+offset,
        extentOffset: extent+offset
      );
    }
  }
}

String addAtPosition(String source, String data, int index) => source.substring(0,index)+data+source.substring(index);

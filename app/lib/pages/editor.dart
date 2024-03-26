import 'package:flutter/material.dart';
import 'package:md_notes/models/note.dart';
import 'package:md_notes/ui.dart';
import 'dart:math' as math;

class Editor extends StatefulWidget {
  Editor({
    required this.note,
  });
  final NoteModel note;

  @override
  State<Editor> createState() => _EditorState();
}

class _EditorState extends State<Editor> {
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    ColorScheme colorScheme = theme.colorScheme;

    /*
    note.body = controller.text;
        if (note.body.isNotEmpty) {
          note.save();
        }
        Navigator.pop(context, note);
    */

    return Scaffold(
      body: SafeArea(
          child: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
          ),
          SliverPadding(
            padding: EdgeInsets.only(top: 16, bottom: 56, left: 16, right: 16),
            sliver: SliverToBoxAdapter(
              child: Align(
                alignment: Alignment.topCenter,
                child: TextField(
                  maxLines: null,
                  maxLength: null,
                  autofocus: widget.note.body.isEmpty,
                  style: TextStyle(
                    color: colorScheme.onBackground.withOpacity(0.7),
                    fontSize: 16.5,
                    fontFamily: "monospace",
                  ),
                  textInputAction: TextInputAction.newline,
                  controller: controller,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "You can write anything",
                  ),
                ),
              ),
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
                icon: Icon(Icons.insert_link_outlined),
                onPressed: () => setInline("[", end: "]()"),
              ),
              IconButton(
                icon: Icon(Icons.image_outlined),
                onPressed: () => setInline("![", end: "]()"),
              ),
              IconButton(
                icon: Icon(Icons.format_bold_outlined),
                onPressed: () => setInline("**"),
              ),
              IconButton(
                icon: Icon(Icons.format_italic_outlined),
                onPressed: () => setInline("_"),
              ),
              IconButton(
                icon: Icon(Icons.format_quote_outlined),
                onPressed: () => setBlock(before: "> ", repeat: true),
              ),
              IconButton(
                icon: Icon(Icons.title_outlined),
                onPressed: () => setBlock(before: "# ", repeat: true),
              ),
              IconButton(
                icon: Icon(Icons.format_list_bulleted_outlined),
                onPressed: () => setBlock(before: "- "),
              ),
              IconButton(
                  icon: Icon(Icons.check_box_outlined),
                  onPressed: () => setBlock(before: "- [ ] ")),
              GestureDetector(
                onLongPress: () => setBlock(before: "```\n", after: "\n```"),
                child: IconButton(
                  icon: Icon(Icons.code_outlined),
                  onPressed: () => setInline("`"),
                ),
              ),
              IconButton(
                icon: Icon(Icons.keyboard_tab_outlined),
                onPressed: () =>
                    setBlock(before: "\t", repeat: true, trim: false),
              ),
            ],
          ),
        ),
      ),
    );
  }

  setBlock({
    required String before,
    String after = "",
    bool repeat = false,
    bool trim = true,
  }) {
    int offset = before.length;

    TextSelection selection = controller.selection;

    String text = controller.text;

    int base = selection.baseOffset;
    int extent = selection.extentOffset;

    if (base != -1) {
      int place = text.substring(0, base).lastIndexOf("\n");
      int endPlace = text.substring(extent).indexOf("\n");

      if (place == -1)
        place = 0;
      else
        place += "\n".length;

      if (endPlace == -1)
        endPlace = text.length + offset;
      else
        endPlace += offset + extent;

      String find = trim ? before.trim() : before;

      if (text.substring(place).startsWith(find)) {
        if (repeat) {
          before = find;
          offset = find.length;
        } else {
          offset = 0;
        }
      }

      text = addAtPosition(text, before, place);
      text = addAtPosition(text, after, endPlace);

      controller.text = text;
      controller.selection = selection.copyWith(
          baseOffset: base + offset, extentOffset: extent + offset);
    }
  }

  setInline(String start, {String? end}) {
    int offset = start.length;

    TextSelection selection = controller.selection;

    String text = controller.text;

    int base = selection.baseOffset;
    int extent = selection.extentOffset;

    if (base != -1 && extent != -1) {
      text = addAtPosition(text, start, base);

      text = addAtPosition(text, end ?? start, extent + offset);

      controller.text = text;
      controller.selection = selection.copyWith(
          baseOffset: base + offset, extentOffset: extent + offset);
    }
  }
}

String addAtPosition(String source, String data, int index) =>
    source.substring(0, index) + data + source.substring(index);

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:md_notes/models/note.dart';
import 'package:md_notes/widgets/surface_container.dart';

class Editor extends StatefulWidget {
  Editor({
    required this.state,
  });
  final GoRouterState state;

  @override
  State<Editor> createState() => _EditorState();
}

class _EditorState extends State<Editor> {
  late Note note;

  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    if (widget.state.extra != null) {
      note = widget.state.extra as Note;
      controller.text = note.body;
    }

    super.initState();
  }

  handlePop(bool didPop) {
    bool changed = controller.text != note.body;
    if (changed) {
      String path = "users/${note.author}/notes/${note.id}";
      DocumentReference ref = FirebaseFirestore.instance.doc(path);
      ref.update({
        "body": controller.text,
      });
    }
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    TextTheme textTheme = theme.textTheme;
    ColorScheme colorScheme = theme.colorScheme;

    return PopScope(
      canPop: false,
      onPopInvoked: handlePop,
      child: Scaffold(
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
              ),
              SliverPadding(
                padding: EdgeInsets.only(
                  top: 16,
                  bottom: 56,
                  left: 16,
                  right: 16,
                ),
                sliver: SliverToBoxAdapter(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: TextField(
                      maxLines: null,
                      maxLength: null,
                      autofocus: note.body.isEmpty,
                      style: textTheme.bodyMedium!.copyWith(
                        color: colorScheme.onBackground.withOpacity(0.7),
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
          ),
        ),
        bottomSheet: _CommandBar(
          controller: controller,
        ),
      ),
    );
  }
}

class _CommandBar extends StatelessWidget {
  _CommandBar({
    required this.controller,
  });

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    const EdgeInsetsGeometry padding = EdgeInsets.symmetric(
      vertical: 4,
      horizontal: 8,
    );

    return SurfaceContainer(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          vertical: 8,
        ),
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          height: 32,
          child: DividerTheme(
            data: DividerThemeData(indent: 8, endIndent: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  padding: padding,
                  icon: Icon(Icons.text_fields_outlined),
                  onPressed: () => setBlock(before: "# ", repeat: true),
                ),
                VerticalDivider(),
                IconButton(
                  padding: padding,
                  icon: Icon(Icons.format_bold),
                  onPressed: () => setInline("**"),
                ),
                IconButton(
                  padding: padding,
                  icon: Icon(Icons.format_italic),
                  onPressed: () => setInline("_"),
                ),
                IconButton(
                  padding: padding,
                  icon: Icon(Icons.strikethrough_s),
                  onPressed: () => setInline("~"),
                ),
                VerticalDivider(),
                IconButton(
                  padding: padding,
                  icon: Icon(Icons.format_list_bulleted),
                  onPressed: () => setBlock(before: "- "),
                ),
                IconButton(
                  padding: padding,
                  icon: Icon(Icons.format_list_numbered),
                  onPressed: () => setBlock(before: "- "),
                ),
                IconButton(
                  padding: padding,
                  icon: Icon(Icons.checklist),
                  onPressed: () => setBlock(before: "- [ ] "),
                ),
                VerticalDivider(),
                IconButton(
                  padding: padding,
                  icon: Icon(Icons.insert_photo_outlined),
                  onPressed: () => setInline("![", end: "]()"),
                ),
                GestureDetector(
                  onLongPress: () => setBlock(before: "```\n", after: "\n```"),
                  child: IconButton(
                    padding: padding,
                    icon: Icon(Icons.code_rounded),
                    onPressed: () => setInline("`"),
                  ),
                ),
                IconButton(
                  padding: padding,
                  icon: Icon(Icons.format_quote_outlined),
                  onPressed: () => setBlock(before: "> ", repeat: true),
                ),
                IconButton(
                  padding: padding,
                  icon: Icon(Icons.insert_link_outlined),
                  onPressed: () => setInline("[", end: "]()"),
                ),
                VerticalDivider(),
                IconButton(
                  padding: padding,
                  icon: Icon(Icons.format_indent_increase),
                  onPressed: () =>
                      setBlock(before: "\t", repeat: true, trim: false),
                ),
              ],
            ),
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

  String addAtPosition(String source, String data, int index) =>
      source.substring(0, index) + data + source.substring(index);
}

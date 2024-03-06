import 'dart:convert';
import 'dart:math';

import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:md_notes/auth.dart';
import 'package:md_notes/home.dart';
import 'package:md_notes/overflow.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:provider/provider.dart';

import 'main.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:markdown/markdown.dart' as md;


enum NoteState{
  pinned,    //0 
  none,     //1
  archived, //2
  deleted   //3
}

class OverflowMarkdown extends MarkdownWidget {

  final double suggested;
  
  const OverflowMarkdown({
    Key key,
    @required String data,
    bool selectable = false,
    this.suggested,
    MarkdownStyleSheet styleSheet,
    MarkdownStyleSheetBaseTheme styleSheetTheme,
    SyntaxHighlighter syntaxHighlighter,
    MarkdownTapLinkCallback onTapLink,
    String imageDirectory,
    md.ExtensionSet extensionSet,
    MarkdownImageBuilder imageBuilder,
    MarkdownCheckboxBuilder checkboxBuilder,
    Map<String, MarkdownElementBuilder> builders = const {},
  }) : super(
          key: key,
          data: data,
          selectable: selectable,
          styleSheet: styleSheet,
          styleSheetTheme: styleSheetTheme,
          syntaxHighlighter: syntaxHighlighter,
          onTapLink: onTapLink,
          imageDirectory: imageDirectory,
          extensionSet: extensionSet,
          imageBuilder: imageBuilder,
          checkboxBuilder: checkboxBuilder,
          builders: builders,
        );

  @override
  Widget build(BuildContext context, List<Widget> children) {
    return OverFlow(
      tolerance: 1,
      children: children,
      suggested: suggested,
      canvasColor: Theme.of(context).canvasColor,
    );
  }
}

class SliverMarkdown extends MarkdownWidget {
  /// Creates a sliver widget that parses and displays Markdown.
  const SliverMarkdown({
    Key key,
    @required String data,
    bool selectable = false,
    MarkdownStyleSheet styleSheet,
    MarkdownStyleSheetBaseTheme styleSheetTheme,
    SyntaxHighlighter syntaxHighlighter,
    MarkdownTapLinkCallback onTapLink,
    String imageDirectory,
    md.ExtensionSet extensionSet,
    MarkdownImageBuilder imageBuilder,
    MarkdownCheckboxBuilder checkboxBuilder,
    Map<String, MarkdownElementBuilder> builders = const {},
  }) : super(
          key: key,
          data: data,
          selectable: selectable,
          styleSheet: styleSheet,
          styleSheetTheme: styleSheetTheme,
          syntaxHighlighter: syntaxHighlighter,
          onTapLink: onTapLink,
          imageDirectory: imageDirectory,
          extensionSet: extensionSet,
          imageBuilder: imageBuilder,
          checkboxBuilder: checkboxBuilder,
          builders: builders,
        );

  @override
  Widget build(BuildContext context, List<Widget> children) {
    return SliverList(
      delegate: SliverChildListDelegate(children),
    );
  }
}

String generateId(){
  List<int> bytes = [];
  var millis = DateTime.now().millisecondsSinceEpoch;
  var hex = millis.toRadixString(2);
  if(hex.length < 48){
    var diff = 48 - hex.length;
    hex = ('0'*diff)+hex;
  }
  var random = List<int>.generate(72, (index) => Random().nextInt(2));
  hex = hex + random.join();
  for(var i = 0; i < 15; i++){
    bytes.add(int.parse('${hex.substring(i*8, (i*8)+8)}', radix: 2));
  }
  return Base64Encoder.urlSafe().convert(bytes);
}

enum NoteOrigin{
  file,
  link,
  app
}

class NoteSource {
  String name, uri;
  NoteOrigin origin;
  GlobalKey<ScaffoldState> key;

  NoteSource({this.name = "/", this.key, this.origin = NoteOrigin.app, this.uri}){
    if(key==null)
      key = homeScaffold;
  }
}

class NoteFile {
  String mimeType, ending;
  NoteFile({this.ending, this.mimeType});

  @override
  String toString() {
    return "mimeType: $mimeType, ending: $ending";
  }
}

class Note{
  NoteState state;
  NoteSource source = NoteSource();
  String uid;
  DocumentReference ref;
  Map<String, dynamic> data = {};

  Note(DocumentSnapshot snapshot, {this.source}){
    if(source==null)
      source = NoteSource();
    data = snapshot.data();
    ref = snapshot.reference;
    state = NoteState.values[this.data["state"]??0];
  }

  Note.blank(BuildContext context){
    data["labels"] = [];
    state = NoteState.none;
    isSharing = false;
    shareId = generateId();
    ref = Provider.of<GoodUser>(context, listen: false).reference.collection("notes").doc();
  }

  getTitle(BuildContext context){
    String title = FlutterI18n.translate(context, "Untiteled");

    RegExp altTitles = RegExp(r"(.*)(?=\n[=-]+\n)", multiLine: true),
    titles = RegExp(r"^#{1,6} (.*)", multiLine: true);
    
    int index = body.indexOf(titles);
    int altIndex = body.indexOf(altTitles);

    if((index!=-1)&&((altIndex==-1)||(index < altIndex))){
      return titles.firstMatch(body).group(1);
    }

    if((altIndex!=-1)&&((index==-1)||(altIndex < index))){
      return altTitles.firstMatch(body).group(1);
    }

    return title;
  }

  String get body => data["body"]??"";
  set body(String b) => data["body"] = b;

  String get author => ref.parent.parent.id;

  Timestamp get lastEdit => data["last_edit"];
  set lastEdit(Timestamp t) => data["last_edit"] = t;

  String get shareId => data["share_id"];
  set shareId(String b) => data["share_id"] = b;

  bool get isSharing => data["is_sharing"];
  set isSharing(bool b) => data["is_sharing"] = b;

  List get labels => data["labels"]??[];
  set labels(List<String> b) => data["labels"] = b;

  save({isEdit = true}) async {
    data["state"] = state.index;
    data["author"] = author;

    if(isEdit){
      lastEdit = Timestamp.now();
    }
    
    await ref.set(data);
  }

  delete()async{
    await ref.delete();
  }
}

class NoteMardown extends StatelessWidget{
  final String data;
  final ScrollController controller;
  final double suggested;
  final bool preview, sliver;

  NoteMardown({this.controller, this.data, this.suggested, this.preview = false, this.sliver=false});

  Widget checkBuilder(bool checked, BuildContext context){
    return Icon(
      checked ? Icons.check_box : Icons.check_box_outline_blank,
      color: Theme.of(context).colorScheme.secondary,
    );
  }

  Widget imageBuilder(BuildContext context, uri, title, alt) {
    return Align(
      alignment: Alignment.center,
        child: Column(
        children: [
          CachedNetworkImage(
            fit: BoxFit.contain,
            imageUrl: uri.toString(),
            placeholder: (context, string) => AspectRatio(
              aspectRatio: 16/9,
              child: Container(
                color: Theme.of(context).textTheme.bodyMedium.color.withOpacity(0.12),
              )
            ),
            errorWidget: (context, url, error) {
              return Row(
                children: [
                  Icon(Icons.broken_image),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(alt??"")
                  )
                ],
              );
            },
          ),
          title!=null?Padding(
            padding: EdgeInsets.only(top:8, bottom: 16),
            child: Text("$title", style: TextStyle(color: Theme.of(context).textTheme.bodyMedium.color.withOpacity(0.54), fontSize: 16),textAlign: TextAlign.center)
          ):SizedBox()
        ]
      )
    );
  }

  TextStyle getBase(BuildContext context){
    return Theme.of(context).textTheme.bodyMedium;
  }

  MarkdownStyleSheet nss(BuildContext context){

    ThemeData theme = Theme.of(context);
    TextStyle base = getBase(context);
    TextStyle baseHeader = TextStyle(fontWeight: FontWeight.w500);

    TextStyle getHeader(double  multiplier) => baseHeader.copyWith(fontSize: base.fontSize*multiplier);

    return  MarkdownStyleSheet(
      h1: getHeader(2.25),
      h2: getHeader(2),
      h3: getHeader(1.75),
      h4: getHeader(1.5),
      h5: getHeader(1.25),
      h6: getHeader(1),
      a: base.copyWith(
        color: theme.primaryColor
      ),
      code: base.copyWith(
        fontFamily: "monospace",
        fontSize: base.fontSize*0.875,
        color: theme.brightness==Brightness.light?Color(0xFFe83e8c):Color(0xFFFF8AC0),
        backgroundColor: theme.cardColor,
      ),
      p: base,
      listBullet: base,
      blockquoteDecoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            width: 3, 
            color: theme.colorScheme.secondary
          )
        )
      ),
      blockquotePadding: EdgeInsets.only(left: 16)
    );
  }

  MarkdownStyleSheet pss(BuildContext context){
    MarkdownStyleSheet sheet = nss(context);
    TextStyle h5 = sheet.h5;
    TextStyle h6 = sheet.h6;
    return  sheet.copyWith(
      h1: h5,
      h2: h6,
      h3: h6,
      h4: h6,
      h5: h6,
      h6: h6
    );
  }

  String rewriteFootNotes(String source){

    RegExp pattern = RegExp(r"(\[\^(([^\x00-\x7F]|\w|-)+)\]: )(.*((\n*)?([ \t].*)?)*)", multiLine: true, unicode: true);

    String footnotes = pattern.allMatches(source).map((e){
      if(e.groupCount>=4){
        return "1. "+"{#${e[2]}}"+"${e[4]}";
      }else{
        return e[0];
      }
    }).join();

    if(footnotes.isNotEmpty){
      return source.replaceAll(pattern, "")+"\n***\n"+footnotes;
    }

    return source;
  }

  handleLink(String link, BuildContext context) async {

    if(link.isEmpty)
      return;

    if(link.startsWith("#")){
      if(sliver){
        String id = link.substring(1);

        print(id);

        BuildContext _context;
        
        bool reached = false, found = false;
        
        ScrollPosition position = Scrollable.of(context).position;
        
        double initOffset = position.extentBefore;
        
        while(!reached){
          _context = GlobalObjectKey(id).currentContext;

          print(_context);
          
          if(_context==null){
            double newPos = position.extentBefore+position.extentInside;
            position.moveTo(newPos);
          }else{
            found = true;
            await position.ensureVisible(
              context.findRenderObject()
            );
            break;
          }
          reached = position.extentAfter==0;
        }
      }
      return;
    }

    Uri uri = Uri.parse(link);

    if(uri.host == "the-good-text.com"){
      ScaffoldState scaffoldState = Scaffold.of(context);
      LinkCallback callback = await Provider.of<GoodUser>(context, listen: false).openNoteFromUrl(link);

      if(callback.isError){
        scaffoldState.showSnackBar(
          SnackBar(content: I18nText(callback.result))
        );
      }else if(callback.isOther){
        loadweb(link, context);
      }else{
        Note note = callback.result;
        note.source.key = scaffoldState.widget.key;
        note.source.name = ModalRoute.of(context).settings.name;
        
        Navigator.of(context).pushNamed("/reader", arguments: note);
      }
    }else{
      openLink(link);
    }
  }

  @override
  Widget build(BuildContext context) {
    md.ExtensionSet customSet = md.ExtensionSet([
      const md.FencedCodeBlockSyntax(),
      const md.TableSyntax()
    ], [
      FootNoteRef(),
      Id(),
      md.InlineHtmlSyntax(),
      md.StrikethroughSyntax(),
      md.AutolinkExtensionSyntax(),
    ]);

    return sliver?SliverMarkdown(
      extensionSet: customSet,
      builders: {
        "id": IdBuilder()
      },
      syntaxHighlighter: CustomHighlighter(getBase(context)),
      styleSheet: preview?pss(context):nss(context),
      imageBuilder: (uri,title,alt)=> imageBuilder(context, uri, title, alt),
      onTapLink: (link) => handleLink(link, context),
      checkboxBuilder: (v)=> checkBuilder(v, context),
      data: rewriteFootNotes(data),
    ):OverflowMarkdown(
      extensionSet: customSet,
      suggested: suggested,
      syntaxHighlighter: CustomHighlighter(getBase(context)),
      styleSheet: preview?pss(context):nss(context),
      imageBuilder: (uri,title,alt)=> imageBuilder(context, uri, title, alt),
      onTapLink: (link) => handleLink(link, context),
      checkboxBuilder: (v)=> checkBuilder(v, context),
      data: rewriteFootNotes(data),
    );
  }
}

class CustomHighlighter extends SyntaxHighlighter{

  TextStyle base;

  CustomHighlighter(this.base);

  @override
  TextSpan format(String source) {
    return TextSpan(
      text: source, 
      style: base.copyWith(
        color: base.color.withOpacity(0.5), 
        fontFamily: 'monospace', 
        fontSize: base.fontSize*0.875
      )
    );
  }
}

String superIx(int index){
  const List<String> _superscipts = [
    '⁰',
    '¹',
    '²',
    '³',
    '⁴',
    '⁵',
    '⁶',
    '⁷',
    '⁸',
    '⁹'
  ];

  String textContent = "$index";
  String text = "";
  for (int i = 0; i < textContent.length; i++) {
      text += _superscipts[int.parse(textContent[i])];
  }

  return text;
}

Map<int, Map<String,int>> allFootnotes = {};

class IdBuilder extends MarkdownElementBuilder {

  @override
  Widget visitElementAfter(md.Element element, TextStyle preferredStyle) {
    String id = element.attributes['id'];

    print(id);

    return Text("", key: GlobalObjectKey(id));
  }
}

class Id extends md.InlineSyntax{
  static final _pattern = r'{#(([^\x00-\x7F]|\w|-)+)}';

  Id() : super(_pattern);

  @override
  bool onMatch(md.InlineParser parser, Match match) {

    var id = md.Element.text('id','');
    id.attributes["id"] = match[1];
    parser.addNode(id);

    //parser.addNode(link);
    return true;
  }
}

class FootNoteRef extends md.InlineSyntax {
  static final _pattern = r'\[\^(([^\x00-\x7F]|\w)+)\](?!:)';
  

  FootNoteRef() : super(_pattern);

  @override
  bool onMatch(md.InlineParser parser, Match match) {

    var id = match[1];

    allFootnotes.putIfAbsent(parser.document.hashCode, () => {null: 0});

    Map<String,int> dFN = allFootnotes[parser.document.hashCode];

    if(!dFN.containsKey(id)){
      dFN[id] = dFN.values.last+1;
    }

    var anchor = md.Element.text('a', "[${superIx(dFN[id])}]");
    anchor.attributes['href'] = "#$id";
    parser.addNode(anchor);

    //parser.addNode(link);
    return true;
  }
}

class NoteWidget extends StatelessWidget{

  final Note note;
  final double maxHeight;
  final bool showArchived;

  NoteWidget({this.note, this.maxHeight = 200, this.showArchived});

  Color getBorderColor(BuildContext context, NoteState state){
    ThemeData theme = Theme.of(context);

    if(state == NoteState.pinned) return theme.colorScheme.secondary;

    if(state == NoteState.archived) return theme.textTheme.bodyMedium.color;

    return theme.textTheme.bodyMedium.color.withOpacity(0.38);
  }

  Widget getIcon(BuildContext context, NoteState state, bool showArchived){
    ThemeData theme = Theme.of(context);

    if(state == NoteState.pinned) return Transform.rotate( angle: -math.pi/4, child: Icon( 
      Icons.favorite, 
      size: 18,
      color: theme.colorScheme.secondary,
    ));

    if(state == NoteState.archived&&showArchived) return Icon(
      OMIcons.archive,
      size: 18, 
      color: theme.textTheme.bodyMedium.color, 
    );

    return SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          width: 1.5,
          color: getBorderColor(context, note.state)
        ),
        borderRadius: BorderRadius.circular(8)
      ),
      child: InkWell(
        onTap: ()=> Navigator.pushNamed(context,"/reader", arguments: note),
        child: Padding(
          padding: EdgeInsets.only(left: 12, right: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children:[ 
              SizedBox(height: 8),
              getIcon(context, note.state, showArchived),
              SizedBox(height: 4),
              NoteMardown(
                preview: true,
                data: note.body,
                suggested: maxHeight,
              ),
              NoteLabelList(note: note, maxLength: 4),
            ]
          )
        ) 
      )
    );
  }
}

class NoteLabelList extends StatelessWidget{

  final Note note;
  final int maxLength;
  final EdgeInsets margin;

  NoteLabelList({this.note, this.maxLength, this.margin = const EdgeInsets.only(right:4, bottom: 8)});

  @override
  Widget build(BuildContext context) {
    List labels = [];
    ThemeData theme = Theme.of(context);
    if(note.labels.length==0)
      return SizedBox(height: 12);

    if(maxLength==null){
      labels = note.labels;
    }else{
      if(note.labels.length >= maxLength){
        var top = maxLength-1;
        labels = note.labels.take(top).toList()+["+ ${note.labels.length-top}"];
      }else{
        labels = note.labels.take(maxLength).toList();
      }
    }

    return Padding(
      padding: EdgeInsets.only(top: 6),
      child: Wrap(
        children: labels.map((l) => Container(
          padding: EdgeInsets.all(8),
          margin: margin,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: theme.cardTheme.color
          ),
          child: Text(
            "$l", 
            maxLines: 1,
            style: theme.textTheme.bodyMedium.copyWith(height: 1)
          ),
        )).toList(),
      )
    );
  }
}
class NoteGridList extends StatelessWidget{
  final bool showArchived, grid;
  final List<Note> notes;
  final EdgeInsets padding;

  NoteGridList({
    this.grid = true,
    this.showArchived = false,
    this.notes, 
    this.padding = const EdgeInsets.all(16)
  });


  @override
  Widget build(BuildContext context) {
    return grid?NoteGrid(
      padding: padding,
      notes: notes,
      showArchived: showArchived
    ):NoteList(
      padding: padding,
      notes: notes,
      showArchived: showArchived
    );
  }
  
}

class NoteGrid extends StatelessWidget{
  final bool showArchived;
  final List<Note> notes;
  final EdgeInsets padding;

  NoteGrid({
    this.showArchived = false,
    @required this.notes, 
    this.padding = const EdgeInsets.all(16)
  });

  @override
  Widget build(BuildContext context) {
    if(notes == null){
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: CircularProgressIndicator(),
        )
      );
    }
    return notes.length>0?SliverPadding(
      padding: padding,
      sliver: SliverStaggeredGrid.countBuilder(
      crossAxisCount: 4,
      itemCount: notes.length,
      itemBuilder: (BuildContext context, int index) => NoteWidget(
        maxHeight: 150,
        showArchived: showArchived,
        note: notes[index]
      ),
      staggeredTileBuilder: (int index) => StaggeredTile.fit(2),
      mainAxisSpacing: 8.0,
      crossAxisSpacing: 8.0,
    )):SliverToBoxAdapter();
  }
}

class NoteList extends StatelessWidget{
  final bool showArchived;
  final List<Note> notes;
  final EdgeInsets padding;

  NoteList({
    this.showArchived = false,
    @required this.notes, 
    this.padding = const EdgeInsets.all(16)
  });

  @override
  Widget build(BuildContext context) {
     if(notes == null){
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: CircularProgressIndicator(),
        )
      );
    }
    return notes.length>0?SliverPadding(
      padding: padding,
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) => Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: NoteWidget(
              maxHeight: 100,
              showArchived: showArchived,
              note: notes[index]
            )
          ),
          childCount: notes.length
        ),
      )
    ):SliverToBoxAdapter();
  }
}

const firebase_tools = require('firebase-tools');
const functions = require('firebase-functions');
const express = require('express');
const admin = require('firebase-admin');
var serviceAccount = require("./key.json");

const { Remarkable } = require('remarkable');
var md = new Remarkable();

var exphbs = require('express-handlebars');
const { user } = require('firebase-functions/lib/providers/auth');
const { response } = require('express');
var hbs = exphbs.create({
    extname: "hbs",
    defaultLayout: false,
    layoutsDir: "views",
});

const app = express();
app.engine('hbs', hbs.engine);
app.set('view engine', 'hbs');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  apiKey: "AIzaSyCZofyRA8gZIBfR6A7ZJaq01GzhkU7wcgM",
  authDomain: "the-good-text-ef33a.firebaseapp.com",
  databaseURL: "https://the-good-text-ef33a.firebaseio.com",
  projectId: "the-good-text-ef33a",
  storageBucket: "the-good-text-ef33a.appspot.com",
  messagingSenderId: "237457989005",
  appId: "1:237457989005:web:f6b174abc8e00e330331c4",
  measurementId: "G-Y4T0W1WGXW"
});

var db = admin.firestore();

function getItem(html, pattern){

    let content = (pattern.exec(html)||["",""])[1];

    let stripped = content.replace(/<[^>]+>/g,""); 

    return stripped;
}

app.get("/legal/*", async (request, response) => {

    var renderData = {};

    var id = request.params[0];

    var legal = (await db.doc("blogs/legal").get()).data();

    var article = legal.articles[id];

    if(article){
        legal.articles[id].active = "disabled";
        var content = (await article.ref.get()).data().body;
        renderData.data = md.render(content);
    }

    renderData.article = legal.articles;

    return response.render("legal", renderData);
});

app.get("/*/", async (request,response)=>{

    const description = /<p>(.*?)<\/p>/g;
    const title = /<h[1-6]>(.*?)<\/h[1-6]>/g;
    const image = /<img.*?src="(.*?)"[^>]+>/g;

    var shareId = request.path.split("/")[1];

    var docs = (await db.collectionGroup("notes").where('share_id', '==', shareId).limit(1).get()).docs;
    
    var renderData = {
        url: request.url,
        title: "Something is wrong",
    }
    
    if(docs.length === 0){
        renderData.description = "Sorry, we couldn't find the text you were looking for.";
        renderData.image = "https://the-good-text.com/assets/not_found.png";

        return response.render('shared', renderData);
    }

    var nota = docs[0].data();

    if(nota.state === 3){
        renderData.description = "This text no longer exists, the author deleted it.";
        renderData.image = "https://the-good-text.com/assets/trash.png";
    }else if(nota.is_sharing){
        var user = (await docs[0].ref.parent.parent.get()).data();
        var html = md.render(nota.body); 
        renderData.title = getItem(html, title);
        renderData.description = getItem(html, description);
        renderData.image = getItem(html, image);
        renderData.date = nota.last_edit.toDate();
        renderData.data = html;
        renderData.labels = nota.labels;
        renderData.author = {
            name: user.name,
            photo: user.photo,
            description: user.description,
        };
    }else{
        renderData.description = "This text is private, if you got the link we are sorry but they don't longer want you to see this";
        renderData.image = "https://the-good-text.com/assets/private.png";
    }

    return response.render('shared', renderData);
});

exports.app = functions.https.onRequest(app);

exports.create_profile = functions.auth.user().onCreate( async (user) => {

    return db.collection("users").doc(user.uid).set({
        "labels": [],
        "grid": true,
        "photo": "https://the-good-text.com/assets/photos/G.png",
        "name": "",
        "uid": user.uid,
        "theme-mode": 0,
        "description": "",  
    });

});

exports.update_user = functions.firestore
    .document('users/{userId}')
    .onUpdate((change, context) => {
      // Get an object representing the document
      const newValue = change.after.data();

      // ...or the previous value before this update
      const oldValue = change.before.data();

      const first = newValue.name.substr(0,1).toUpperCase();
      const old_first = oldValue.name.substr(0,1).toUpperCase();

      console.log(first, old_first, newValue.photo,  newValue.photo.startsWith("https://the-good-text.com/assets/"));

      if(first!==old_first && newValue.photo.startsWith("https://the-good-text.com/assets/")){
        const letters = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"];
        var leter = letters.includes(first)?first:"G";
        return db.collection("users").doc(context.params.userId).update({photo: `https://the-good-text.com/assets/photos/${leter}.png`});
      }

      return "No se hizo nada";
    });

exports.delete_profile = functions.auth.user().onDelete( async (user) => {

    return db.doc(`users/${user.id}`).delete();
});

exports.empty_trash = functions.pubsub.schedule('0 0 * * *')
.onRun(async (context) => {

  const now = admin.firestore.Timestamp.now();
  const before = new admin.firestore.Timestamp(now.seconds-(604800), now.nanoseconds);

  const query = db.collectionGroup("notes").where("state", "==", 3).where("last_edit", "<=", before);

  const events = await query.get();

  if(events.docs.length === 0){
      console.log("No hay nada que borrar");
      return;
  }

  var batch = admin.firestore().batch();

  events.forEach((event)=> batch.delete(event.ref));

  try{
    await batch.commit();
    console.log(`Found ${events.size} notes to delete`);
  }catch(e){
    return e.message;
  }
  return;
});
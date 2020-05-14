import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'stopp.dart';

class InteractionPage extends StatefulWidget {  
  final  List<Drug> drugsPhoto;

  const InteractionPage({Key key, @required this.drugsPhoto}) : super(key: key);
  @override
  _InteractionPageState createState() => _InteractionPageState();
}

class _InteractionPageState extends State<InteractionPage> with SingleTickerProviderStateMixin {
  static Color bleuC = Color(0xFF74b9ff);
  static Color bleuF = Color(0xFF4da6ff);

  String recherche;

  List<DrugInteraction> _drugsListe = [];
  TextEditingController myController = TextEditingController();
  List<String> categorieUtilisee = [];
  List<Interaction> _interactionListe = [];
  bool interactionDetecte = false;

  @override
  void initState() {
    super.initState();
    for(int i=0;i<widget.drugsPhoto.length;i++){
      _drugsListe.add(new DrugInteraction.transfer(widget.drugsPhoto[i]));
    }
    for(int i=0;i < _drugsListe.length;i++){
      if(!categorieUtilisee.contains(_drugsListe[i].category)){
        categorieUtilisee.add(_drugsListe[i].category);
      } 
    }
    initCheckInteraction(_drugsListe).then((interactionInit){
      setState(() {
        _interactionListe = interactionInit;
        if(_interactionListe.length > 0) interactionDetecte = true;
      });
    });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar:AppBar(
        title: Text("Interactions"),
        ),
        body: Column(children: <Widget>[
          TextField(
            controller: myController,
            onSubmitted: (String value) async {
              DrugInteraction temporaryDrug = await getDrugInteraction(value);
              if(temporaryDrug.category == "pas trouvé") _alertPasTrouve();
              else{
                _drugsListe.add(temporaryDrug);
                if(!categorieUtilisee.contains(temporaryDrug.category)) categorieUtilisee.add(temporaryDrug.category);
                if((temporaryDrug.category2 != null)&&(!categorieUtilisee.contains(temporaryDrug.category2))) categorieUtilisee.add(temporaryDrug.category2);
                if((temporaryDrug.category3 != null)&&(!categorieUtilisee.contains(temporaryDrug.category3))) categorieUtilisee.add(temporaryDrug.category3);
                if((temporaryDrug.category4 != null)&&(!categorieUtilisee.contains(temporaryDrug.category4))) categorieUtilisee.add(temporaryDrug.category4);
                if((temporaryDrug.category5 != null)&&(!categorieUtilisee.contains(temporaryDrug.category5))) categorieUtilisee.add(temporaryDrug.category5);
                List<Interaction> interactions = await checkInteraction(categorieUtilisee,_interactionListe);
                interactions.forEach((element) {
                  if(element.category1 != "vide") _interactionListe.add(element);
                });
                if(_interactionListe.length > 0){
                  setState(() {
                    interactionDetecte = true;
                  });
                } 
            }
            }
          ),
          if(_drugsListe.isNotEmpty) _listeBuild(),
        ],
 
          ),
    );
  }
  Widget _listeBuild(){
    return ListView.builder(
      shrinkWrap: true,
      itemCount: _drugsListe.length+1,
      padding: const EdgeInsets.all(16.0),
      itemBuilder: (context,i){
      return _buildRow(i);
      }
      );
  }
  Widget _buildRow(int i)  {
    if(i == _drugsListe.length){
      return _buildRowFinale();
    }
    else{
    String texte = _drugsListe[i].name+" / "+_drugsListe[i].category;
    if(_drugsListe[i].category2!=null)  texte+=" / "+_drugsListe[i].category2;
    if(_drugsListe[i].category3!=null)  texte+=" / "+_drugsListe[i].category3;
    if(_drugsListe[i].category4!=null)  texte+=" / "+_drugsListe[i].category4;
    if(_drugsListe[i].category5!=null)  texte+=" / "+_drugsListe[i].category5;
    return ListTile(
        title: Text(
          texte,
          textAlign: TextAlign.center,
          ),
    );
    }
  }
  Widget _buildRowFinale() {
    if(interactionDetecte){
      return ListTile(
        title:
          Container(
            height: 50, 
            width: 300,
            child : Center(
              child :RaisedButton(
                child : Text(
                  "Interaction détéctée",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red)
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    new MaterialPageRoute(
                      builder: (context) => new DesInteractions(interactions : _interactionListe),
                    ),
                  );
                }
                )
            )
            )
        );

    }
    else{
      return ListTile(
        title: Text("Pas d'interactions",
        textAlign : TextAlign.center
        )
      );
    }
  }
    void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  Future<DrugInteraction> getDrugInteraction(String name) async{
    DrugInteraction drugInteraction;
    name = toutMajuscule(name);
    QuerySnapshot snapshot = await Firestore.instance.collection('drugs').where('name', isEqualTo: name).getDocuments();
    if(snapshot.documents.isNotEmpty){
        drugInteraction = DrugInteraction.fromMap(snapshot.documents[0].data);
        //on prends toutes les catégories, la première
        DocumentSnapshot category = await Firestore.instance.collection('categories').document(drugInteraction.category).get();
        if(category.data == null) drugInteraction.category = "Pas de catégorie";
        else drugInteraction.category = category.data['name'];
        // la deuxième catégorie
        if(drugInteraction.category2!=null){
          DocumentSnapshot category2 = await Firestore.instance.collection('categories').document(drugInteraction.category2).get();
          if(category2.data == null) drugInteraction.category2 = "Pas de catégorie";
          else drugInteraction.category2 = category2.data['name'];
        }
        //la troisième catégorie
        if(drugInteraction.category3!= null){
          DocumentSnapshot category3 = await Firestore.instance.collection('categories').document(drugInteraction.category3).get();
          if(category3.data == null) drugInteraction.category3 = "Pas de catégorie";
          else drugInteraction.category3 = category3.data['name'];
        }
        // la quatrième catégorie
        if(drugInteraction.category4!=null){
          DocumentSnapshot category4 = await Firestore.instance.collection('categories').document(drugInteraction.category4).get();
          if(category4.data == null) drugInteraction.category4 = "Pas de catégorie";
          else drugInteraction.category4 = category4.data['name'];
        }
        // la cinquième catégorie
        if(drugInteraction.category5!=null){
          DocumentSnapshot category5 = await Firestore.instance.collection('categories').document(drugInteraction.category5).get();
          if(category5.data == null) drugInteraction.category5 = "Pas de catégorie";
          else drugInteraction.category5 = category5.data['name'];
        }
        drugInteraction.stopp = "Pas besoin de stopp pour les interactions";
    }
    else{
        drugInteraction = DrugInteraction("pas trouvé","pas trouvé","pas trouvé","pas trouvé","pas trouvé","pas trouvé","pas trouvé");
    }
    return drugInteraction;
  }
  Future<Interaction> getInteraction(String category1,String category2) async{
    Interaction interaction;
    QuerySnapshot snapshot = await Firestore.instance.collection('interactions').where('categorie1', isEqualTo: category1).where('categorie2',isEqualTo: category2).getDocuments();
    if (snapshot.documents.isEmpty) snapshot = await Firestore.instance.collection('interactions').where('categorie1', isEqualTo: category2).where('categorie2',isEqualTo: category1).getDocuments();
    if(snapshot.documents.isNotEmpty){
        interaction = Interaction.fromMap(snapshot.documents[0].data);
    }
    if(snapshot.documents.isEmpty) {
      interaction = Interaction("vide","vide","vide","vide");
    }
    return interaction;
  }
  Future<List<Interaction>> checkInteraction(List<String> categories, List<Interaction> interactionActuelle) async{
    List<Interaction> interactionTemp = [];
    Interaction interaction;
    for(var i=0;i < categories.length-1; i++){
      interaction = await getInteraction(categories[categories.length-1], categories[i]);
      if((!interactionActuelle.contains(interaction))&&(interaction.explication != "vide")) interactionTemp.add(interaction);
    }
    return interactionTemp;
  }
  Future<List<Interaction>> initCheckInteraction(List<DrugInteraction> drugsInit) async{
    List<Interaction> interactionTemp = [];
    Interaction interaction;
    for(int i=0;i<_drugsListe.length;i++){
      _drugsListe[i] = await getDrugInteraction(_drugsListe[i].name);
    }
    for (int i=0; i < drugsInit.length;i++){
      for (int j = i; j< drugsInit.length;j++){
          interaction = await getInteraction(drugsInit[i].category, drugsInit[j].category); 
          if((!interactionTemp.contains(interaction))&&(interaction.explication != "vide")) interactionTemp.add(interaction);
      }
    }
    return interactionTemp;
  }
  Future<void> _alertPasTrouve() async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Le médicament que vous recherché n\'a pas été trouvé'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('Avez-vous donné la bonne orthographe ?'),
              Text('Il est possible que le médicament ne soit pas enregistré dans la base de donnée.'),
            ],
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('Ok'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
  String toutMajuscule(String string){
    String temp = "";
    for(int i=0;i <string.length;i++){
      temp += string[i].toUpperCase();
    }
    return temp;
  }
}

  class Interaction{
  String category1;
  String category2;
  String explication;
  String mesureAPrendre;

  Interaction(this.category1, this.category2, this.explication, this.mesureAPrendre);
  Interaction.fromMap(map) : category1 = map['categorie1'], category2 = map['categorie2'], explication = map['explication'], mesureAPrendre = map['mesureAPrendre'];
  }

  class DesInteractions extends StatefulWidget {
  final  List<Interaction> interactions;

  const DesInteractions({Key key, @required this.interactions}) : super(key: key);

  @override
  DesInteractionsState createState() => DesInteractionsState();
}
  class DesInteractionsState extends State<DesInteractions> {
    Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Signification des interactions"),
      ),
      body: _build(),
    );
  }
  Widget _build(){
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: widget.interactions.length,
      itemBuilder: (context,i){
        if(i.isOdd) return Divider();
        return Column(children: <Widget>[
        Text(
          "Interaction entre les "+ widget.interactions[i].category1 +" et les "+widget.interactions[i].category2
        ),
        Text(
          "Explication : "+widget.interactions[i].explication
        ),
        Text(
          "Marche à suivre : "+widget.interactions[i].mesureAPrendre
        ),
        ]
        );
      },
      );
  }
}

class DrugInteraction {
  String name;
  String category;
  String category2;
  String category3;
  String category4;
  String category5;
  String stopp;

  DrugInteraction(this.name, this.category, this.category2, this.category3, this.category4, this.category5, this.stopp);
  DrugInteraction.fromMap(map) : name = map['name'], category = map['category'],
     category2 = map['category2'], category3 = map['category3'] ,category4 = map['category4'], category5 = map['category5'];

  DrugInteraction.transfer(Drug drug){
    this.name = drug.name;
    this.category = drug.category;
    this.stopp = drug.stopp;
  }
}
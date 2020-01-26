import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'stopp.dart';

class InteractionPage extends StatefulWidget {  
  @override
  _InteractionPageState createState() => _InteractionPageState();
}

class _InteractionPageState extends State<InteractionPage> with SingleTickerProviderStateMixin {
  static Color bleuC = Color(0xFF74b9ff);
  static Color bleuF = Color(0xFF4da6ff);

  String recherche;

  List<Drug> _drugsListe = [];
  TextEditingController myController = TextEditingController();
  List<String> categorieUtilisee = [];
  List<Interaction> _interactionListe = [];
  bool interactionDetecte = false;

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
              Drug temporaryDrug = await getDrugInteraction(value);
              _drugsListe.add(temporaryDrug);
              categorieUtilisee.add(temporaryDrug.category);
              List<Interaction> interactions = await checkInteraction(categorieUtilisee,_interactionListe);
              interactions.forEach((element) {
                print(element.category1);
                 if(element.category1 != "vide") _interactionListe.add(element);
              });
              if(_interactionListe.length > 0){
                interactionDetecte = true;
              } 
            },
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
    return ListTile(
        title: Text(
          _drugsListe[i].name+" / "+_drugsListe[i].category,
          textAlign: TextAlign.center,
          ),
    );
    }
  }
  Widget _buildRowFinale() {
    if(interactionDetecte){
      return ListTile(
        title: Text("Interaction détectée",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.red)),
        onTap: (){
          Navigator.push(
            context,
            new MaterialPageRoute(
              builder: (context) => new DesInteractions(interactions : _interactionListe),
            ),
          );
        },
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

  Future<Drug> getDrugInteraction(String name) async{
    Drug drug;
    QuerySnapshot snapshot = await Firestore.instance.collection('drugs').where('name', isEqualTo: name).getDocuments();
    if(snapshot.documents.isNotEmpty){
        drug = Drug.fromMap(snapshot.documents[0].data);
        drug.name = drug.name;
        DocumentSnapshot category = await Firestore.instance.collection('categories').document(drug.category).get();
        if(category.data == null) drug.category = "Pas de catégorie";
        else drug.category = category.data['name'];
        drug.stopp = "Pas besoin de stopp pour les interactions";
    }
    return drug;
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
      if(!interactionActuelle.contains(interaction)) interactionTemp.add(interaction);
    }
    return interactionTemp;
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
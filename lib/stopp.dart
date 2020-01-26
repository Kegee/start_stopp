import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mlkit/mlkit.dart';
import 'start.dart';
import 'interaction.dart';

class StoppPage extends StatefulWidget {
  @override
  _StoppPageState createState() => _StoppPageState();
}

class _StoppPageState extends State<StoppPage> with SingleTickerProviderStateMixin{
  static Color bleuC = Color(0xFF74b9ff);
  static Color bleuF = Color(0xFF4da6ff);
  File _image;
  List<VisionText> _textDetected = [];
  List<Drug> _drugs = [];
  FirebaseVisionTextDetector textDetector = FirebaseVisionTextDetector.instance;
  Widget _widget = Text(
      "Veuillez prendre une photo de l'ordonnance",
      style: TextStyle(
        fontSize: 22,
        color: bleuF,
      ),
      textAlign: TextAlign.center,
    );
  bool _olderThan65 = false;

  @override
  Widget build(context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        drawer: Drawer(
          child: ListView(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: ListTile(
                  leading: Container(
                    width: 50.0,
                    height: 50.0,
                    child: CircleAvatar(
                      backgroundImage: AssetImage('assets/launcher/drug.png'),
                      backgroundColor: Colors.white,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                        color: bleuF,
                      ),
                      shape: BoxShape.circle
                    ),
                  ),
                  title: Text(
                    'Start & Stopp App',
                    style: Theme.of(context).textTheme.title,
                  ),
                ),
              ),
              Divider(
                height: 1,
              ),
              ListTile(
                leading: Icon(Icons.error_outline, color: Colors.red),
                title: Text(
                  'Scanner d\'Ordonnance',
                  style: Theme.of(context).textTheme.subtitle,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    new MaterialPageRoute(
                      builder: (context) => new StoppPage()
                    ),
                  );
                },
              ),
              Divider(
                height: 1,
              ),
              ListTile(
                leading: Icon(Icons.check_circle, color: Colors.green),
                title: Text(
                  'Sélecteur de Symptômes',
                  style: Theme.of(context).textTheme.subtitle,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    new MaterialPageRoute(
                      builder: (context) => new StartPage()
                    ),
                  );
                },
              ),
              Divider(
                height: 1,
              ),
              ListTile(
                leading: Icon(Icons.category,color: Colors.green),
                title: Text(
                  'Interactions',
                  style: Theme.of(context).textTheme.subtitle,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    new MaterialPageRoute(
                      builder: (context) => new InteractionPage()
                    ),
                  );
                },
              ),
              Divider(
                height: 1,
              ),
              ListTile(
                leading: Icon(Icons.help, color: bleuF),
                title: Text(
                  'Aide et commentaires',
                  style: Theme.of(context).textTheme.subtitle,
                ),
                onTap: () {
                  return showDialog(
                    context: context,
                    builder: (BuildContext context){
                      return AlertDialog(
                        title: Text("Contacter le développeur"),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children:[
                            Text(
                              "N'hésitez pas à me contacter pour toutes questions ou commentaires concernant l'utilisation ou le développement de l'application.\n",
                              textAlign: TextAlign.justify,
                            ),
                            Text(
                              "antoineconqui@gmail.com",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: bleuF)
                            ),
                          ],
                        ),
                        actions: <Widget>[
                          FlatButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(
                              "Ok",
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ],
                      );
                    }
                  );
                },
              ),
            ],
          ),
        ),
        appBar: AppBar(
          backgroundColor: bleuC,
          centerTitle: true,
          title: Text(
            'Scanner d\'Ordonnance',
            style: TextStyle(
              fontSize: 25,
              fontFamily: 'OpenSans',
              color: Colors.white,
            ),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.help),
              onPressed: () {},
            ),
          ],
        ),
        body: _buildBodyStop(),
        floatingActionButton: Container(
          height: 200,
          child: Stack(
            children: <Widget>[
              Align(
                alignment: Alignment.bottomRight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      height: 60,
                      child: FloatingActionButton(
                        heroTag: 'olderThan65',
                        onPressed: (){
                          setState(() {
                            _olderThan65 = !_olderThan65; 
                          });
                        },
                        backgroundColor: (_olderThan65) ? bleuF : Colors.white,
                        foregroundColor: (_olderThan65) ? Colors.white : bleuF,
                        shape: CircleBorder(
                          side: BorderSide(
                            color: bleuF,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          '+65',
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 10,
                    ),
                    Container(
                      height: 60,
                      child: FloatingActionButton(
                        heroTag: 'delete',
                        onPressed: (){
                          setState(() {
                           _drugs = [];
                           _widget =
                            Text(
                              "Veuillez prendre une photo de l'ordonnance",
                              style: Theme.of(context).textTheme.title,
                              textAlign: TextAlign.center,
                            );
                          });
                        },
                        child: Icon(Icons.delete),
                        backgroundColor: bleuF,
                      ),
                    ),
                    Container(
                      height: 10,
                    ),
                    Container(
                      height: 60,
                      child: FloatingActionButton(
                        heroTag: 'photo',
                        onPressed: () async {
                          try {
                            _image = await ImagePicker.pickImage(source: ImageSource.camera);
                            //_image = await ImagePicker.pickImage(source: ImageSource.gallery);
                            setState(() {
                              _widget = CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(bleuF),
                              );
                            });
                            try {
                              _textDetected = await textDetector.detectFromPath(_image?.path);
                              _drugs = [];
                              try {
                                List<Drug> drugs = await getDrugs();
                                setState(() {
                                  _drugs = drugs;
                                  if(_drugs.length == 0)
                                    _widget = Text(
                                      "Aucun médicament trouvé",
                                      style: Theme.of(context).textTheme.body1,
                                      textAlign: TextAlign.center,
                                    );
                                });
                              } catch (e) {
                              }
                            } catch (e) {
                            }
                          } catch (e) {
                          }

                        },
                        child: Icon(Icons.add_a_photo),
                        backgroundColor: bleuF,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        )
      ),
    );
  }

  Widget _buildBodyStop(){
    return Container(
      child: Column(
        children: <Widget>[
          _buildList(),
        ],
      ),
    );
  }

  Widget _buildList() {
    if (_drugs.length == 0)
      return Expanded(
        child:Container(
          child: Center(
            child: _widget,
          ),
        ),
      );
    return Expanded(
      child: Container(
        child: ListView.separated(
          separatorBuilder: (context, index) => Divider(
            color: bleuF,
          ),
          padding: const EdgeInsets.all(1.0),
          itemCount: _drugs.length,
          itemBuilder: (context, i) {
            return _buildRow(_drugs[i]);
        }),
      ),
    );
  }

  Widget _buildRow(drug) {
    if(drug.stopp=='')
      return ListTile(
        leading: Icon(
          Icons.check,
          color: Colors.green,
        ),
        title: Padding(
          padding: EdgeInsets.fromLTRB(40.0,0.0,0.0,0.0),
          child: Text(
            drug.name,
            style: Theme.of(context).textTheme.body1,
            textAlign: TextAlign.left,
          ),
        ),
      );
    return ExpansionTile(
      leading: Icon(
        Icons.warning,
        color: Colors.red,
      ),
      title: Padding(
        padding: EdgeInsets.fromLTRB(40.0,0.0,0.0,0.0),
        child: Text(
          drug.name,
          style: Theme.of(context).textTheme.body1,
          textAlign: TextAlign.left,
        ),
      ),
      children:<Widget>[
        Text(
          drug.category,
          style: TextStyle(
            color: Colors.red,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.left,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Text(
          drug.stopp[0].toUpperCase()+drug.stopp.substring(1).toLowerCase(),
          style: TextStyle(
            color: Colors.red,
            fontSize: 15.0
          ),
          textAlign: TextAlign.justify,
        ),
        ),
      ],
    );
  }

  Future<Drug> getDrug(String name) async {
    Drug drug;
    QuerySnapshot snapshot = await Firestore.instance.collection('drugs').where('name', isEqualTo: name).getDocuments();
    if(snapshot.documents.isNotEmpty){
        drug = Drug.fromMap(snapshot.documents[0].data);
        drug.name = eachfirstUpper(drug.name);
        DocumentSnapshot category = await Firestore.instance.collection('categories').document(drug.category).get();
        drug.category = eachfirstUpper(category.data['name']);
        DocumentSnapshot stopp = await Firestore.instance.collection('stopp').document(category.data['stopp']).get();
        drug.stopp = stopp.data['text'];
    }
    return drug;
  }

  Future<List<Drug>> getDrugs() async {
    List<Drug> drugs = [];
    RegExp reg = RegExp(r'0|1|2|3|4|5|6|7|8|9|\(|\)|\*|\.');
    for (VisionText block in _textDetected)
      for (String line in block.text.split("\n"))
        for (String word in line.split(RegExp(r" |/"))){
          Drug drug = await getDrug(word.toUpperCase());
          if(drug == null && word.length > 3 && reg.allMatches(word).length==0){
            if(word == word.toUpperCase())
              drug = Drug(eachfirstUpper(word),'','');
          }
          if(drug!=null && !drugs.contains(drug))
            drugs.add(drug);
        }
    return drugs;
  }

  String eachfirstUpper(String string){
    List<String> list = [];
    string.split(' ').forEach((word) {
      list.add(word[0].toUpperCase()+word.substring(1).toLowerCase());
    });
    return list.join(' ');
  }
}

class Drug {
  String name;
  String category;
  String stopp;

  Drug(this.name, this.category, this.stopp);
  Drug.fromMap(map) : name = map['name'], category = map['category'];
}
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'stopp.dart';
import 'interaction.dart';

class StartPage extends StatefulWidget {
  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> with SingleTickerProviderStateMixin{
  static Color bleuC = Color(0xFF74b9ff);
  static Color bleuF = Color(0xFF4da6ff);
  Symptome _selectedSymptome;
  bool _symptomesLoaded = false;
  
  List<bool> _checked;
  List<Symptome> symptomesList = [];
  List<String> _drugs = [];
  Widget _widget = Column(
    children: <Widget>[
      Text("Chargement des symptômes"),
      CircularProgressIndicator(),
    ],
  );

  @override
  initState() {
    super.initState();
    getSymptomes().then((newSymptomesList){
      setState(() {
        symptomesList = newSymptomesList;
        _widget = Text(
          "Veuillez renseigner les symptômes du patient",
          style: TextStyle(
            fontSize: 22,
            color: bleuF,
          ),
          textAlign: TextAlign.center,
        );
        _symptomesLoaded = true;
      });
    });
  }

  @override
  Widget build(context){
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
            'Sélecteur de Symptômes',
            style: TextStyle(
              fontSize: 23,
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
        body: _buildBody(),
        // floatingActionButton: Container(
        //   height: 200,
        //   child: Stack(
        //     children: <Widget>[
        //       Align(
        //         alignment: Alignment.bottomRight,
        //         child: Column(
        //           crossAxisAlignment: CrossAxisAlignment.end,
        //           children: <Widget>[
        //             Container(
        //               height: 60,
        //               child: FloatingActionButton(
        //                 heroTag: 'olderThan65',
        //                 onPressed: (){
        //                   setState(() {
        //                     _olderThan65 = !_olderThan65; 
        //                   });
        //                 },
        //                 backgroundColor: (_olderThan65) ? bleuF : Colors.white,
        //                 foregroundColor: (_olderThan65) ? Colors.white : bleuF,
        //                 shape: CircleBorder(
        //                   side: BorderSide(
        //                     color: bleuF,
        //                     width: 2,
        //                   ),
        //                 ),
        //                 child: Text(
        //                   '+65',
        //                   style: TextStyle(
        //                     fontSize: 20,
        //                   ),
        //                 ),
        //               ),
        //             ),
        //           ],
        //         ),
        //       )
        //     ],
        //   ),
        // )
      ),
    );
  }

  Widget _buildBody(){
    return Container(
      child: Column(
        children: <Widget>[
          Visibility(
            visible: _symptomesLoaded,
            child: Center(
              child: DropdownButtonHideUnderline(
                child:  DropdownButton<Symptome>(
                  value: _selectedSymptome,
                  items: symptomesList.map((Symptome symptome) {
                    return DropdownMenuItem<Symptome>(
                      value: symptome,
                      child: Center(child:Text(symptome.name)),
                    );
                  }).toList(),
                  onChanged: (Symptome symptome) {
                    setState(() {
                      _selectedSymptome = symptome;
                      _checked = List.filled(_selectedSymptome.drugsToGive.length, false);
                      _drugs = symptome.drugsToGive;
                    });
                  },
                  hint: Center(child:Text('Choisissez un symptôme')),
                  isExpanded: true,
                  // isDense: true,
                ),
              ),
            ),
          ),
          Visibility(
            visible: _symptomesLoaded,
            child: Divider(
              color: bleuF,
              thickness: 2,
            ),
          ),
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
    return Container(
        height: 300,
        child: Card(
          elevation: 3,
          margin: EdgeInsets.all(30),
          child:Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  _selectedSymptome.name,
                  style: TextStyle(
                    fontSize: 30,
                    fontFamily: 'OpenSans'
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                  padding: EdgeInsets.only(left: 30),
                  child : Text(
                      'Médicaments à prescrire :',
                      style: TextStyle(
                        fontSize: 20,
                        decoration: TextDecoration.underline,
                      ),
                      textAlign: TextAlign.left,
                    ),
              ),
              
              Expanded(
                child: Container(
                  margin: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: bleuF)
                  ),
                  child: ListView.separated(
                    separatorBuilder: (context, index) => Divider(
                      color: bleuF,
                    ),
                    padding: const EdgeInsets.all(1.0),
                    itemCount: _drugs.length,
                    itemBuilder: (context, i) {
                      return _buildRow(_drugs[i], i);
                  }),
                ),
              ),
            ]
          ),
        )
    );
  }

  Widget _buildRow(drug, i) {
    
      return ListTile(
        leading: Checkbox(
          value: _checked[i],
          onChanged: (context){
            setState( () {
              _checked[i] = !_checked[i];
            });
          },
        ),
        title: Text(
            drug,
            style: Theme.of(context).textTheme.body1,
            textAlign: TextAlign.left,
          ),
      );
  }

  Future<List<Symptome>> getSymptomes() async{
    List<Symptome> symptomes = [];
    QuerySnapshot snapshot = await Firestore.instance.collection('Catégories_start').getDocuments();
    if(snapshot.documents.isNotEmpty){
      for (var i = 0; i < snapshot.documents.length; i++) {
        Symptome symptome = Symptome.fromMap(snapshot.documents[i].data);
        List<String> drugsToGive = [];
        for (var j = 0; j < symptome.references.length; j++) {
          DocumentSnapshot drug = await symptome.references[j].get();
          drugsToGive.add(drug.data['name']);
        }
        symptome.drugsToGive = drugsToGive;
        symptomes.add(symptome);
      }
    }
    return symptomes;  
  }

}

class Symptome {
  String name;
  List<dynamic> references;
  List<String> drugsToGive;

  Symptome(this.name, this.drugsToGive);
  Symptome.fromMap(map) : name = map['name'], references = map['drugs'];
}
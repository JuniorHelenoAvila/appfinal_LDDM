import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
/*
a collection 'anotacoes' é a minha agenda de contatos, mas acabei deixando isso pois foi como o cara fez no video que a Ivre mandou
 */

class HomePage extends StatelessWidget {
  //static String tag = '/home';

  @override
  Widget build(BuildContext context) {
    var snapshots = FirebaseFirestore.instance
        .collection('anotacoes')
        .where('excluido', isEqualTo: false)
        //.orderBy('tecnica')
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: Text('Smoke combos notes'), // titulo apenas na pagina
      ),
      backgroundColor: Colors.grey[200],
      body: StreamBuilder(
          stream: snapshots,
          builder: (
            BuildContext context,
            AsyncSnapshot<QuerySnapshot> snapshot,
          ) {
            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } // fim if 1

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } // fim if 2

            if (snapshot.data.docs.length == 0) {
              return Center(child: Text('No notes yet'));
            } // fim if 3

            return ListView.builder(
              itemCount: snapshot.data.docs.length,
              itemBuilder: (BuildContext context, int i) {
                //var item = snapshot.data.docs[i].data;
                var item = snapshot.data.docs[i]
                    .get('tecnica'); // assim estou pegando o campo apenas
                /***
                 * descobrir como fazer para pegar cada campo, acho que vou tentar usar o meanotacoes usando o forEach
                 */
                var doc = snapshot.data.docs[i];

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  margin: const EdgeInsets.all(5),
                  child: ListTile(
                    isThreeLine: true,
                    leading: IconButton(
                      icon: Icon(snapshot.data.docs[i].get('feito')
                          ? Icons.check_circle
                          : Icons.check_circle_outline),
                      iconSize: 32,
                      onPressed: () => doc.reference.update({
                        'feito': !snapshot.data.docs[i].get('feito'),
                      }),
                    ),
                    title: Text(
                        item), // se colocar item[i] ou algo do genero ele está pegando só a primeira letra
                    subtitle: Text(snapshot.data.docs[i]
                        .get('notes')), // solução para deixar igual o do cara
                    trailing: CircleAvatar(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      child: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => doc.reference.update({
                                'excluido': true,
                              })),
                    ),
                  ),
                );
                /***
                 * meanotacoes acima prestar atenção
                 */
              },
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => modalCreate(context), // fim onPressed
        tooltip: 'Adicionar novo',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  modalCreate(BuildContext context) {
    // GlobalKey<FormState> form = GlobalKey<FormState>(); // funfa também, o cara do video mudou apenas, mas tem varias maneiras
    var form = GlobalKey<FormState>();

    var tecnica = TextEditingController();
    var notes = TextEditingController();

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Criar novo contato'),
            content: Form(
              key: form,
              child: ListView(
                children: <Widget>[
                  // primeiro campo a ser inserido - tecnica
                  Text('tecnica'),
                  TextFormField(
                      decoration: InputDecoration(
                          hintText: 'Ex.: GetOverHere',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15))),
                      controller: tecnica,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Este campo nao pode ser vazio';
                        } // fim if do validator
                        return null;
                      } // fim do validator
                      ),
                  // segundo campo a ser inserido - notes
                  SizedBox(height: 5),
                  Text('notes'),
                  TextFormField(
                      decoration: InputDecoration(
                          hintText: 'cima x baixo b L y R a',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15))),
                      controller: notes,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Este campo nao pode ser vazio';
                        } // fim if do validator
                        return null;
                      } // fim do validator
                      ),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Fechar')),
              FlatButton(
                  onPressed: () async {
                    if (form.currentState.validate()) {
                      print('valido');
                      await FirebaseFirestore.instance
                          .collection('anotacoes')
                          .add({
                        'tecnica': tecnica.text,
                        'notes': notes.text,
                        'excluido': false,
                        'feito': false
                      });

                      Navigator.of(context)
                          .pop(); // fecha a janela depois de salvar
                    }
                  },
                  color: Colors.green,
                  child: Text('Salvar')),
            ],
          );
        } // fim builder do showDialog
        );
  }
}

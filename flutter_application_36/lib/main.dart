import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
//import 'package:audio_picker/audio_picker.dart';

void main() {
  runApp(MyApp());
}

class Event {
  String title;
  DateTime date;
  String description;
  File photo;
  File audio;

  Event({required this.title, required this.date, required this.description, required this.photo,required this.audio});
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Registro de Eventos',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Event> events = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro de Eventos'),
      ),
      body: ListView.builder(
        itemCount: events.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(events[index].title),
            subtitle: Text(events[index].date.toString()),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventDetailPage(event: events[index]),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewEventPage(
                onSave: (Event event) {
                  setState(() {
                    events.add(event);
                  });
                },
              ),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class NewEventPage extends StatefulWidget {
  final Function onSave;

  NewEventPage({required this.onSave});

  @override
  _NewEventPageState createState() => _NewEventPageState();
}

class _NewEventPageState extends State<NewEventPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  late DateTime _selectDate;
  late File _imageFile;
  late File _audioFile;

  Future<void>_selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectDate)
      setState(() {
        _selectDate = picked;
      });
  }

  Future<void> _getImage() async {
    final pickedFile = await ImagePicker().getImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = File(pickedFile.path);
    });
  }

  Future<void> _getAudio() async {
    var AudioPicker;
    final pickedFile = await AudioPicker.pickAudio();
    setState(() {
      _audioFile = File(pickedFile.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    var _selectedDate;
    return Scaffold(
      appBar: AppBar(
        title: Text('Nuevo Evento'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: 'Título'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Por favor ingrese un título';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Descripción'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Por favor ingrese una descripción';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(_selectDate == null
                          ? 'No ha seleccionado fecha'
                          : 'Fecha seleccionada: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                    ),
                  : FlatButton(
                      onPressed: () => _selectDate,
                      child: Text('Seleccionar Fecha'),
                      textColor: Theme.of(context).primaryColor,
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                _imageFile != null
                    ? Image.file(
                        _imageFile,
                        height: 100,
                      )
                    : FlatButton(
                        onPressed: () => _getImage(),
                        child: Text('Seleccionar Foto'),
                      ),
                SizedBox(height: 16.0),
                _audioFile != null
                    ? Text('Archivo de audio seleccionado')
                    : FlatButton(
                        onPressed: () => _getAudio(),
                        child: Text('Seleccionar Audio'),
                      ),
                SizedBox(height: 16.0),
                RaisedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate() &&
                        _selectedDate != null &&
                        _imageFile != null &&
                        _audioFile != null) {
                      final newEvent = Event(
                        title: _titleController.text,
                        date: _selectedDate,
                        description: _descriptionController.text,
                        photo: _imageFile,
                        audio: _audioFile,
                      );
                      widget.onSave(newEvent);
                      Navigator.pop(context);
                    } else {
                      Scaffold.of(context).showSnackBar(SnackBar(
                        content: Text('Por favor complete todos los campos'),
                      ));
                    }
                  },
                  child: Text('Guardar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  FlatButton({required Future<void> Function() onPressed, required Text child}) {}
}

RaisedButton({required Null Function() onPressed, required Text child}) {
}

class EventDetailPage extends StatelessWidget {
  final Event event;

  EventDetailPage({required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(event.title),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Fecha: ${event.date.day}/${event.date.month}/${event.date.year}'),
            SizedBox(height: 16.0),
            Text('Descripción: ${event.description}'),
            SizedBox(height: 16.0),
            Image.file(
              event.photo,
              height: 200,
            ),
            SizedBox(height: 16.0),
           RaisedButton(
              onPressed: () {
                // Aquí puedes implementar la lógica de reproducción de audio
              },
              child: Text('Reproducir Audio'),
            ),
          ],
        ),
      ),
    );
  }
  
  RaisedButton({required Null Function() onPressed, required Text child}) {}
}


//Aidil Garcia 2022/0430
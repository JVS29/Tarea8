import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Elecciones App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: EleccionesApp(),
    );
  }
}

class EleccionesApp extends StatefulWidget {
  @override
  _EleccionesAppState createState() => _EleccionesAppState();
}

class _EleccionesAppState extends State<EleccionesApp> {
  int _currentIndex = 0;

  List<Eleccion> elecciones = [];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void agregarEleccion(Eleccion eleccion) {
    setState(() {
      elecciones.add(eleccion);
      _currentIndex = 2; // Cambiar a la vista de visualización
    });
  }

  void eliminarEleccion(int index) {
    setState(() {
      elecciones.removeAt(index);
    });
  }

  void editarEleccion(int index, Eleccion nuevaEleccion) {
    setState(() {
      elecciones[index] = nuevaEleccion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Elecciones App'),
      ),
      body: _currentIndex == 0
          ? Portada()
          : _currentIndex == 1
              ? CRUDScreen(agregarEleccion: agregarEleccion)
              : TarjetasScreen(
                  elecciones: elecciones,
                  eliminarEleccion: eliminarEleccion,
                  editarEleccion: editarEleccion,
                ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Portada',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'CRUD',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Tarjetas',
          ),
        ],
      ),
    );
  }
}

class Portada extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
            vertical: 100.0), // Ajusta el espacio vertical
        child: Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/img/prm.png'), // Ruta de la imagen
              fit: BoxFit.cover, // Ajuste de la imagen
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'PRM',
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Eleccion {
  String titulo;
  DateTime fecha;
  String descripcion;

  Eleccion(
      {required this.titulo, required this.fecha, required this.descripcion});
}

class CRUDScreen extends StatefulWidget {
  final Function agregarEleccion;

  CRUDScreen({required this.agregarEleccion});

  @override
  _CRUDScreenState createState() => _CRUDScreenState();
}

class _CRUDScreenState extends State<CRUDScreen> {
  TextEditingController tituloController = TextEditingController();
  DateTime? selectedDate;
  TextEditingController descripcionController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: tituloController,
            decoration: InputDecoration(labelText: 'Título'),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    _selectDate(context);
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Fecha',
                      hintText: 'Seleccione una fecha',
                    ),
                    child: Text(
                      selectedDate != null
                          ? DateFormat('yyyy-MM-dd').format(selectedDate!)
                          : 'Seleccione una fecha',
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.calendar_today),
                onPressed: () {
                  _selectDate(context);
                },
              ),
            ],
          ),
          SizedBox(height: 8),
          TextField(
            controller: descripcionController,
            decoration: InputDecoration(labelText: 'Descripción'),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              widget.agregarEleccion(Eleccion(
                titulo: tituloController.text,
                fecha: selectedDate ?? DateTime.now(),
                descripcion: descripcionController.text,
              ));
              tituloController.clear();
              descripcionController.clear();
              selectedDate = null;
            },
            child: Text('Agregar'),
          ),
        ],
      ),
    );
  }
}

class TarjetasScreen extends StatelessWidget {
  final List<Eleccion> elecciones;
  final Function eliminarEleccion;
  final Function editarEleccion;

  TarjetasScreen({
    required this.elecciones,
    required this.eliminarEleccion,
    required this.editarEleccion,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: elecciones.length,
      itemBuilder: (context, index) {
        final eleccion = elecciones[index];
        return Card(
          child: ListTile(
            title: Text(eleccion.titulo),
            subtitle: Text(eleccion.descripcion),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    _mostrarDialogoEditar(context, index, eleccion);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    eliminarEleccion(index);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _mostrarDialogoEditar(
      BuildContext context, int index, Eleccion eleccion) {
    TextEditingController tituloController =
        TextEditingController(text: eleccion.titulo);
    TextEditingController descripcionController =
        TextEditingController(text: eleccion.descripcion);
    DateTime? fechaSeleccionada = eleccion.fecha;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Editar Elección'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: tituloController,
                  decoration: InputDecoration(labelText: 'Título'),
                ),
                SizedBox(height: 8),
                InkWell(
                  onTap: () {
                    _selectDate(context, fechaSeleccionada).then((fecha) {
                      if (fecha != null) {
                        fechaSeleccionada = fecha;
                      }
                    });
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Fecha',
                      hintText: 'Seleccione una fecha',
                    ),
                    child: Text(
                      fechaSeleccionada != null
                          ? DateFormat('yyyy-MM-dd').format(fechaSeleccionada!)
                          : 'Seleccione una fecha',
                    ),
                  ),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: descripcionController,
                  decoration: InputDecoration(labelText: 'Descripción'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Eleccion nuevaEleccion = Eleccion(
                  titulo: tituloController.text,
                  fecha: fechaSeleccionada ?? DateTime.now(),
                  descripcion: descripcionController.text,
                );
                editarEleccion(index, nuevaEleccion);
                Navigator.of(context).pop();
              },
              child: Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  Future<DateTime?> _selectDate(
      BuildContext context, DateTime? initialDate) async {
    return await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
  }
}

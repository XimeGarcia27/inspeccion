import 'package:app_inspections/models/reporte_model.dart';
import 'package:app_inspections/services/auth_service.dart';
import 'package:app_inspections/services/db_offline.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:pdf/pdf.dart';
// ignore: library_prefixes
import 'package:pdf/widgets.dart' as pdfWidgets;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class ReporteF1Screen extends StatelessWidget {
  final int idTienda;
  final String nomTienda;

  const ReporteF1Screen(
      {Key? key, required this.idTienda, required this.nomTienda})
      : super(key: key);

  Future<List<Reporte>> _cargarReporte(int idTienda) async {
    //DatabaseProvider databaseProvider = DatabaseProvider();
    return DatabaseProvider.mostrarReporteF1(idTienda);
  }

  void _descargarPDF(BuildContext context, String? user) async {
    // Obtener los datos del informe
    List<Reporte> datos = await _cargarReporte(idTienda);
    print("DATOS DE REPORTEE $datos");

    // Generar el PDF
    File pdfFile = await generatePDF(datos, nomTienda, user);

    // Abrir el diálogo de compartir para compartir o guardar el PDF
    // ignore: deprecated_member_use
    Share.shareFiles([pdfFile.path], text: 'Descarga tu reporte en PDF');
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    String? user = authService.currentUser;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 40.0, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop(); // Cierra el diálogo
          },
        ),
        backgroundColor: const Color.fromRGBO(6, 6, 68, 1),
        title: const Text(
          "REPORTE FORMATO 1",
          style: TextStyle(fontSize: 24.0, color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.download, color: Colors.white),
            onPressed: () {
              _descargarPDF(context, user);
            },
          ),
        ],
      ),
      body: ReporteF1Widget(idTienda: idTienda),
    );
  }

  void setState(Null Function() param0) {}
}

class ReporteF1Widget extends StatefulWidget {
  final int idTienda;

  const ReporteF1Widget({Key? key, required this.idTienda}) : super(key: key);

  @override
  State<ReporteF1Widget> createState() => _ReporteWidgetState();
}

Future<File> generatePDF(
    List<Reporte> data, String nomTiend, String? user) async {
  final pdfWidgets.Font customFont = pdfWidgets.Font.ttf(
    await rootBundle.load('assets/fonts/OpenSans-Italic.ttf'),
  );
  final dateFormatter = DateFormat('yyyy-MM-dd');
  final formattedDate = dateFormatter.format(DateTime.now());
  final pdf = pdfWidgets.Document();
  final Uint8List imageData = await _loadImageData('assets/logoconexsa.png');
  const int itemsPerPage = 20;
  final int totalPages = (data.length / itemsPerPage).ceil();
  final Uint8List backgroundImageData =
      await _loadImageData('assets/portada1.png');

  pdf.addPage(
    pdfWidgets.Page(
      orientation: pdfWidgets.PageOrientation.landscape,
      pageFormat: PdfPageFormat.a4.copyWith(
        marginLeft: 0,
        marginRight: -60,
        marginTop: 0,
        marginBottom: 0,
      ),
      build: (context) {
        return pdfWidgets.Stack(
          alignment: pdfWidgets.Alignment.center,
          children: [
            pdfWidgets.Positioned.fill(
              child: pdfWidgets.Image(
                pdfWidgets.MemoryImage(backgroundImageData),
                fit: pdfWidgets.BoxFit.cover,
              ),
            ),
            pdfWidgets.Center(
              child: pdfWidgets.Column(
                mainAxisAlignment: pdfWidgets.MainAxisAlignment.center,
                children: [
                  pdfWidgets.Positioned(
                    right: 0,
                    top: 0,
                    child: pdfWidgets.Container(
                      margin: const pdfWidgets.EdgeInsets.all(5),
                      child:
                          pdfWidgets.Image(pdfWidgets.MemoryImage(imageData)),
                      width: 250,
                    ),
                  ),
                  pdfWidgets.SizedBox(height: 20),
                  pdfWidgets.Text(
                    'Reporte de Contrastista F1',
                    style: pdfWidgets.TextStyle(
                      font: customFont,
                      fontSize: 30,
                      fontWeight: pdfWidgets.FontWeight.bold,
                      color: PdfColors.blueGrey500,
                    ),
                  ),
                  pdfWidgets.Text(
                    'Fecha: $formattedDate',
                    style: pdfWidgets.TextStyle(
                      font: customFont,
                      fontSize: 18,
                      color: PdfColors.black,
                    ),
                  ),
                  pdfWidgets.Text(
                    'Tienda: $nomTiend',
                    style: pdfWidgets.TextStyle(
                      font: customFont,
                      fontSize: 18,
                      color: PdfColors.black,
                    ),
                  ),
                  pdfWidgets.Text(
                    'Nombre de Inspector: $user',
                    style: pdfWidgets.TextStyle(
                      font: customFont,
                      fontSize: 18,
                      color: PdfColors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    ),
  );

  for (int pageIndex = 0; pageIndex < totalPages; pageIndex++) {
    final int startIndex = pageIndex * itemsPerPage;
    final int endIndex = (startIndex + itemsPerPage < data.length)
        ? startIndex + itemsPerPage
        : data.length;
    final List<Reporte> pageData = data.sublist(startIndex, endIndex);

    pdf.addPage(
      pdfWidgets.MultiPage(
        orientation: pdfWidgets.PageOrientation.landscape,
        pageFormat: PdfPageFormat.a4.copyWith(
          marginLeft: 30, // Margen izquierdo
          marginRight: 30, // Margen derecho
          marginTop: 40, // Margen superior
          marginBottom: 40, // Margen inferior
        ),
        build: (context) {
          List<pdfWidgets.Widget> widgets = [
            // ignore: deprecated_member_use
            pdfWidgets.Table.fromTextArray(
              context: context,
              data: [
                [
                  'Departamento',
                  'Ubicación',
                  'Problema',
                  'Material',
                  'Cantidad',
                  'Mano de Obra',
                  'Cantidad',
                ],
                for (var row in pageData)
                  [
                    row.nomDep.toString(),
                    row.claveUbi.toString(),
                    pdfWidgets.Text(
                      row.nomProbl.toString(),
                      style: pdfWidgets.TextStyle(
                        font: customFont,
                        fontSize: 12,
                        color: PdfColors.black,
                      ),
                    ),
                    pdfWidgets.Text(
                      row.nomMat.toString(),
                      style: pdfWidgets.TextStyle(
                        font: customFont,
                        fontSize: 12,
                        color: PdfColors.black,
                      ),
                    ),
                    row.cantMat.toString(),
                    row.nomObr.toString(),
                    row.cantObr.toString(),
                  ]
              ],
              border: pdfWidgets.TableBorder.all(
                color: PdfColors.black,
                width: 1,
              ),
              cellAlignment: pdfWidgets.Alignment.center,
              cellStyle: const pdfWidgets.TextStyle(
                fontSize: 12,
                color: PdfColors.black,
              ),
              headerStyle: pdfWidgets.TextStyle(
                fontWeight: pdfWidgets.FontWeight.bold,
                color: PdfColors.white,
              ),
              headerDecoration: const pdfWidgets.BoxDecoration(
                color: PdfColors.lightBlue900,
              ),
            ),
          ];
          return widgets;
        },
      ),
    );
  }

  // Guarda el PDF en un archivo
  final Directory directory = await getApplicationDocumentsDirectory();
  final String filePath = '${directory.path}/reporteContratistaF1.pdf';
  final File file = File(filePath);
  await file.writeAsBytes(await pdf.save());

  return file;
}

Future<Uint8List> _loadImageData(String imagePath) async {
  final ByteData data = await rootBundle.load(imagePath);
  return data.buffer.asUint8List();
}

class _ReporteWidgetState extends State<ReporteF1Widget> {
  late Future<List<Reporte>> _futureReporte;
  String datounico = "";

  @override
  void initState() {
    super.initState();
    _futureReporte = _cargarReporte(widget.idTienda);
  }

  Future<List<Reporte>> _cargarReporte(int idTienda) async {
    return DatabaseProvider.mostrarReporteF1(idTienda);
  }

  void _showImageDialog(String url) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Image.file(
          File(url.trim()),
          errorBuilder: (context, error, stackTrace) {
            return Image.asset(
              'assets/no_image.png',
              width: 70,
              height: 70,
            );
          },
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  int calculateRowsPerPage(List<Reporte> data) {
    // Define el número máximo de filas por página que deseas mostrar
    int maxRowsPerPage = 15;

    // Calcula el número de filas por página basado en la longitud de tus datos
    int calculatedRowsPerPage =
        data.length > maxRowsPerPage ? maxRowsPerPage : data.length;

    return calculatedRowsPerPage;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: FutureBuilder(
        future: _futureReporte,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Revisa tu conexión a internet'));
          } else {
            List<Reporte> datos = snapshot.data ?? [];
            if (datos.isEmpty) {
              return const Center(child: Text('No hay datos disponibles'));
            }
            return ConstrainedBox(
              constraints:
                  BoxConstraints(minWidth: MediaQuery.of(context).size.width),
              child: Theme(
                data: Theme.of(context).copyWith(
                  cardTheme: CardTheme.of(context).copyWith(
                    color: Color.fromARGB(255, 243, 244, 250),
                  ),
                ),
                child: Card(
                  elevation: 0,
                  child: PaginatedDataTable(
                    columns: const [
                      DataColumn(label: Text('Departamento')),
                      DataColumn(label: Text('Ubicación')),
                      DataColumn(label: Text('Problema')),
                      DataColumn(label: Text('Material')),
                      DataColumn(label: Text('Especifique (Otro)')),
                      DataColumn(label: Text('Cantidad')),
                      DataColumn(label: Text('Mano de Obra')),
                      DataColumn(label: Text('Especifique (Otro)')),
                      DataColumn(label: Text('Cantidad')),
                      DataColumn(label: Text('URL FOTO')),
                    ],
                    source: MyDataTableSource(datos, _showImageDialog),
                    rowsPerPage: calculateRowsPerPage(datos),
                    sortColumnIndex: 0,
                    sortAscending: true,
                    columnSpacing: 20.0,
                    horizontalMargin: 10.0,
                    showCheckboxColumn: true,
                    showFirstLastButtons: true,
                    // ignore: deprecated_member_use
                    dataRowHeight: 60.0,
                    headingRowHeight: 65.0,
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

class MyDataTableSource extends DataTableSource {
  final List<Reporte> _data;
  final Function(String url) _showImageDialog;

  MyDataTableSource(this._data, this._showImageDialog);

  @override
  DataRow getRow(int index) {
    if (index >= _data.length) {
      return const DataRow(cells: []);
    }

    final dato = _data[index];
    print('Building row for index $index: $dato');

    final List<String> fotos =
        dato.foto != null ? List<String>.from(jsonDecode(dato.foto!)) : [];

    return DataRow(cells: [
      DataCell(Text('${dato.nomDep}')),
      DataCell(Text('${dato.claveUbi}')),
      DataCell(Text('${dato.nomProbl}')),
      DataCell(Text('${dato.nomMat}')),
      DataCell(Text('${dato.otro}')),
      DataCell(Text('${dato.cantMat}')),
      DataCell(Text('${dato.nomObr}')),
      DataCell(Text('${dato.otroObr}')),
      DataCell(Text('${dato.cantObr}')),
      DataCell(
        Row(
          children: fotos.map<Widget>((url) {
            print('Loading image from URL: $url'); // Debug print for each URL
            return Padding(
              padding: const EdgeInsets.all(4),
              child: InkWell(
                onTap: () => _showImageDialog(url),
                child: Image.file(
                  File(url.trim()),
                  errorBuilder: (context, error, stackTrace) {
                    print(
                        'Error loading image: $url'); // Debug print for errors
                    return Image.asset('assets/no_image.png',
                        width: 70, height: 70);
                  },
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _data.length; // Use the length of the data list

  @override
  int get selectedRowCount => 0;
}
            /* return ListView(children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: (MediaQuery.of(context).size.width / 10) * 0.5,
                  // ignore: deprecated_member_use
                  dataRowHeight: 100,
                  columns: const [
                    DataColumn(
                        label: Center(
                      child: Text(
                        'Departamento',
                        softWrap: true,
                      ),
                    )),
                    DataColumn(
                        label: Text(
                      'Ubicación',
                      softWrap: true,
                    )),
                    DataColumn(
                      label: Text(
                        'Problema',
                        softWrap: true,
                      ),
                    ),
                    DataColumn(
                        label: Text(
                      'Material',
                      softWrap: true,
                    )),
                    DataColumn(
                        label: Text(
                      'Especifique (Otro)',
                      softWrap: true,
                    )),
                    DataColumn(
                        label: Text(
                      'Cantidad',
                      softWrap: true,
                    )),
                    DataColumn(
                        label: Text(
                      'Mano de Obra',
                      softWrap: true,
                    )),
                    DataColumn(
                        label: Text(
                      'Especifique (Otro)',
                      softWrap: true,
                    )),
                    DataColumn(
                        label: Text(
                      'Cantidad',
                      softWrap: true,
                    )),
                    DataColumn(
                        label: Text(
                      'URL FOTO',
                      softWrap: true,
                    )),
                  ],
                  rows: datos.map((dato) {
                    datounico = dato.datoU!;
                    return DataRow(
                      cells: [
                        DataCell(
                          Text(dato.nomDep ?? ''),
                        ),
                        DataCell(
                          Text(dato.claveUbi ?? ''),
                        ),
                        DataCell(
                          Container(
                            width: (MediaQuery.of(context).size.width / 10) * 3,
                            padding: const EdgeInsets.all(3),
                            child: Center(child: Text(dato.nomProbl ?? '')),
                          ),
                        ),
                        DataCell(
                          Container(
                            width: (MediaQuery.of(context).size.width / 10) * 3,
                            padding: const EdgeInsets.all(3),
                            child: Text(dato.nomMat ?? ''),
                          ),
                        ),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.all(3),
                            child: Center(child: Text(dato.otro ?? '')),
                          ),
                        ),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.all(3),
                            child: Text('${dato.cantMat}'),
                          ),
                        ),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.all(3),
                            child: Text(dato.nomObr ?? ''),
                          ),
                        ),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.all(3),
                            child: Text(dato.otroObr ?? ''),
                          ),
                        ),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.all(3),
                            child: Text('${dato.cantObr}'),
                          ),
                        ),
                        DataCell(
                          SizedBox(
                            width: 500,
                            child: Row(
                              children: dato.foto!.map<Widget>((url) {
                                return Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: InkWell(
                                    onTap: () => _showImageDialog(url),
                                    child: Image.file(
                                      File(url.trim()),
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Image.asset(
                                          'assets/no_image.png',
                                          width: 70,
                                          height: 70,
                                        );
                                      },
                                      width: 70,
                                      height: 70,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ]); */

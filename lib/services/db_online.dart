import 'package:app_inspections/models/images_model.dart';
import 'package:app_inspections/models/reporte_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:postgres/postgres.dart';

class DatabaseHelper {
  final storage = const FlutterSecureStorage();

  /* static Future<PostgreSQLConnection> _getConnection() async {
    return await AuthService().openConnection();
  } */

  static PostgreSQLConnection? connection;

  static Future<PostgreSQLConnection> openConnection() async {
    try {
      const databaseHost =
          'ep-red-wood-a4nzhmfu-pooler.us-east-1.postgres.vercel-storage.com';
      const databasePort = 5432;
      const databaseName = 'verceldb';
      const username = 'default';
      const password = 'Iqkc7nFOlR6d';

      final connection = PostgreSQLConnection(
        databaseHost,
        databasePort,
        databaseName,
        username: username,
        password: password,
        useSSL: true, // Habilita el uso de SSL
      );

      await connection.open();
      print('BASE CONECTADA');
      return connection;
    } catch (e) {
      print('Error al abrir la conexión: $e');
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> mostrarTiendas() async {
    final connection = await openConnection();
    try {
      //print('Antes de la consulta');
      final results = await connection.query('SELECT * FROM tiendas');
      //print('despues de la consulta');
      if (kDebugMode) {
        print('Resultados de la consulta: $results');
      }

      final List<Map<String, dynamic>> mappedResults = results
          .map((row) => Map<String, dynamic>.from(row.toColumnMap()))
          .toList();
      return mappedResults;
    } catch (e) {
      const Text('Comprueba tu conexión a internet');
      return [];
    } finally {
      try {
        await connection.query('DEALLOCATE ALL');
        await connection.close();
      } catch (e) {
        if (kDebugMode) {
          print('Error al cerrar la conexión: $e');
        }
      }
    }
  }

  static Future<List<Map<String, dynamic>>> searchTiendas(String query) async {
    final connection = await openConnection();
    try {
      final results = await connection.query(
        'SELECT * FROM tiendas WHERE cod_tienda ILIKE @query OR nom_tienda ILIKE @query_nom',
        substitutionValues: {'query': '%$query%', 'query_nom': '%$query%'},
      );

      return results
          .map((row) => Map<String, dynamic>.from(row.toColumnMap()))
          .toList();
    } catch (e) {
      const Text('Vuelve a intentar de nuevo');
      return [];
    } finally {
      try {
        await connection.query('DEALLOCATE ALL');
        await connection.close();
      } catch (e) {
        if (kDebugMode) {
          print('Error al cerrar la conexión: $e');
        }
      }
    }
  }

  static Future<List<Map<String, dynamic>>> mostrarProblemas(
      String query) async {
    final connection = await openConnection();
    try {
      final results = await connection.query('SELECT * FROM problemas');
      final List<Map<String, dynamic>> mappedResults = results
          .map((row) => Map<String, dynamic>.from(row.toColumnMap()))
          .toList();
      return mappedResults;
    } catch (e) {
      //mostrar alerta de error
      const Text('Comprueba tu conexión a internet');
      return [];
    } finally {
      try {
        await connection.query('DEALLOCATE ALL');
        await connection.close();
      } catch (e) {
        if (kDebugMode) {
          print('Error al cerrar la conexión: $e');
        }
      }
    }
  }

  static Future<List<Map<String, dynamic>>> mostrarMateriales(
      String query) async {
    final connection = await openConnection();
    try {
      final results = await connection.query('SELECT * FROM materiales');
      final List<Map<String, dynamic>> mappedResults = results
          .map((row) => Map<String, dynamic>.from(row.toColumnMap()))
          .toList();
      return mappedResults;
    } catch (e) {
      const Text('Comprueba tu conexión a internet');
      return [];
    } finally {
      try {
        await connection.query('DEALLOCATE ALL');
        await connection.close();
      } catch (e) {
        if (kDebugMode) {
          print('Error al cerrar la conexión: $e');
        }
      }
    }
  }

  static Future<List<Map<String, dynamic>>> mostrarObra(String query) async {
    final connection = await openConnection();
    try {
      final results = await connection.query('SELECT * FROM obra');
      final List<Map<String, dynamic>> mappedResults = results
          .map((row) => Map<String, dynamic>.from(row.toColumnMap()))
          .toList();
      return mappedResults;
    } catch (e) {
      const Text('Comprueba tu conexión a internet');
      return [];
    } finally {
      try {
        await connection.query('DEALLOCATE ALL');
        await connection.close();
      } catch (e) {
        if (kDebugMode) {
          print('Error al cerrar la conexión: $e');
        }
      }
    }
  }

  static Future<void> insertarReporte(
      String formato,
      String valorDepartamento,
      String valorUbicacion,
      int idProbl,
      String nomProbl,
      int idMat,
      String nomMat,
      String otro,
      int cantM,
      int idObra,
      String nomObr,
      String otroObr,
      int cantO,
      String foto,
      String datoUnico,
      String nomUser,
      String lastUpdated,
      int idTiend) async {
    final connection = await openConnection();
    try {
      // Validación de parámetros
      if (valorDepartamento.isEmpty || valorUbicacion.isEmpty || idTiend <= 0) {
        throw ArgumentError(
            'Los parámetros no pueden estar vacíos o ser menores o iguales a cero.');
      }

      // Realizar la inserción en la base de datos utilizando una sentencia preparada
      await connection.query(
        'INSERT INTO reportes (formato, nom_dep, clave_ubi, id_probl, nom_probl, id_mat, nom_mat, otro, cant_mat, id_obr, nom_obr, otro_obr, cant_obr, foto, dato_unico, nom_user, last_updated, id_tienda)'
        'VALUES (@formato, @valorDepartamento, @valorUbicacion, @idProbl, @nomProbl, @idMat, @nomMat, @otro, @cantM, @idObra, @nomObr, @otroObr, @cantO, @foto, @datoUnico, @nomUser, @lastUpdated, @idTiend)',
        substitutionValues: {
          'formato': formato,
          'valorDepartamento': valorDepartamento,
          'valorUbicacion': valorUbicacion,
          'idProbl': idProbl,
          'nomProbl': nomProbl,
          'idMat': idMat,
          'nomMat': nomMat,
          'otro': otro,
          'cantM': cantM,
          'idObra': idObra,
          'nomObr': nomObr,
          'otroObr': otroObr,
          'cantO': cantO,
          'foto': foto,
          'datoUnico': datoUnico,
          'nomUser': nomUser,
          'lastUpdated': lastUpdated,
          'idTiend': idTiend,
        },
      );
      print("DATOS DE MI BD $formato");
      print("DATOS DE MI BD $valorDepartamento");
      print("DATOS DE MI BD $valorUbicacion");
      print("DATOS DE MI BD $idProbl");
      print("DATOS DE MI BD $nomProbl");
      print("DATOS DE MI BD $idMat");
      print("DATOS DE MI BD $nomMat");
      print("DATOS DE MI BD $otro");
      print("DATOS DE MI BD $cantM");
      print("DATOS DE MI BD $idObra");
      print("DATOS DE MI BD $nomObr");
      print("DATOS DE MI BD $otroObr");

      if (kDebugMode) {
        print("CONSULTA INSERTADA CORRECTAMENTE");
      }
    } catch (e) {
      // Manejo de errores
      if (kDebugMode) {
        print('Error al insertar el reporte: $e');
      }
      rethrow; // Lanzar la excepción para que la maneje el código que llamó a esta función
    }
  }

  Future<List<Map<String, dynamic>>> mostrarReporte(int idtienda) async {
    //print("ID TIENDA EN CONSULTA $idtienda");
    final connection = await openConnection();
    try {
      //print('Antes de la consulta');
      final results = await connection
          .query("SELECT * FROM reporte WHERE id_tienda = $idtienda");

      //print('despues de la consulta');
      if (kDebugMode) {
        print('Resultados de la consulta: $results');
      }

      final List<Map<String, dynamic>> mappedResults = results
          .map((row) => Map<String, dynamic>.from(row.toColumnMap()))
          .toList();
      return mappedResults;
    } catch (e) {
      const Text('Comprueba tu conexión a internet');
      return [];
    } finally {
      try {
        await connection.query('DEALLOCATE ALL');
        await connection.close();
      } catch (e) {
        if (kDebugMode) {
          print('Error al cerrar la conexión: $e');
        }
      }
    }
  }

  Future<List<Map<String, dynamic>>> mostrarReporteF1(int idtienda) async {
    final connection = await openConnection();
    try {
      final results = await connection.query(
          "SELECT * FROM reporte WHERE id_tienda = $idtienda AND formato = 'F1' ORDER BY id_rep, dato_unico");
      final List<Map<String, dynamic>> mappedResults = results
          .map((row) => Map<String, dynamic>.from(row.toColumnMap()))
          .toList();
      print(results);
      return mappedResults;
    } catch (e) {
      const Text('Comprueba tu conexión a internet');
      return [];
    } finally {
      try {
        await connection.query('DEALLOCATE ALL');
        await connection.close();
      } catch (e) {
        if (kDebugMode) {
          print('Error al cerrar la conexión: $e');
        }
      }
    }
  }

  Future<List<Map<String, dynamic>>> mostrarReporteF2(int idtienda) async {
    final connection = await openConnection();
    try {
      final results = await connection.query(
          "SELECT * FROM reporte WHERE id_tienda = $idtienda AND formato = 'F2' ");
      final List<Map<String, dynamic>> mappedResults = results
          .map((row) => Map<String, dynamic>.from(row.toColumnMap()))
          .toList();
      return mappedResults;
    } catch (e) {
      const Text('Comprueba tu conexión a internet');
      return [];
    } finally {
      try {
        await connection.query('DEALLOCATE ALL');
        await connection.close();
      } catch (e) {
        if (kDebugMode) {
          print('Error al cerrar la conexión: $e');
        }
      }
    }
  }

  static Future<void> editarReporte(
    int idReporte,
    String formato,
    String valorDepartamento,
    String valorUbicacion,
    int idProbl,
    String nomProbl,
    int idMat,
    String nomMat,
    String otro,
    int cantM,
    int idObra,
    String nomObr,
    String otroObr,
    int cantO,
    int idTiend,
  ) async {
    final connection = await openConnection();
    try {
      // Validación de parámetros
      if (valorDepartamento.isEmpty ||
          valorUbicacion.isEmpty ||
          idProbl <= 0 ||
          idObra <= 0 ||
          idTiend <= 0) {
        throw ArgumentError(
            'Los parámetros no pueden estar vacíos o ser menores o iguales a cero.');
      }
      // Realizar la actualización en la base de datos utilizando una sentencia preparada
      await connection.query(
        'UPDATE reporte SET formato = @formato, nom_dep = @valorDepartamento, clave_ubi = @valorUbicacion,'
        'id_probl = @idProbl, nom_probl = @nomProbl, id_mat = @idMat, nom_mat = @nomMat, otro = @otro, cant_mat = @cantM, id_obr = @idObra, nom_obr = @nomObr, otro_obr = @otroObr,'
        'cant_obr = @cantO, id_tienda = @idTiend WHERE id_rep = @idReporte',
        substitutionValues: {
          'idReporte': idReporte,
          'formato': formato,
          'valorDepartamento': valorDepartamento,
          'valorUbicacion': valorUbicacion,
          'idProbl': idProbl,
          'nomProbl': nomProbl,
          'idMat': idMat,
          'nomMat': nomMat,
          'otro': otro,
          'cantM': cantM,
          'idObra': idObra,
          'nomObr': nomObr,
          'otroObr': otroObr,
          'cantO': cantO,
          'idTiend': idTiend,
        },
      );
    } catch (e) {
      // Manejo de errores
      if (kDebugMode) {
        print('Error al editar el reporte: $e');
      }
      rethrow; // Lanzar la excepción para que la maneje el código que llamó a esta función
    }
  }

  Future<Map<String, dynamic>> obtenerDefectoPorId(int idDefecto) async {
    try {
      final connection = await openConnection();

      // Realiza la consulta en tu tabla de problemas utilizando el ID proporcionado
      List<Map<String, Map<String, dynamic>>> resultados =
          await connection.mappedResultsQuery(
        'SELECT * FROM problemas WHERE id_probl = @id',
        substitutionValues: {'id': idDefecto},
      );

      // Cierra la conexión después de realizar la consulta
      await connection.close();

      // Si se encontraron resultados, retorna el primer resultado
      if (resultados.isNotEmpty) {
        return resultados.first.values.first;
      } else {
        // Si no se encontraron resultados, retorna un mapa vacío
        return {};
      }
    } catch (e) {
      // Manejo de errores, puedes imprimir el error o manejarlo de acuerdo a tus necesidades
      if (kDebugMode) {
        print('Error al obtener el defecto por ID: $e');
      }
      return {};
    }
  }

  Future<Map<String, dynamic>> obtenerMaterialPorId(int idMaterial) async {
    try {
      final connection = await openConnection();

      // Realiza la consulta en tu tabla de problemas utilizando el ID proporcionado
      List<Map<String, Map<String, dynamic>>> resultados =
          await connection.mappedResultsQuery(
        'SELECT * FROM materiales WHERE id_mat = @id',
        substitutionValues: {'id': idMaterial},
      );

      // Cierra la conexión después de realizar la consulta
      await connection.close();

      // Si se encontraron resultados, retorna el primer resultado
      if (resultados.isNotEmpty) {
        return resultados.first.values.first;
      } else {
        // Si no se encontraron resultados, retorna un mapa vacío
        return {};
      }
    } catch (e) {
      // Manejo de errores, puedes imprimir el error o manejarlo de acuerdo a tus necesidades
      if (kDebugMode) {
        print('Error al obtener el defecto por ID: $e');
      }
      return {};
    }
  }

  Future<Map<String, dynamic>> obtenerObraPorId(int idObra) async {
    try {
      final connection = await openConnection();

      // Realiza la consulta en tu tabla de problemas utilizando el ID proporcionado
      List<Map<String, Map<String, dynamic>>> resultados =
          await connection.mappedResultsQuery(
        'SELECT * FROM obra WHERE id_obr = @id',
        substitutionValues: {'id': idObra},
      );

      // Cierra la conexión después de realizar la consulta
      await connection.close();

      // Si se encontraron resultados, retorna el primer resultado
      if (resultados.isNotEmpty) {
        return resultados.first.values.first;
      } else {
        // Si no se encontraron resultados, retorna un mapa vacío
        return {};
      }
    } catch (e) {
      // Manejo de errores, puedes imprimir el error o manejarlo de acuerdo a tus necesidades
      if (kDebugMode) {
        print('Error al obtener el defecto por ID: $e');
      }
      return {};
    }
  }

  Future<List<Map<String, dynamic>>> mostrarCantidades(int idtienda) async {
    final connection = await openConnection();
    try {
      final results = await connection.query(
          "SELECT nom_mat, SUM(cant_mat) as cantidad_total FROM reporte WHERE id_tienda = $idtienda GROUP BY nom_mat");
      final List<Map<String, dynamic>> mappedResults = results
          .map((row) => Map<String, dynamic>.from(row.toColumnMap()))
          .toList();
      return mappedResults;
    } catch (e) {
      const Text('Comprueba tu conexión a internet');
      return [];
    } finally {
      try {
        await connection.query('DEALLOCATE ALL');
        await connection.close();
      } catch (e) {
        if (kDebugMode) {
          print('Error al cerrar la conexión: $e');
        }
      }
    }
  }

  static Future<void> insertarImagenes(
      String fotos, String datoUnico, int idTienda) async {
    final connection = await openConnection();

    try {
      //for (var foto in fotos) {
      await connection.query(
        'INSERT INTO images (url_img, dato_unico, id_tienda) VALUES (@url, @datoUnico, @idTienda)',
        substitutionValues: {
          'url': fotos,
          'datoUnico': datoUnico,
          'idTienda': idTienda,
        },
      );

      if (kDebugMode) {
        print("Imágenes insertadas correctamente");
      }
    } catch (e) {
      // Manejo de errores
      if (kDebugMode) {
        print('Error al insertar imágenes: $e');
      }
      rethrow;
    }
  }

  //soncronizar con bd local
  static Future<void> sincronizarConPostgreSQL(List<Reporte> reportes) async {
    // Establecer la conexión a la base de datos PostgreSQL
    final connection = await openConnection();

    // Utilizar un conjunto para evitar duplicados
    final Set<String> reportesExistente = <String>{};

    // Iterar sobre los reportes y realizar la inserción o actualización en PostgreSQL
    try {
      for (final reporte in reportes) {
        // Verificar si el reporte ya existe en PostgreSQL
        if (!reportesExistente.contains(reporte.datoU)) {
          // Marcar el reporte como existente para evitar duplicados
          reportesExistente.add(reporte.datoU!);

          // Realizar la consulta para verificar la existencia del reporte
          final result = await connection.query(
            'SELECT * FROM reportes WHERE dato_unico = @datoUnico',
            substitutionValues: {'datoUnico': reporte.datoU},
          );

          if (result.isNotEmpty) {
            print("EL DATO SE ACTUALIZARA");
            // El reporte ya existe, actualizarlo en PostgreSQL
            await connection.execute(
              'UPDATE reportes SET formato = @formato, nom_dep = @valorDepartamento, clave_ubi = @valorUbicacion, '
              'id_probl = @idProbl, nom_probl = @nomProbl, id_mat = @idMat, nom_mat = @nomMat, otro = @otro, cant_mat = @cantM, id_obr = @idObra, '
              'nom_obr = @nomObr, otro_obr = @otroObr, cant_obr = @cantO, foto = @foto, last_updated = @lastUpdated, id_tienda = @idTiend '
              'WHERE dato_unico = @datoUnico',
              substitutionValues: {
                'formato': reporte.formato,
                'valorDepartamento': reporte.nomDep,
                'valorUbicacion': reporte.claveUbi,
                'idProbl': reporte.idProbl,
                'nomProbl': reporte.nomProbl,
                'idMat': reporte.idMat,
                'nomMat': reporte.nomMat,
                'otro': reporte.otro,
                'cantM': reporte.cantMat,
                'idObra': reporte.idObr,
                'nomObr': reporte.nomObr,
                'otroObr': reporte.otroObr,
                'cantO': reporte.cantObr,
                'foto': reporte.foto,
                'lastUpdated': reporte.lastUpdated,
                'idTiend': reporte.idTienda,
                'datoUnico': reporte.datoU,
              },
            );
            print("Reporte actualizado correctamente ");
          } else {
            print("EL DATO SE INSERTARA");

            await connection.query(
              'INSERT INTO reportes (formato, nom_dep, clave_ubi, id_probl, nom_probl, id_mat, nom_mat, otro, cant_mat, id_obr, nom_obr, otro_obr, cant_obr, foto, dato_unico, dato_comp, nom_user, last_updated, id_tienda)'
              'VALUES (@formato, @valorDepartamento, @valorUbicacion, @idProbl, @nomProbl, @idMat, @nomMat, @otro, @cantM, @idObra, @nomObr, @otroObr, @cantO, @foto, @datoUnico, @datoCompartido, @nomUser, @lastUpdated, @idTiend)',
              substitutionValues: {
                'formato': reporte.formato,
                'valorDepartamento': reporte.nomDep,
                'valorUbicacion': reporte.claveUbi,
                'idProbl': reporte.idProbl,
                'nomProbl': reporte.nomProbl,
                'idMat': reporte.idMat,
                'nomMat': reporte.nomMat,
                'otro': reporte.otro,
                'cantM': reporte.cantMat,
                'idObra': reporte.idObr,
                'nomObr': reporte.nomObr,
                'otroObr': reporte.otroObr,
                'cantO': reporte.cantObr,
                'foto': reporte.foto,
                'datoUnico': reporte.datoU,
                'datoCompartido': reporte.datoC,
                'nomUser': reporte.nombUser,
                'lastUpdated': reporte.lastUpdated,
                'idTiend': reporte.idTienda,
              },
            );
            print("Reporte insertado correctamente");
          }
        } else {
          print(
              "El reporte con dato único ${reporte.datoU} ya se ha procesado");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error al insertar el reporte online $e');
      }
    }

    // Cerrar la conexión a la base de datos PostgreSQL
    //await connection.close();
  }

  static Future<void> sincronizarConPostgreSQLImagenes(
      List<Images> imagenes) async {
    // Establecer la conexión a la base de datos PostgreSQL
    final connection = await openConnection();

    // Utilizar un conjunto para evitar duplicados
    final Set<String> reportesExistente = <String>{};

    // Iterar sobre los reportes y realizar la inserción o actualización en PostgreSQL
    try {
      for (final imagen in imagenes) {
        // Verificar si el reporte ya existe en PostgreSQL
        if (!reportesExistente.contains(imagen.datoUnicRepor)) {
          // Marcar el reporte como existente para evitar duplicados
          reportesExistente.add(imagen.datoUnicRepor);

          // Realizar la consulta para verificar la existencia del reporte
          final result = await connection.query(
            'SELECT * FROM images WHERE dato_unico = @datoUnico',
            substitutionValues: {'datoUnico': imagen.datoUnicRepor},
          );

          if (result.isNotEmpty) {
            //print("EL DATO SE ACTUALIZARA");
            // El reporte ya existe, actualizarlo en PostgreSQL
            await connection.execute(
              'UPDATE images SET url_img = @image WHERE dato_unico = @datoUnico',
              substitutionValues: {
                'image': imagen.imagen,
                'datoUnico': imagen.datoUnicRepor,
              },
            );
            print("IMagenes actualizadas correctamente ");
          } else {
            print("EL DATO SE INSERTARA de IMAGENES");

            await connection.query(
              'INSERT INTO images (url_img, dato_unico, id_tienda)'
              'VALUES (@datoUnico, @imagen, @tienda)',
              substitutionValues: {
                'imagen': imagen.imagen,
                'datoUnico': imagen.datoUnicRepor,
                'tienda': imagen.tienda,
              },
            );
            print("IMAGEN insertado correctamente");
          }
        } else {
          print(
              "La imagen con dato único ${imagen.datoUnicRepor} ya se ha procesado");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error al insertar la imagen online $e');
      }
    }

    // Cerrar la conexión a la base de datos PostgreSQL
    //await connection.close();
  }
}

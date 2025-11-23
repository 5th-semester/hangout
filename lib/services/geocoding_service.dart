import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/coordinates.dart';

class GeocodingService {
  static Future<Coordinates?> getCoordinatesFromAddress(
    String street,
    String city,
    String state,
  ) async {
    final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
      'street': street,
      'city': city,
      'state': state,
      'country': 'Brazil',
      'format': 'json',
      'limit': '1',
    });

    try {
      final response = await http.get(
        uri,
        headers: {'User-Agent': 'HangoutApp_StudentProject/1.0'},
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        if (data.isNotEmpty) {
          final lat = double.parse(data[0]['lat']);
          final lon = double.parse(data[0]['lon']);
          return Coordinates(latitude: lat, longitude: lon);
        }
      }
    } catch (e) {
      print('Erro ao buscar coordenadas: $e');
    }
    return null;
  }
}

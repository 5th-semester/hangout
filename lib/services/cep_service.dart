import 'dart:convert';
import 'package:http/http.dart' as http;

class CepService {
  static Future<Map<String, dynamic>?> fetchAddress(String cep) async {
    final cleanCep = cep.replaceAll(RegExp(r'[^\d]'), '');

    if (cleanCep.length != 8) {
      return null;
    }

    final url = Uri.parse('https://viacep.com.br/ws/$cleanCep/json/');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.containsKey('erro')) {
          return null;
        }
        return data;
      }
    } catch (e) {
      print('Erro na API: $e');
    }
    return null;
  }
}

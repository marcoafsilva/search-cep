import 'package:flutter/widgets.dart';
import 'package:search_cep/models/ResultCep.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_masked_text/flutter_masked_text.dart';



class ViaCepService {

  static Future<ResultCep> fetchCep({@required String cep}) async {

	final response = await http.get('https://viacep.com.br/ws/$cep/json/');

	print("Status Response: ${response.statusCode}");

	if (response.statusCode == 200) {
		return ResultCep.fromJson(response.body);
	} else {
		throw Exception('Requisição inválida!');
	}
  } // Close method - fetchCep

} // Close class - ViaCepService
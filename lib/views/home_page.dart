import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:search_cep/models/ResultCep.dart';
import 'package:search_cep/services/via_cep_service.dart';
import 'package:screen/screen.dart';
import 'package:flushbar/flushbar.dart';
import 'package:share/share.dart';



class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _searchCepController = TextEditingController();
  bool _loading = false;
  ResultCep _resultCep;

  @override
  Widget build(BuildContext context) {
    Screen.keepOn(true);
    return Scaffold(
      appBar: AppBar(
        title: Text('Consultas de CEP'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.lightbulb_outline),
            onPressed: () {
              Share.share('check out my website https://example.com');
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: _buildForm(),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _buildSearchCepTextField(),
        _buildSearchCepButton(),
        _buildResultCepText()
      ],
    );
  }

  Widget _buildResultCepText() {
    return Padding(
      padding: EdgeInsets.only(top: 20),
      child: Text(
        _resultCep != null ? _resultCep.toJson() : 'Digite um CEP!'
      ),
    );
  }

  Widget _buildSearchCepTextField() {
    return TextFormField(
      // autofocus: true,
      inputFormatters: [
        LengthLimitingTextInputFormatter(8)
      ],
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(labelText: 'Cep'),
      controller: _searchCepController,
      enabled: !_loading,
      validator: (value) {
        if (value.isEmpty || (value.length < 8)) {
          return 'Por favor, digite um CEP válido!';
        }
        return null;
      },
    );
  }

  Widget _buildSearchCepButton() {
    return Padding(
      padding: EdgeInsets.only(top: 20.0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0)
        ),
        onPressed: _searchCep,
        child: _loading ? _showLoading() : Text('Consultar'), 
      ),
    );
  }
 
  Widget _showLoading() {
    return Container(
      width: 15.0,
      height: 15.0,
      child: CircularProgressIndicator(),
    );
  }

  void _searching({bool enable}) {
    setState(() {
      _loading = enable;
    });
  }

  Future _searchCep() async {

    _searching(enable: true);

    final cep = _searchCepController.text;

    if (cep.isEmpty || (cep.length < 8)) {
      Flushbar(
        title:  "Ops...",
        message:  "Digite um CEP válido!",
        duration:  Duration(seconds: 3),              
      ).show(context);
      
      _searching(enable: false);
      return;
    }

    try {
      final result = await ViaCepService.fetchCep(cep: cep);
      

      setState(() {
        _resultCep = result;
      });
      
    } catch (e) {
      Flushbar(
        title:  "Ops...",
        message:  "Erro desconhecido",
        duration:  Duration(seconds: 3),              
      ).show(context);
    }

    _searching(enable: false);
  }
}

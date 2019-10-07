import 'package:dynamic_theme/dynamic_theme.dart';
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
              changeBrightness();

            },
          ),
          IconButton(
            icon: Icon(Icons.share),
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

  void changeBrightness() {
    DynamicTheme.of(context).setBrightness(Theme.of(context).brightness == Brightness.dark? Brightness.light: Brightness.dark);
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
      child: (
        _resultCep != null ? _printCepData(_resultCep) : Text('Digite um CEP!')
      ),
    );
  }

  Widget _printCepData(cep) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _cepLinePrint('Cep', cep.cep),
        _cepLinePrint('Logradouro', cep.logradouro),
        _cepLinePrint('Complemento', cep.complemento),
        _cepLinePrint('Bairro', cep.bairro),
        _cepLinePrint('Localidade', cep.localidade),
        _cepLinePrint('UF', cep.uf),
        _cepLinePrint('Unidade', cep.unidade),
        _cepLinePrint('Ibge', cep.ibge),
        _cepLinePrint('Gia', cep.gia),
        
      ],
    );
  }

  Widget _cepLinePrint(title, value) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: 16.0,
          color: Colors.black
        ),
        children: <TextSpan>[
          TextSpan(text: '$title: ', style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: value)
        ]
      ),
    );
  }

  Widget _buildSearchCepTextField() {
    return TextFormField(
      // autofocus: true,
      inputFormatters: [
        LengthLimitingTextInputFormatter(8),
        WhitelistingTextInputFormatter.digitsOnly
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
      var result = await ViaCepService.fetchCep(cep: cep);

      if (result.cep == null) {

        Flushbar(
          title: "Ops...",
          message: "CEP Desconhecido! =(",
          duration: Duration(seconds: 3),
        ).show(context);

        result = null;
      }      

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

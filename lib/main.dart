import 'package:example_generate_pdf/models/invoice.dart';
import 'package:example_generate_pdf/models/product.dart';
import 'package:example_generate_pdf/utils_pdf.dart';
import 'package:flutter/material.dart';

import 'models/client.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Example PDF',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Example gererate PDF'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Invoice invoice = Invoice();
          invoice.id = 00006531;
          invoice.client =
              Client(name: 'Teste', address: 'Rua dos expedicionários, Centro');
          invoice.products = [
            Product(name: 'Pizza Calabresa', value: 23.4, id: 1, quantity: 1),
            Product(name: 'Sanduíche Natual', value: 12.2, id: 7, quantity: 2),
            Product(name: 'Porção de Batata', value: 35.2, id: 23, quantity: 1),
            Product(name: 'Tábua de Carne', value: 73.9, id: 18, quantity: 1),
            Product(name: 'Suco natural', value: 23.4, id: 14, quantity: 4),
          ];
          invoice.products.forEach((element) {
            invoice.total += (element.value * element.quantity);
          });
          GeneratePDF generatePdf = GeneratePDF(invoice: invoice);
          generatePdf.generatePDFInvoice();
        },
        child: Icon(Icons.print),
      ),
    );
  }
}

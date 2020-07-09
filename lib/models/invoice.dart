import 'package:example_generate_pdf/models/client.dart';
import 'package:example_generate_pdf/models/product.dart';

class Invoice {
  int id;
  DateTime date;
  Client client;
  double total;
  List<Product> products;
  Invoice({this.id, this.date, this.client, this.products, this.total = 0});
}

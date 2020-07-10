import 'package:example_generate_pdf/models/invoice.dart';
import 'package:example_generate_pdf/models/product.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class GeneratePDF {
  Invoice invoice;
  GeneratePDF({
    @required this.invoice,
  });

  /// Cria e Imprime a fatura
  generatePDFInvoice() async {
    final pw.Document doc = pw.Document();
    final pw.Font customFont =
        pw.Font.ttf((await rootBundle.load('assets/RobotoSlabt.ttf')));
    doc.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
            margin: pw.EdgeInsets.zero,
            theme:
                pw.ThemeData(defaultTextStyle: pw.TextStyle(font: customFont))),
        header: _buildHeader,
        footer: _buildPrice,
        build: (context) => _buildContent(context),
      ),
    );
    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => doc.save());
  }

  /// Constroi o cabeçalho da página
  pw.Widget _buildHeader(pw.Context context) {
    return pw.Container(
        color: PdfColors.blue,
        height: 150,
        child: pw.Padding(
            padding: pw.EdgeInsets.all(16),
            child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Padding(
                            padding: pw.EdgeInsets.all(8), child: pw.PdfLogo()),
                        pw.Text('Fatura',
                            style: pw.TextStyle(
                                fontSize: 22, color: PdfColors.white))
                      ]),
                  pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Restaurante do Vale',
                          style: pw.TextStyle(
                              fontSize: 22, color: PdfColors.white)),
                      pw.Text('Rua dos Expedicionários',
                          style: pw.TextStyle(color: PdfColors.white)),
                      pw.Text('Curitiba',
                          style: pw.TextStyle(color: PdfColors.white)),
                    ],
                  )
                ])));
  }

  /// Constroi o conteúdo da página
  List<pw.Widget> _buildContent(pw.Context context) {
    return [
      pw.Padding(
          padding: pw.EdgeInsets.only(top: 30, left: 25, right: 25),
          child: _buildContentClient()),
      pw.Padding(
          padding: pw.EdgeInsets.only(top: 50, left: 25, right: 25),
          child: _contentTable(context)),
    ];
  }

  pw.Widget _buildContentClient() {
    return pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _titleText('Cliente'),
              pw.Text(invoice.client.name),
              _titleText('Endereço'),
              pw.Text(invoice.client.address)
            ],
          ),
          pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
            _titleText('Número da fatura'),
            pw.Text(invoice.id.toString()),
            _titleText('Data'),
            pw.Text(DateFormat('dd/MM/yyyy').format(DateTime.now()))
          ])
        ]);
  }

  /// Retorna um texto com formatação própria para título
  _titleText(String text) {
    return pw.Padding(
        padding: pw.EdgeInsets.only(top: 8),
        child: pw.Text(text,
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)));
  }

  /// Constroi uma tabela com base nos produtos da fatura
  pw.Widget _contentTable(pw.Context context) {
    // Define uma lista usada no cabeçalho
    const tableHeaders = ['ID#', 'Descrição', 'Preço', 'Quantidade', 'Total'];

    return pw.Table.fromTextArray(
      border: null,
      cellAlignment: pw.Alignment.centerLeft,
      headerDecoration: pw.BoxDecoration(
        borderRadius: 2,
      ),
      headerHeight: 25,
      cellHeight: 40,
      // Define o alinhamento das células, onde a chave é a coluna
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.center,
        4: pw.Alignment.centerRight,
      },
      // Define um estilo para o cabeçalho da tabela
      headerStyle: pw.TextStyle(
        fontSize: 10,
        color: PdfColors.blue,
        fontWeight: pw.FontWeight.bold,
      ),
      // Define um estilo para a célula
      cellStyle: const pw.TextStyle(
        fontSize: 10,
      ),
      // Define a decoração
      rowDecoration: pw.BoxDecoration(
        border: pw.BoxBorder(
          bottom: true,
          color: PdfColors.blue,
          width: .5,
        ),
      ),
      headers: tableHeaders,
      // retorna os valores da tabela, de acordo com a linha e a coluna
      data: List<List<String>>.generate(
        invoice.products.length,
        (row) => List<String>.generate(
          tableHeaders.length,
          (col) => _getValueIndex(invoice.products[row], col),
        ),
      ),
    );
  }

  /// Retorna o valor correspondente a coluna
  String _getValueIndex(Product product, int col) {
    switch (col) {
      case 0:
        return product.id.toString();
      case 1:
        return product.name;
      case 2:
        return product.quantity.toString();
      case 3:
        return _formatValue(product.value);
      case 4:
        return _formatValue(product.value * product.quantity);
    }
    return '';
  }

  /// Formata o valor informado na formatação pt/BR
  String _formatValue(double value) {
    final NumberFormat numberFormat = new NumberFormat("#,##0.00", "pt_BR");
    return numberFormat.format(value);
  }

  /// Retorna o QrCode da fatura
  pw.Widget _buildQrCode(pw.Context context) {
    return pw.Container(
        height: 65,
        width: 65,
        child: pw.BarcodeWidget(
            barcode: pw.Barcode.fromType(pw.BarcodeType.QrCode),
            data: 'invoice_id=${invoice.id}',
            color: PdfColors.white));
  }

  /// Retorna o rodapé da página
  pw.Widget _buildPrice(pw.Context context) {
    return pw.Container(
      color: PdfColors.blue,
      height: 130,
      child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Padding(
                padding: pw.EdgeInsets.only(left: 16),
                child: pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      _buildQrCode(context),
                      pw.Padding(
                          padding: pw.EdgeInsets.only(top: 12),
                          child: pw.Text('Use esse QR para pagar',
                              style: pw.TextStyle(
                                  color: PdfColor(0.85, 0.85, 0.85))))
                    ])),
            pw.Padding(
                padding: pw.EdgeInsets.all(16),
                child: pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Padding(
                          padding: pw.EdgeInsets.only(bottom: 0),
                          child: pw.Text('TOTAL',
                              style: pw.TextStyle(color: PdfColors.white))),
                      pw.Text('R\$: ${_formatValue(invoice.total)}',
                          style: pw.TextStyle(
                              color: PdfColors.white, fontSize: 22))
                    ]))
          ]),
    );
  }
}

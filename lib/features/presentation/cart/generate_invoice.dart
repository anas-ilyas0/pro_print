import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:proprint/core/constants/app_images.dart';
import 'package:proprint/core/providers/cart_provider.dart';
import 'package:provider/provider.dart';

Future<void> generateInvoicePdf(
    BuildContext context,
    String invoiceNo,
    String vatRegNo,
    String billTo,
    String shipTo,
    String name,
    String email,
    String telNo) async {
  final cart = Provider.of<CartProvider>(context, listen: false);
  final pdf = pw.Document();
  var arabicFont =
      pw.Font.ttf(await rootBundle.load("assets/fonts/Hacen Tunisia.ttf"));
  var latinFont =
      pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Regular.ttf'));

  final logoImage = pw.MemoryImage(
    (await rootBundle.load(AppImages.proPrintLogoBlackLetters)).buffer.asUint8List(),
  );

  final date = DateFormat('MM/dd/yyyy').format(DateTime.now());
  final subtotal = cart.totalAmount;
  final tax = subtotal * 0.19;
  final total = subtotal + tax;

  pdf.addPage(pw.MultiPage(
          theme: pw.ThemeData.withFont(
            base: arabicFont,
            fontFallback: [latinFont],
          ),
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return [
              pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.yellow, width: 4),
                ),
                padding: pw.EdgeInsets.all(20.r),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Image(logoImage, width: 120),
                            pw.SizedBox(height: 8),
                            pw.Text('Pro Print',
                                style: pw.TextStyle(fontSize: 12)),
                            pw.Text('VAT Reg. No: $vatRegNo',
                                style: pw.TextStyle(fontSize: 10.sp)),
                            pw.Text(billTo,
                                style: pw.TextStyle(fontSize: 10.sp)),
                            pw.Text(shipTo,
                                style: pw.TextStyle(fontSize: 10.sp)),
                            pw.Text('Email: $email',
                                style: pw.TextStyle(fontSize: 10.sp)),
                            pw.Text('Tel: $telNo',
                                style: pw.TextStyle(fontSize: 10.sp)),
                            pw.Text(name, style: pw.TextStyle(fontSize: 10.sp)),
                          ],
                        ),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            pw.Container(
                              color: PdfColors.yellow,
                              padding: pw.EdgeInsets.all(6.r),
                              child: pw.Text('Invoice',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold)),
                            ),
                            pw.SizedBox(height: 10.h),
                            pw.Text('Date: $date',
                                style: pw.TextStyle(fontSize: 10.sp)),
                            pw.Text('Invoice No.: $invoiceNo',
                                style: pw.TextStyle(fontSize: 10.sp)),
                          ],
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 20.h),
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('Bill To:',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold)),
                              pw.Text(billTo),
                            ],
                          ),
                        ),
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.end,
                            children: [
                              pw.Text('Ship To:',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold)),
                              pw.Text(shipTo),
                            ],
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 20.h),
                    pw.TableHelper.fromTextArray(
                      headers: [
                        'Qty',
                        'Item',
                        'Description',
                        'Unit Price',
                        'Total'
                      ],
                      data: cart.items.map((item) {
                        return [
                          item.quantity.toString(),
                          item.name,
                          item.description,
                          '€${item.price.toStringAsFixed(1)}',
                          '€${(item.total).toStringAsFixed(1)}',
                        ];
                      }).toList(),
                      border: pw.TableBorder.all(),
                      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      cellStyle: pw.TextStyle(fontSize: 10.sp),
                      columnWidths: {
                        0: pw.FixedColumnWidth(30),
                        1: pw.FlexColumnWidth(1),
                        2: pw.FlexColumnWidth(2),
                        3: pw.FixedColumnWidth(60),
                        4: pw.FixedColumnWidth(60),
                      },
                    ),
                    pw.SizedBox(height: 20.h),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        _buildTotalRow(
                            'Subtotal: €', '\$${subtotal.toStringAsFixed(1)}'),
                        _buildTotalRow(
                            'Sales Tax: €', '\$${tax.toStringAsFixed(1)}'),
                        _buildTotalRow(
                            'Total: €', '€${total.toStringAsFixed(1)}'),
                        pw.Divider(color: PdfColors.white),
                        _buildTotalRow(
                            'Balance Due: €', total.toStringAsFixed(1),
                            isBold: true),
                      ],
                    ),
                    pw.SizedBox(height: 20.h),
                    pw.Text(
                        'Please contact us for more information about payment options.',
                        style: pw.TextStyle(fontSize: 10.sp)),
                    pw.Text('Thank you for your business.',
                        style: pw.TextStyle(fontSize: 10.sp)),
                  ],
                ),
              )
            ];
          })
      // pw.Page(
      //   pageFormat: PdfPageFormat.a4,
      //   margin: pw.EdgeInsets.all(20.r),
      //   build: (pw.Context context) {
      //     return pw.Container(
      //       decoration: pw.BoxDecoration(
      //         border: pw.Border.all(color: PdfColors.yellow, width: 4),
      //       ),
      //       padding: pw.EdgeInsets.all(20.r),
      //       child: pw.Column(
      //         crossAxisAlignment: pw.CrossAxisAlignment.start,
      //         children: [
      //           pw.Row(
      //             mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      //             crossAxisAlignment: pw.CrossAxisAlignment.start,
      //             children: [
      //               pw.Column(
      //                 crossAxisAlignment: pw.CrossAxisAlignment.start,
      //                 children: [
      //                   pw.Image(logoImage, width: 120),
      //                   pw.SizedBox(height: 8),
      //                   pw.Text('Pro Print', style: pw.TextStyle(fontSize: 12)),
      //                   pw.Text('VAT Reg. No: $vatRegNo',
      //                       style: pw.TextStyle(fontSize: 10.sp)),
      //                   pw.Text('Archiepiskopou Makariou III 61',
      //                       style: pw.TextStyle(fontSize: 10.sp)),
      //                   pw.Text('2572, Dali - Cyprus',
      //                       style: pw.TextStyle(fontSize: 10.sp)),
      //                   pw.Text('Email: $email',
      //                       style: pw.TextStyle(fontSize: 10.sp)),
      //                   pw.Text('Tel: $telNo',
      //                       style: pw.TextStyle(fontSize: 10.sp)),
      //                   pw.Text(name, style: pw.TextStyle(fontSize: 10.sp)),
      //                 ],
      //               ),
      //               pw.Column(
      //                 crossAxisAlignment: pw.CrossAxisAlignment.end,
      //                 children: [
      //                   pw.Container(
      //                     color: PdfColors.yellow,
      //                     padding: pw.EdgeInsets.all(6.r),
      //                     child: pw.Text('Invoice',
      //                         style:
      //                             pw.TextStyle(fontWeight: pw.FontWeight.bold)),
      //                   ),
      //                   pw.SizedBox(height: 10.h),
      //                   pw.Text('Date: $date',
      //                       style: pw.TextStyle(fontSize: 10.sp)),
      //                   pw.Text('Invoice No.: $invoiceNo',
      //                       style: pw.TextStyle(fontSize: 10.sp)),
      //                 ],
      //               ),
      //             ],
      //           ),
      //           pw.SizedBox(height: 20.h),
      //           pw.Row(
      //             crossAxisAlignment: pw.CrossAxisAlignment.start,
      //             children: [
      //               pw.Expanded(
      //                 child: pw.Column(
      //                   crossAxisAlignment: pw.CrossAxisAlignment.start,
      //                   children: [
      //                     pw.Text('Bill To:',
      //                         style:
      //                             pw.TextStyle(fontWeight: pw.FontWeight.bold)),
      //                     pw.Text(billTo),
      //                     pw.Text('Paste Ltd'),
      //                     pw.Text('Nicosia'),
      //                   ],
      //                 ),
      //               ),
      //               pw.Expanded(
      //                 child: pw.Column(
      //                   crossAxisAlignment: pw.CrossAxisAlignment.end,
      //                   children: [
      //                     pw.Text('Ship To:',
      //                         style:
      //                             pw.TextStyle(fontWeight: pw.FontWeight.bold)),
      //                     pw.Text(shipTo),
      //                   ],
      //                 ),
      //               ),
      //             ],
      //           ),
      //           pw.SizedBox(height: 20.h),
      //           pw.TableHelper.fromTextArray(
      //             headers: ['Qty', 'Item', 'Description', 'Unit Price', 'Total'],
      //             data: cart.items.map((item) {
      //               return [
      //                 item.quantity.toString(),
      //                 item.name,
      //                 item.description,
      //                 '€${item.price.toStringAsFixed(1)}',
      //                 '€${(item.total).toStringAsFixed(1)}',
      //               ];
      //             }).toList(),
      //             border: pw.TableBorder.all(),
      //             headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      //             cellStyle: pw.TextStyle(fontSize: 10.sp),
      //             columnWidths: {
      //               0: pw.FixedColumnWidth(30),
      //               1: pw.FlexColumnWidth(1),
      //               2: pw.FlexColumnWidth(2),
      //               3: pw.FixedColumnWidth(60),
      //               4: pw.FixedColumnWidth(60),
      //             },
      //           ),
      //           pw.SizedBox(height: 20.h),
      //           pw.Column(
      //             crossAxisAlignment: pw.CrossAxisAlignment.end,
      //             children: [
      //               _buildTotalRow(
      //                   'Subtotal: €', '\$${subtotal.toStringAsFixed(1)}'),
      //               _buildTotalRow('Sales Tax: €', '\$${tax.toStringAsFixed(1)}'),
      //               _buildTotalRow('Total: €', '€${total.toStringAsFixed(1)}'),
      //               pw.Divider(color: PdfColors.white),
      //               _buildTotalRow('Balance Due: €', total.toStringAsFixed(1),
      //                   isBold: true),
      //             ],
      //           ),
      //           pw.SizedBox(height: 20.h),
      //           pw.Text(
      //               'Please contact us for more information about payment options.',
      //               style: pw.TextStyle(fontSize: 10.sp)),
      //           pw.Text('Thank you for your business.',
      //               style: pw.TextStyle(fontSize: 10.sp)),
      //         ],
      //       ),
      //     );

      //   },
      // ),
      );

  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
  );
}

pw.Widget _buildTotalRow(String label, String amount, {bool isBold = false}) {
  return pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.end,
    children: [
      pw.Text(label,
          style: pw.TextStyle(
              fontSize: 10.sp,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
      pw.Text(amount,
          style: pw.TextStyle(
              fontSize: 10.sp,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
    ],
  );
}

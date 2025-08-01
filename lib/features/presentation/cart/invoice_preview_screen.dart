import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:proprint/core/constants/app_images.dart';
import 'package:proprint/core/models/cart_model.dart';
import 'package:proprint/core/providers/category_provider.dart';
import 'package:proprint/core/providers/dashboard_provider.dart';
import 'package:proprint/core/providers/product_provider.dart';
import 'package:proprint/features/presentation/cart/generate_invoice.dart';
import 'package:proprint/features/presentation/dashboard/dashboard_screen.dart';
import 'package:provider/provider.dart';
import 'package:proprint/core/providers/cart_provider.dart';
import 'package:proprint/core/theme/app_colors.dart';
import 'package:proprint/core/theme/app_text_style.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class InvoicePreviewScreen extends StatefulWidget {
  final String vatRegNo, billTo, shipTo, name, email, telNo;
  const InvoicePreviewScreen(
      {super.key,
      required this.vatRegNo,
      required this.billTo,
      required this.shipTo,
      required this.name,
      required this.email,
      required this.telNo});

  @override
  State<InvoicePreviewScreen> createState() => _InvoicePreviewScreenState();
}

class _InvoicePreviewScreenState extends State<InvoicePreviewScreen> {
  Future<void> saveOrderToDatabase({
    required String invoiceNumber,
    required List<CartItem> items,
    required double subtotal,
    required double tax,
    required double total,
    required String vatRegNo,
    required String billTo,
    required String shipTo,
    required String name,
    required String email,
    required String telNo,
  }) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception("User not logged in");
    await supabase.from('orders').insert({
      'invoice_no': invoiceNumber,
      'items': jsonEncode(items.map((e) => e.toMap()).toList()),
      'subtotal': subtotal,
      'tax': tax,
      'total': total,
      'vat_reg_no': vatRegNo,
      'bill_to': billTo,
      'ship_to': shipTo,
      'name': name,
      'user_email': email,
      'tel_no': telNo,
      'user_id': user.id,
    });
  }

  Future<void> updateProductStock(List<CartItem> cartItems) async {
    final supabase = Supabase.instance.client;

    for (var item in cartItems) {
      final response = await supabase
          .from('products')
          .select('quantity')
          .eq('name', item.name)
          .single();

      if (response != null) {
        final currentStock = response['quantity'] as int;
        final newStock = currentStock - item.quantity;

        if (newStock < 0) {
          print('Not enough stock for ${item.name}');
          continue;
        }
        await supabase
            .from('products')
            .update({'quantity': newStock}).eq('name', item.name);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final categoryProvider =
        Provider.of<CategoryProvider>(context, listen: false);
    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);
    final dashboardProvider =
        Provider.of<DashboardProvider>(context, listen: false);
    final subtotal = cartProvider.totalAmount;
    final tax = subtotal * 0.19;
    final total = subtotal + tax;
    final date = DateFormat('MM/dd/yyyy').format(DateTime.now());
    final invoiceNumber = const Uuid().v4().substring(0, 8).toUpperCase();

    return Scaffold(
      appBar: AppBar(title: const Text('Invoice Preview')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset(
                          AppImages.proPrintLogo,
                          width: 120.w,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            FittedBox(
                              child: Text('Date: $date',
                                  style: AppTextStyle(fontSize: 10.sp)),
                            ),
                            FittedBox(
                              child: Text('Invoice No.: $invoiceNumber',
                                  style: AppTextStyle(fontSize: 10.sp)),
                            ),
                          ],
                        )
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Text('Pro Print',
                        style: AppTextStyle(
                            fontSize: 14.sp, fontWeight: FontWeight.bold)),
                    Text('VAT Reg. No: ${widget.vatRegNo}',
                        style: AppTextStyle(fontSize: 12.sp)),
                    Text(widget.billTo, style: AppTextStyle(fontSize: 12.sp)),
                    Text(widget.shipTo, style: AppTextStyle(fontSize: 12.sp)),
                    Text(widget.email, style: AppTextStyle(fontSize: 12.sp)),
                    Text('Tel: ${widget.telNo}',
                        style: AppTextStyle(fontSize: 12.sp)),
                    Text(widget.name, style: AppTextStyle(fontSize: 12.sp)),
                    Divider(height: 30.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Bill To:',
                                style: AppTextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.sp)),
                            Text(widget.billTo),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Ship To:',
                                style: AppTextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.sp)),
                            Text(widget.shipTo),
                          ],
                        )
                      ],
                    ),
                    SizedBox(height: 20.h),
                    Table(
                      border: TableBorder.all(
                          color: AppColors.blueGrey.withValues(alpha: 0.6)),
                      defaultVerticalAlignment:
                          TableCellVerticalAlignment.middle,
                      columnWidths: const {
                        0: FixedColumnWidth(40),
                        1: FlexColumnWidth(1),
                        2: FlexColumnWidth(2),
                        3: FixedColumnWidth(70),
                        4: FixedColumnWidth(70),
                      },
                      children: [
                        TableRow(
                          decoration: BoxDecoration(
                              color: AppColors.blueGrey
                                  .withValues(alpha: 0.6)
                                  .withValues(alpha: 0.3)),
                          children: const [
                            Padding(
                                padding: EdgeInsets.all(8), child: Text('Qty')),
                            Padding(
                                padding: EdgeInsets.all(8),
                                child: Text('Item')),
                            Padding(
                                padding: EdgeInsets.all(8),
                                child: Text('Description')),
                            Padding(
                                padding: EdgeInsets.all(8),
                                child: Text('Unit Price')),
                            Padding(
                                padding: EdgeInsets.all(8),
                                child: Text('Total')),
                          ],
                        ),
                        ...cartProvider.items.map((item) {
                          return TableRow(
                            children: [
                              Padding(
                                  padding: EdgeInsets.all(6.r),
                                  child: Text(item.quantity.toString())),
                              Padding(
                                  padding: EdgeInsets.all(6.r),
                                  child: Text(item.name)),
                              Padding(
                                  padding: EdgeInsets.all(6.r),
                                  child: Text(item.description)),
                              Padding(
                                  padding: EdgeInsets.all(6.r),
                                  child: Text(
                                      '€${item.price.toStringAsFixed(1)}')),
                              Padding(
                                  padding: EdgeInsets.all(6.r),
                                  child: Text(
                                      '€${item.total.toStringAsFixed(1)}')),
                            ],
                          );
                        }).toList(),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    Column(
                      spacing: 5.h,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Subtotal: €${subtotal.toStringAsFixed(1)}'),
                        Text('Sales Tax: €${tax.toStringAsFixed(1)}'),
                        Text('Total: €${total.toStringAsFixed(1)}',
                            style: AppTextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16.sp)),
                        Divider(
                          color: AppColors.transparent,
                        ),
                        Text('Balance Due: €${total.toStringAsFixed(1)}',
                            style: AppTextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16.sp)),
                      ],
                    ),
                    SizedBox(height: 10.h),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blueGrey.withValues(alpha: 0.6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r))),
                onPressed: () async {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => const Center(
                      child: CircularProgressIndicator(color: AppColors.white),
                    ),
                  );
                  final cart =
                      Provider.of<CartProvider>(context, listen: false);
                  final itemsCopy = cart.items;
                  await updateProductStock(cartProvider.items);
                  await saveOrderToDatabase(
                    invoiceNumber: invoiceNumber,
                    items: itemsCopy,
                    subtotal: subtotal,
                    tax: tax,
                    total: total,
                    vatRegNo: widget.vatRegNo,
                    billTo: widget.billTo,
                    shipTo: widget.shipTo,
                    name: widget.name,
                    email: widget.email,
                    telNo: widget.telNo,
                  );
                  if (!context.mounted) return;
                  await generateInvoicePdf(
                          context,
                          invoiceNumber,
                          widget.vatRegNo,
                          widget.billTo,
                          widget.shipTo,
                          widget.name,
                          widget.email,
                          widget.telNo)
                      .then(((_) async {
                    setState(() {
                      cartProvider.clearCart();
                    });
                    await categoryProvider.fetchCategories();
                    await productProvider.fetchProducts();
                    if (!context.mounted) return;
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const DashboardScreen()));
                    dashboardProvider.setSelectedIndex(0);
                  }));
                },
                child: Text(
                  'Generate PDF Invoice',
                  style: AppTextStyle(color: AppColors.white, fontSize: 16.sp),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:proprint/core/theme/app_colors.dart';
import 'package:proprint/core/theme/app_text_style.dart';
import 'package:proprint/core/utils/widgets/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrderHistoryDetails extends StatelessWidget {
  final String invoiceNo, vatRegNo, billTo, shipTo, name, email, telNo;
  final List<Map<String, dynamic>> items;

  const OrderHistoryDetails({
    super.key,
    required this.invoiceNo,
    required this.vatRegNo,
    required this.billTo,
    required this.shipTo,
    required this.name,
    required this.email,
    required this.telNo,
    required this.items,
  });
  Future<void> deleteOrder(BuildContext context) async {
    final supabase = Supabase.instance.client;

    try {
      await supabase.from('orders').delete().eq('invoice_no', invoiceNo);
      if (context.mounted) {
        Widgets.customSnackbar(
            context, AppColors.blueGrey, 'Order deleted successfully');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (context.mounted) {
        Widgets.customSnackbar(
            context, AppColors.blueGrey, 'Failed to delete order: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final subtotal =
        items.fold<double>(0, (sum, item) => sum + (item['total'] ?? 0));
    final tax = subtotal * 0.19;
    final total = subtotal + tax;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Customer Info',
                      style: AppTextStyle(
                          fontSize: 16.sp, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10.h),
                  _buildInfoRow('Name:', name),
                  _buildInfoRow('Email:', email),
                  _buildInfoRow('Tel:', telNo),
                  _buildInfoRow('VAT Reg. No:', vatRegNo),
                  _buildInfoRow('Bill To:', billTo),
                  _buildInfoRow('Ship To:', shipTo),
                  SizedBox(height: 20.h),
                  Text('Products',
                      style: AppTextStyle(
                          fontSize: 16.sp, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8.h),
                  Table(
                    border: TableBorder.all(
                        color: AppColors.blueGrey.withValues(alpha: 0.6)),
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
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
                                .withAlpha(30)),
                        children: [
                          Padding(
                              padding: EdgeInsets.all(8.r), child: Text('Qty')),
                          Padding(
                              padding: EdgeInsets.all(8.r),
                              child: Text('Item')),
                          Padding(
                              padding: EdgeInsets.all(8.r),
                              child: Text('Description')),
                          Padding(
                              padding: EdgeInsets.all(8.r),
                              child: Text('Unit Price')),
                          Padding(
                              padding: EdgeInsets.all(8.r),
                              child: Text('Total')),
                        ],
                      ),
                      ...items.map((item) {
                        return TableRow(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(6.r),
                              child: Text(item['quantity'].toString()),
                            ),
                            Padding(
                              padding: EdgeInsets.all(6.r),
                              child: Text(item['name']),
                            ),
                            Padding(
                              padding: EdgeInsets.all(6.r),
                              child: Text(item['description']),
                            ),
                            Padding(
                              padding: EdgeInsets.all(6.r),
                              child: Text(
                                  '€${(item['price'] as num).toStringAsFixed(1)}'),
                            ),
                            Padding(
                              padding: EdgeInsets.all(6.r),
                              child: Text(
                                  '€${(item['total'] as num).toStringAsFixed(1)}'),
                            ),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildTotalRow('Subtotal:', subtotal),
                        _buildTotalRow('Tax (19%):', tax),
                        Divider(thickness: 1, height: 16.h),
                        Text('Total: €${total.toStringAsFixed(1)}',
                            style: AppTextStyle(
                                fontSize: 16.sp, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.red,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r)),
                  ),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: AppColors.scaffoldBackgroundColor,
                        title: const Text('Delete Order'),
                        content: const Text(
                            'Are you sure you wants to delete this order?'),
                        actions: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                style: ButtonStyle(
                                    backgroundColor: WidgetStatePropertyAll(
                                        AppColors.blueGrey
                                            .withValues(alpha: 0.6))),
                                onPressed: () => Navigator.pop(context, false),
                                child: Text(
                                  'Cancel',
                                  style: AppTextStyle(
                                      fontSize: 16.sp, color: AppColors.white),
                                ),
                              ),
                              TextButton(
                                style: ButtonStyle(
                                    backgroundColor:
                                        WidgetStatePropertyAll(AppColors.red)),
                                onPressed: () => Navigator.pop(context, true),
                                child: Text(
                                  'Delete',
                                  style: AppTextStyle(
                                      fontSize: 16.sp, color: AppColors.white),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    );
                    if (confirm == true) {
                      if (context.mounted) {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => const Center(
                            child: CircularProgressIndicator(
                                color: AppColors.white),
                          ),
                        );
                      }
                      if (context.mounted) {
                        await deleteOrder(context);
                      }
                      if (context.mounted) {
                        Navigator.pop(context, true);
                      }
                    }
                  },
                  child: Text(
                    'Delete Order',
                    style:
                        AppTextStyle(color: AppColors.white, fontSize: 16.sp),
                  )),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        children: [
          Expanded(
              flex: 2,
              child: Text(title,
                  style: AppTextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13.sp))),
          Expanded(
              flex: 3,
              child: Text(value, style: AppTextStyle(fontSize: 13.sp))),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String title, double value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Text('$title €${value.toStringAsFixed(1)}',
          style: AppTextStyle(fontSize: 13.sp)),
    );
  }
}

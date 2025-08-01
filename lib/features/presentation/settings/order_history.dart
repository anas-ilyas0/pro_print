import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:proprint/core/theme/app_colors.dart';
import 'package:proprint/core/theme/app_text_style.dart';
import 'package:proprint/features/presentation/settings/order_history_details.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrderHistory extends StatefulWidget {
  const OrderHistory({super.key});

  @override
  State<OrderHistory> createState() => _OrderHistoryState();
}

class _OrderHistoryState extends State<OrderHistory> {
  Future<List<Map<String, dynamic>>> fetchOrders() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) throw Exception('User not logged in');
    final response = await Supabase.instance.client
        .from('orders')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order History')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(color: AppColors.white));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
                child: Text(
              'No orders found',
              style: AppTextStyle(fontSize: 16.sp),
            ));
          }
          final orders = snapshot.data!;
          return ListView.separated(
            itemCount: orders.length,
            separatorBuilder: (_, __) => Divider(color: AppColors.white),
            itemBuilder: (context, index) {
              final order = orders[index];
              return ListTile(
                title: Text(
                  'Invoice: ${order['invoice_no']}',
                  style: AppTextStyle(fontSize: 16.sp),
                ),
                subtitle: Text('Total: €${order['total']}',
                    style: AppTextStyle(fontSize: 16.sp)),
                trailing: Text(order['created_at'].toString().split('T').first,
                    style: AppTextStyle(fontSize: 16.sp)),
                onTap: () async {
                  final items = List<Map<String, dynamic>>.from(
                      jsonDecode(order['items']));
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => OrderHistoryDetails(
                              invoiceNo: order['invoice_no'],
                              vatRegNo: order['vat_reg_no'],
                              billTo: order['bill_to'],
                              shipTo: order['ship_to'],
                              name: order['name'],
                              email: order['user_email'],
                              telNo: order['tel_no'],
                              items: items,
                            )),
                  );
                  if (result == true) {
                    setState(() {});
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}

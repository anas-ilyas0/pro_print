import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserNameProvider with ChangeNotifier {
  String _name = '';

  String get name => _name.trim();

  Future<void> fetchUserData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final response = await Supabase.instance.client
          .from('profiles')
          .select('name')
          .eq('id', user.id)
          .single();

      _name = response['name'] ?? '';
      notifyListeners();
    }
  }

  void clearUserData() {
    _name = '';
    notifyListeners();
  }
}

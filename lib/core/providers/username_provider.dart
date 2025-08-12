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
          .select('name, surname')
          .eq('id', user.id)
          .single();

      final firstName = response['name'] ?? '';
      final lastName = response['surname'] ?? '';

      _name = '$firstName $lastName'.trim();
      notifyListeners();
    }
  }

  void clearUserData() {
    _name = '';
    notifyListeners();
  }
}

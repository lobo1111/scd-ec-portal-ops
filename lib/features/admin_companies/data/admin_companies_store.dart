import 'package:flutter/foundation.dart';

import '../models/admin_company.dart';

/// In-memory store for admin companies. Updated by sync pull; UI reads from here first (offline-first).
class AdminCompaniesStore extends ChangeNotifier {
  List<AdminCompany> _items = [];
  List<AdminCompany> get items => List.unmodifiable(_items);

  void setItems(List<AdminCompany> list) {
    _items = list;
    notifyListeners();
  }

  void addOrUpdate(AdminCompany company) {
    final i = _items.indexWhere((c) => c.id == company.id);
    if (i >= 0) {
      _items = List.from(_items)..[i] = company;
    } else {
      _items = [..._items, company];
    }
    notifyListeners();
  }
}

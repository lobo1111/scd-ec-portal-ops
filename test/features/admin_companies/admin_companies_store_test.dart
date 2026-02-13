import 'package:flutter_test/flutter_test.dart';

import 'package:flut_template/features/admin_companies/data/admin_companies_store.dart';
import 'package:flut_template/features/admin_companies/models/admin_company.dart';

void main() {
  group('AdminCompaniesStore', () {
    late AdminCompaniesStore store;

    setUp(() {
      store = AdminCompaniesStore();
    });

    test('items is initially empty', () {
      expect(store.items, isEmpty);
    });

    test('setItems replaces list and notifies', () {
      final companies = [
        const AdminCompany(id: '1', legalName: 'A', contactEmail: 'a@a.a'),
        const AdminCompany(id: '2', legalName: 'B', contactEmail: 'b@b.b'),
      ];
      store.setItems(companies);
      expect(store.items.length, 2);
      expect(store.items[0].legalName, 'A');
    });

    test('addOrUpdate adds new company', () {
      store.setItems([const AdminCompany(id: '1', legalName: 'A', contactEmail: 'a@a.a')]);
      store.addOrUpdate(const AdminCompany(id: '2', legalName: 'B', contactEmail: 'b@b.b'));
      expect(store.items.length, 2);
    });

    test('addOrUpdate updates existing company', () {
      store.setItems([
        const AdminCompany(id: '1', legalName: 'A', contactEmail: 'a@a.a'),
      ]);
      store.addOrUpdate(const AdminCompany(id: '1', legalName: 'A Updated', contactEmail: 'a@a.a'));
      expect(store.items.length, 1);
      expect(store.items[0].legalName, 'A Updated');
    });
  });
}

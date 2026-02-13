import 'package:flutter_test/flutter_test.dart';

import 'package:flut_template/features/admin_companies/models/admin_company.dart';

void main() {
  group('AdminCompany', () {
    test('fromJson parses API response', () {
      final json = {
        'id': '01abc123',
        'legalName': 'Acme Estates Ltd',
        'contactEmail': 'admin@acme.example',
        'address': 'Street 1',
        'communityCount': 3,
        'adminUserCount': 5,
      };
      final company = AdminCompany.fromJson(json);
      expect(company.id, '01abc123');
      expect(company.legalName, 'Acme Estates Ltd');
      expect(company.contactEmail, 'admin@acme.example');
      expect(company.address, 'Street 1');
      expect(company.communityCount, 3);
      expect(company.adminUserCount, 5);
    });

    test('fromJson handles null address and zero counts', () {
      final json = {
        'id': '01xyz',
        'legalName': 'Test Co',
        'contactEmail': 'a@b.c',
      };
      final company = AdminCompany.fromJson(json);
      expect(company.address, isNull);
      expect(company.communityCount, 0);
      expect(company.adminUserCount, 0);
    });

    test('toJson round-trip', () {
      const company = AdminCompany(
        id: '01id',
        legalName: 'Legal',
        contactEmail: 'e@e.e',
        address: 'Addr',
        communityCount: 1,
        adminUserCount: 2,
      );
      final json = company.toJson();
      expect(AdminCompany.fromJson(json).id, company.id);
      expect(AdminCompany.fromJson(json).legalName, company.legalName);
    });
  });
}

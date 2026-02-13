/// List admin companies (paged). Use for sync pull.
const String listAdminCompaniesQuery = r'''
  query ListAdminCompanies($limit: Int, $nextToken: String) {
    listAdminCompanies(limit: $limit, nextToken: $nextToken) {
      items {
        id
        legalName
        contactEmail
        address
        communityCount
        adminUserCount
      }
      nextToken
    }
  }
''';

/// Create admin company.
const String createAdminCompanyMutation = r'''
  mutation CreateAdminCompany($input: CreateAdminCompanyInput!) {
    createAdminCompany(input: $input) {
      id
      legalName
      contactEmail
      address
      communityCount
      adminUserCount
    }
  }
''';

/// Update admin company.
const String updateAdminCompanyMutation = r'''
  mutation UpdateAdminCompany($id: ID!, $input: UpdateAdminCompanyInput!) {
    updateAdminCompany(id: $id, input: $input) {
      id
      legalName
      contactEmail
      address
      communityCount
      adminUserCount
    }
  }
''';

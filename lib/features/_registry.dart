import 'feature_descriptor.dart';
import 'admin_companies/admin_companies_feature.dart';
import 'home/home_feature.dart';

/// Central list of feature descriptors. The shell builds [GoRouter] from these.
final List<FeatureDescriptor> featureDescriptors = [
  homeFeatureDescriptor,
  adminCompaniesFeatureDescriptor,
];

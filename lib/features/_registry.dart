import 'feature_descriptor.dart';
import 'home/home_feature.dart';

/// Central list of feature descriptors. The shell builds [GoRouter] from these.
final List<FeatureDescriptor> featureDescriptors = [
  homeFeatureDescriptor,
];

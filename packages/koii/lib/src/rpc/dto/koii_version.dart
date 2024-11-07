import 'package:json_annotation/json_annotation.dart';

part 'koii_version.g.dart';

/// The koii version
@JsonSerializable(createToJson: false)
class KoiiVersion {
  const KoiiVersion({
    required this.koiiCore,
    required this.featureSet,
  });

  factory KoiiVersion.fromJson(Map<String, dynamic> json) =>
      _$KoiiVersionFromJson(json);

  /// Software version of koii-core.
  @JsonKey(name: 'koii-core')
  final String koiiCore;

  /// Unique identifier of current feature set.
  @JsonKey(name: 'feature-set')
  final int featureSet;
}

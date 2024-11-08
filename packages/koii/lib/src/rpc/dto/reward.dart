import 'package:json_annotation/json_annotation.dart';
import 'package:koii/src/rpc/dto/reward_type.dart';

part 'reward.g.dart';

/// A reward
@JsonSerializable(createToJson: false)
class Reward {
  const Reward({
    required this.pubkey,
    required this.lamports,
    required this.postBalance,
    required this.rewardType,
    required this.commission,
  });

  factory Reward.fromJson(Map<String, dynamic> json) => _$RewardFromJson(json);

  /// The public key, as base-58 encoded string, of the account
  /// that received the reward.
  final String pubkey;

  /// Number of reward lamports credited or debited by the
  /// account, as a i64.
  final int lamports;

  /// Account balance in lamports after the reward was applied.
  final int postBalance;

  /// Type of reward
  final RewardType rewardType;

  /// vote account commission when the reward was credited, only
  /// present for voting and staking rewards
  final int commission;
}

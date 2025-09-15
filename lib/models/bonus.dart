class Bonus {
  final String id;
  final DateTime createdAt;
  final String title;
  final String? description;
  // Guide / embed link
  final String embedUrl; // from guide_url or embed_url
  // Steps (max steps for progress)
  final int totalSteps;

  // Legacy total bonus (fallback)
  final String bonusAmount;

  // Visuals
  final String? companyLogoUrl;
  final String? imageUrl; // Large cover image for cards

  // Meta
  final String estimatedTime;
  final bool isActive;

  // New fields for Landing/Dashboard
  final String? status; // e.g., 'ATTIVA'
  final String? depositRequired; // e.g., '25'
  final String? registrationBonusAmount; // e.g., '25'
  final String? registrationBonusType;   // e.g., '€', 'In Buoni', '$'
  final String? inviteBonusAmount;       // e.g., '100'
  final String? inviteBonusType;         // e.g., '€', 'In Buoni', '$'
  final String? referralCodeOrLink;      // code or registration link
  final String? expiryDateText;          // free text like '30/09/2025'

  const Bonus({
    required this.id,
    required this.createdAt,
    required this.title,
    this.description,
    required this.embedUrl,
    required this.totalSteps,
    required this.bonusAmount,
    this.companyLogoUrl,
    this.imageUrl,
    this.estimatedTime = '5 minuti',
    this.isActive = true,
    this.status,
    this.depositRequired,
    this.registrationBonusAmount,
    this.registrationBonusType,
    this.inviteBonusAmount,
    this.inviteBonusType,
    this.referralCodeOrLink,
    this.expiryDateText,
  });

  factory Bonus.fromJson(Map<String, dynamic> json) {
    final img = (json['image_url'] ??
        json['cover_image_url'] ??
        json['bonus_image_url'] ??
        json['link_immagine_bonus'] ??
        json['link_immagine'] ??
        json['company_logo_url']) as String?;

    final guide = (json['guide_url'] ?? json['embed_url']) as String? ?? '';

    int steps = (json['total_steps'] as int?) ?? 50;
    if (steps <= 0) steps = 50;

    return Bonus(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      title: json['title'] as String,
      description: json['description'] as String?,
      embedUrl: guide,
      totalSteps: steps,
      bonusAmount: (json['bonus_amount'] as String?) ?? '',
      companyLogoUrl: json['company_logo_url'] as String?,
      imageUrl: img,
      estimatedTime: json['estimated_time'] as String? ?? '5 minuti',
      isActive: json['is_active'] as bool? ?? true,
      status: json['status'] as String?,
      depositRequired: json['deposit_required']?.toString(),
      registrationBonusAmount: json['registration_bonus_amount']?.toString(),
      registrationBonusType: json['registration_bonus_type'] as String?,
      inviteBonusAmount: json['invite_bonus_amount']?.toString(),
      inviteBonusType: json['invite_bonus_type'] as String?,
      referralCodeOrLink: json['referral_code_or_registration_link'] as String?,
      expiryDateText: json['expiry_date_text'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'title': title,
      'description': description,
      'embed_url': embedUrl,
      'total_steps': totalSteps,
      'bonus_amount': bonusAmount,
      'company_logo_url': companyLogoUrl,
      'image_url': imageUrl,
      'estimated_time': estimatedTime,
      'is_active': isActive,
      'status': status,
      'deposit_required': depositRequired,
      'registration_bonus_amount': registrationBonusAmount,
      'registration_bonus_type': registrationBonusType,
      'invite_bonus_amount': inviteBonusAmount,
      'invite_bonus_type': inviteBonusType,
      'referral_code_or_registration_link': referralCodeOrLink,
      'expiry_date_text': expiryDateText,
    };
  }
}

class UserBonusProgress {
  final int id;
  final String userId;
  final String bonusId;
  final int currentStep;
  final bool completed;
  final DateTime updatedAt;

  const UserBonusProgress({
    required this.id,
    required this.userId,
    required this.bonusId,
    required this.currentStep,
    required this.completed,
    required this.updatedAt,
  });

  factory UserBonusProgress.fromJson(Map<String, dynamic> json) {
    return UserBonusProgress(
      id: json['id'] as int,
      userId: json['user_id'] as String,
      bonusId: json['bonus_id'] as String,
      currentStep: json['current_step'] as int,
      completed: json['completed'] as bool,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'bonus_id': bonusId,
      'current_step': currentStep,
      'completed': completed,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UserBonusProgress copyWith({
    int? currentStep,
    bool? completed,
    DateTime? updatedAt,
  }) {
    return UserBonusProgress(
      id: id,
      userId: userId,
      bonusId: bonusId,
      currentStep: currentStep ?? this.currentStep,
      completed: completed ?? this.completed,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
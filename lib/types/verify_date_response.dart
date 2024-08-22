class VerifyDateResponse {
  List<VeirfyDetails>? details;
  bool? isVerified;

  VerifyDateResponse({this.details, this.isVerified});

  VerifyDateResponse.fromJson(Map<String, dynamic> json) {
    try {
      if (json['data'] != null) {
        if (json['data'] is List) {
          details = (json['data'] as List)
              .map((item) => VeirfyDetails.fromJson(item))
              .toList();
        } else if (json['data'] is Map) {
          // details = VeirfyDetails.fromJson(json['data']);
        }
      }
      isVerified = json['isVerified'];
    } catch (e) {
      print(e);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (details != null) {
      print(details![0].verifiedBy);
      data['data'] = details!.map((v) => v.toJson()).toList();
    }
    data['isVerified'] = isVerified;
    return data;
  }
}

class VeirfyDetails {
  String? verifiedBy;
  bool? verificationStatus;
  String? verifiedByUsertype;

  VeirfyDetails({
    this.verifiedBy,
    this.verificationStatus,
    this.verifiedByUsertype,
  });

  VeirfyDetails.fromJson(Map<String, dynamic> json) {
    verifiedBy = json['verified_by'];
    verificationStatus = json['verification_status'];
    verifiedByUsertype = json['verified_by_usertype'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['verified_by'] = verifiedBy;
    data['verification_status'] = verificationStatus;
    data['verified_by_usertype'] = verifiedByUsertype;
    return data;
  }
}


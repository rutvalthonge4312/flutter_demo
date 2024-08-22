class VerifiedTrainsResponse {
  int? count;
  String? next;
  String? previous;
  List<VeirfyDetails>? details;

  VerifiedTrainsResponse({
    this.count,
    this.next,
    this.previous,
    this.details,
  });

  VerifiedTrainsResponse.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    next = json['next'];
    previous = json['previous'];
    if (json['results'] != null) {
      details = (json['results'] as List)
          .map((item) => VeirfyDetails.fromJson(item))
          .toList();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['count'] = count;
    data['next'] = next;
    data['previous'] = previous;
    if (details != null) {
      data['results'] = details?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class VeirfyDetails {
  int? trainNumber;
  String? trainName;
  StatusCounts? statusCounts;

  VeirfyDetails({
    this.trainNumber,
    this.trainName,
    this.statusCounts,
  });

  VeirfyDetails.fromJson(Map<String, dynamic> json) {
    trainNumber = json['train_number'];
    trainName = json['train_name'];
    statusCounts = json['status_counts'] != null
        ? StatusCounts.fromJson(json['status_counts'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['train_number'] = trainNumber;
    data['train_name'] = trainName;
    if (statusCounts != null) {
      data['status_counts'] = statusCounts?.toJson();
    }
    return data;
  }
}

class StatusCounts {
  int? overflow;
  int? full;
  int? partial;
  int? empty;
  int? na;

  StatusCounts({
    this.overflow,
    this.full,
    this.partial,
    this.empty,
    this.na,
  });

  StatusCounts.fromJson(Map<String, dynamic> json) {
    overflow = json['overflow'];
    full = json['full'];
    partial = json['partial'];
    empty = json['empty'];
    na = json['na'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['overflow'] = overflow;
    data['full'] = full;
    data['partial'] = partial;
    data['empty'] = empty;
    data['na'] = na;
    return data;
  }
}

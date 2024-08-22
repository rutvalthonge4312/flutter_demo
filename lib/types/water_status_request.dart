class CoachStatusRequest {
  final String coachStatus;
  final String token;

  CoachStatusRequest({required this.coachStatus, required this.token});

  Map<String, dynamic> toJson() => {
    'coach_status': coachStatus,
    'token': token,
  };
}
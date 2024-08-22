class AccessHandleRequest {
  final String token;
  

  AccessHandleRequest({required this.token});

  Map<String, dynamic> toJson() {
      return{
        'token':token
      };
    
  }
}
class RatingsRequest {
  final String token;
  final String status;
  final String fetchInfo;

  RatingsRequest({required this.token, required this.status,required this.fetchInfo});
  

  Map<String, dynamic> toJson() {
    if(fetchInfo=="fetchData"){
      return{
        'token':token,
      };
    }
    return{
      'token':token,
      "task_status":status,
    };
    
  }
}
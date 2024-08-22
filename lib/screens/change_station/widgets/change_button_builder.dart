import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wrms.app/models/index.dart';
import 'package:wrms.app/routes.dart';
import 'package:wrms.app/services/station_services/station_service.dart';
import 'package:wrms.app/widgets/loader_new.dart';
import 'package:wrms.app/widgets/success_modal.dart';


class ChangeButtonBuilder extends StatefulWidget {
  final String token;
  final String stationName;
  final int stationCode;
  const ChangeButtonBuilder({Key? key, required this.token,required this.stationName,required this.stationCode}) : super(key: key);

  @override
  _ChangeButtonBuilder createState() => _ChangeButtonBuilder();
}

class _ChangeButtonBuilder extends State<ChangeButtonBuilder> {
  String? token;
   
  Future<void> changeStationFunction()async {
    loaderNew(context, "Changing station, Please Wait...");
    try{
      final changeStationResponse = await StationService.handleChangeStation(widget.stationName, widget.token);
      Navigator.of(context).pop();
      final userModel = Provider.of<UserModel>(context, listen: false);
      userModel.updateStationDetails(stationCode: widget.stationCode,stationName: widget.stationName);
      showSuccessModal(context,changeStationResponse,"Success",(){});
      Navigator.pushReplacementNamed(context, Routes.home);
    }
    catch(e){
      Navigator.of(context).pop();
      showSuccessModal(context,'$e',"Error",(){});
      
    }
  }

  @override
  Widget build(BuildContext context) {
   
    return ElevatedButton(
      onPressed: () {
        changeStationFunction();
      },
      style:ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder( 
            borderRadius: BorderRadius.circular(8), 
        ),
      ),
     
      child: Text(widget.stationName),
    );
  }
}

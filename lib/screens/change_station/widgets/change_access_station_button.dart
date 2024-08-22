import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wrms.app/models/index.dart';
import 'package:wrms.app/routes.dart';
import 'package:wrms.app/services/station_services/station_service.dart';
import 'package:wrms.app/widgets/loader_new.dart';
import 'package:wrms.app/widgets/success_modal.dart';


class ChangeAccessStationButton extends StatefulWidget {
  final String token;
  final String stationName;
  const ChangeAccessStationButton({Key? key, required this.token,required this.stationName}) : super(key: key);

  @override
  _ChangeAccessStationButton createState() => _ChangeAccessStationButton();
}

class _ChangeAccessStationButton extends State<ChangeAccessStationButton> {
  String? token;
   
  Future<void> changeStationFunction()async {
    loaderNew(context, "Changing Access station, Please Wait...");
    try{
      final changeStationResponse = await StationService.changedAccessStation(widget.stationName, widget.token);
      Navigator.of(context).pop();
      final userModel = Provider.of<UserModel>(context, listen: false);
      userModel.updateStationDetails(stationName: widget.stationName);
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

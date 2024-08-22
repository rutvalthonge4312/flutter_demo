import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wrms.app/models/auth_model.dart';
import 'package:wrms.app/models/user_model.dart';
import 'package:wrms.app/routes.dart';
import 'package:wrms.app/screens/change_station/widgets/change_access_station_button.dart';
import 'package:wrms.app/screens/change_station/widgets/change_button_builder.dart';
import 'package:wrms.app/services/auth_service.dart';
import 'package:wrms.app/services/station_services/access_service.dart';
import 'package:wrms.app/services/station_services/station_service.dart';
import 'package:wrms.app/types/index.dart';
import 'package:wrms.app/widgets/loader_new.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  List<StationResponse>? stationData;
  List<AccessStationResponse>? accessStationData;
  String? token;
  String? userType;

  @override
  void initState() {
    final userModel = Provider.of<UserModel>(context, listen: false);
    token = userModel.token;
    userType = userModel.userType;
    super.initState();
  }

  Future<void> getStations() async {
    loaderNew(context, "Loading Stations");
    try {
      final stationResponse = await StationService.fetchAllStations(token!);
      setState(() {
        stationData = stationResponse;
      });
      Navigator.of(context).pop();
      showStationModal(context);
    } catch (e) {
      Navigator.of(context).pop();
      print(e);
    }
  }

  //access_stations_data
  Future<void> getAccessStations() async {
    loaderNew(context, "Loading Access Stations");
    try {
      final stationResponse = await AccessService.getAccessStationData(token!);
      setState(() {
        accessStationData = stationResponse;
      });
      print(accessStationData);
      Navigator.of(context).pop();
      showAccessStationModal(context);
    } catch (e) {
      Navigator.of(context).pop();
      print(e);
    }
  }
  //ChangeAccessStationButton

  void showAccessStationModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Select Station"),
          content: SingleChildScrollView(
            child: Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children:( accessStationData != null && accessStationData!.isNotEmpty)
                  ? accessStationData!
                      .where((station) => station.status == "Active")
                      .map((station) {
                      return ChangeAccessStationButton(
                        token: token!,
                        stationName: station.stationName,
                      );
                    }).toList()
                  : [
                   const Text("No Access stations found"),
                  ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void showStationModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Select Station"),
          content: SingleChildScrollView(
            child: Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: stationData!.map((station) {
                return ChangeButtonBuilder(
                  token: token!,
                  stationName: station.stationName,
                  stationCode: station.stationId,
                );
              }).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.6,
      child: Drawer(
        child: Column(
          children: <Widget>[
            Stack(
              children: [
                DrawerHeader(
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                  ),
                  child: Consumer<UserModel>(
                    builder: (context, userModel, child) {
                      return Row(
                        children: [
                          const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Hello, ${userModel.trimmedUserName}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 8.0,
                  left: 8.0,
                  child: IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  ListTile(
                    leading: const Icon(Icons.home),
                    title: const Text('Home'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, Routes.home);
                    },
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color.fromARGB(255, 223, 223, 223),
                        width: 0.3,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.picture_as_pdf),
                      title: const Text('Get Pdf'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, Routes.pdfPages);
                      },
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color.fromARGB(255, 223, 223, 223),
                        width: 0.3,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: const Text('Verify Date'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, Routes.verifyDaily);
                      },
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color.fromARGB(255, 223, 223, 223),
                        width: 0.3,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.add_box_outlined),
                      title: const Text('Additional Stations'),
                      onTap: () {
                        getAccessStations();
                      },
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color.fromARGB(255, 223, 223, 223),
                        width: 0.3,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.train_sharp),
                      title: const Text('Add New Train'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, Routes.addTrain);
                      },
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color.fromARGB(255, 223, 223, 223),
                        width: 0.3,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.edit),
                      title: const Text('Edit Train Info'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, Routes.updateTrain);
                      },
                    ),
                  ),
                  if (userType != "supervisor" && userType != "contractor")
                    Column(children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color.fromARGB(255, 223, 223, 223),
                            width: 0.3,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.person_add),
                          title: const Text('Requested Users'),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, Routes.requestUser);
                          },
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color.fromARGB(255, 223, 223, 223),
                            width: 0.3,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.toggle_off_rounded),
                          title: const Text('Enable/Disable Users'),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, Routes.allUser);
                          },
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color.fromARGB(255, 223, 223, 223),
                            width: 0.3,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.label),
                          title: const Text('Accept/Deny Leave'),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, Routes.leaveApproval);
                          },
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color.fromARGB(255, 223, 223, 223),
                            width: 0.3,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.change_circle),
                          title: const Text('Change Station'),
                          onTap: () {
                            getStations();
                          },
                        ),
                      ),
                    ])
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color.fromARGB(255, 223, 223, 223),
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(0.0),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.logout,
                  color: Colors.red,
                ),
                title: const Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
                onTap: () async {
                  final authModel =
                      Provider.of<AuthModel>(context, listen: false);
                  try {
                    await AuthService.logout(
                      authModel.loginResponse!.refreshToken,
                      authModel.loginResponse!.token,
                    );
                    authModel.logout();
                    Navigator.pushReplacementNamed(context, Routes.login);
                  } catch (e) {
                    authModel.logout();
                    Navigator.pushReplacementNamed(context, Routes.login);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

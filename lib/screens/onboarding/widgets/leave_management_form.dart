import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wrms.app/models/index.dart';
import 'package:wrms.app/services/station_services/access_service.dart';
import 'package:wrms.app/services/station_services/station_service.dart';
import 'package:wrms.app/types/index.dart';
import 'package:wrms.app/widgets/loader_new.dart';
import 'package:wrms.app/widgets/success_modal.dart';

class LeaveManagementForm extends StatefulWidget {
  final UserModel userModel;

  const LeaveManagementForm({Key? key, required this.userModel})
      : super(key: key);

  @override
  _LeaveManagementFormState createState() => _LeaveManagementFormState();
}

class _LeaveManagementFormState extends State<LeaveManagementForm> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  List<StationResponse> stations = [];
  List<StationResponse> filteredStations = [];
  List<AccessRequestedResponse>? requestedData;
  String selectedStation = "";
  List<String> selectedStationCode = [];

  @override
  void initState() {
    super.initState();
    final DateTime today = DateTime.now();
    final DateTime oneWeekLater = today.add(const Duration(days: 7));
    _startDateController.text = DateFormat('yyyy-MM-dd').format(today);
    _endDateController.text = DateFormat('yyyy-MM-dd').format(oneWeekLater);
    getStations();
    getLeaveData();
    _searchController.addListener(() {
      searchStation(_searchController.text);
    });
  }

  Future<void> getStations() async {
    try {
      final stationResponse =
          await StationService.fetchAllStations(widget.userModel.token);
      setState(() {
        stations = stationResponse!;
        filteredStations = stationResponse!;
      });
    } catch (e) {
      print(e);
    }
  }

  void searchStation(String query) {
    setState(() {
      filteredStations = stations.where((station) {
        return station.stationName.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  void handleStartDateChange(String value) {
    setState(() {
      _startDateController.text = value;
    });
  }

  void handleEndDateChange(String value) {
    setState(() {
      _endDateController.text = value;
    });
  }

  void handleLeaveRequest() async {
    loaderNew(context, "Sending Leave Request. Please Wait..");
    try {
      final stationResponse = await AccessService.requestLeave(
          selectedStationCode!,
          _startDateController.text,
          _startDateController.text,
          widget.userModel.token);
      Navigator.of(context).pop();
      getLeaveData();
      showSuccessModal(context, stationResponse, "Success", () {});
    } catch (e) {
      Navigator.of(context).pop();
      showSuccessModal(context, '$e', "Error", () {});
    }
  }

  void getLeaveData() async {
    try {
      final stationResponse =
          await AccessService.getRequestedStationData(widget.userModel.token);
      setState(() {
        requestedData = stationResponse;
      });
    } catch (e) {
      showSuccessModal(context, '$e', "Error", () {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      TextField(
                        controller: _searchController,
                        onChanged: searchStation,
                        decoration: InputDecoration(
                          labelText: "Search Stations",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.search, size: 16),
                        ),
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 20),
                      if (filteredStations!.isNotEmpty) ...[
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final bool isDesktop = constraints.maxWidth > 600;
                            final int stationsPerRow = isDesktop ? 8 : 3;
                            final double itemWidth =
                                (constraints.maxWidth - 16) / stationsPerRow;

                            return Wrap(
                              spacing: 8.0,
                              runSpacing: 8.0,
                              children: filteredStations!.map((station) {
                                return SizedBox(
                                  width: itemWidth,
                                  child: GestureDetector(
                                    onTap: () {
                                      selectedStationCode
                                          .add(station.stationName);
                                      setState(() {
                                        selectedStation = station.stationName;
                                        _searchController.text =
                                            selectedStation;
                                        searchStation(_searchController.text);
                                      });
                                    },
                                    child: Chip(
                                      label: Text(
                                        station.stationName,
                                        style: const TextStyle(
                                            fontSize: 12.0,
                                            color: Colors.white),
                                      ),
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 8.0),
                                      backgroundColor: selectedStation ==
                                              station
                                          ? Color.fromARGB(255, 52, 7, 92)
                                              .withOpacity(0.5)
                                          : Color.fromARGB(255, 102, 79, 146),
                                    ),
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ] else ...[
                        const Text('No stations found'),
                      ],
                      const SizedBox(height: 90),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _startDateController,
                              decoration: InputDecoration(
                                labelText: 'Start Date',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                suffixIcon:
                                    const Icon(Icons.calendar_today, size: 16),
                              ),
                              readOnly: true,
                              onTap: () async {
                                DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2101),
                                );
                                if (pickedDate != null) {
                                  handleStartDateChange(DateFormat('yyyy-MM-dd')
                                      .format(pickedDate));
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _endDateController,
                              decoration: InputDecoration(
                                labelText: 'End Date',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                suffixIcon:
                                    const Icon(Icons.calendar_today, size: 16),
                              ),
                              readOnly: true,
                              onTap: () async {
                                DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now().add(
                                    const Duration(days: 7),
                                  ),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2101),
                                );
                                if (pickedDate != null) {
                                  handleEndDateChange(DateFormat('yyyy-MM-dd')
                                      .format(pickedDate));
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          onPressed: selectedStation.isNotEmpty
                              ? handleLeaveRequest
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 52, 7, 92),
                            foregroundColor: Colors.white,
                            minimumSize: Size(150, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Request Leave'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Card(
                color: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 15),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 79, 54, 123),
                            borderRadius: BorderRadius.circular(8.0),
                            border:
                                Border.all(color: Colors.blueGrey, width: 1),
                          ),
                          child: Text(
                            'Leave Management Access Status',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final bool isDesktop = constraints.maxWidth > 600;
                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columnSpacing: isDesktop ? 350.0 : 16.0,
                              dataRowHeight: 50,
                              headingRowHeight: 50,
                              columns: [
                                DataColumn(
                                  label: Padding(
                                    padding: EdgeInsets.only(
                                        left: isDesktop ? 16.0 : 1.0,),
                                    child: Text(
                                      'For Station',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontSize: isDesktop ? 16 : 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Padding(
                                    padding: EdgeInsets.only(
                                        left: isDesktop ? 16.0 : 8.0),
                                    child: Text(
                                      'From',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontSize: isDesktop ? 16 : 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Padding(
                                    padding: EdgeInsets.only(
                                        left: isDesktop ? 16.0 : 8.0),
                                    child: Text(
                                      'To',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontSize: isDesktop ? 16 : 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Padding(
                                    padding: EdgeInsets.only(
                                        left: isDesktop ? 16.0 : 8.0),
                                    child: Text(
                                      'Status',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontSize: isDesktop ? 16 : 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                              
                                  rows:requestedData != null 
                                  
                                  ? requestedData!.map((response) {
                                    return DataRow(
                                      cells: [
                                        DataCell(
                                          Text(
                                            response.forStation.join(
                                                ', ',),
                                            style:const TextStyle(fontSize: 12.0),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            response.fromForStation,
                                            style:const TextStyle(fontSize: 12.0),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            response.toForStation,
                                            style:const TextStyle(fontSize: 12.0),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            response.approved
                                                ? 'Approved'
                                                : 'Not Approved',
                                            style:const TextStyle(fontSize: 12.0),
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList() : [],
                                ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

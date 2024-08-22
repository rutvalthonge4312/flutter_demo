import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wrms.app/models/index.dart';
import 'package:wrms.app/services/station_services/access_service.dart';
import 'package:wrms.app/services/station_services/station_service.dart';
import 'package:wrms.app/services/user_services.dart';
import 'package:wrms.app/types/index.dart';
import 'package:wrms.app/types/user_all_response.dart';
import 'package:wrms.app/widgets/error_modal.dart';
import 'package:wrms.app/widgets/loader.dart';
import 'package:wrms.app/widgets/loader_new.dart';

class LeaveCard extends StatefulWidget {
  final UserModel userModel;
  const LeaveCard({Key? key, required this.userModel}) : super(key: key);

  @override
  _LeaveCard createState() => _LeaveCard();
}

class _LeaveCard extends State<LeaveCard> {
  String? value;
  String? type;
  String? token;
  List<AccessRequestedResponse> userArray = [];
  List<AccessRequestedResponse> filteredUserArray = [];
  bool _isLoading = false;
  bool _isButtonLoading = false;
  bool _showModal = false;

  String _searchText = '';

  @override
  void initState() {
    super.initState();
    token = widget.userModel.token;
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final fetchUserResponse =
          await AccessService.getAllRequestedUserData(token!);
      setState(() {
        userArray = fetchUserResponse;
        _filterUsers();
      });
    } catch (e) {
      showErrorModal(context, '$e', "Error", (){});
      if (e is StateError && e.toString().contains('mounted')) {
        print('Widget disposed before operation completes');
      } else {
        print('Fetch Users Failed: $e');
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  

  void _filterUsers() {
    setState(() {
      filteredUserArray = userArray.where((user) {
        final searchLower = _searchText.toLowerCase();
        return user.userEmail.toLowerCase().contains(searchLower) ||
            user.userPhone.toLowerCase().contains(searchLower);
      }).toList();
    });
  }

  Future<void> _handleUserApproval(decision, userID) async {
    setState(() {
      _isButtonLoading = true;
    });
    loaderNew(context, "Sending Request. Please Wait..");
    try {
      final response =
          await AccessService.handleLeaveStatus(decision, userID, token!);
        Navigator.of(context).pop();
        showErrorModal(context, response, "Success", (){});
      _fetchUsers();
    } catch (e) {
        Navigator.of(context).pop();
        showErrorModal(context, '$e', "Error", (){});
      if (e is StateError && e.toString().contains('mounted')) {
        print('Widget disposed before operation completes');
      } else {
        print('Fetch Users Failed: $e');
      }
    }
    setState(() {
      _isButtonLoading = false;
    });
  }

  Future<void> _showConfirmationDialog(
      String action, int userId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$action Confirmation',
              style: const TextStyle(
                color: Colors.blue,
              )),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to $action the user?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _handleUserApproval(action.toUpperCase(), userId);
                Navigator.of(context).pop();
              },
              child: Text(action),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel>(context);
    token = userModel.token;
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Search',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (text) {
                    setState(() {
                      _searchText = text;
                      _filterUsers();
                    });
                  },
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Loader(message: "Loading Users...Please Wait")
                    : filteredUserArray.isEmpty
                        ? const Center(
                            child: Text(
                              'No Requests available!',
                              style: TextStyle(
                                fontSize: 18.0,
                                color: Colors.blue,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: filteredUserArray.length,
                            itemBuilder: (context, index) {
                              final user = filteredUserArray[index];
                              return Card(
                                margin: const EdgeInsets.all(10.0),
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 10),
                                      Text(
                                        'Email: ${user.userEmail}',
                                        style: const TextStyle(fontSize: 16.0),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        'Phone: ${user.userPhone}',
                                        style: const TextStyle(fontSize: 16.0),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        'Station Requested: ${user.forStation}',
                                        style: const TextStyle(fontSize: 16.0),
                                      ),
                                      const SizedBox(height: 10),
                                      // Text(
                                      //   'Role: ${user.role}',
                                      //   style: const TextStyle(fontSize: 16.0),
                                      // ),
                                      const SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                              _showConfirmationDialog(
                                                  'APPROVE', user.id);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors
                                                  .green, // background color
                                              foregroundColor:
                                                  Colors.white, // text color
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 12),
                                              textStyle: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              elevation: 5,
                                            ),
                                            child: const Text(
                                              'Accept',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              _showConfirmationDialog(
                                                  'Deny', user.id,);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors
                                                  .red, // background color
                                              foregroundColor:
                                                  Colors.white, // text color
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 12),
                                              textStyle: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              elevation: 5,
                                            ),
                                            child: const Text(
                                              'Deny',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

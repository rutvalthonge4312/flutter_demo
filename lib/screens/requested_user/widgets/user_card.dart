import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wrms.app/models/index.dart';
import 'package:wrms.app/services/station_services/access_service.dart';
import 'package:wrms.app/types/access_hanle_response.dart';
import 'package:wrms.app/widgets/loader.dart';

class UserCard extends StatefulWidget {
  final UserModel userModel;
  const UserCard({Key? key, required this.userModel}) : super(key: key);

  @override
  _UserCardState createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {
  String? value;
  String? type;
  String? token;
  List<AccessHanleResponse> userArray = [];
  String _searchText = '';
  List<AccessHanleResponse> filteredUserArray = [];

  bool _showModal = false;
  bool _isLoading = false;
  bool _isButtonLoading = false;

  @override
  void initState() {
    super.initState();
    token = widget.userModel.token;
    _fetchUsers();
  }
  Future<void> _fetchUsers() async {
    setState(() {
      _isLoading=true;
    });
    try {
      final fetchUserResponse = await AccessService.showRequests(token!);
      setState(() {
        userArray = fetchUserResponse;
        _filterUsers(); 
      });
    } catch (e) {
      setState(() {
        _showErrorModal(context,'$e');
      });
      if (e is StateError && e.toString().contains('mounted')) {
        print('Widget disposed before operation completes');
      } else {
        print('Fetch Users Failed: $e');
      }
    }
    setState(() {
      _isLoading=false;
    });
  }

  void _filterUsers() {
    setState(() {
      filteredUserArray = userArray.where((user) {
        final searchLower = _searchText.toLowerCase();
        return user.userFName.toLowerCase().contains(searchLower) ||
               user.userLName.toLowerCase().contains(searchLower) ||
               user.userEmail.toLowerCase().contains(searchLower) ||
               user.userPhone.toLowerCase().contains(searchLower) ||
               user.userType.toLowerCase().contains(searchLower);
      }).toList();
    });
  }

  Future<void> _approveDeny(String decision, String id) async {
    setState(() {
      _isButtonLoading = true;
    });
    try {
      await AccessService.approveUser(decision, id, token!);
      _fetchUsers();
    } catch (e) {
      setState(() {
        _showErrorModal(context,'$e');
      });
      if (e is StateError && e.toString().contains('mounted')) {
        print('Widget disposed before operation completes');
      } else {
        print('Fetch Users Failed: $e');
      }
    }
    setState(() {
      _isButtonLoading=false;
    });
  }


  Future<void> _showConfirmationDialog(String action, String userName, AccessHanleResponse user) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button to close modal
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$action Confirmation',
          style:const TextStyle(
          color: Colors.blue,)),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to $action the request for $userName?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child:const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _approveDeny(action.toUpperCase(), user.id.toString());
                Navigator.of(context).pop(); 
              },
              child:Text(action), 
            ),
          ],
        );
      },
    );
  }

  void _showErrorModal(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Alert'),
          content: Text(errorMessage),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                setState(() {
                  _showModal = false;
                });
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
    final userModel = Provider.of<UserModel>(context);
    token = userModel.token;
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
      ),
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
                  ? const Loader(message: "Loading Users...Please Wait",)
                  : filteredUserArray.isEmpty
                    ? const Center(child: Text('No User Requests available!',
                            style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.blue,
                          ),))
                    : ListView.builder(
                        itemCount: filteredUserArray.length,
                        itemBuilder: (context, index) {
                          final user = filteredUserArray[index];
                          return Card(
                            margin:const EdgeInsets.all(10.0),
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${user.userFName} ${user.userMName ?? ''} ${user.userLName}',
                                    style:const TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Email: ${user.userEmail}',
                                    style:const TextStyle(fontSize: 16.0),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Phone: ${user.userPhone}',
                                    style:const TextStyle(fontSize: 16.0),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Station Code: ${user.userStation.toString()}',
                                    style:const TextStyle(fontSize: 16.0),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Role: ${user.userType}',
                                    style:const TextStyle(fontSize: 16.0),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        _showConfirmationDialog('Approve', '${user.userFName} ${user.userMName ?? ''} ${user.userLName}',user);
                                      },
                                      
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green, // background color
                                        foregroundColor: Colors.white, // text color
                                        padding:const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                        textStyle:const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        elevation: 5,
                                      ),
                                      child:const Text(
                                        'Approve',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    const SizedBox(width: 10), // Adds spacing between buttons
                                    ElevatedButton(
                                      onPressed: () {
                                        _showConfirmationDialog('Deny', '${user.userFName} ${user.userMName ?? ''} ${user.userLName}',user);
                                      },
                                      
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red, // background color
                                        foregroundColor: Colors.white, // text color
                                        padding:const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                        textStyle:const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        elevation: 5,
                                      ),
                                      child:const Text(
                                        'Deny',
                                        style: TextStyle(color: Colors.white),
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

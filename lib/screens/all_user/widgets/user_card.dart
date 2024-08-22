import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wrms.app/models/index.dart';
import 'package:wrms.app/services/station_services/access_service.dart';
import 'package:wrms.app/services/user_services.dart';
import 'package:wrms.app/types/access_hanle_response.dart';
import 'package:wrms.app/types/user_all_response.dart';
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
  List<UserAllResponse> userArray = [];
  List<UserAllResponse> filteredUserArray = [];
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
      final fetchUserResponse = await UserServices.showUsers(token!);
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
      _isLoading = false;
    });
  }
  
  void _showErrorModal(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
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


  void _filterUsers() {
    setState(() {
      filteredUserArray = userArray.where((user) {
        final searchLower = _searchText.toLowerCase();
        return user.email.toLowerCase().contains(searchLower) ||
               user.phone.toLowerCase().contains(searchLower) ||
               user.role.toLowerCase().contains(searchLower);
      }).toList();
    });
  }

  Future<void> _handleUserApproval(decision, username) async {
    setState(() {
      _isButtonLoading = true;
    });
    try {
      final response=await UserServices.handleUserStatus(decision,username,token!);
        setState(() {
          _showErrorModal(context,'$response');
        });
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
  

  Future<void> _showConfirmationDialog(String action, UserAllResponse user) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, 
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('$action Confirmation',
        style:const TextStyle(
        color: Colors.blue,)),
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
            child:const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _handleUserApproval(action.toLowerCase(), user.username);
              Navigator.of(context).pop(); 
            },
            child:Text(action), 
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
                  ? const Loader(message: "Loading Users...Please Wait")
                  : filteredUserArray.isEmpty
                      ? const Center(
                          child: Text(
                            'No Users available!',
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 10),
                                    Text(
                                      'Email: ${user.email}',
                                      style: const TextStyle(fontSize: 16.0),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Phone: ${user.phone}',
                                      style: const TextStyle(fontSize: 16.0),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Station Code: ${user.station.toString()}',
                                      style: const TextStyle(fontSize: 16.0),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Role: ${user.role}',
                                      style: const TextStyle(fontSize: 16.0),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        !user.enabled
                                            ? ElevatedButton(
                                                onPressed: () {
                                                  _showConfirmationDialog('Enable', user);
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.green, // background color
                                                  foregroundColor: Colors.white, // text color
                                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                                  textStyle: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  elevation: 5,
                                                ),
                                                child: const Text(
                                                  'Enable',
                                                  style: TextStyle(color: Colors.white),
                                                ),
                                              )
                                            : ElevatedButton(
                                                onPressed: () {
                                                  _showConfirmationDialog('Disable', user);
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red, // background color
                                                  foregroundColor: Colors.white, // text color
                                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                                  textStyle: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  elevation: 5,
                                                ),
                                                child: const Text(
                                                  'Disable',
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wrms.app/models/index.dart';
import 'package:wrms.app/routes.dart';
import 'package:wrms.app/screens/all_user/widgets/user_card.dart';
import 'package:wrms.app/widgets/index.dart';

class AllUserScreen extends StatelessWidget {
  const AllUserScreen({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'All Users'),
      drawer: const CustomDrawer(),
      body: Center(
        child: FutureBuilder(
          future: Provider.of<AuthModel>(context, listen: false).loadAuthState(),
          builder: (context, AsyncSnapshot<void> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.connectionState == ConnectionState.done) {
              final authModel = Provider.of<AuthModel>(context, listen: false);
              if (authModel.isAuthenticated) {
                return UserCard(userModel: Provider.of<UserModel>(context));
              } else {
                WidgetsBinding.instance!.addPostFrameCallback((_) {
                  Navigator.pushReplacementNamed(context, Routes.login);
                });
                return const CircularProgressIndicator();
              }
            } else if (snapshot.hasError) {
              // Handle error state here
              return const Text('Error loading authentication state');
            }
            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}

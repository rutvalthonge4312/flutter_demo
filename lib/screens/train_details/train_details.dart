import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wrms.app/models/index.dart';
import 'package:wrms.app/routes.dart';
import 'package:wrms.app/screens/train_details/train_details_form.dart';

class TrainDetails extends StatelessWidget {
  const TrainDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Consumer2<AuthModel, UserModel>(
          builder: (context, authModel, userModel, child) {
            if (authModel.isAuthenticated) {
              return TrainDetailsForm(userModel: userModel);
            } else {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushReplacementNamed(context, Routes.login);
              });
              return const CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}

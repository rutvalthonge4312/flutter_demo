import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wrms.app/models/index.dart';
import 'package:wrms.app/route_logger.dart';
import 'package:wrms.app/routes.dart';
import 'package:wrms.app/screens/add_train/add_train_screen.dart';
import 'package:wrms.app/screens/all_user/all_user_screen.dart';
import 'package:wrms.app/screens/index.dart';
import 'package:wrms.app/screens/onboarding/change_email.dart';
import 'package:wrms.app/screens/onboarding/change_mobile.dart';
import 'package:wrms.app/screens/onboarding/change_password.dart';
import 'package:wrms.app/screens/onboarding/edit_profile.dart';
import 'package:wrms.app/screens/onboarding/sign_up_screen.dart';
import 'package:wrms.app/screens/otp_login/otp_screen.dart';
import 'package:wrms.app/screens/onboarding/widgets/forgot_password_form.dart';
import 'package:wrms.app/screens/pages/add_task_screen.dart';
import 'package:wrms.app/screens/pages/pdf_page_screen.dart';
import 'package:wrms.app/screens/train_details/verify_daily_service.dart';
import 'package:wrms.app/screens/update_train/update_train_screen.dart';
import 'package:wrms.app/screens/onboarding/leave_management_screen.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? lastRoute = prefs.getString('lastRoute') ?? Routes.splashScreen;

  runApp(MainApp(initialRoute: lastRoute));
}

class MainApp extends StatelessWidget {
  final String initialRoute;

  const MainApp({Key? key, required this.initialRoute}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RouteLogger routes = new RouteLogger();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthModel()),
        ChangeNotifierProvider(create: (_) => UserModel()),
      ],
      child: MaterialApp(
        title: 'WRMS',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        navigatorObservers: [routes],
        initialRoute: Routes.splashScreen,
        routes: {
          Routes.login: (context) => const LoginScreen(),
          Routes.home: (context) => const HomeScreen(),
          Routes.requestUser: (context) => const RequestedUser(),
          Routes.otpEnter: (context) => const Otp(),
          Routes.mobileLogin: (context) => const MobileNumberScreen(),
          Routes.signUp: (context) => const SignupScreen(),
          Routes.trainDetails: (context) => const TrainDetails(),
          Routes.forgotPassword: (context) => const ForgotPasswordForm(),
          Routes.addRatings: (context) => const AddTaskScreen(),
          Routes.addTrain: (context) => const AddTrainScreen(),
          Routes.splashScreen: (context) => const SplashScreen(),
          Routes.editProfle: (context) => EditProfileScreen(),
          Routes.changeEmail: (context) => ChangeEmailScreen(),
          Routes.changeMobile: (context) => ChangeMobileScreen(),
          Routes.changePassword: (context) => ChangePasswordScreen(),
          Routes.allUser: (context) => const AllUserScreen(),
          Routes.pdfPages: (context) => const PdfPagesScreen(),
          Routes.verifyDaily: (context) =>const VerifyDailyService(),
          Routes.updateTrain: (context) => const UpdateTrainScreen(),
          Routes.leaveManagement: (context) => const LeaveManagementScreen(),
          Routes.leaveApproval: (context) => const AcceptLeaveScreen(),
        },
      ),
    );
  }
}

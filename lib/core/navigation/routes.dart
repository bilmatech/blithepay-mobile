import 'package:blithepay/features/auth/presentation/views/setup_pin_view.dart';
import 'package:blithepay/features/common/data/success_args_model.dart';
import 'package:blithepay/features/dashboard/presentation/models/dashboard_model.dart';
import 'package:blithepay/features/fees/presentation/views/payment_confirmation_view.dart';
import 'package:blithepay/features/fees/presentation/views/payment_success_view.dart';
import 'package:blithepay/features/profile/presentation/views/change_password_view.dart';
import 'package:blithepay/features/profile/presentation/views/profile_view.dart';
import 'package:blithepay/features/fees/presentation/views/fees_breakdown_view.dart';
import 'package:blithepay/features/schools/data/models/linked_student_model.dart';
import 'package:blithepay/features/schools/presentation/views/link_child_school_view.dart';
import 'package:blithepay/features/schools/presentation/views/link_profile.dart';
import 'package:blithepay/features/schools/presentation/views/student_linked_success_view.dart';
import 'package:blithepay/features/splash/presentation/views/splash_view.dart';
import 'package:blithepay/features/students/data/models/verify_student_model.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/views/login_view.dart';
import '../../features/auth/presentation/views/signup_view.dart';
import '../../features/auth/presentation/views/forgot_password_view.dart';
import '../../features/auth/presentation/views/verify_otp_view.dart';
import '../../features/auth/presentation/views/reset_password_view.dart';
import '../../features/auth/presentation/views/password_changed_view.dart';
import '../../features/auth/presentation/views/onboarding_view.dart';
import '../../features/dashboard/presentation/views/dashboard_view.dart';
import '../../features/schools/presentation/views/confirm_school_view.dart';
import '../../features/schools/presentation/views/search_school_view.dart';
import '../../features/schools/presentation/views/add_school_view.dart';
import '../../features/schools/presentation/views/edit_schools_view.dart';
import '../../features/schools/presentation/views/edit_school_detail_view.dart';
import '../../features/students/presentation/views/link_students_view.dart';
import '../../features/students/presentation/views/guardian_verification_view.dart';
import '../../features/students/presentation/views/linked_students_view.dart';
import '../../features/profile/presentation/views/change_phone_number_view.dart';
import '../../features/profile/presentation/views/profile_detail_view.dart';
import '../../features/common/presentation/views/request_pending_view.dart';
import '../../features/common/presentation/views/request_failed_view.dart';
import '../../features/common/presentation/views/success_view.dart';
import '../../features/notifications/presentation/views/notifications_view.dart';
import '../../features/wallet/presentation/views/fund_wallet_view.dart';
import '../../features/wallet/presentation/views/transactions_view.dart';
import '../../features/wallet/presentation/views/wallet_management_view.dart';
import '../../features/wallet/presentation/views/transaction_detail_view.dart';
import '../../features/fees/presentation/views/pay_fees_view.dart';
import '../../features/support/presentation/views/help_support_view.dart';
import 'app_routes.dart';

class AppRouterConfig {
  static GoRouter createRouter() {
    return GoRouter(
      initialLocation: AppRoutes.splash,
      routes: [
        GoRoute(path: AppRoutes.splash, builder: (_, __) => const SplashView()),
        GoRoute(
          path: AppRoutes.onboarding,
          builder: (_, __) => const OnboardingView(),
        ),
        GoRoute(path: AppRoutes.login, builder: (_, __) => const LoginView()),
        GoRoute(path: AppRoutes.signup, builder: (_, __) => const SignupView()),
        GoRoute(
          path: AppRoutes.forgotPassword,
          builder: (_, __) => const ForgotPasswordView(),
        ),
        GoRoute(
          path: AppRoutes.verifyOtp,
          builder: (context, state) {
            final args = state.extra as Map<String, dynamic>;

            return VerifyOtpView(email: args['email'], flow: args['flow']);
          },
        ),
        GoRoute(
          path: AppRoutes.setupOtp,
          builder: (context, state) {
            final args = state.extra as Map<String, dynamic>;

            return SetupOtpView(
              email: args['email'],
              flow: args['flow'],
              popOnSuccess: args['pop'] ?? false,
            );
          },
        ),
        GoRoute(
          path: AppRoutes.resetPassword,
          builder: (context, state) {
            final email = state.extra as String? ?? '';
            return ResetPasswordView(email: email);
          },
        ),
        GoRoute(
          path: AppRoutes.passwordChanged,
          builder: (_, __) => const PasswordChangedView(),
        ),
        GoRoute(
          path: AppRoutes.changePassword,
          builder: (_, __) => const ChangePasswordView(),
        ),
        ShellRoute(
          builder: (context, state, child) {
            return DashboardView(child: child);
          },
          routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (context, state) => const HomeView(),
            ),
            GoRoute(
              path: AppRoutes.linkedStudents,
              builder: (_, __) => const LinkedStudentsView(),
            ),
            GoRoute(
              path: AppRoutes.profile,
              builder: (context, state) => const ProfileView(),
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.walletManagement,
          builder: (context, state) => const WalletManagementView(),
        ),
        GoRoute(
          path: AppRoutes.profileDetail,
          builder: (context, state) => const ProfileDetailView(),
        ),
        GoRoute(
          path: AppRoutes.confirmSchool,
          builder: (_, __) => const ConfirmSchoolView(),
        ),
        GoRoute(
          path: AppRoutes.searchSchool,
          builder: (_, __) => const SearchSchoolView(),
        ),
        GoRoute(
          path: AppRoutes.addSchool,
          builder: (_, __) => const AddSchoolView(),
        ),
        GoRoute(
          path: AppRoutes.linkchildSchool,
          builder: (_, __) => const LinkChildSchoolView(),
        ),
        GoRoute(
          path: AppRoutes.linkProfile,
          builder: (context, state){
            final student = state.extra as VerifiedStudentModel;

            return LinkProfileView(student: student);
          },
        ),
        GoRoute(
          path: AppRoutes.studentLinkedSuccess,
            builder: (context, state){
            final student = state.extra as LinkedStudentModel;

            return StudentLinkedSucessView(student: student);
          },
       //   builder: (_, __) => const StudentLinkedSucessView(),
        ),
        GoRoute(
          path: AppRoutes.feeSelection,
          builder: (_, __) => const FeeBreakDownView(
            fees: [
              {'name': 'Tuition Fees', 'amount': 300000},
              {'name': 'Exam Fees', 'amount': 50000},
              {'name': 'Library Fees', 'amount': 10000},
              {'name': 'Tuition Fees', 'amount': 300000},
              {'name': 'Exam Fees', 'amount': 50000},
              {'name': 'Library Fees', 'amount': 10000},
            ],
          ),
        ),
        GoRoute(
          path: AppRoutes.feeConfirmation,
          builder: (_, __) => const PaymentConfirmationView(),
        ),
        GoRoute(
          path: AppRoutes.feeSuccess,
          builder: (_, __) => const PaymentSuccessView(),
        ),
        GoRoute(
          path: AppRoutes.editSchools,
          builder: (_, __) => const EditSchoolsView(),
        ),
        GoRoute(
          path: AppRoutes.editSchoolDetail,
          builder: (context, state) {
            final schoolId = state.pathParameters['id'] ?? '';
            return EditSchoolDetailView(schoolId: schoolId);
          },
        ),

        GoRoute(
          path: AppRoutes.linkStudents,
          builder: (_, __) => const LinkStudentsView(),
        ),

        GoRoute(
          path: AppRoutes.guardianVerification,
          builder: (_, __) => const GuardianVerificationView(),
        ),

        GoRoute(
          path: AppRoutes.changePhoneNumber,
          builder: (_, __) => const ChangePhoneNumberView(),
        ),

        GoRoute(
          path: AppRoutes.fundWallet,
          builder: (_, __) => const FundWalletView(),
        ),
        GoRoute(
          path: AppRoutes.transactions,
          builder: (_, __) => const TransactionsView(),
        ),
        GoRoute(
          path: AppRoutes.transactionDetail,
          builder: (context, state) {
            final transaction = state.extra as TransactionItem?;
            return TransactionDetailView(transaction: transaction);
          },
        ),

        GoRoute(
          path: AppRoutes.payFees,
          builder: (_, __) => const PayFeesView(),
        ),

        GoRoute(
          path: AppRoutes.notifications,
          builder: (_, __) => const NotificationsView(),
        ),

        GoRoute(
          path: AppRoutes.helpSupport,
          builder: (_, __) => const HelpSupportView(),
        ),

        GoRoute(
          path: AppRoutes.requestPending,
          builder: (_, __) => const RequestPendingView(),
        ),
        GoRoute(
          path: AppRoutes.requestFailed,
          builder: (_, __) => const RequestFailedView(),
        ),

        GoRoute(
          path: AppRoutes.success,
          builder: (context, state) {
            final args = state.extra as SuccessArgs;

            return SuccessView(
              title: args.title,
              message: args.message,
              buttonLabel: args.buttonLabel,
              nextRoute: args.nextRoute,
              nextExtra: args.nextExtra,
            );
          },
        ),
      ],
    );
  }
}

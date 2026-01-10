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
import '../../features/profile/presentation/views/profile_view.dart';
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
      initialLocation: AppRoutes.onboarding,
      routes: [
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
            final email = state.extra as String? ?? '';
            return VerifyOtpView(email: email);
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
          path: AppRoutes.home,
          builder: (_, __) => const DashboardView(),
        ),
        GoRoute(
          path: AppRoutes.dashboard,
          builder: (_, __) => const DashboardView(),
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
          path: AppRoutes.linkedStudents,
          builder: (_, __) => const LinkedStudentsView(),
        ),
        GoRoute(
          path: AppRoutes.guardianVerification,
          builder: (_, __) => const GuardianVerificationView(),
        ),

        GoRoute(
          path: AppRoutes.profile,
          builder: (_, __) => const ProfileView(),
        ),
        GoRoute(
          path: AppRoutes.changePhoneNumber,
          builder: (_, __) => const ChangePhoneNumberView(),
        ),

        GoRoute(
          path: AppRoutes.walletManagement,
          builder: (_, __) => const WalletManagementView(),
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
            final transactionId = state.extra as String?;
            return TransactionDetailView(transactionId: transactionId);
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
            final extra = state.extra as Map<String, String>?;
            return SuccessView(
              title: extra?['title'] ?? 'Success',
              message: extra?['message'] ?? 'Operation completed successfully',
              buttonLabel: extra?['buttonLabel'] ?? 'My Dashboard',
            );
          },
        ),
      ],
    );
  }
}

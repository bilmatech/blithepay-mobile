import 'package:blithepay/core/navigation/index.dart';
import 'package:blithepay/features/students/data/models/verify_student_model.dart';
import 'package:blithepay/features/students/data/models/view_invoice_model.dart';

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
              path: AppRoutes.linkedStudents,
              builder: (_, __) => const LinkedStudentsView(),
            ),
            GoRoute(
              path: AppRoutes.home,
              builder: (context, state) => const HomeView(),
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
          builder: (context, state) {
            final student = state.extra as VerifiedStudentModel;

            return LinkProfileView(student: student);
          },
        ),
        GoRoute(
          path: AppRoutes.studentLinkedSuccess,
          builder: (context, state) {
            final student = state.extra as LinkedStudentModel;

            return StudentLinkedSucessView(student: student);
          },
          //   builder: (_, __) => const StudentLinkedSucessView(),
        ),
        GoRoute(
          path: AppRoutes.feeSelection,
          builder: (context, state) {
            final args = state.extra as FeeSelectionArgs;

            return FeeBreakDownView(
              student: args.student,
              invoice: args.invoice,
              latePaymentFee: args.latePaymentFee,
            );
          },
        ),
        GoRoute(
          path: AppRoutes.feeConfirmation,
          builder: (context, state) {
            final invoiceId = state.extra as String;

            return PaymentConfirmationView(invoiceId: invoiceId);
          },
        ),
        GoRoute(
          path: AppRoutes.feeSuccess,
          builder: (context, state) {
            final extraData = state.extra as Map<String, dynamic>;
            final invoice = extraData['invoice'] as ViewInvoiceModel;
            final paymentData = extraData['paymentData'] as WalletPaymentData;

            return PaymentSuccessView(
              invoice: invoice,
              paymentData: paymentData,
            );
          },
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
          path: AppRoutes.transactionReceiptView,
          builder: (context, state) {
            final transaction = state.extra as WalletTransactionModel;
            return TransactionReceiptView(transaction: transaction);
          },
        ),

        GoRoute(
          path: AppRoutes.invoicedetail,
          builder: (context, state) {
            final extraData = state.extra as Map<String, dynamic>;

            final invoice = extraData['invoice'] as InvoiceModel;
            final student = extraData['student'] as VerifiedStudentModel;

            return InvoiceAndFeeDetailsView(
              invoice: invoice,
              student: student,
              // fees: invoice.fee,
            );
          },
        ),

        GoRoute(
          path: AppRoutes.transactionDetail,
          builder: (context, state) {
            final transaction = state.extra as WalletTransactionModel;
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
          path: AppRoutes.feeTransactions,
          builder: (context, state) {
            final studentId = state.extra as VerifiedStudentModel;
            return FeesTransactionsView(student: studentId);
          },
        ),
        GoRoute(
          path: AppRoutes.studentTransactionDetail,
          builder: (context, state) {
            final transaction = state.extra as StudentTransactionModel;
            return PaymentHistoryDetailView(transaction: transaction);
          },
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

import 'package:flutter/material.dart';
import 'package:shop/entry_point.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/models/address_model.dart';

import 'screen_export.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case onbordingScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const EntryPoint(),
      );
    // case preferredLanuageScreenRoute:
    //   return MaterialPageRoute(
    //     builder: (context) => const PreferredLanguageScreen(),
    //   );
    case logInScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      );
    case signUpScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const SignUpScreen(),
      );
    // case profileSetupScreenRoute:
    //   return MaterialPageRoute(
    //     builder: (context) => const ProfileSetupScreen(),
    //   );
    case passwordRecoveryScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const PasswordRecoveryScreen(),
      );
    // case verificationMethodScreenRoute:
    //   return MaterialPageRoute(
    //     builder: (context) => const VerificationMethodScreen(),
    //   );
    // case otpScreenRoute:
    //   return MaterialPageRoute(
    //     builder: (context) => const OtpScreen(),
    //   );
    // case newPasswordScreenRoute:
    //   return MaterialPageRoute(
    //     builder: (context) => const SetNewPasswordScreen(),
    //   );
    // case doneResetPasswordScreenRoute:
    //   return MaterialPageRoute(
    //     builder: (context) => const DoneResetPasswordScreen(),
    //   );
    // case termsOfServicesScreenRoute:
    //   return MaterialPageRoute(
    //     builder: (context) => const TermsOfServicesScreen(),
    //   );
    // case noInternetScreenRoute:
    //   return MaterialPageRoute(
    //     builder: (context) => const NoInternetScreen(),
    //   );
    // case serverErrorScreenRoute:
    //   return MaterialPageRoute(
    //     builder: (context) => const ServerErrorScreen(),
    //   );
    // case signUpVerificationScreenRoute:
    //   return MaterialPageRoute(
    //     builder: (context) => const SignUpVerificationScreen(),
    //   );
    // case setupFingerprintScreenRoute:
    //   return MaterialPageRoute(
    //     builder: (context) => const SetupFingerprintScreen(),
    //   );
    // case setupFaceIdScreenRoute:
    //   return MaterialPageRoute(
    //     builder: (context) => const SetupFaceIdScreen(),
    //   );
    case productDetailsScreenRoute:
      return MaterialPageRoute(
        builder: (context) {
          final product = settings.arguments as ProductModel;
          return ProductDetailsScreen(product: product);
        },
      );
    case productReviewsScreenRoute:
      return MaterialPageRoute(
        builder: (context) {
          final product = settings.arguments as ProductModel;
          return ProductReviewsScreen(product: product);
        },
      );
    // case addReviewsScreenRoute:
    //   return MaterialPageRoute(
    //     builder: (context) => const AddReviewScreen(),
    //   );
    case homeScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      );
    // case brandScreenRoute:
    //   return MaterialPageRoute(
    //     builder: (context) => const BrandScreen(),
    //   );
    // case discoverWithImageScreenRoute:
    //   return MaterialPageRoute(
    //     builder: (context) => const DiscoverWithImageScreen(),
    //   );
    // case subDiscoverScreenRoute:
    //   return MaterialPageRoute(
    //     builder: (context) => const SubDiscoverScreen(),
    //   );
    // case discoverScreenRoute:
    //   return MaterialPageRoute(
    //     builder: (context) => const DiscoverScreen(),
    //   );
    case categoryProductsScreenRoute:
      return MaterialPageRoute(
        builder: (context) {
          final category = settings.arguments as String;
          return CategoryProductsScreen(category: category);
        },
      );
    case searchScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const SearchScreen(),
      );
    // case searchHistoryScreenRoute:
    //   return MaterialPageRoute(
    //     builder: (context) => const SearchHistoryScreen(),
    //   );
    case bookmarkScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const BookmarkScreen(),
      );
    case entryPointScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const EntryPoint(),
      );
    case profileScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const ProfileScreen(),
      );
    case getHelpScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const GetHelpScreen(),
      );
    case faqScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const FAQScreen(),
      );
    case supportChatScreenRoute:
      return MaterialPageRoute(
        builder: (context) {
          final ticket = settings.arguments as Map<String, dynamic>;
          return SupportChatScreen(ticket: ticket);
        },
      );
    // case chatScreenRoute:
    //   return MaterialPageRoute(
    //     builder: (context) => const ChatScreen(),
    //   );
    case userInfoScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const UserInfoScreen(),
      );
    // case currentPasswordScreenRoute:
    //   return MaterialPageRoute(
    //     builder: (context) => const CurrentPasswordScreen(),
    //   );
    case editUserInfoScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const EditUserInfoScreen(),
      );
    case notificationsScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const NotificationsScreen(),
      );
    case noNotificationScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const NoNotificationScreen(),
      );
    case enableNotificationScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const EnableNotificationScreen(),
      );
    case notificationOptionsScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const NotificationOptionsScreen(),
      );
    // case selectLanguageScreenRoute:
    //   return MaterialPageRoute(
    //     builder: (context) => const SelectLanguageScreen(),
    //   );
    // case noAddressScreenRoute:
    //   return MaterialPageRoute(
    //     builder: (context) => const NoAddressScreen(),
    //   );
    case addressesScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const AddressesScreen(),
      );
    case addNewAddressesScreenRoute:
      return MaterialPageRoute(
        builder: (context) {
          final address = settings.arguments as AddressModel?;
          return AddNewAddressScreen(address: address);
        },
      );
    case ordersScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const OrdersScreen(),
      );
    case orderProcessingScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const OrderListScreen(
          title: "Processing",
          status: OrderStatus.processing,
        ),
      );
    // case orderDetailsScreenRoute:
    //   return MaterialPageRoute(
    //     builder: (context) => const OrderDetailsScreen(),
    //   );
    // case cancleOrderScreenRoute:
    //   return MaterialPageRoute(
    //     builder: (context) => const CancleOrderScreen(),
    //   );
    case deliveredOrdersScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const OrderListScreen(
          title: "Delivered",
          status: OrderStatus.delivered,
        ),
      );
    case cancledOrdersScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const OrderListScreen(
          title: "Canceled",
          status: OrderStatus.canceled,
        ),
      );
    case awaitingPaymentOrdersScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const OrderListScreen(
          title: "Awaiting Payment",
          status: OrderStatus.awaitingPayment,
        ),
      );
    case returnedOrdersScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const OrderListScreen(
          title: "Returned",
          status: OrderStatus.returned,
        ),
      );
    case preferencesScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const PreferencesScreen(),
      );
    case cartScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const CartScreen(),
      );
    case paymentScreenRoute:
      return MaterialPageRoute(
        builder: (context) {
          final args = settings.arguments as PaymentScreenArgs;
          return PaymentScreen(args: args);
        },
      );
    case thanksForOrderScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const ThanksForOrderScreen(),
      );
    default:
      return MaterialPageRoute(
        // Make a screen for undefine
        builder: (context) => const EntryPoint(),
      );
  }
}

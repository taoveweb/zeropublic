import 'dart:async';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get_storage/get_storage.dart';
import 'package:square_in_app_payments/in_app_payments.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:zero/common/utils/deveice_info.dart';
import 'package:zero/common/utils/storage.dart';
import 'package:zero/common/utils/util.dart';
import 'package:zero/shared/notification/firebase.dart';
import 'package:zero/pages/payment_methods/widgets/config.dart';
import 'common/utils/env/env.dart';
import 'package:square_in_app_payments/google_pay_constants.dart'
    as google_pay_constants;

///框架启动前的一些初始化工作放这里
class Global {
  static bool googlePayEnabled = false;
  static bool applePayEnabled = false;

  static Future<void> init() async {
    WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
    await GetStorage.init();
    await dotenv.load(fileName: ".env");
    tz.initializeTimeZones();

    /**
     * 业务类型初始化
     */

    // 支付
    await _initPayment();

    // 获取当前时区
    await getLocalTimeZone();

    // 设备信息
    Storage.deviceInfo = await initPlatformState();

    // 推送 阻塞初始化
    await FireBaseMessageUtil.init();
  }

  static Future<void> _initPayment() async {
    await InAppPayments.setSquareApplicationId(
      squareApplicationId,
    );
    if (Platform.isAndroid) {
      await InAppPayments.initializeGooglePay(
        squareLocationId,
        google_pay_constants.environmentProduction,
      );
      googlePayEnabled = await InAppPayments.canUseGooglePay;
    } else if (Platform.isIOS) {
      await InAppPayments.initializeApplePay(
        applePayMerchantId,
      );
      applePayEnabled = await InAppPayments.canUseApplePay;
    }
  }
}

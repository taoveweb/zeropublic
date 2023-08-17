import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:zero/common/utils/utils.dart';
import 'package:zero/global.dart';
import 'package:zero/pages/home/home_controller.dart';
import 'package:zero/pages/tabs/TabsBinding.dart';
import 'package:zero/routers/router.dart';
import 'package:zero/routers/router_path.dart';
import 'package:zero/shared/version_update/version_update_controller.dart';

void main() async {
  runZonedGuarded<Future<void>>(() async {
    await Global.init();
    await ScreenUtil.ensureScreenSize();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));
    await SystemChrome.setPreferredOrientations(
      [
        DeviceOrientation.portraitUp, // 竖屏 Portrait 模式
        DeviceOrientation.portraitDown,
      ],
    );
    // var dsn =
    //     'https://7b09a5a9e6ed4fb680d99bb1402b1047@o1203683.ingest.sentry.io/6330241';
    // if (kDebugMode) {
    //   dsn =
    //       'https://23226ef3b8f5410cb4c0a3be8a7cc457@o1203683.ingest.sentry.io/6547176';
    // }

    /*  await SentryFlutter.init(
      (options) {
        options.dsn = dsn;
      },
    ); */
    runApp(const MyApp());
  }, (error, stack) async {
    await FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);

    // await Sentry.captureException(error, stackTrace: stack);
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FlutterNativeSplash.remove();
    final easyload = EasyLoading.init();

    return ScreenUtilInit(
      designSize: const Size(750, 1623),
      minTextAdapt: false,
      splitScreenMode: false,
      builder: (context, Widget? widget) {
        return GetMaterialApp(
          routingCallback: (routing) async {
            if (routing?.current != '/rewards') {
              //如果不是Rewards页面，就还原导航栏颜色
              SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
              ));
            }

            //结算页面回退后刷新购物车 从购物车到结算页面也会触发
            final HomeController c = Get.put(HomeController());

            if (routing?.current == RouterPath.shoppingCartPage &&
                routing?.isBack == true &&
                routing?.isDialog == false &&
                Get.isDialogOpen != true &&
                c.isShopCar.value == false) {
              //TODO 有些回退不需要刷，且会有多余loading
              await Future.delayed(Duration(milliseconds: 500));
              c.maincheck();
            }

            VersionUpdateController.onRouteChange();
          },
          theme: ThemeData(
            primarySwatch: createMaterialColor(const Color(0xffffffff)),
            primaryColor: const Color(0xffffffff),
            textTheme: TextTheme(
              bodyText1: TextStyle(fontSize: 16.sp),
              bodyText2: TextStyle(fontSize: 16.sp),
            ),
          ),
          initialRoute: !isLogin()
              ? RouterPath.login
              : Storage.storeId != null
                  ? RouterPath.home
                  : RouterPath.store,
          getPages: Routers.routes,
          builder: (context, widget) {
            var child = easyload(context, widget);

            return MediaQuery(
              ///设置文字大小不随系统设置改变
              data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
              child: child,
            );
          },
          initialBinding: InitBinding(),
        );
      },
    );
  }
}

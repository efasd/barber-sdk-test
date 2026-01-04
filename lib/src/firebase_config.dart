import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BarberFirebaseConfig {
  static Future<FirebaseFirestore> init() async {
    FirebaseOptions options = Platform.isIOS
        ? const FirebaseOptions(
            apiKey: "AIzaSyApTwKhdt92AjOT0cI6ha-06cO8ZomWR0Y",
            appId: "1:430107490046:ios:dcbd06334a8f0eb97497af",
            messagingSenderId: "430107490046",
            projectId: "khovsgol-7cf1b",
            storageBucket: "khovsgol-7cf1b.firebasestorage.app",
            iosBundleId: "com.barbermn.mng",
          )
        : const FirebaseOptions(
            apiKey: "AIzaSyBIwR3yL2LzE9Ss5zUOb9nfowUwUr_LgRk",
            appId: "1:430107490046:android:2d385a4668832ef47497af",
            messagingSenderId: "430107490046",
            projectId: "khovsgol-7cf1b",
            storageBucket: "khovsgol-7cf1b.firebasestorage.app",
          );

    FirebaseApp barberApp;
    try {
      barberApp = Firebase.app('BarberProject');
    } catch (e) {
      barberApp = await Firebase.initializeApp(
        name: 'BarberProject',
        options: options,
      );
    }
    return FirebaseFirestore.instanceFor(app: barberApp);
  }
}
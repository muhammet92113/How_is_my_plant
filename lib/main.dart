import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart'; // Firebase geçici olarak devre dışı
// import 'package:firebase_messaging/firebase_messaging.dart'; // Firebase geçici olarak devre dışı
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login_page.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'package:provider/provider.dart';
import 'services/current_plant.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(); // Firebase geçici olarak devre dışı

  // Supabase'i başlat
  await Supabase.initialize(
    url: 'https://ghrmrpazuoivzmtyrmhl.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdocm1ycGF6dW9pdnptdHlybWhsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM0ODQ2NzQsImV4cCI6MjA2OTA2MDY3NH0.7yXv0zlXwGuPic0K1JmVWyndjh0MHXqExhew7z8fHeE',
  );

  // Bildirim izni iste (özellikle iOS için)
  // await FirebaseMessaging.instance.requestPermission(); // Firebase geçici olarak devre dışı

  // Cihaz tokenını al
  // String? token = await FirebaseMessaging.instance.getToken(); // Firebase geçici olarak devre dışı
  // print('FCM Device Token: $token');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CurrentPlant(),
      child: MaterialApp(
        title: 'Bitki Takip',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.green,
          brightness: Brightness.light,
          cardTheme: const CardThemeData(margin: EdgeInsets.symmetric(vertical: 6)),
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();

    // Arka planda ve kapalıyken gelen bildirimleri dinle
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) { // Firebase geçici olarak devre dışı
    //   print('Bildirim geldi: ${message.notification?.title} - ${message.notification?.body}');
    //   // İstersen burada lokal bildirim gösterebilirsin
    // });

    // FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) { // Firebase geçici olarak devre dışı
    //   print('Bildirime tıklandı');
    //   // Bildirime tıklanınca yapılacaklar
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bitki Takip')),
      body: const Center(child: Text('Ana Sayfa')),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:skillsync/bloc/auth/auth_bloc.dart';
import 'package:skillsync/bloc/auth/auth_event.dart';
import 'package:skillsync/bloc/auth/skill/skill_bloc.dart';
import 'package:skillsync/repositories/auth_repository.dart';
import 'package:skillsync/repositories/skill_repository.dart';

import 'package:skillsync/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyD1ZGF3NjapAoAhdkQTuJK8ih_hNd5k0TE",
      authDomain:
          "skillsync-5c54e.firebaseapp.com", // usually projectId + ".firebaseapp.com"
      projectId: "skillsync-5c54e",
      storageBucket: "skillsync-5c54e.appspot.com",
      messagingSenderId: "701224764701",
      appId:
          "1:701224764701:web:XXXXXXXXXXXXXX", // get this from your Firebase web app settings
      measurementId:
          "G-XXXXXXXXXX", // optional, from Firebase Analytics web setup
    ),
  );
  runApp(const SkillSyncApp());
}

class SkillSyncApp extends StatelessWidget {
  const SkillSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (context) => AuthRepository(),
        ),
        RepositoryProvider<FirebaseSkillRepository>(
          create: (context) => FirebaseSkillRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create:
                (context) =>
                    AuthBloc(authRepository: context.read<AuthRepository>())
                      ..add(AuthCheckRequested()),
          ),
          BlocProvider<SkillBloc>(
            create:
                (context) =>
                    SkillBloc(skillRepository: context.read<FirebaseSkillRepository>()),
          ),
        ],
        child: MaterialApp(
          title: 'Skill Sync',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF6366F1),
              brightness: Brightness.light,
            ),
            useMaterial3: true,
            appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
          ),
          home: const SplashScreen(),
        ),
      ),
    );
  }
}


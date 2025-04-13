import 'package:attend_app/components/buttons.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFD60A),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Welcome to RISE',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 30),

          // LOGO with animation
          FadeTransition(
            opacity: _fadeIn,
            child: Center(
              child: Image.asset(
                "assets/images/rise_logo.png",
                height: 120,
                fit: BoxFit.contain,
              ),
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            'Train. Track. Transform.',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              letterSpacing: 1.1,
            ),
          ),

          const SizedBox(height: 40),

          MyButton(
            text: "Users List",
            onTap: () {
              Navigator.pushNamed(context, '/Userslist');
            },
          ),

          MyButton(
            text: "Add User",
            onTap: () {
              Navigator.pushNamed(context, '/AddUser');
            },
          ),

          const Spacer(),

          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              "Powered by Rise Superhuman",
              style: TextStyle(color: Colors.black38, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../core/utils/premium_checker.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  bool _unlocked = false;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    final result = await PremiumChecker.isPremiumUnlocked();
    setState(() => _unlocked = result);
  }

  Future<void> _unlock() async {
    await PremiumChecker.unlockPremium();
    setState(() => _unlocked = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Premium unlocked!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Premium Features')),
      body: Center(
        child: _unlocked
            ? const Text('Thank you for supporting us!')
            : ElevatedButton(
                onPressed: _unlock,
                child: const Text('Unlock Premium'),
              ),
      ),
    );
  }
}
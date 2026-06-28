import 'package:flutter/material.dart';

import '../main.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> logout(BuildContext context) async {
    await ApiService.logout();

    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
        (route) => false,
      );
    }
  }

  Widget buildProfileCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2563EB),
            Color(0xFF1D4ED8),
            Color(0xFF0F172A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ApiService.fullName ?? "User",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "User ID: ${ApiService.userId ?? "-"}",
                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  Widget buildDarkModeSwitch() {
    return ValueListenableBuilder<bool>(
      valueListenable: ThemeController.isDarkMode,
      builder: (context, isDark, _) {
        return SwitchListTile(
          contentPadding: EdgeInsets.zero,
          secondary: const Icon(
            Icons.dark_mode_outlined,
            color: Color(0xFF2563EB),
          ),
          title: const Text(
            "Dark Mode",
            style: TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
          subtitle: const Text("Switch between light and dark theme"),
          value: isDark,
          onChanged: (value) {
            ThemeController.toggleTheme(value);
          },
        );
      },
    );
  }

  Widget buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        icon,
        color: const Color(0xFF2563EB),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Text(subtitle),
    );
  }

  Widget buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => logout(context),
        icon: const Icon(Icons.logout),
        label: const Text("Logout"),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            vertical: 16,
          ),
          foregroundColor: const Color(0xFFEF4444),
          side: const BorderSide(
            color: Color(0xFFEF4444),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            buildProfileCard(),

            buildSectionCard(
              title: "Appearance",
              children: [
                buildDarkModeSwitch(),
              ],
            ),

            buildSectionCard(
              title: "App Info",
              children: [
                buildInfoTile(
                  icon: Icons.notifications_active_outlined,
                  title: "Reminder App",
                  subtitle: "AI-powered schedule and reminder manager",
                ),
                buildInfoTile(
                  icon: Icons.security_outlined,
                  title: "Security",
                  subtitle: "JWT login with user-specific schedules",
                ),
                buildInfoTile(
                  icon: Icons.auto_awesome,
                  title: "AI Upload",
                  subtitle: "Timetable image and PDF analysis support",
                ),
              ],
            ),

            const SizedBox(height: 22),

            buildLogoutButton(context),
          ],
        ),
      ),
    );
  }
}
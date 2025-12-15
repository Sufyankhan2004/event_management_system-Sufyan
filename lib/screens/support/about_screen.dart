import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/app_theme.dart';

// ================================
// ABOUT SCREEN
// ================================

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // App Logo/Icon
          Center(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.event,
                size: 60,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // App Name
          Center(
            child: Text(
              'Event Management System',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          
          // Version
          Center(
            child: Text(
              'Version 1.0.0',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 32),
          
          // Description
          Text(
            'About the App',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Event Management System is a comprehensive platform that connects event organizers with attendees. Discover exciting events, manage your registrations, and create memorable experiences.',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          
          // Features
          Text(
            'Features',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildFeatureItem('Browse and discover events'),
          _buildFeatureItem('Easy registration and payment'),
          _buildFeatureItem('Digital tickets with QR codes'),
          _buildFeatureItem('Favorite events for quick access'),
          _buildFeatureItem('Real-time notifications'),
          _buildFeatureItem('Event organization tools'),
          _buildFeatureItem('Analytics for organizers'),
          const SizedBox(height: 24),
          
          // Developer Info
          Text(
            'Developer',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Developed by Sufyan Khan',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Semester Project',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          
          // Legal Section
          _buildLegalLink(
            context,
            title: 'Terms of Service',
            onTap: () {
              _showTermsOfService(context);
            },
          ),
          _buildLegalLink(
            context,
            title: 'Privacy Policy',
            onTap: () {
              _showPrivacyPolicy(context);
            },
          ),
          _buildLegalLink(
            context,
            title: 'Licenses',
            onTap: () {
              showLicensePage(
                context: context,
                applicationName: 'Event Management System',
                applicationVersion: '1.0.0',
                applicationIcon: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.event,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          
          // Copyright
          Center(
            child: Text(
              '© 2024 Event Management System\nAll rights reserved',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            size: 20,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              feature,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalLink(BuildContext context, {required String title, required VoidCallback onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showTermsOfService(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Service'),
        content: const SingleChildScrollView(
          child: Text(
            'These are the terms of service for Event Management System.\n\n'
            '1. By using this app, you agree to these terms.\n'
            '2. You must be 18 or older to use this service.\n'
            '3. You are responsible for maintaining account security.\n'
            '4. We reserve the right to modify these terms at any time.\n'
            '5. Event registrations are subject to organizer policies.\n\n'
            'For complete terms, please visit our website.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'Privacy Policy for Event Management System\n\n'
            '1. We collect personal information to provide our services.\n'
            '2. Your data is stored securely and encrypted.\n'
            '3. We do not sell your personal information.\n'
            '4. You can request data deletion at any time.\n'
            '5. We use cookies to improve user experience.\n'
            '6. Payment information is processed securely.\n\n'
            'For our complete privacy policy, please visit our website.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

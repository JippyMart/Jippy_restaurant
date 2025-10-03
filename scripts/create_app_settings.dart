import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

// Firebase configuration - Update these with your project details
const String projectId = 'your-firebase-project-id';
const String apiKey = 'your-firebase-api-key';

class AppSettingsCreator {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // App configurations
  static const Map<String, Map<String, dynamic>> appConfigs = {
    'restaurant': {
      'package_name': 'com.jippymart.restaurant',
      'app_name': 'Restaurant App',
      'play_store_url': 'https://play.google.com/store/apps/details?id=com.jippymart.restaurant',
      'app_store_url': 'https://apps.apple.com/app/restaurant-app/id123456789',
    },
    'customer': {
      'package_name': 'com.jippymart.customer',
      'app_name': 'Customer App',
      'play_store_url': 'https://play.google.com/store/apps/details?id=com.jippymart.customer',
      'app_store_url': 'https://apps.apple.com/app/customer-app/id987654321',
    },
    'driver': {
      'package_name': 'com.jippymart.driver',
      'app_name': 'Driver App',
      'play_store_url': 'https://play.google.com/store/apps/details?id=com.jippymart.driver',
      'app_store_url': 'https://apps.apple.com/app/driver-app/id456789123',
    },
  };

  Future<void> initializeFirebase() async {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        projectId: projectId,
        apiKey: apiKey,
        appId: 'your-app-id',
        messagingSenderId: 'your-sender-id',
      ),
    );
  }

  Map<String, dynamic> createVersionData({
    required String appType,
    required String latestVersion,
    required String androidBuild,
    required String iosBuild,
    required bool forceUpdate,
    required String minRequiredVersion,
    required String updateMessage,
  }) {
    final appConfig = appConfigs[appType]!;
    final now = DateTime.now().toIso8601String();

    return {
      'latest_version': latestVersion,
      'force_update': forceUpdate,
      'update_url': Platform.isAndroid 
          ? appConfig['play_store_url'] 
          : appConfig['app_store_url'],
      'android_version': latestVersion,
      'ios_version': latestVersion,
      'android_build': androidBuild,
      'ios_build': iosBuild,
      'min_required_version': minRequiredVersion,
      'update_message': updateMessage,
      'last_updated': now,
      'app_name': appConfig['app_name'],
      'package_name': appConfig['package_name'],
      'app_type': appType,
    };
  }

  Future<void> createAppSettings({
    required String appType,
    required String latestVersion,
    required String androidBuild,
    required String iosBuild,
    required bool forceUpdate,
    required String minRequiredVersion,
    required String updateMessage,
  }) async {
    try {
      final versionData = createVersionData(
        appType: appType,
        latestVersion: latestVersion,
        androidBuild: androidBuild,
        iosBuild: iosBuild,
        forceUpdate: forceUpdate,
        minRequiredVersion: minRequiredVersion,
        updateMessage: updateMessage,
      );

      await _firestore
          .collection('app_settings')
          .doc(appType)
          .set(versionData);

      print('✅ Created app settings for $appType');
      print('📄 Document: app_settings/$appType');
      print('📱 Version: $latestVersion');
      print('🔗 Update URL: ${versionData['update_url']}');
      print('---');
    } catch (e) {
      print('❌ Error creating app settings for $appType: $e');
    }
  }

  Future<void> createAllAppSettings({
    required String latestVersion,
    required String androidBuild,
    required String iosBuild,
    required bool forceUpdate,
    required String minRequiredVersion,
    required String updateMessage,
  }) async {
    print('🚀 Creating app settings for all apps...');
    print('📱 Latest Version: $latestVersion');
    print('🔧 Force Update: $forceUpdate');
    print('---');

    for (String appType in appConfigs.keys) {
      await createAppSettings(
        appType: appType,
        latestVersion: latestVersion,
        androidBuild: androidBuild,
        iosBuild: iosBuild,
        forceUpdate: forceUpdate,
        minRequiredVersion: minRequiredVersion,
        updateMessage: updateMessage,
      );
    }

    print('🎉 All app settings created successfully!');
  }

  Future<void> updateSpecificApp({
    required String appType,
    required String latestVersion,
    required String androidBuild,
    required String iosBuild,
    bool? forceUpdate,
    String? minRequiredVersion,
    String? updateMessage,
  }) async {
    try {
      final docRef = _firestore.collection('app_settings').doc(appType);
      final doc = await docRef.get();

      if (!doc.exists) {
        print('❌ App settings document for $appType does not exist');
        return;
      }

      final currentData = doc.data()!;
      final updateData = <String, dynamic>{};

      // Update only provided fields
      if (latestVersion.isNotEmpty) updateData['latest_version'] = latestVersion;
      if (androidBuild.isNotEmpty) updateData['android_build'] = androidBuild;
      if (iosBuild.isNotEmpty) updateData['ios_build'] = iosBuild;
      if (forceUpdate != null) updateData['force_update'] = forceUpdate;
      if (minRequiredVersion != null) updateData['min_required_version'] = minRequiredVersion;
      if (updateMessage != null) updateData['update_message'] = updateMessage;

      updateData['last_updated'] = DateTime.now().toIso8601String();

      await docRef.update(updateData);

      print('✅ Updated app settings for $appType');
      print('📄 Document: app_settings/$appType');
      print('📱 New Version: $latestVersion');
      print('---');
    } catch (e) {
      print('❌ Error updating app settings for $appType: $e');
    }
  }

  Future<void> listAllAppSettings() async {
    try {
      final snapshot = await _firestore.collection('app_settings').get();
      
      print('📋 Current App Settings:');
      print('---');
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        print('📱 ${data['app_name'] ?? doc.id}');
        print('   Document ID: ${doc.id}');
        print('   Latest Version: ${data['latest_version']}');
        print('   Force Update: ${data['force_update']}');
        print('   Last Updated: ${data['last_updated']}');
        print('   Package: ${data['package_name']}');
        print('---');
      }
    } catch (e) {
      print('❌ Error listing app settings: $e');
    }
  }

  Future<void> deleteAppSettings(String appType) async {
    try {
      await _firestore.collection('app_settings').doc(appType).delete();
      print('✅ Deleted app settings for $appType');
    } catch (e) {
      print('❌ Error deleting app settings for $appType: $e');
    }
  }
}

// CLI Interface
void main(List<String> args) async {
  if (args.isEmpty) {
    printUsage();
    return;
  }

  final creator = AppSettingsCreator();
  await creator.initializeFirebase();

  final command = args[0];

  switch (command) {
    case 'create-all':
      if (args.length < 7) {
        print('❌ Usage: dart create_app_settings.dart create-all <version> <android_build> <ios_build> <force_update> <min_version> <message>');
        return;
      }
      await creator.createAllAppSettings(
        latestVersion: args[1],
        androidBuild: args[2],
        iosBuild: args[3],
        forceUpdate: args[4] == 'true',
        minRequiredVersion: args[5],
        updateMessage: args[6],
      );
      break;

    case 'create':
      if (args.length < 8) {
        print('❌ Usage: dart create_app_settings.dart create <app_type> <version> <android_build> <ios_build> <force_update> <min_version> <message>');
        return;
      }
      await creator.createAppSettings(
        appType: args[1],
        latestVersion: args[2],
        androidBuild: args[3],
        iosBuild: args[4],
        forceUpdate: args[5] == 'true',
        minRequiredVersion: args[6],
        updateMessage: args[7],
      );
      break;

    case 'update':
      if (args.length < 3) {
        print('❌ Usage: dart create_app_settings.dart update <app_type> <version> [android_build] [ios_build] [force_update] [min_version] [message]');
        return;
      }
      await creator.updateSpecificApp(
        appType: args[1],
        latestVersion: args[2],
        androidBuild: args.length > 3 ? args[3] : '',
        iosBuild: args.length > 4 ? args[4] : '',
        forceUpdate: args.length > 5 ? args[5] == 'true' : null,
        minRequiredVersion: args.length > 6 ? args[6] : null,
        updateMessage: args.length > 7 ? args[7] : null,
      );
      break;

    case 'list':
      await creator.listAllAppSettings();
      break;

    case 'delete':
      if (args.length < 2) {
        print('❌ Usage: dart create_app_settings.dart delete <app_type>');
        return;
      }
      await creator.deleteAppSettings(args[1]);
      break;

    default:
      printUsage();
  }
}

void printUsage() {
  print('''
🔄 App Settings Manager

Usage:
  dart create_app_settings.dart <command> [options]

Commands:
  create-all <version> <android_build> <ios_build> <force_update> <min_version> <message>
    Create settings for all apps (restaurant, customer, driver)
    
  create <app_type> <version> <android_build> <ios_build> <force_update> <min_version> <message>
    Create settings for specific app (restaurant, customer, driver)
    
  update <app_type> <version> [android_build] [ios_build] [force_update] [min_version] [message]
    Update settings for specific app
    
  list
    List all current app settings
    
  delete <app_type>
    Delete settings for specific app

Examples:
  # Create settings for all apps
  dart create_app_settings.dart create-all 2.2.4 13 13 false 2.0.0 "New features available!"
  
  # Create settings for restaurant app only
  dart create_app_settings.dart create restaurant 2.2.4 13 13 false 2.0.0 "Restaurant app update!"
  
  # Update restaurant app version
  dart create_app_settings.dart update restaurant 2.2.5
  
  # List all settings
  dart create_app_settings.dart list
  
  # Delete restaurant settings
  dart create_app_settings.dart delete restaurant
''');
}

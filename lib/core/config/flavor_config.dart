// lib/core/config/flavor_config.dart
enum Flavor { dev, staging, prod }

class FlavorConfig {
  final Flavor flavor;
  final String appName;
  final String baseUrl;
  final String socketUrl;
  final bool enableLogging;

  const FlavorConfig._({
    required this.flavor,
    required this.appName,
    required this.baseUrl,
    required this.socketUrl,
    required this.enableLogging,
  });

  static late FlavorConfig _instance;
  static FlavorConfig get instance => _instance;

  static void initialize(Flavor flavor) {
    _instance = switch (flavor) {
      Flavor.dev => const FlavorConfig._(
          flavor: Flavor.dev, appName: 'e-Drive DEV',
          baseUrl:
              'https://api.edrive.ng/api', // use same API for dev until a dev env exists
          socketUrl: 'https://api.edrive.ng',
          enableLogging: true,
        ),
      Flavor.staging => const FlavorConfig._(
          flavor: Flavor.staging,
          appName: 'e-Drive Staging',
          baseUrl: 'https://api.edrive.ng/api',
          socketUrl: 'https://api.edrive.ng',
          enableLogging: true,
        ),
      Flavor.prod => const FlavorConfig._(
          flavor: Flavor.prod,
          appName: 'e-Drive',
          baseUrl: 'https://api.edrive.ng/api',
          socketUrl: 'https://api.edrive.ng',
          enableLogging: false,
        ),
    };
  }

  bool get isDev => flavor == Flavor.dev;
  bool get isStaging => flavor == Flavor.staging;
  bool get isProd => flavor == Flavor.prod;
}

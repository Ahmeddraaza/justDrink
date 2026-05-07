import 'package:get_it/get_it.dart';
import '../../services/database_service.dart';
import '../../services/notification_service.dart';
import '../../services/widget_service.dart';
import '../../services/purchase_service.dart';
import '../../services/ad_service.dart';
import '../../data/preferences/preferences_service.dart';

final sl = GetIt.instance;

Future<void> configureDependencies() async {
  // Services already initialized in main.dart can be registered as singletons
  // or lazy singletons if they handle their own initialization.
  
  // Note: DatabaseService and PreferencesService are initialized in main.dart
  // and then registered here.
  
  DatabaseService.registerWithGetIt(sl);
  
  sl.registerLazySingleton<PreferencesService>(() => PreferencesService.instance);
  
  // NotificationService, WidgetService, AdService, PurchaseService 
  // are registered as singletons in main.dart for this architecture.
  // But we can also register them here if preferred.
  // For consistency with the blueprint's main.dart, we'll let main.dart register them.
}

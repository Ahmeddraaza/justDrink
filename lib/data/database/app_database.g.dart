// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $WaterLogsTable extends WaterLogs
    with TableInfo<$WaterLogsTable, WaterLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WaterLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _loggedAtMeta =
      const VerificationMeta('loggedAt');
  @override
  late final GeneratedColumn<DateTime> loggedAt = GeneratedColumn<DateTime>(
      'logged_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _amountMlMeta =
      const VerificationMeta('amountMl');
  @override
  late final GeneratedColumn<int> amountMl = GeneratedColumn<int>(
      'amount_ml', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('app'));
  @override
  List<GeneratedColumn> get $columns => [id, loggedAt, amountMl, source];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'water_logs';
  @override
  VerificationContext validateIntegrity(Insertable<WaterLog> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('logged_at')) {
      context.handle(_loggedAtMeta,
          loggedAt.isAcceptableOrUnknown(data['logged_at']!, _loggedAtMeta));
    }
    if (data.containsKey('amount_ml')) {
      context.handle(_amountMlMeta,
          amountMl.isAcceptableOrUnknown(data['amount_ml']!, _amountMlMeta));
    } else if (isInserting) {
      context.missing(_amountMlMeta);
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WaterLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WaterLog(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      loggedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}logged_at'])!,
      amountMl: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}amount_ml'])!,
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source'])!,
    );
  }

  @override
  $WaterLogsTable createAlias(String alias) {
    return $WaterLogsTable(attachedDatabase, alias);
  }
}

class WaterLog extends DataClass implements Insertable<WaterLog> {
  final int id;
  final DateTime loggedAt;
  final int amountMl;
  final String source;
  const WaterLog(
      {required this.id,
      required this.loggedAt,
      required this.amountMl,
      required this.source});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['logged_at'] = Variable<DateTime>(loggedAt);
    map['amount_ml'] = Variable<int>(amountMl);
    map['source'] = Variable<String>(source);
    return map;
  }

  WaterLogsCompanion toCompanion(bool nullToAbsent) {
    return WaterLogsCompanion(
      id: Value(id),
      loggedAt: Value(loggedAt),
      amountMl: Value(amountMl),
      source: Value(source),
    );
  }

  factory WaterLog.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WaterLog(
      id: serializer.fromJson<int>(json['id']),
      loggedAt: serializer.fromJson<DateTime>(json['loggedAt']),
      amountMl: serializer.fromJson<int>(json['amountMl']),
      source: serializer.fromJson<String>(json['source']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'loggedAt': serializer.toJson<DateTime>(loggedAt),
      'amountMl': serializer.toJson<int>(amountMl),
      'source': serializer.toJson<String>(source),
    };
  }

  WaterLog copyWith(
          {int? id, DateTime? loggedAt, int? amountMl, String? source}) =>
      WaterLog(
        id: id ?? this.id,
        loggedAt: loggedAt ?? this.loggedAt,
        amountMl: amountMl ?? this.amountMl,
        source: source ?? this.source,
      );
  WaterLog copyWithCompanion(WaterLogsCompanion data) {
    return WaterLog(
      id: data.id.present ? data.id.value : this.id,
      loggedAt: data.loggedAt.present ? data.loggedAt.value : this.loggedAt,
      amountMl: data.amountMl.present ? data.amountMl.value : this.amountMl,
      source: data.source.present ? data.source.value : this.source,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WaterLog(')
          ..write('id: $id, ')
          ..write('loggedAt: $loggedAt, ')
          ..write('amountMl: $amountMl, ')
          ..write('source: $source')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, loggedAt, amountMl, source);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WaterLog &&
          other.id == this.id &&
          other.loggedAt == this.loggedAt &&
          other.amountMl == this.amountMl &&
          other.source == this.source);
}

class WaterLogsCompanion extends UpdateCompanion<WaterLog> {
  final Value<int> id;
  final Value<DateTime> loggedAt;
  final Value<int> amountMl;
  final Value<String> source;
  const WaterLogsCompanion({
    this.id = const Value.absent(),
    this.loggedAt = const Value.absent(),
    this.amountMl = const Value.absent(),
    this.source = const Value.absent(),
  });
  WaterLogsCompanion.insert({
    this.id = const Value.absent(),
    this.loggedAt = const Value.absent(),
    required int amountMl,
    this.source = const Value.absent(),
  }) : amountMl = Value(amountMl);
  static Insertable<WaterLog> custom({
    Expression<int>? id,
    Expression<DateTime>? loggedAt,
    Expression<int>? amountMl,
    Expression<String>? source,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (loggedAt != null) 'logged_at': loggedAt,
      if (amountMl != null) 'amount_ml': amountMl,
      if (source != null) 'source': source,
    });
  }

  WaterLogsCompanion copyWith(
      {Value<int>? id,
      Value<DateTime>? loggedAt,
      Value<int>? amountMl,
      Value<String>? source}) {
    return WaterLogsCompanion(
      id: id ?? this.id,
      loggedAt: loggedAt ?? this.loggedAt,
      amountMl: amountMl ?? this.amountMl,
      source: source ?? this.source,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (loggedAt.present) {
      map['logged_at'] = Variable<DateTime>(loggedAt.value);
    }
    if (amountMl.present) {
      map['amount_ml'] = Variable<int>(amountMl.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WaterLogsCompanion(')
          ..write('id: $id, ')
          ..write('loggedAt: $loggedAt, ')
          ..write('amountMl: $amountMl, ')
          ..write('source: $source')
          ..write(')'))
        .toString();
  }
}

class $UserProfileTable extends UserProfile
    with TableInfo<$UserProfileTable, UserProfileData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProfileTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _genderMeta = const VerificationMeta('gender');
  @override
  late final GeneratedColumn<String> gender = GeneratedColumn<String>(
      'gender', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('male'));
  static const VerificationMeta _weightKgMeta =
      const VerificationMeta('weightKg');
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
      'weight_kg', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(70.0));
  static const VerificationMeta _ageMeta = const VerificationMeta('age');
  @override
  late final GeneratedColumn<int> age = GeneratedColumn<int>(
      'age', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(25));
  static const VerificationMeta _unitPreferenceMeta =
      const VerificationMeta('unitPreference');
  @override
  late final GeneratedColumn<String> unitPreference = GeneratedColumn<String>(
      'unit_preference', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('metric'));
  static const VerificationMeta _dailyGoalMlMeta =
      const VerificationMeta('dailyGoalMl');
  @override
  late final GeneratedColumn<int> dailyGoalMl = GeneratedColumn<int>(
      'daily_goal_ml', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(2500));
  static const VerificationMeta _wakeTimeMeta =
      const VerificationMeta('wakeTime');
  @override
  late final GeneratedColumn<String> wakeTime = GeneratedColumn<String>(
      'wake_time', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('07:00'));
  static const VerificationMeta _sleepTimeMeta =
      const VerificationMeta('sleepTime');
  @override
  late final GeneratedColumn<String> sleepTime = GeneratedColumn<String>(
      'sleep_time', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('23:00'));
  static const VerificationMeta _reminderCountMeta =
      const VerificationMeta('reminderCount');
  @override
  late final GeneratedColumn<int> reminderCount = GeneratedColumn<int>(
      'reminder_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(6));
  static const VerificationMeta _remindersEnabledMeta =
      const VerificationMeta('remindersEnabled');
  @override
  late final GeneratedColumn<bool> remindersEnabled = GeneratedColumn<bool>(
      'reminders_enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("reminders_enabled" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _customNotificationTextMeta =
      const VerificationMeta('customNotificationText');
  @override
  late final GeneratedColumn<String> customNotificationText =
      GeneratedColumn<String>('custom_notification_text', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _quickAdd1MlMeta =
      const VerificationMeta('quickAdd1Ml');
  @override
  late final GeneratedColumn<int> quickAdd1Ml = GeneratedColumn<int>(
      'quick_add1_ml', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(250));
  static const VerificationMeta _quickAdd2MlMeta =
      const VerificationMeta('quickAdd2Ml');
  @override
  late final GeneratedColumn<int> quickAdd2Ml = GeneratedColumn<int>(
      'quick_add2_ml', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(500));
  static const VerificationMeta _isPremiumMeta =
      const VerificationMeta('isPremium');
  @override
  late final GeneratedColumn<bool> isPremium = GeneratedColumn<bool>(
      'is_premium', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_premium" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _onboardingCompleteMeta =
      const VerificationMeta('onboardingComplete');
  @override
  late final GeneratedColumn<bool> onboardingComplete = GeneratedColumn<bool>(
      'onboarding_complete', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("onboarding_complete" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _premiumProductIdMeta =
      const VerificationMeta('premiumProductId');
  @override
  late final GeneratedColumn<String> premiumProductId = GeneratedColumn<String>(
      'premium_product_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        gender,
        weightKg,
        age,
        unitPreference,
        dailyGoalMl,
        wakeTime,
        sleepTime,
        reminderCount,
        remindersEnabled,
        customNotificationText,
        quickAdd1Ml,
        quickAdd2Ml,
        isPremium,
        onboardingComplete,
        premiumProductId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_profile';
  @override
  VerificationContext validateIntegrity(Insertable<UserProfileData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('gender')) {
      context.handle(_genderMeta,
          gender.isAcceptableOrUnknown(data['gender']!, _genderMeta));
    }
    if (data.containsKey('weight_kg')) {
      context.handle(_weightKgMeta,
          weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta));
    }
    if (data.containsKey('age')) {
      context.handle(
          _ageMeta, age.isAcceptableOrUnknown(data['age']!, _ageMeta));
    }
    if (data.containsKey('unit_preference')) {
      context.handle(
          _unitPreferenceMeta,
          unitPreference.isAcceptableOrUnknown(
              data['unit_preference']!, _unitPreferenceMeta));
    }
    if (data.containsKey('daily_goal_ml')) {
      context.handle(
          _dailyGoalMlMeta,
          dailyGoalMl.isAcceptableOrUnknown(
              data['daily_goal_ml']!, _dailyGoalMlMeta));
    }
    if (data.containsKey('wake_time')) {
      context.handle(_wakeTimeMeta,
          wakeTime.isAcceptableOrUnknown(data['wake_time']!, _wakeTimeMeta));
    }
    if (data.containsKey('sleep_time')) {
      context.handle(_sleepTimeMeta,
          sleepTime.isAcceptableOrUnknown(data['sleep_time']!, _sleepTimeMeta));
    }
    if (data.containsKey('reminder_count')) {
      context.handle(
          _reminderCountMeta,
          reminderCount.isAcceptableOrUnknown(
              data['reminder_count']!, _reminderCountMeta));
    }
    if (data.containsKey('reminders_enabled')) {
      context.handle(
          _remindersEnabledMeta,
          remindersEnabled.isAcceptableOrUnknown(
              data['reminders_enabled']!, _remindersEnabledMeta));
    }
    if (data.containsKey('custom_notification_text')) {
      context.handle(
          _customNotificationTextMeta,
          customNotificationText.isAcceptableOrUnknown(
              data['custom_notification_text']!, _customNotificationTextMeta));
    }
    if (data.containsKey('quick_add1_ml')) {
      context.handle(
          _quickAdd1MlMeta,
          quickAdd1Ml.isAcceptableOrUnknown(
              data['quick_add1_ml']!, _quickAdd1MlMeta));
    }
    if (data.containsKey('quick_add2_ml')) {
      context.handle(
          _quickAdd2MlMeta,
          quickAdd2Ml.isAcceptableOrUnknown(
              data['quick_add2_ml']!, _quickAdd2MlMeta));
    }
    if (data.containsKey('is_premium')) {
      context.handle(_isPremiumMeta,
          isPremium.isAcceptableOrUnknown(data['is_premium']!, _isPremiumMeta));
    }
    if (data.containsKey('onboarding_complete')) {
      context.handle(
          _onboardingCompleteMeta,
          onboardingComplete.isAcceptableOrUnknown(
              data['onboarding_complete']!, _onboardingCompleteMeta));
    }
    if (data.containsKey('premium_product_id')) {
      context.handle(
          _premiumProductIdMeta,
          premiumProductId.isAcceptableOrUnknown(
              data['premium_product_id']!, _premiumProductIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserProfileData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProfileData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      gender: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}gender'])!,
      weightKg: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}weight_kg'])!,
      age: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}age'])!,
      unitPreference: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}unit_preference'])!,
      dailyGoalMl: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}daily_goal_ml'])!,
      wakeTime: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}wake_time'])!,
      sleepTime: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sleep_time'])!,
      reminderCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}reminder_count'])!,
      remindersEnabled: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}reminders_enabled'])!,
      customNotificationText: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}custom_notification_text']),
      quickAdd1Ml: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quick_add1_ml'])!,
      quickAdd2Ml: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quick_add2_ml'])!,
      isPremium: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_premium'])!,
      onboardingComplete: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}onboarding_complete'])!,
      premiumProductId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}premium_product_id']),
    );
  }

  @override
  $UserProfileTable createAlias(String alias) {
    return $UserProfileTable(attachedDatabase, alias);
  }
}

class UserProfileData extends DataClass implements Insertable<UserProfileData> {
  final int id;
  final String gender;
  final double weightKg;
  final int age;
  final String unitPreference;
  final int dailyGoalMl;
  final String wakeTime;
  final String sleepTime;
  final int reminderCount;
  final bool remindersEnabled;
  final String? customNotificationText;
  final int quickAdd1Ml;
  final int quickAdd2Ml;
  final bool isPremium;
  final bool onboardingComplete;
  final String? premiumProductId;
  const UserProfileData(
      {required this.id,
      required this.gender,
      required this.weightKg,
      required this.age,
      required this.unitPreference,
      required this.dailyGoalMl,
      required this.wakeTime,
      required this.sleepTime,
      required this.reminderCount,
      required this.remindersEnabled,
      this.customNotificationText,
      required this.quickAdd1Ml,
      required this.quickAdd2Ml,
      required this.isPremium,
      required this.onboardingComplete,
      this.premiumProductId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['gender'] = Variable<String>(gender);
    map['weight_kg'] = Variable<double>(weightKg);
    map['age'] = Variable<int>(age);
    map['unit_preference'] = Variable<String>(unitPreference);
    map['daily_goal_ml'] = Variable<int>(dailyGoalMl);
    map['wake_time'] = Variable<String>(wakeTime);
    map['sleep_time'] = Variable<String>(sleepTime);
    map['reminder_count'] = Variable<int>(reminderCount);
    map['reminders_enabled'] = Variable<bool>(remindersEnabled);
    if (!nullToAbsent || customNotificationText != null) {
      map['custom_notification_text'] =
          Variable<String>(customNotificationText);
    }
    map['quick_add1_ml'] = Variable<int>(quickAdd1Ml);
    map['quick_add2_ml'] = Variable<int>(quickAdd2Ml);
    map['is_premium'] = Variable<bool>(isPremium);
    map['onboarding_complete'] = Variable<bool>(onboardingComplete);
    if (!nullToAbsent || premiumProductId != null) {
      map['premium_product_id'] = Variable<String>(premiumProductId);
    }
    return map;
  }

  UserProfileCompanion toCompanion(bool nullToAbsent) {
    return UserProfileCompanion(
      id: Value(id),
      gender: Value(gender),
      weightKg: Value(weightKg),
      age: Value(age),
      unitPreference: Value(unitPreference),
      dailyGoalMl: Value(dailyGoalMl),
      wakeTime: Value(wakeTime),
      sleepTime: Value(sleepTime),
      reminderCount: Value(reminderCount),
      remindersEnabled: Value(remindersEnabled),
      customNotificationText: customNotificationText == null && nullToAbsent
          ? const Value.absent()
          : Value(customNotificationText),
      quickAdd1Ml: Value(quickAdd1Ml),
      quickAdd2Ml: Value(quickAdd2Ml),
      isPremium: Value(isPremium),
      onboardingComplete: Value(onboardingComplete),
      premiumProductId: premiumProductId == null && nullToAbsent
          ? const Value.absent()
          : Value(premiumProductId),
    );
  }

  factory UserProfileData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProfileData(
      id: serializer.fromJson<int>(json['id']),
      gender: serializer.fromJson<String>(json['gender']),
      weightKg: serializer.fromJson<double>(json['weightKg']),
      age: serializer.fromJson<int>(json['age']),
      unitPreference: serializer.fromJson<String>(json['unitPreference']),
      dailyGoalMl: serializer.fromJson<int>(json['dailyGoalMl']),
      wakeTime: serializer.fromJson<String>(json['wakeTime']),
      sleepTime: serializer.fromJson<String>(json['sleepTime']),
      reminderCount: serializer.fromJson<int>(json['reminderCount']),
      remindersEnabled: serializer.fromJson<bool>(json['remindersEnabled']),
      customNotificationText:
          serializer.fromJson<String?>(json['customNotificationText']),
      quickAdd1Ml: serializer.fromJson<int>(json['quickAdd1Ml']),
      quickAdd2Ml: serializer.fromJson<int>(json['quickAdd2Ml']),
      isPremium: serializer.fromJson<bool>(json['isPremium']),
      onboardingComplete: serializer.fromJson<bool>(json['onboardingComplete']),
      premiumProductId: serializer.fromJson<String?>(json['premiumProductId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'gender': serializer.toJson<String>(gender),
      'weightKg': serializer.toJson<double>(weightKg),
      'age': serializer.toJson<int>(age),
      'unitPreference': serializer.toJson<String>(unitPreference),
      'dailyGoalMl': serializer.toJson<int>(dailyGoalMl),
      'wakeTime': serializer.toJson<String>(wakeTime),
      'sleepTime': serializer.toJson<String>(sleepTime),
      'reminderCount': serializer.toJson<int>(reminderCount),
      'remindersEnabled': serializer.toJson<bool>(remindersEnabled),
      'customNotificationText':
          serializer.toJson<String?>(customNotificationText),
      'quickAdd1Ml': serializer.toJson<int>(quickAdd1Ml),
      'quickAdd2Ml': serializer.toJson<int>(quickAdd2Ml),
      'isPremium': serializer.toJson<bool>(isPremium),
      'onboardingComplete': serializer.toJson<bool>(onboardingComplete),
      'premiumProductId': serializer.toJson<String?>(premiumProductId),
    };
  }

  UserProfileData copyWith(
          {int? id,
          String? gender,
          double? weightKg,
          int? age,
          String? unitPreference,
          int? dailyGoalMl,
          String? wakeTime,
          String? sleepTime,
          int? reminderCount,
          bool? remindersEnabled,
          Value<String?> customNotificationText = const Value.absent(),
          int? quickAdd1Ml,
          int? quickAdd2Ml,
          bool? isPremium,
          bool? onboardingComplete,
          Value<String?> premiumProductId = const Value.absent()}) =>
      UserProfileData(
        id: id ?? this.id,
        gender: gender ?? this.gender,
        weightKg: weightKg ?? this.weightKg,
        age: age ?? this.age,
        unitPreference: unitPreference ?? this.unitPreference,
        dailyGoalMl: dailyGoalMl ?? this.dailyGoalMl,
        wakeTime: wakeTime ?? this.wakeTime,
        sleepTime: sleepTime ?? this.sleepTime,
        reminderCount: reminderCount ?? this.reminderCount,
        remindersEnabled: remindersEnabled ?? this.remindersEnabled,
        customNotificationText: customNotificationText.present
            ? customNotificationText.value
            : this.customNotificationText,
        quickAdd1Ml: quickAdd1Ml ?? this.quickAdd1Ml,
        quickAdd2Ml: quickAdd2Ml ?? this.quickAdd2Ml,
        isPremium: isPremium ?? this.isPremium,
        onboardingComplete: onboardingComplete ?? this.onboardingComplete,
        premiumProductId: premiumProductId.present
            ? premiumProductId.value
            : this.premiumProductId,
      );
  UserProfileData copyWithCompanion(UserProfileCompanion data) {
    return UserProfileData(
      id: data.id.present ? data.id.value : this.id,
      gender: data.gender.present ? data.gender.value : this.gender,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      age: data.age.present ? data.age.value : this.age,
      unitPreference: data.unitPreference.present
          ? data.unitPreference.value
          : this.unitPreference,
      dailyGoalMl:
          data.dailyGoalMl.present ? data.dailyGoalMl.value : this.dailyGoalMl,
      wakeTime: data.wakeTime.present ? data.wakeTime.value : this.wakeTime,
      sleepTime: data.sleepTime.present ? data.sleepTime.value : this.sleepTime,
      reminderCount: data.reminderCount.present
          ? data.reminderCount.value
          : this.reminderCount,
      remindersEnabled: data.remindersEnabled.present
          ? data.remindersEnabled.value
          : this.remindersEnabled,
      customNotificationText: data.customNotificationText.present
          ? data.customNotificationText.value
          : this.customNotificationText,
      quickAdd1Ml:
          data.quickAdd1Ml.present ? data.quickAdd1Ml.value : this.quickAdd1Ml,
      quickAdd2Ml:
          data.quickAdd2Ml.present ? data.quickAdd2Ml.value : this.quickAdd2Ml,
      isPremium: data.isPremium.present ? data.isPremium.value : this.isPremium,
      onboardingComplete: data.onboardingComplete.present
          ? data.onboardingComplete.value
          : this.onboardingComplete,
      premiumProductId: data.premiumProductId.present
          ? data.premiumProductId.value
          : this.premiumProductId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProfileData(')
          ..write('id: $id, ')
          ..write('gender: $gender, ')
          ..write('weightKg: $weightKg, ')
          ..write('age: $age, ')
          ..write('unitPreference: $unitPreference, ')
          ..write('dailyGoalMl: $dailyGoalMl, ')
          ..write('wakeTime: $wakeTime, ')
          ..write('sleepTime: $sleepTime, ')
          ..write('reminderCount: $reminderCount, ')
          ..write('remindersEnabled: $remindersEnabled, ')
          ..write('customNotificationText: $customNotificationText, ')
          ..write('quickAdd1Ml: $quickAdd1Ml, ')
          ..write('quickAdd2Ml: $quickAdd2Ml, ')
          ..write('isPremium: $isPremium, ')
          ..write('onboardingComplete: $onboardingComplete, ')
          ..write('premiumProductId: $premiumProductId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      gender,
      weightKg,
      age,
      unitPreference,
      dailyGoalMl,
      wakeTime,
      sleepTime,
      reminderCount,
      remindersEnabled,
      customNotificationText,
      quickAdd1Ml,
      quickAdd2Ml,
      isPremium,
      onboardingComplete,
      premiumProductId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProfileData &&
          other.id == this.id &&
          other.gender == this.gender &&
          other.weightKg == this.weightKg &&
          other.age == this.age &&
          other.unitPreference == this.unitPreference &&
          other.dailyGoalMl == this.dailyGoalMl &&
          other.wakeTime == this.wakeTime &&
          other.sleepTime == this.sleepTime &&
          other.reminderCount == this.reminderCount &&
          other.remindersEnabled == this.remindersEnabled &&
          other.customNotificationText == this.customNotificationText &&
          other.quickAdd1Ml == this.quickAdd1Ml &&
          other.quickAdd2Ml == this.quickAdd2Ml &&
          other.isPremium == this.isPremium &&
          other.onboardingComplete == this.onboardingComplete &&
          other.premiumProductId == this.premiumProductId);
}

class UserProfileCompanion extends UpdateCompanion<UserProfileData> {
  final Value<int> id;
  final Value<String> gender;
  final Value<double> weightKg;
  final Value<int> age;
  final Value<String> unitPreference;
  final Value<int> dailyGoalMl;
  final Value<String> wakeTime;
  final Value<String> sleepTime;
  final Value<int> reminderCount;
  final Value<bool> remindersEnabled;
  final Value<String?> customNotificationText;
  final Value<int> quickAdd1Ml;
  final Value<int> quickAdd2Ml;
  final Value<bool> isPremium;
  final Value<bool> onboardingComplete;
  final Value<String?> premiumProductId;
  const UserProfileCompanion({
    this.id = const Value.absent(),
    this.gender = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.age = const Value.absent(),
    this.unitPreference = const Value.absent(),
    this.dailyGoalMl = const Value.absent(),
    this.wakeTime = const Value.absent(),
    this.sleepTime = const Value.absent(),
    this.reminderCount = const Value.absent(),
    this.remindersEnabled = const Value.absent(),
    this.customNotificationText = const Value.absent(),
    this.quickAdd1Ml = const Value.absent(),
    this.quickAdd2Ml = const Value.absent(),
    this.isPremium = const Value.absent(),
    this.onboardingComplete = const Value.absent(),
    this.premiumProductId = const Value.absent(),
  });
  UserProfileCompanion.insert({
    this.id = const Value.absent(),
    this.gender = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.age = const Value.absent(),
    this.unitPreference = const Value.absent(),
    this.dailyGoalMl = const Value.absent(),
    this.wakeTime = const Value.absent(),
    this.sleepTime = const Value.absent(),
    this.reminderCount = const Value.absent(),
    this.remindersEnabled = const Value.absent(),
    this.customNotificationText = const Value.absent(),
    this.quickAdd1Ml = const Value.absent(),
    this.quickAdd2Ml = const Value.absent(),
    this.isPremium = const Value.absent(),
    this.onboardingComplete = const Value.absent(),
    this.premiumProductId = const Value.absent(),
  });
  static Insertable<UserProfileData> custom({
    Expression<int>? id,
    Expression<String>? gender,
    Expression<double>? weightKg,
    Expression<int>? age,
    Expression<String>? unitPreference,
    Expression<int>? dailyGoalMl,
    Expression<String>? wakeTime,
    Expression<String>? sleepTime,
    Expression<int>? reminderCount,
    Expression<bool>? remindersEnabled,
    Expression<String>? customNotificationText,
    Expression<int>? quickAdd1Ml,
    Expression<int>? quickAdd2Ml,
    Expression<bool>? isPremium,
    Expression<bool>? onboardingComplete,
    Expression<String>? premiumProductId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (gender != null) 'gender': gender,
      if (weightKg != null) 'weight_kg': weightKg,
      if (age != null) 'age': age,
      if (unitPreference != null) 'unit_preference': unitPreference,
      if (dailyGoalMl != null) 'daily_goal_ml': dailyGoalMl,
      if (wakeTime != null) 'wake_time': wakeTime,
      if (sleepTime != null) 'sleep_time': sleepTime,
      if (reminderCount != null) 'reminder_count': reminderCount,
      if (remindersEnabled != null) 'reminders_enabled': remindersEnabled,
      if (customNotificationText != null)
        'custom_notification_text': customNotificationText,
      if (quickAdd1Ml != null) 'quick_add1_ml': quickAdd1Ml,
      if (quickAdd2Ml != null) 'quick_add2_ml': quickAdd2Ml,
      if (isPremium != null) 'is_premium': isPremium,
      if (onboardingComplete != null) 'onboarding_complete': onboardingComplete,
      if (premiumProductId != null) 'premium_product_id': premiumProductId,
    });
  }

  UserProfileCompanion copyWith(
      {Value<int>? id,
      Value<String>? gender,
      Value<double>? weightKg,
      Value<int>? age,
      Value<String>? unitPreference,
      Value<int>? dailyGoalMl,
      Value<String>? wakeTime,
      Value<String>? sleepTime,
      Value<int>? reminderCount,
      Value<bool>? remindersEnabled,
      Value<String?>? customNotificationText,
      Value<int>? quickAdd1Ml,
      Value<int>? quickAdd2Ml,
      Value<bool>? isPremium,
      Value<bool>? onboardingComplete,
      Value<String?>? premiumProductId}) {
    return UserProfileCompanion(
      id: id ?? this.id,
      gender: gender ?? this.gender,
      weightKg: weightKg ?? this.weightKg,
      age: age ?? this.age,
      unitPreference: unitPreference ?? this.unitPreference,
      dailyGoalMl: dailyGoalMl ?? this.dailyGoalMl,
      wakeTime: wakeTime ?? this.wakeTime,
      sleepTime: sleepTime ?? this.sleepTime,
      reminderCount: reminderCount ?? this.reminderCount,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      customNotificationText:
          customNotificationText ?? this.customNotificationText,
      quickAdd1Ml: quickAdd1Ml ?? this.quickAdd1Ml,
      quickAdd2Ml: quickAdd2Ml ?? this.quickAdd2Ml,
      isPremium: isPremium ?? this.isPremium,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      premiumProductId: premiumProductId ?? this.premiumProductId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (gender.present) {
      map['gender'] = Variable<String>(gender.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (age.present) {
      map['age'] = Variable<int>(age.value);
    }
    if (unitPreference.present) {
      map['unit_preference'] = Variable<String>(unitPreference.value);
    }
    if (dailyGoalMl.present) {
      map['daily_goal_ml'] = Variable<int>(dailyGoalMl.value);
    }
    if (wakeTime.present) {
      map['wake_time'] = Variable<String>(wakeTime.value);
    }
    if (sleepTime.present) {
      map['sleep_time'] = Variable<String>(sleepTime.value);
    }
    if (reminderCount.present) {
      map['reminder_count'] = Variable<int>(reminderCount.value);
    }
    if (remindersEnabled.present) {
      map['reminders_enabled'] = Variable<bool>(remindersEnabled.value);
    }
    if (customNotificationText.present) {
      map['custom_notification_text'] =
          Variable<String>(customNotificationText.value);
    }
    if (quickAdd1Ml.present) {
      map['quick_add1_ml'] = Variable<int>(quickAdd1Ml.value);
    }
    if (quickAdd2Ml.present) {
      map['quick_add2_ml'] = Variable<int>(quickAdd2Ml.value);
    }
    if (isPremium.present) {
      map['is_premium'] = Variable<bool>(isPremium.value);
    }
    if (onboardingComplete.present) {
      map['onboarding_complete'] = Variable<bool>(onboardingComplete.value);
    }
    if (premiumProductId.present) {
      map['premium_product_id'] = Variable<String>(premiumProductId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProfileCompanion(')
          ..write('id: $id, ')
          ..write('gender: $gender, ')
          ..write('weightKg: $weightKg, ')
          ..write('age: $age, ')
          ..write('unitPreference: $unitPreference, ')
          ..write('dailyGoalMl: $dailyGoalMl, ')
          ..write('wakeTime: $wakeTime, ')
          ..write('sleepTime: $sleepTime, ')
          ..write('reminderCount: $reminderCount, ')
          ..write('remindersEnabled: $remindersEnabled, ')
          ..write('customNotificationText: $customNotificationText, ')
          ..write('quickAdd1Ml: $quickAdd1Ml, ')
          ..write('quickAdd2Ml: $quickAdd2Ml, ')
          ..write('isPremium: $isPremium, ')
          ..write('onboardingComplete: $onboardingComplete, ')
          ..write('premiumProductId: $premiumProductId')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $WaterLogsTable waterLogs = $WaterLogsTable(this);
  late final $UserProfileTable userProfile = $UserProfileTable(this);
  late final WaterLogDao waterLogDao = WaterLogDao(this as AppDatabase);
  late final UserProfileDao userProfileDao =
      UserProfileDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [waterLogs, userProfile];
}

typedef $$WaterLogsTableCreateCompanionBuilder = WaterLogsCompanion Function({
  Value<int> id,
  Value<DateTime> loggedAt,
  required int amountMl,
  Value<String> source,
});
typedef $$WaterLogsTableUpdateCompanionBuilder = WaterLogsCompanion Function({
  Value<int> id,
  Value<DateTime> loggedAt,
  Value<int> amountMl,
  Value<String> source,
});

class $$WaterLogsTableFilterComposer
    extends Composer<_$AppDatabase, $WaterLogsTable> {
  $$WaterLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get loggedAt => $composableBuilder(
      column: $table.loggedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get amountMl => $composableBuilder(
      column: $table.amountMl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnFilters(column));
}

class $$WaterLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $WaterLogsTable> {
  $$WaterLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get loggedAt => $composableBuilder(
      column: $table.loggedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amountMl => $composableBuilder(
      column: $table.amountMl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnOrderings(column));
}

class $$WaterLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WaterLogsTable> {
  $$WaterLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get loggedAt =>
      $composableBuilder(column: $table.loggedAt, builder: (column) => column);

  GeneratedColumn<int> get amountMl =>
      $composableBuilder(column: $table.amountMl, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);
}

class $$WaterLogsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $WaterLogsTable,
    WaterLog,
    $$WaterLogsTableFilterComposer,
    $$WaterLogsTableOrderingComposer,
    $$WaterLogsTableAnnotationComposer,
    $$WaterLogsTableCreateCompanionBuilder,
    $$WaterLogsTableUpdateCompanionBuilder,
    (WaterLog, BaseReferences<_$AppDatabase, $WaterLogsTable, WaterLog>),
    WaterLog,
    PrefetchHooks Function()> {
  $$WaterLogsTableTableManager(_$AppDatabase db, $WaterLogsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WaterLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WaterLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WaterLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime> loggedAt = const Value.absent(),
            Value<int> amountMl = const Value.absent(),
            Value<String> source = const Value.absent(),
          }) =>
              WaterLogsCompanion(
            id: id,
            loggedAt: loggedAt,
            amountMl: amountMl,
            source: source,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime> loggedAt = const Value.absent(),
            required int amountMl,
            Value<String> source = const Value.absent(),
          }) =>
              WaterLogsCompanion.insert(
            id: id,
            loggedAt: loggedAt,
            amountMl: amountMl,
            source: source,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$WaterLogsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $WaterLogsTable,
    WaterLog,
    $$WaterLogsTableFilterComposer,
    $$WaterLogsTableOrderingComposer,
    $$WaterLogsTableAnnotationComposer,
    $$WaterLogsTableCreateCompanionBuilder,
    $$WaterLogsTableUpdateCompanionBuilder,
    (WaterLog, BaseReferences<_$AppDatabase, $WaterLogsTable, WaterLog>),
    WaterLog,
    PrefetchHooks Function()>;
typedef $$UserProfileTableCreateCompanionBuilder = UserProfileCompanion
    Function({
  Value<int> id,
  Value<String> gender,
  Value<double> weightKg,
  Value<int> age,
  Value<String> unitPreference,
  Value<int> dailyGoalMl,
  Value<String> wakeTime,
  Value<String> sleepTime,
  Value<int> reminderCount,
  Value<bool> remindersEnabled,
  Value<String?> customNotificationText,
  Value<int> quickAdd1Ml,
  Value<int> quickAdd2Ml,
  Value<bool> isPremium,
  Value<bool> onboardingComplete,
  Value<String?> premiumProductId,
});
typedef $$UserProfileTableUpdateCompanionBuilder = UserProfileCompanion
    Function({
  Value<int> id,
  Value<String> gender,
  Value<double> weightKg,
  Value<int> age,
  Value<String> unitPreference,
  Value<int> dailyGoalMl,
  Value<String> wakeTime,
  Value<String> sleepTime,
  Value<int> reminderCount,
  Value<bool> remindersEnabled,
  Value<String?> customNotificationText,
  Value<int> quickAdd1Ml,
  Value<int> quickAdd2Ml,
  Value<bool> isPremium,
  Value<bool> onboardingComplete,
  Value<String?> premiumProductId,
});

class $$UserProfileTableFilterComposer
    extends Composer<_$AppDatabase, $UserProfileTable> {
  $$UserProfileTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get gender => $composableBuilder(
      column: $table.gender, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get weightKg => $composableBuilder(
      column: $table.weightKg, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get age => $composableBuilder(
      column: $table.age, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get unitPreference => $composableBuilder(
      column: $table.unitPreference,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get dailyGoalMl => $composableBuilder(
      column: $table.dailyGoalMl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get wakeTime => $composableBuilder(
      column: $table.wakeTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sleepTime => $composableBuilder(
      column: $table.sleepTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get reminderCount => $composableBuilder(
      column: $table.reminderCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get remindersEnabled => $composableBuilder(
      column: $table.remindersEnabled,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get customNotificationText => $composableBuilder(
      column: $table.customNotificationText,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quickAdd1Ml => $composableBuilder(
      column: $table.quickAdd1Ml, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quickAdd2Ml => $composableBuilder(
      column: $table.quickAdd2Ml, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isPremium => $composableBuilder(
      column: $table.isPremium, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get onboardingComplete => $composableBuilder(
      column: $table.onboardingComplete,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get premiumProductId => $composableBuilder(
      column: $table.premiumProductId,
      builder: (column) => ColumnFilters(column));
}

class $$UserProfileTableOrderingComposer
    extends Composer<_$AppDatabase, $UserProfileTable> {
  $$UserProfileTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get gender => $composableBuilder(
      column: $table.gender, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get weightKg => $composableBuilder(
      column: $table.weightKg, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get age => $composableBuilder(
      column: $table.age, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get unitPreference => $composableBuilder(
      column: $table.unitPreference,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get dailyGoalMl => $composableBuilder(
      column: $table.dailyGoalMl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get wakeTime => $composableBuilder(
      column: $table.wakeTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sleepTime => $composableBuilder(
      column: $table.sleepTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get reminderCount => $composableBuilder(
      column: $table.reminderCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get remindersEnabled => $composableBuilder(
      column: $table.remindersEnabled,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get customNotificationText => $composableBuilder(
      column: $table.customNotificationText,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quickAdd1Ml => $composableBuilder(
      column: $table.quickAdd1Ml, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quickAdd2Ml => $composableBuilder(
      column: $table.quickAdd2Ml, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isPremium => $composableBuilder(
      column: $table.isPremium, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get onboardingComplete => $composableBuilder(
      column: $table.onboardingComplete,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get premiumProductId => $composableBuilder(
      column: $table.premiumProductId,
      builder: (column) => ColumnOrderings(column));
}

class $$UserProfileTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserProfileTable> {
  $$UserProfileTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<int> get age =>
      $composableBuilder(column: $table.age, builder: (column) => column);

  GeneratedColumn<String> get unitPreference => $composableBuilder(
      column: $table.unitPreference, builder: (column) => column);

  GeneratedColumn<int> get dailyGoalMl => $composableBuilder(
      column: $table.dailyGoalMl, builder: (column) => column);

  GeneratedColumn<String> get wakeTime =>
      $composableBuilder(column: $table.wakeTime, builder: (column) => column);

  GeneratedColumn<String> get sleepTime =>
      $composableBuilder(column: $table.sleepTime, builder: (column) => column);

  GeneratedColumn<int> get reminderCount => $composableBuilder(
      column: $table.reminderCount, builder: (column) => column);

  GeneratedColumn<bool> get remindersEnabled => $composableBuilder(
      column: $table.remindersEnabled, builder: (column) => column);

  GeneratedColumn<String> get customNotificationText => $composableBuilder(
      column: $table.customNotificationText, builder: (column) => column);

  GeneratedColumn<int> get quickAdd1Ml => $composableBuilder(
      column: $table.quickAdd1Ml, builder: (column) => column);

  GeneratedColumn<int> get quickAdd2Ml => $composableBuilder(
      column: $table.quickAdd2Ml, builder: (column) => column);

  GeneratedColumn<bool> get isPremium =>
      $composableBuilder(column: $table.isPremium, builder: (column) => column);

  GeneratedColumn<bool> get onboardingComplete => $composableBuilder(
      column: $table.onboardingComplete, builder: (column) => column);

  GeneratedColumn<String> get premiumProductId => $composableBuilder(
      column: $table.premiumProductId, builder: (column) => column);
}

class $$UserProfileTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UserProfileTable,
    UserProfileData,
    $$UserProfileTableFilterComposer,
    $$UserProfileTableOrderingComposer,
    $$UserProfileTableAnnotationComposer,
    $$UserProfileTableCreateCompanionBuilder,
    $$UserProfileTableUpdateCompanionBuilder,
    (
      UserProfileData,
      BaseReferences<_$AppDatabase, $UserProfileTable, UserProfileData>
    ),
    UserProfileData,
    PrefetchHooks Function()> {
  $$UserProfileTableTableManager(_$AppDatabase db, $UserProfileTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserProfileTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserProfileTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserProfileTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> gender = const Value.absent(),
            Value<double> weightKg = const Value.absent(),
            Value<int> age = const Value.absent(),
            Value<String> unitPreference = const Value.absent(),
            Value<int> dailyGoalMl = const Value.absent(),
            Value<String> wakeTime = const Value.absent(),
            Value<String> sleepTime = const Value.absent(),
            Value<int> reminderCount = const Value.absent(),
            Value<bool> remindersEnabled = const Value.absent(),
            Value<String?> customNotificationText = const Value.absent(),
            Value<int> quickAdd1Ml = const Value.absent(),
            Value<int> quickAdd2Ml = const Value.absent(),
            Value<bool> isPremium = const Value.absent(),
            Value<bool> onboardingComplete = const Value.absent(),
            Value<String?> premiumProductId = const Value.absent(),
          }) =>
              UserProfileCompanion(
            id: id,
            gender: gender,
            weightKg: weightKg,
            age: age,
            unitPreference: unitPreference,
            dailyGoalMl: dailyGoalMl,
            wakeTime: wakeTime,
            sleepTime: sleepTime,
            reminderCount: reminderCount,
            remindersEnabled: remindersEnabled,
            customNotificationText: customNotificationText,
            quickAdd1Ml: quickAdd1Ml,
            quickAdd2Ml: quickAdd2Ml,
            isPremium: isPremium,
            onboardingComplete: onboardingComplete,
            premiumProductId: premiumProductId,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> gender = const Value.absent(),
            Value<double> weightKg = const Value.absent(),
            Value<int> age = const Value.absent(),
            Value<String> unitPreference = const Value.absent(),
            Value<int> dailyGoalMl = const Value.absent(),
            Value<String> wakeTime = const Value.absent(),
            Value<String> sleepTime = const Value.absent(),
            Value<int> reminderCount = const Value.absent(),
            Value<bool> remindersEnabled = const Value.absent(),
            Value<String?> customNotificationText = const Value.absent(),
            Value<int> quickAdd1Ml = const Value.absent(),
            Value<int> quickAdd2Ml = const Value.absent(),
            Value<bool> isPremium = const Value.absent(),
            Value<bool> onboardingComplete = const Value.absent(),
            Value<String?> premiumProductId = const Value.absent(),
          }) =>
              UserProfileCompanion.insert(
            id: id,
            gender: gender,
            weightKg: weightKg,
            age: age,
            unitPreference: unitPreference,
            dailyGoalMl: dailyGoalMl,
            wakeTime: wakeTime,
            sleepTime: sleepTime,
            reminderCount: reminderCount,
            remindersEnabled: remindersEnabled,
            customNotificationText: customNotificationText,
            quickAdd1Ml: quickAdd1Ml,
            quickAdd2Ml: quickAdd2Ml,
            isPremium: isPremium,
            onboardingComplete: onboardingComplete,
            premiumProductId: premiumProductId,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UserProfileTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UserProfileTable,
    UserProfileData,
    $$UserProfileTableFilterComposer,
    $$UserProfileTableOrderingComposer,
    $$UserProfileTableAnnotationComposer,
    $$UserProfileTableCreateCompanionBuilder,
    $$UserProfileTableUpdateCompanionBuilder,
    (
      UserProfileData,
      BaseReferences<_$AppDatabase, $UserProfileTable, UserProfileData>
    ),
    UserProfileData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$WaterLogsTableTableManager get waterLogs =>
      $$WaterLogsTableTableManager(_db, _db.waterLogs);
  $$UserProfileTableTableManager get userProfile =>
      $$UserProfileTableTableManager(_db, _db.userProfile);
}

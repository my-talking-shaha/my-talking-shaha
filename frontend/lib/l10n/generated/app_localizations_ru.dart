// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appLanguage => 'Язык приложения';

  @override
  String get english => 'Английский';

  @override
  String get russian => 'Русский';

  @override
  String get profile => 'Профиль';

  @override
  String get driver => 'Водитель';

  @override
  String get signedIn => 'Выполнен вход';

  @override
  String get theme => 'Тема';

  @override
  String get light => 'Светлая';

  @override
  String get dark => 'Темная';

  @override
  String get general => 'Общие';

  @override
  String get notifications => 'Уведомления';

  @override
  String get vehicle => 'Автомобиль';

  @override
  String get allNotifications => 'Все уведомления';

  @override
  String get logOut => 'Выйти';

  @override
  String get dashboard => 'Панель';

  @override
  String get garage => 'Гараж';

  @override
  String get history => 'История';

  @override
  String get chat => 'Чат';

  @override
  String get analytics => 'Аналитика';

  @override
  String get settings => 'Настройки';

  @override
  String get brandName => 'My Talking Shaha';

  @override
  String get retry => 'Повторить';

  @override
  String get tryAgain => 'Попробовать снова';

  @override
  String get cancel => 'Отмена';

  @override
  String get delete => 'Удалить';

  @override
  String get edit => 'Изменить';

  @override
  String get save => 'Сохранить';

  @override
  String get openGarage => 'Открыть гараж';

  @override
  String get email => 'Email';

  @override
  String get enterYourEmail => 'Введите email';

  @override
  String get enterValidEmail => 'Введите корректный email';

  @override
  String get password => 'Пароль';

  @override
  String get enterYourPassword => 'Введите пароль';

  @override
  String passwordMinLength(int count) {
    return 'Пароль должен быть не короче $count символов';
  }

  @override
  String get passwordHint => 'Минимум 6 символов';

  @override
  String get showPassword => 'Показать пароль';

  @override
  String get hidePassword => 'Скрыть пароль';

  @override
  String get forgotPassword => 'Забыли пароль?';

  @override
  String get logIn => 'Войти';

  @override
  String get noAccount => 'Нет аккаунта?';

  @override
  String get register => 'Зарегистрироваться';

  @override
  String get registration => 'Регистрация';

  @override
  String get createYourProfile => 'Создайте профиль';

  @override
  String get fullName => 'Полное имя';

  @override
  String get enterYourFullName => 'Введите полное имя';

  @override
  String get fullNameHint => 'Иван Иванов';

  @override
  String get confirmPassword => 'Подтвердите пароль';

  @override
  String get repeatPassword => 'Повторите пароль';

  @override
  String get confirmYourPassword => 'Подтвердите пароль';

  @override
  String get passwordsDoNotMatch => 'Пароли не совпадают';

  @override
  String get alreadyHaveAccount => 'Уже есть аккаунт?';

  @override
  String get somethingWentWrong => 'Что-то пошло не так. Попробуйте позже';

  @override
  String get couldNotLogOut => 'Не удалось выйти. Попробуйте снова';

  @override
  String get deleteVehicleQuestion => 'Удалить автомобиль?';

  @override
  String deleteVehicleConfirmation(Object vehicleName) {
    return '$vehicleName будет удален из гаража.';
  }

  @override
  String get garageEmpty => 'Гараж пуст';

  @override
  String get garageEmptyDescription =>
      'Добавьте первую машину, чтобы создать ее цифрового двойника.';

  @override
  String get garageEmptyCompactDescription =>
      'Добавьте первую машину, чтобы открыть ее цифрового двойника.';

  @override
  String get addVehicle => 'Добавить авто';

  @override
  String get addCar => 'Добавить авто';

  @override
  String get yourFleet => 'ВАШ АВТОПАРК';

  @override
  String get couldNotLoadGarage => 'Не удалось загрузить гараж';

  @override
  String get openCockpit => 'Открыть кокпит';

  @override
  String get mileage => 'ПРОБЕГ';

  @override
  String get service => 'СЕРВИС';

  @override
  String get fuel => 'ТОПЛИВО';

  @override
  String get noIssues => 'Проблем нет';

  @override
  String get noData => 'Нет данных';

  @override
  String warningsCount(int count) {
    return '$count предупреждений';
  }

  @override
  String get editCar => 'Редактировать авто';

  @override
  String get carSpecifications => 'Характеристики авто';

  @override
  String get vehicleNotFound => 'Автомобиль не найден';

  @override
  String get brand => 'Марка';

  @override
  String get model => 'Модель';

  @override
  String get year => 'Год';

  @override
  String get currentMileage => 'Текущий пробег';

  @override
  String get color => 'Цвет';

  @override
  String get vinOptional => 'VIN номер (необязательно)';

  @override
  String get engineType => 'Тип двигателя';

  @override
  String get selectEngineType => 'Выберите тип двигателя';

  @override
  String get gasoline => 'Бензин';

  @override
  String get diesel => 'Дизель';

  @override
  String get hybrid => 'Гибрид';

  @override
  String get electric => 'Электро';

  @override
  String get powerOutputHp => 'Мощность (л.с.)';

  @override
  String get engineVolumeL => 'Объем двигателя (л)';

  @override
  String get saveChanges => 'Сохранить изменения';

  @override
  String get startNewShaha => 'Создать новую шаху!';

  @override
  String get vehicleUpdated => 'Автомобиль обновлен';

  @override
  String get vehicleAdded => 'Автомобиль добавлен';

  @override
  String get checkVehicleDetails => 'Проверьте данные автомобиля';

  @override
  String get couldNotUpdateVehicle => 'Не удалось обновить автомобиль';

  @override
  String get couldNotSaveVehicle => 'Не удалось сохранить автомобиль';

  @override
  String get enterBrand => 'Введите марку';

  @override
  String get enterModel => 'Введите модель';

  @override
  String get enterProductionYear => 'Введите год выпуска';

  @override
  String enterProductionYearRange(int year) {
    return 'Введите год выпуска от 1900 до $year';
  }

  @override
  String get mileageCannotBeNegative => 'Пробег не может быть отрицательным';

  @override
  String get enterCurrentMileage => 'Введите текущий пробег';

  @override
  String get enterPowerOutput => 'Введите мощность';

  @override
  String get enterEngineVolume => 'Введите объем двигателя';

  @override
  String get enterEngineSpecification => 'Введите объем двигателя или мощность';

  @override
  String get powerOutputPositive => 'Мощность должна быть больше нуля';

  @override
  String get engineVolumePositive => 'Объем двигателя должен быть больше нуля';

  @override
  String get vinLengthError => 'VIN должен содержать ровно 17 символов';

  @override
  String get myShaha => 'Моя Shaha';

  @override
  String get couldNotLoadDashboard => 'Не удалось загрузить панель';

  @override
  String get currentOdometer => 'Текущий одометр';

  @override
  String get engine => 'ДВИГАТЕЛЬ';

  @override
  String get vinNumber => 'VIN НОМЕР';

  @override
  String get vinUnavailable => 'VIN недоступен';

  @override
  String get copyVin => 'Скопировать VIN';

  @override
  String get vinCopied => 'VIN скопирован';

  @override
  String get latestEvents => 'ПОСЛЕДНИЕ СОБЫТИЯ';

  @override
  String get viewAll => 'Все';

  @override
  String get noEventsYet => 'Событий пока нет';

  @override
  String get maintenanceHistory => 'История обслуживания';

  @override
  String get addEvent => 'Добавить событие';

  @override
  String get searchHistory => 'Поиск по истории…';

  @override
  String get all => 'ВСЕ';

  @override
  String get repairs => 'РЕМОНТ';

  @override
  String get trips => 'ПОЕЗДКИ';

  @override
  String get noEventsFound => 'События не найдены';

  @override
  String get historyEmpty => 'История пуста';

  @override
  String get tryAnotherSearch => 'Попробуйте другой поиск или тип события.';

  @override
  String get historyEmptyDescription =>
      'Поездки, заправки и ремонты появятся здесь.';

  @override
  String get couldNotLoadHistory => 'Не удалось загрузить историю';

  @override
  String get newRefueling => 'Новая заправка';

  @override
  String get newMaintenance => 'Новое обслуживание';

  @override
  String get newTrip => 'Новая поездка';

  @override
  String get eventType => 'ТИП СОБЫТИЯ';

  @override
  String get dateAndTime => 'ДАТА И ВРЕМЯ';

  @override
  String get title => 'НАЗВАНИЕ';

  @override
  String get enterEventTitle => 'Введите название события...';

  @override
  String get currentMileageLabel => 'ТЕКУЩИЙ ПРОБЕГ';

  @override
  String get refuelingDetails => 'ДЕТАЛИ ЗАПРАВКИ';

  @override
  String get amount => 'КОЛИЧЕСТВО';

  @override
  String get cost => 'СТОИМОСТЬ';

  @override
  String get fuelType => 'ТИП ТОПЛИВА';

  @override
  String get mileageForecastInfo =>
      'Пробег будет использован для обновления сервисных интервалов и прогнозов.';

  @override
  String get workDescription => 'ОПИСАНИЕ РАБОТ';

  @override
  String get describeWorkPerformed => 'Опишите выполненные работы...';

  @override
  String get replacedParts => 'ЗАМЕНЕННЫЕ ДЕТАЛИ';

  @override
  String get enterPartsSeparated => 'Введите детали через запятую...';

  @override
  String get route => 'МАРШРУТ';

  @override
  String get duration => 'ДЛИТЕЛЬНОСТЬ';

  @override
  String get start => 'СТАРТ';

  @override
  String get end => 'ФИНИШ';

  @override
  String get optional => 'необязательно';

  @override
  String get partPhoto => 'ФОТО ДЕТАЛИ';

  @override
  String get addPhoto => 'Добавить фото';

  @override
  String get openingGallery => 'Открываем галерею...';

  @override
  String get removePhoto => 'Удалить фото';

  @override
  String get chooseAnotherPhoto => 'Выбрать другое фото';

  @override
  String get couldNotSaveEvent =>
      'Не удалось сохранить событие. Попробуйте снова.';

  @override
  String get couldNotAccessPhotoLibrary => 'Не удалось открыть фотогалерею.';

  @override
  String get couldNotSelectPhoto => 'Не удалось выбрать фото.';

  @override
  String get couldNotRestorePhoto => 'Не удалось восстановить выбранное фото.';

  @override
  String get fuelEvent => 'Заправка';

  @override
  String get maintenanceEvent => 'Обслуживание';

  @override
  String get tripEvent => 'Поездка';

  @override
  String fieldMustBePositive(Object field) {
    return '$field должно быть больше нуля';
  }

  @override
  String fieldIsRequired(Object field) {
    return '$field обязательно';
  }

  @override
  String mileageAtLeastKm(int km) {
    return 'Должно быть не меньше $km км';
  }

  @override
  String atLeastKm(int km) {
    return 'Не меньше $km км';
  }

  @override
  String get mustExceedStart => 'Должно быть больше старта';

  @override
  String replaced(Object parts) {
    return 'Заменено: $parts';
  }

  @override
  String get partPhotoLabel => 'Фото детали:';

  @override
  String get chatWithShaha => 'Чат с Shaha';

  @override
  String get vehicleAiAssistant => 'AI-ассистент автомобиля';

  @override
  String get shahaOnline => 'Shaha на связи';

  @override
  String get chatEmptyDescription =>
      'Спросите о состоянии авто, расходах или обслуживании.';

  @override
  String get quickQuestionVehicleStatus => 'Состояние авто';

  @override
  String get quickQuestionOil => 'Когда менять масло?';

  @override
  String get quickQuestionBreakSoon => 'Что скоро может сломаться?';

  @override
  String get message => 'Сообщение';

  @override
  String get sendMessage => 'Отправить сообщение';

  @override
  String get assistantThinking => 'Ассистент думает';

  @override
  String get shahaThinking => 'Shaha думает';

  @override
  String get connectingToShaha => 'Подключаемся к Shaha';

  @override
  String get preparingChat => 'Готовим историю и быстрые вопросы.';

  @override
  String get chatDidNotLoad => 'Чат не загрузился';

  @override
  String get checkConnectionTryAgain =>
      'Проверьте соединение и попробуйте снова.';

  @override
  String get couldNotGetReply =>
      'Не удалось получить ответ. Проверьте backend и попробуйте снова.';

  @override
  String get openAnalytics => 'Открыть аналитику';

  @override
  String get openForecast => 'Открыть прогноз';

  @override
  String get openDashboard => 'Открыть панель';

  @override
  String get open => 'Открыть';

  @override
  String get addRefuel => 'Добавить заправку';

  @override
  String get addTrip => 'Добавить поездку';

  @override
  String get addPartRecord => 'Добавить запись о детали';

  @override
  String get addMaintenance => 'Добавить обслуживание';

  @override
  String get openForm => 'Открыть форму';

  @override
  String get intelligence => 'Интеллект';

  @override
  String get performanceOverview => 'Обзор расходов и состояния';

  @override
  String get seasonalExpenses => 'СЕЗОННЫЕ РАСХОДЫ';

  @override
  String totalAmount(Object amount) {
    return 'ИТОГО: $amount';
  }

  @override
  String get monthlyExpenseTrend => 'Динамика расходов по месяцам';

  @override
  String get historyAnalysis => 'АНАЛИЗ ИСТОРИИ';

  @override
  String expensesLabel(Object period) {
    return 'РАСХОДЫ: $period';
  }

  @override
  String get costPerKm => 'СТОИМОСТЬ ЗА КМ';

  @override
  String averageLabel(Object value) {
    return 'Среднее: $value';
  }

  @override
  String get performanceTrendOverTime => 'ДИНАМИКА СОСТОЯНИЯ';

  @override
  String get companyMetricsUnavailable => 'Метрики компании недоступны';

  @override
  String get countsUnavailable => 'Счетчики недоступны';

  @override
  String get companyMetrics => 'МЕТРИКИ КОМПАНИИ';

  @override
  String get keyCounts => 'КЛЮЧЕВЫЕ СЧЕТЧИКИ';

  @override
  String get subscription => 'Подписка';

  @override
  String get electronics => 'Электроника';

  @override
  String get notEnoughAnalytics => 'Недостаточно данных для аналитики';

  @override
  String get analyticsEmptyDescription =>
      'Добавьте поездки, заправки, ремонты или обслуживание.';

  @override
  String get addRepair => 'Добавить ремонт';

  @override
  String get couldNotLoadAnalytics => 'Не удалось загрузить аналитику';

  @override
  String get month => 'МЕСЯЦ';

  @override
  String get yearPeriod => 'ГОД';

  @override
  String get allTime => 'ВСЕ ВРЕМЯ';

  @override
  String get monthly => 'МЕСЯЧНЫЕ';

  @override
  String get annual => 'ГОДОВЫЕ';

  @override
  String get allTimeAdjective => 'ЗА ВСЕ ВРЕМЯ';

  @override
  String get fuelCategory => 'Топливо';

  @override
  String get maintenanceCategory => 'Обслуживание';

  @override
  String get partsCategory => 'Детали';

  @override
  String get otherCategory => 'Другое';

  @override
  String get maintenanceForecast => 'Прогноз обслуживания';

  @override
  String get noPartsAdded => 'Детали не добавлены';

  @override
  String get partsEmptyDescription =>
      'Когда появятся данные о ресурсе деталей, прогноз обслуживания будет здесь.';

  @override
  String get couldNotLoadParts => 'Не удалось загрузить ресурс деталей';

  @override
  String get partsRetryDescription =>
      'Попробуйте снова обновить прогноз обслуживания.';

  @override
  String get lifetimeNotSet => 'Ресурс не задан';

  @override
  String get resource => 'РЕСУРС';

  @override
  String get updatedTwoHoursAgo => 'ОБНОВЛЕНО 2 ЧАСА НАЗАД';

  @override
  String get maintenanceForecastCaps => 'ПРОГНОЗ ОБСЛУЖИВАНИЯ';

  @override
  String get serviceNeededNow => 'Нужен сервис сейчас';

  @override
  String inKm(Object km) {
    return 'Через $km км';
  }

  @override
  String get notEnoughData => 'Недостаточно данных';

  @override
  String get addLifetimeData => 'Добавьте данные ресурса для прогноза';

  @override
  String get nextService => 'СЛЕДУЮЩИЙ СЕРВИС';

  @override
  String approxDateInDays(int days) {
    return 'Примерная дата: через $days дн.';
  }

  @override
  String replacePartNow(Object part) {
    return 'Замените $part сейчас';
  }

  @override
  String replaceCriticalPartsNow(int count) {
    return 'Замените критичные детали: $count';
  }

  @override
  String get noNotificationsYet => 'Уведомлений пока нет';

  @override
  String get networkError => 'Ошибка сети';

  @override
  String get notificationsLoadError =>
      'Не удалось загрузить уведомления. Проверьте соединение и попробуйте снова.';

  @override
  String get notificationDetails => 'Детали уведомления';

  @override
  String get notificationNotFound => 'Уведомление не найдено';

  @override
  String get remainingResource => 'Оставшийся ресурс';

  @override
  String get recommendedAction => 'Рекомендованное действие';
}

# User stories

---

### 1. Аккаунт и авторизация

| Короткое название | Полное название user story | Описание user story | Приоритет | Acceptance criteria |
| --- | --- | --- | --- | --- |
| ACC-01 | Регистрация в приложении | Как пользователь, я хочу регистрироваться в приложении, чтобы все данные были привязаны к моей учётной записи, и я мог получить к ним доступ с разных устройств. | Must |   • Пользователь может создать аккаунт, указав email и пароль
  • Пароль должен быть не менее 6 символов
  • При успешной регистрации автоматически создаётся пустой «гараж»
  • После регистрации пользователь автоматически входит в приложение
  • При попытке зарегистрироваться с уже существующим email — показывается ошибка
  • Пользователь может выйти из аккаунта и войти снова с теми же данными |
| ACC-02 | Вход/регистрация через Яндекс ID | Как пользователь, я хочу иметь возможность регистрации/авторизации через Яндекс-аккаунт, чтобы процесс входа был быстрее и не требовал ввода дополнительных паролей. | Should |   • На экране входа есть кнопка «Войти через Яндекс ID»
  • При нажатии открывается стандартный Яндекс OAuth виджет
  • После успешной авторизации через Яндекс создаётся аккаунт (если его ещё нет)
  • Аккаунт привязывается к Яндекс ID пользователя
  • При повторном входе через Яндекс пользователь попадает в свой существующий аккаунт
  • Email из Яндекс используется как основной email в системе
  • При ошибке Яндекс-авторизации показывается понятное сообщение |
| ACC-03 | Добавление нескольких автомобилей | Как пользователь, я хочу добавлять несколько автомобилей в свой аккаунт с указанием их марки, модели, цвета, технических характеристик и деталей (либо выбирать машину из общего каталога, если она там есть), чтобы управлять всеми машинами из одного места. | Must |   • Пользователь может открыть форму «Добавить автомобиль»
  • Форма содержит поля: марка, модель, год выпуска, цвет, текущий пробег, тип двигателя
  • Марка и модель могут выбираться из выпадающего списка (каталог) или вводиться вручную
  • Все поля обязательны для заполнения, кроме цвета
  • После сохранения автомобиль появляется в «Гараже»
  • Можно добавить неограниченное количество автомобилей |
| ACC-04 | Список автомобилей (гараж) | Как пользователь, я хочу иметь «гараж» — список всех добавленных мной автомобилей, чтобы быстро переключаться между ними и видеть общую информацию по каждому. | Must |   • В приложении есть отдельный раздел/экран «Гараж»
  • В Гараже отображаются все добавленные пользователем автомобили
  • Каждый автомобиль показан в виде карточки с: маркой, моделью, годом, цветом, фото (если загружено), типом двигателя
  • При нажатии на карточку автомобиля открывается страница с деталями о нем
  • Если автомобилей нет — показывается пустое состояние с предложением добавить авто
  • Пользователь может удалить автомобиль из гаража
  • Удаление сопровождается подтверждением |

#### English version

| Short name | User story title | User story description | Priority | Acceptance criteria |
| --- | --- | --- | --- | --- |
| ACC-01 | App registration | As a user, I want to register in the app so that all data is linked to my account and I can access it from different devices. | Must |   • The user can create an account by providing an email and password
  • The password must be at least 6 characters long
  • After successful registration, an empty “garage” is created automatically
  • After registration, the user is automatically signed in
  • If the user tries to register with an email that already exists, an error is shown
  • The user can sign out and sign in again with the same credentials |
| ACC-02 | Sign in/sign up with Yandex ID | As a user, I want to be able to sign up/sign in with a Yandex account so that the login process is faster and does not require entering additional passwords. | Should |   • The sign-in screen has a “Sign in with Yandex ID” button
  • Tapping it opens the standard Yandex OAuth widget
  • After successful Yandex authorization, an account is created (if it does not exist yet)
  • The account is linked to the user’s Yandex ID
  • On subsequent sign-ins with Yandex, the user lands in the existing account
  • The email from Yandex is used as the primary email in the system
  • If Yandex authorization fails, a clear error message is shown |
| ACC-03 | Add multiple cars | As a user, I want to add multiple cars to my account with make, model, color, technical characteristics and details (or select a car from the common catalog if it exists there) so that I can manage all cars in one place. | Must |   • The user can open the “Add car” form
  • The form includes: make, model, year, color, current mileage, engine type
  • Make and model can be selected from a dropdown (catalog) or entered manually
  • All fields are required except color
  • After saving, the car appears in the “Garage”
  • The user can add an unlimited number of cars |
| ACC-04 | Car list (garage) | As a user, I want to have a “garage” — a list of all cars I’ve added — so that I can quickly switch between them and see basic info for each car. | Must |   • The app has a dedicated “Garage” section/screen
  • The Garage shows all cars added by the user
  • Each car is shown as a card with: make, model, year, color, photo (if uploaded), engine type
  • Tapping a car card opens the car details page
  • If there are no cars, an empty state is shown with an option to add a car
  • The user can delete a car from the garage
  • Deletion requires confirmation |

### 2. Ввод и хранение данных автомобиля

| Короткое название | Полное название user story | Описание user story | Приоритет | Acceptance criteria |
| --- | --- | --- | --- | --- |
| DATA-01 | Загрузка истории автомобиля | Как пользователь, я хочу иметь возможность загружать данные о своей машине (ремонты, пробег, техническое состояние, поездки, заправки), чтобы удобно хранить всю историю в едином цифровом пространстве (таймлайн автомобиля). | Must |   • Пользователь может добавить запись о ремонте с полями: дата, пробег, описание, стоимость, заменённые детали, фото (опционально)
  • Пользователь может добавить запись о заправке с полями: дата, пробег, количество литров, стоимость, тип топлива
  • Пользователь может добавить запись о поездке с полями: дата, пробег начала, пробег конца, маршрут (опционально)
  • Все записи автоматически привязываются к выбранному автомобилю
  • Записи отображаются в хронологическом порядке (таймлайн)
  • Пользователь может редактировать и удалять любую запись
  • При добавлении новой записи таймлайн обновляется без перезагрузки приложения
  • Все поля с пробегом валидируются (новый пробег не может быть меньше предыдущего) |
| DATA-01 | Обновление деталей и состояния | Как пользователь, я хочу загружать данные о новых установленных деталях или выбирать их из каталога, чтобы сохранять актуальную информацию о состоянии автомобиля. | Should |   • Пользователь может добавить деталь к автомобилю с полями: название детали, дата установки, пробег при установке, ресурс в км, фото (опционально)
  • Пользователь может выбрать деталь из предустановленного каталога (например: масло, фильтр, ремень ГРМ, тормозные колодки)
  • При выборе из каталога ресурс может подставляться автоматически (если известен)
  • Деталь сохраняется и отображается в списке деталей автомобиля
  • Пользователь может редактировать ресурс детали вручную
  • Пользователь может отметить деталь как «заменена» — тогда создаётся новая запись с новой датой и пробегом |
| DATA-03 | Фото/3D-модель автомобиля | Как пользователь, я хочу загружать фото своего автомобиля, чтобы видеть в профиле авто его 3D-модель (или фотоизображение). | Could |   • Пользователь может загрузить одно или несколько фото автомобиля
  • Загруженное фото сохраняется и отображается в карточке автомобиля в Гараже
  • Пользователь может удалить или заменить фото
  • Поддерживаются форматы: JPG, PNG 
  • При наличии нескольких фото реализована галерея с пролистыванием
  • Если пользователь загрузил достаточно фото — система может предложить сгенерировать упрощённую 3D-модель  |

#### English version

| Short name | User story title | User story description | Priority | Acceptance criteria |
| --- | --- | --- | --- | --- |
| DATA-01 | Upload vehicle history | As a user, I want to be able to upload data about my car (repairs, mileage, technical condition, trips, refueling) so that I can conveniently store the entire history in a single digital space (car timeline). | Must |   • The user can add a repair record with: date, mileage, description, cost, replaced parts, photos (optional)
  • The user can add a refueling record with: date, mileage, liters, cost, fuel type
  • The user can add a trip record with: date, start mileage, end mileage, route (optional)
  • All records are automatically linked to the selected car
  • Records are displayed in chronological order (timeline)
  • The user can edit and delete any record
  • When a new record is added, the timeline updates without app reload
  • Mileage fields are validated (new mileage cannot be less than the previous one) |
| DATA-01 | Update parts and condition | As a user, I want to upload data about newly installed parts or select them from a catalog so that I can keep up-to-date information about the car’s condition. | Should |   • The user can add a part to the car with: part name, installation date, mileage at installation, lifespan in km, photo (optional)
  • The user can select a part from a predefined catalog (e.g., oil, filter, timing belt, brake pads)
  • When selecting from the catalog, the lifespan can be auto-filled (if known)
  • The part is saved and shown in the car’s parts list
  • The user can edit the part lifespan manually
  • The user can mark a part as “replaced” — then a new record is created with a new date and mileage |
| DATA-03 | Car photo/3D model | As a user, I want to upload photos of my car so that I can see its 3D model (or photo) in the car profile. | Could |   • The user can upload one or more car photos
  • The uploaded photo is saved and displayed on the car card in the Garage
  • The user can delete or replace a photo
  • Supported formats: JPG, PNG 
  • If multiple photos are uploaded, a swipeable gallery is available
  • If the user uploads enough photos, the system may suggest generating a simplified 3D model |

### 3. Мониторинг состояния и прогнозирование

| Короткое название | Полное название user story | Описание user story | Приоритет | Acceptance criteria |
| --- | --- | --- | --- | --- |
| STATUS-01 | Просмотр текущего состояния | Как пользователь, я хочу видеть текущее состояние автомобиля в приложении, чтобы быстро оценивать его общую исправность и необходимость в обслуживании. | Must |   • На главном экране автомобиля отображается сводка: текущий пробег, дата последнего ТО, количество активных предупреждений
  • Отображается индикатор общего состояния (зелёный — всё хорошо, жёлтый — требуется внимание, красный — требуется срочное обслуживание)
  • Пользователь может увидеть список всех деталей с их статусом
  • Состояние обновляется автоматически при добавлении новых записей
  • При нажатии на любой блок открывается детальная информация |
| STATUS-02 | Оставшийся ресурс деталей | Как пользователь, я хочу видеть оставшееся «время жизни» деталей (прогнозируемый ресурс), чтобы планировать их замену до возникновения неисправности. | Must |   • Для каждой детали отображается оставшийся ресурс в км или %
  • Расчёт ресурса: (изначальный ресурс детали) − (текущий пробег − пробег при установке)
  • Для деталей без указанного ресурса отображается «Ресурс не задан»
  • Если остаток ресурса < 10% — деталь подсвечивается жёлтым
  • Если остаток ресурса ≤ 0 км — деталь подсвечивается красным
  • Правила расчёта хранятся в конфигурации
  • Пользователь может вручную скорректировать ресурс детали |
| STATUS-03 | Анализ технической истории | Как пользователь, я хочу видеть анализ технической истории моего автомобиля, чтобы понимать динамику поломок, затрат и эффективности обслуживания. | Should |   • Пользователь может открыть раздел «Анализ истории»
  • Отображается график частоты поломок по месяцам/годам
  • Отображается список самых частых типов ремонтов
  • Отображается динамика пробега по времени
  • Можно выбрать период для анализа (месяц, год, всё время)
  • Данные обновляются при добавлении новых записей |
| STATUS-04 | Аналитика трат и пробега | Как пользователь, я хочу видеть аналитику своих трат, пробега, числа ремонтов, заправок и ТО, чтобы оптимизировать расходы на обслуживание автомобиля. | Should |   • Пользователь может видеть общую сумму расходов на автомобиль (ремонты + заправки + ТО)
  • Расходы можно разбить по категориям (ремонт, топливо, ТО, запчасти)
  • Отображается средний расход топлива на 100 км (если есть данные о заправках и пробеге)
  • Отображается график трат по месяцам/годам
  • Отображается стоимость 1 км пробега (общие расходы / общий пробег) |

#### English version

| Short name | User story title | User story description | Priority | Acceptance criteria |
| --- | --- | --- | --- | --- |
| STATUS-01 | View current condition | As a user, I want to see the car’s current condition in the app so that I can quickly assess its overall health and whether service is needed. | Must |   • The main car screen shows a summary: current mileage, last maintenance date, number of active warnings
  • An overall condition indicator is shown (green — all good, yellow — attention needed, red — urgent service required)
  • The user can view a list of all parts with their status
  • The condition updates automatically when new records are added
  • Tapping any block opens detailed information |
| STATUS-02 | Remaining part lifespan | As a user, I want to see the remaining “lifetime” of parts (predicted lifespan) so that I can plan replacements before a failure occurs. | Must |   • For each part, remaining lifespan is shown in km or %
  • Lifespan calculation: (initial part lifespan) − (current mileage − mileage at installation)
  • For parts without a specified lifespan, “Lifespan not set” is shown
  • If remaining lifespan < 10% — the part is highlighted in yellow
  • If remaining lifespan ≤ 0 km — the part is highlighted in red
  • Calculation rules are stored in configuration
  • The user can manually adjust the part lifespan |
| STATUS-03 | Technical history analysis | As a user, I want to see an analysis of my car’s technical history so that I can understand the dynamics of failures, costs, and service efficiency. | Should |   • The user can open the “History analysis” section
  • A chart of failure frequency by month/year is displayed
  • A list of the most frequent repair types is displayed
  • Mileage dynamics over time are displayed
  • The user can select an analysis period (month, year, all time)
  • Data updates when new records are added |
| STATUS-04 | Spending and mileage analytics | As a user, I want to see analytics of my spending, mileage, number of repairs, refuels, and maintenance so that I can optimize car maintenance costs. | Should |   • The user can see total spending on the car (repairs + refueling + maintenance)
  • Spending can be broken down by category (repairs, fuel, maintenance, parts)
  • Average fuel consumption per 100 km is shown (if refuel and mileage data exist)
  • A spending chart by month/year is shown
  • Cost per 1 km is shown (total spending / total mileage) |

### 4. Уведомления и предупреждения

| Короткое название | Полное название user story | Описание user story | Приоритет | Acceptance criteria |
| --- | --- | --- | --- | --- |
| NOTIF-01 | Уведомления о возможных неисправностях | Как пользователь, я хочу получать уведомления о возможных неисправностях автомобиля, чтобы своевременно обратиться в сервис и предотвратить серьёзную поломку. | Could |   • Система отправляет push-уведомление, когда ресурс любой детали становится < 500 км (или порог задаётся пользователем)
  • Уведомление содержит: название детали, остаток ресурса, рекомендованное действие
  • При нажатии на уведомление открывается экран с деталью и списком рекомендаций
  • Уведомления отправляются не чаще 1 раза в день по одной детали (не спамим)
  • Пользователь может включить/отключить уведомления в настройках
  • В приложении есть экран со всеми полученными уведомлениями |

#### English version

| Short name | User story title | User story description | Priority | Acceptance criteria |
| --- | --- | --- | --- | --- |
| NOTIF-01 | Notifications about potential failures | As a user, I want to receive notifications about potential car failures so that I can visit a service center in time and prevent a serious breakdown. | Could |   • The system sends a push notification when any part’s remaining lifespan becomes < 500 km (or the threshold is set by the user)
  • The notification includes: part name, remaining lifespan, recommended action
  • Tapping the notification opens the part screen with a list of recommendations
  • Notifications are sent no more than once per day per part (no spam)
  • The user can enable/disable notifications in settings
  • The app has a screen with all received notifications |

### 5. Общение с AI-агентом (чат)

| Короткое название | Полное название user story | Описание user story | Приоритет | Acceptance criteria |
| --- | --- | --- | --- | --- |
| CHAT-01 | AI-чат с машиной | Как пользователь, я хочу «общаться» со своей машиной через AI-чат, чтобы узнавать о возможных поломках деталей заранее, следить за состоянием авто и получать рекомендации по обслуживанию. | Must |   • В приложении есть раздел «Чат с автомобилем»
  • Пользователь может написать текстовое сообщение на естественном языке
  • AI-агент отвечает на основе данных автомобиля и правил
  • Ответ содержит конкретные цифры (пробег, остаток ресурса, дату) где возможно
  • Если AI не может ответить — возвращается стандартное сообщение: «Недостаточно данных для ответа»
  • История чата сохраняется и доступна при следующем входе
  • Для каждого автомобиля есть отдельный чат |
| CHAT-02 | Голосовой ввод в AI-чате | Как пользователь, я хочу общаться с AI-агентом моей машины с помощью голосового ввода (или текстового чата), чтобы взаимодействие было удобным и не требовало постоянного набора текста, особенно во время поездок или быстрой проверки состояния. | Could |   • В поле ввода сообщения есть кнопка микрофона
  • При нажатии на микрофон начинается запись голоса пользователя
  • Запись автоматически преобразуется в текст
  • Преобразованный текст отображается в поле ввода и может быть отредактирован перед отправкой
  • Поддерживается как минимум английский язык
  • Если распознавание не удалось — показывается сообщение об ошибке и предлагается повторить
  • Функция работает на iOS и Android  |
| CHAT-03 | Стартовый экран - чат + быстрые вопросы | Как пользователь, я хочу при входе в приложении иметь возможность сразу написать в чат со своей машиной/выбрать вопрос из быстрых вопросов, чтобы сразу узнать интересующую меня информацию/для быстрой навигации по приложению. | Must |   • Главный экран — чат с AI
  • Под полем ввода — кнопки быстрых вопросов
  • Стартовый набор: «Состояние авто», «Когда ТО?», «Что может сломаться?», «Добавить заправку», «Записать ремонт»
  • Кнопки динамические: подбираются под пользователя и авто (например, «Пора менять масло?» при остатке <1000 км)
  • При нажатии — вопрос отправляется в чат |
| CHAT-04 | Чат первичен, вкладки вторичны | Как пользователь, я хочу, чтобы чат с ИИ был основным способом взаимодействия с приложением, но при необходимости я мог переключиться на отдельные вкладки (гараж, аналитика, таймлайн), чтобы управлять автомобилем так, как мне удобно. |  Must |   • По умолчанию открыт чат
  • Нижнее меню: Чат / Гараж / Аналитика / Таймлайн
  • Переключение вкладок — контекст чата сохраняется
  • AI может подсказать: «Перейдите в Аналитику, чтобы посмотреть график трат» |
| CHAT-05 | Чат → форма | Как пользователь, я хочу сообщить ИИ о событии (ремонт, замена детали, заправка, поездка), чтобы ИИ перенаправил меня на предзаполненную форму, где я смогу быстро внести все данные и сохранить их. | Must |   • Пользователь пишет: «Заменил масло на 15000 км»
  • AI распознаёт интент «замена детали»
  • Ответ: «Хотите добавить замену детали?» + кнопка «Перейти к форме»
  • Открывается отдельная форма, предзаполненная (деталь = масло, пробег = 15000)
  • Пользователь дозаполняет и сохраняет
  • После сохранения — возврат в чат с подтверждением AI
  • Интенты: ремонт, замена детали, заправка, поездка
  • Возможность отменить действие |
| CHAT-06 | История чата | Как пользователь, я хочу, чтобы все мои диалоги с ИИ сохранялись, и я мог просматривать историю переписки при следующем входе, чтобы не терять контекст общения с автомобилем. | Should |   • Все диалоги с AI сохраняются
  • История привязана к аккаунту и автомобилю
  • Пользователь может листать историю сообщений
  • Поиск по истории НЕ требуется (сознательное ограничение MVP)
  • История доступна при повторном входе |

#### English version

| Short name | User story title | User story description | Priority | Acceptance criteria |
| --- | --- | --- | --- | --- |
| CHAT-01 | AI chat with the car | As a user, I want to “talk” to my car via an AI chat so that I can learn about potential part failures in advance, monitor the car’s condition, and get maintenance recommendations. | Must |   • The app has a “Chat with the car” section
  • The user can send a natural-language text message
  • The AI agent responds based on car data and rules
  • The response includes specific numbers (mileage, remaining lifespan, date) where possible
  • If the AI cannot answer, it returns a standard message: “Not enough data to answer”
  • Chat history is saved and available on next sign-in
  • Each car has its own separate chat |
| CHAT-02 | Voice input in AI chat | As a user, I want to communicate with my car’s AI agent using voice input (or text chat) so that the interaction is convenient and does not require constant typing, especially while driving or quickly checking the car’s status. | Could |   • The message input field has a microphone button
  • Tapping the microphone starts recording the user’s voice
  • The recording is automatically converted to text
  • The converted text is shown in the input field and can be edited before sending
  • At least English is supported
  • If recognition fails, an error message is shown and the user is prompted to retry
  • The feature works on iOS and Android |
| CHAT-03 | Start screen — chat + quick questions | As a user, I want to be able to immediately type in the chat with my car or pick a question from quick questions when I open the app so that I can quickly get the information I need and navigate the app faster. | Must |   • The home screen is the AI chat
  • Below the input field there are quick-question buttons
  • Starter set: “Car status”, “When is service due?”, “What might break?”, “Add refuel”, “Log repair”
  • Buttons are dynamic: adjusted to the user and car (e.g., “Time to change oil?” when remaining <1000 km)
  • Tapping a button sends the question to the chat |
| CHAT-04 | Chat first, tabs second | As a user, I want the AI chat to be the primary way to interact with the app, but if needed I can switch to dedicated tabs (garage, analytics, timeline) so that I can manage the car in the way that suits me. |  Must |   • By default, the chat is open
  • Bottom navigation: Chat / Garage / Analytics / Timeline
  • Switching tabs keeps the chat context
  • The AI can suggest: “Go to Analytics to view the spending chart” |
| CHAT-05 | Chat → form | As a user, I want to tell the AI about an event (repair, part replacement, refuel, trip) so that the AI redirects me to a pre-filled form where I can quickly enter all data and save it. | Must |   • The user writes: “Changed the oil at 15,000 km”
  • The AI recognizes the “part replacement” intent
  • Response: “Would you like to add a part replacement?” + a “Go to form” button
  • A separate form opens, pre-filled (part = oil, mileage = 15000)
  • The user completes remaining fields and saves
  • After saving, the app returns to the chat with an AI confirmation
  • Intents: repair, part replacement, refuel, trip
  • The user can cancel the action |
| CHAT-06 | Chat history | As a user, I want all my AI conversations to be saved and be able to view the message history the next time I sign in so that I don’t lose the context of communication with the car. | Should |   • All AI dialogs are saved
  • History is linked to the account and the car
  • The user can scroll through the message history
  • Search in history is NOT required (intentional MVP limitation)
  • History is available on subsequent sign-in |
#Использовать irac

Перем ВерсияПлатформы;
Перем ПараметрыКластера;

Перем УправлениеКластером;

Перем АдресСервера;
Перем ПодключениеКСервернойбазе;
Перем ПараметрыПодключения;
Перем ПараметрыБлокировкиСеансов;
Перем АвторизацияВИнформационнойБазе;

Перем Информационнаябаза;

Перем ЭтоФайловаяБаза;

Перем НачалоБлокировкиСеансов;
Перем ОкончаниеБлокировкиСеансов;
Перем СрокОжиданияЗавершенияСеансов;

Перем Лог;

Процедура УстановитьНастройки(НастройкиОбновления) Экспорт

	ЭтоФайловаяБаза = НастройкиОбновления.ЭтоФайловаяБаза();
	ВерсияПлатформы = НастройкиОбновления.ВерсияПлатформы();
	ПараметрыКластера = НастройкиОбновления.ПараметрыКластера;
	ПараметрыПодключения = НастройкиОбновления.ПараметрыПодключения;
	ПараметрыБлокировкиСеансов = НастройкиОбновления.ПараметрыБлокировкиСеансов;
	АвторизацияВИнформационнойБазе = НастройкиОбновления.АвторизацияВИнформационнойБазе();

КонецПроцедуры

Процедура ИнициироватьУправлениеКластером()

	Если Не УправлениеКластером = Неопределено Тогда
		Возврат;
	КонецЕсли;

	АдресСервера = ПараметрыКластера.Сервер;

	Если ПустаяСтрока(АдресСервера) Тогда
		АдресСервера = ПараметрыПодключения.СервернаяБаза.Сервер;
	КонецЕсли;

	ПортСервера = ПараметрыКластера.Порт;
	ПользовательКластера = ПараметрыКластера.Пользователь;
	ПарольКластера = ПараметрыКластера.Пароль;

	УправлениеКластером = Новый АдминистрированиеКластера(АдресСервера, ПортСервера,
						ВерсияПлатформы, ПользовательКластера, ПарольКластера);
КонецПроцедуры

Процедура ПроверитьВозможностьЗаписиВКаталогБазы()
	// TODO: Сделать запись тестового файла в каталог базы
КонецПроцедуры

Процедура БлокировкаДоступа() Экспорт
	
	Если ЭтоФайловаяБаза Тогда
		БлокироватьДоступКФайловойБазе();
	Иначе
		БлокироватьДоступКСервернойБазе();
	КонецЕсли;
	
КонецПроцедуры

Процедура БлокироватьДоступКСервернойБазе()

	ИнициироватьУправлениеКластером();

	ИмяБазы = ПараметрыПодключения.СервернаяБаза.База;
	Информационнаябаза = НайтиИнформационнуюБазу(ИмяБазы);

	Если Информационнаябаза = Неопределено Тогда
		ВызватьИсключение СтрШаблон("Не удалось найти информационную базу <%1> на кластере серверов", ИмяБазы);
	КонецЕсли;

	Информационнаябаза.УстановитьАдминистратора(АвторизацияВИнформационнойБазе.Пользователь, АвторизацияВИнформационнойБазе.Пароль);

	УстановитьБлокировкуИнформационнойБазы();
	
	Если ЕстьПодключенныеСеансы() Тогда
		ОжиданиеОтключенияСеансов();
		ПрерватьПодключения();
	КонецЕсли;

КонецПроцедуры

Процедура УстановитьБлокировкуИнформационнойБазы()
	
	Лог.Отладка("Устанавливаю блокировку сеансов и регламентных заданий");
	
	ПараметрыИнформационнойбазы = Новый Структура();

	НачалоБлокировкиСеансов = ТекущаяДата();
	ОкончаниеБлокировкиСеансов = НачалоБлокировкиСеансов + 60*60; // Параметр в секундах

	СрокОжиданияЗавершенияСеансов = НачалоБлокировкиСеансов + ПараметрыБлокировкиСеансов.ПериодОжиданияЗавершенияСеансов; // Еще ждем минуту
	
	ФорматДаты = "ДФ='yyyy-MM-dd HH:mm:ss'";

	ПараметрыИнформационнойбазы.Вставить("БлокировкаСеансовВключена", "on");
	ПараметрыИнформационнойбазы.Вставить("БлокировкаРегламентныхЗаданийВключена", "on");
	ПараметрыИнформационнойбазы.Вставить("НачалоБлокировкиСеансов", Формат(НачалоБлокировкиСеансов, ФорматДаты));
	ПараметрыИнформационнойбазы.Вставить("ОкончаниеБлокировкиСеансов", Формат(ОкончаниеБлокировкиСеансов, ФорматДаты));
	ПараметрыИнформационнойбазы.Вставить("СообщениеБлокировкиСеансов", ПараметрыБлокировкиСеансов.СообщениеБлокировкиСеансов);
	ПараметрыИнформационнойбазы.Вставить("КодРазрешения", ПараметрыБлокировкиСеансов.КлючРазрешенияЗапуска);
		
	Информационнаябаза.Изменить(ПараметрыИнформационнойбазы);

	Лог.Отладка("Установлена блокировку сеансов и регламентных заданий");

КонецПроцедуры

Процедура СнятьБлокировкуИнформационнойБазы()
	
	Лог.Отладка("Снимаю блокировку сеансов и регламентных заданий");
	
	ПараметрыИнформационнойбазы = Новый Структура();

	ПараметрыИнформационнойбазы.Вставить("БлокировкаСеансовВключена", "off");
	ПараметрыИнформационнойбазы.Вставить("БлокировкаРегламентныхЗаданийВключена", "off");
	ПараметрыИнформационнойбазы.Вставить("НачалоБлокировкиСеансов", "");
	ПараметрыИнформационнойбазы.Вставить("ОкончаниеБлокировкиСеансов", "");
	ПараметрыИнформационнойбазы.Вставить("СообщениеБлокировкиСеансов", "");
	ПараметрыИнформационнойбазы.Вставить("ПараметрБлокировкиСеансов", "");
		
	Информационнаябаза.Изменить(ПараметрыИнформационнойбазы);
	
	Лог.Отладка("Снята блокировку сеансов и регламентных заданий");

КонецПроцедуры

Процедура ПрерватьПодключения()
	
	Лог.Отладка("Прерываю сеансы и подключения");
	
	Информационнаябаза.ОбновитьДанные(Истина);

	Сеансы = Информационнаябаза.Сеансы();
	Соединения = Информационнаябаза.Соединения();

	Лог.Отладка("Количество сеансы <%1>", Сеансы.Количество());
	Лог.Отладка("Количество подключений <%1>", Сеансы.Количество());

	Для каждого Сеанс Из Сеансы.Список(, Истина) Цикл
		
		Лог.Отладка("Прерываю сеанс <%1> пользователь <%2>", Сеанс.Ид(), Сеанс.Получить("Пользователь"));
		Сеанс.Завершить();
		
	КонецЦикла;
		
	Для каждого Соединение Из Соединения.Список(, Истина) Цикл
		Лог.Отладка("Прерываю соединение <%1> приложение <%2>", Соединение.Ид(), Соединение.Получить("Приложение"));
		Соединение.Отключить();
	КонецЦикла;

	Если ЕстьПодключенныеСеансы() Тогда
	
		СнятьБлокировкуИнформационнойБазы();
		
		ВызватьИсключение "Не удалось прервать соединения и сеансы в информационной базе";
	
	КонецЕсли;

	Лог.Отладка("Прерваны сеансы и подключения");
	
КонецПроцедуры

Функция ЕстьПодключенныеСеансы()
	
	Информационнаябаза.ОбновитьДанные(Истина);
	
	Сеансы = Информационнаябаза.Сеансы();

	ЕстьПодключения = Сеансы.Количество() > 0 
					ИЛИ ЕстьСоединения() > 0;

	Возврат ЕстьПодключения;

КонецФункции

Функция ЕстьСоединения()
	
	Соединения = Информационнаябаза.Соединения();

	КлючКонсоли = "SrvrConsole";

	Для каждого Соединение Из Соединения.Список(, Истина) Цикл
		ПроложениеСоединения = Соединение.Получить("Приложение");
		
		Если Не ПроложениеСоединения = КлючКонсоли Тогда
			Возврат Истина;
		КонецЕсли; 
	
	КонецЦикла;

	Возврат Ложь;

КонецФункции

Процедура ОжиданиеОтключенияСеансов()
	
	Лог.Отладка("Ожидаю отключения сеансов и подключений до <%1>", СрокОжиданияЗавершенияСеансов);
	
	Пока СрокОжиданияЗавершенияСеансов > ТекущаяДата() Цикл

		Приостановить(60*1000);

		Если НЕ ЕстьСоединения() Тогда
			Прервать;
		КонецЕсли;
	
	КонецЦикла;

	Лог.Отладка("Ожидание отключения сеансов и подключений завершено");

КонецПроцедуры

Функция НайтиИнформационнуюБазу(Знач ИмяБазы)
	
	Лог.Отладка("Поиск информационной базы с именем <%1>", ИмяБазы);
	
	Кластеры = УправлениеКластером.Кластеры();
	
	СписокКластеров = Кластеры.Список();

	Информационнаябаза = Неопределено;

	Для каждого Кластер Из СписокКластеров Цикл
		
		ИнформационныеБазы = Кластер.ИнформационныеБазы();
	
		Информационнаябаза = ИнформационныеБазы.Получить(ИмяБазы);;

		Если Не Информационнаябаза = Неопределено Тогда
			Прервать;
		КонецЕсли;

	КонецЦикла;

	Возврат Информационнаябаза;

КонецФункции

Процедура БлокироватьДоступКФайловойБазе()
	ПроверитьВозможностьЗаписиВКаталогБазы();
		
	// TODO: Реализовать блокировку через файла для файлового варианта
КонецПроцедуры

Процедура РазблокироватьДоступ() Экспорт
	// TODO: Реализовать разблокировку через файла для файлового варианта
	// TODO: Реализовать разблокировку через irac

	Если ЭтоФайловаяБаза Тогда

	Иначе
		СнятьБлокировкуИнформационнойБазы();
	КонецЕсли;

КонецПроцедуры

Процедура ПриСозданииОбъекта()

	Лог = Логирование.ПолучитьЛог("oscript.app.AutoUpdateIB.session");
	// Лог = Логирование.ПолучитьЛог("ktb.lib.irac");
	Лог.УстановитьУровень(УровниЛога.Отладка);

КонецПроцедуры
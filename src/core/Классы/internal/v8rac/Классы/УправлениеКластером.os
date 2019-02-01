#Использовать v8runner
#Использовать logos
#Использовать 1commands

Перем Лог;
Перем ПутьКлиентаАдминистрирования;
Перем ЭтоWindows;

Перем АвторизацияАдминистратораКластера;
Перем АдресСервера;
Перем ПортСервера;

Перем ИндексЛокальныхКластеров;
Перем ИндексИнформационныхБаз;

Перем ИндексЛокальныхКластеровОбновлен;
Перем ИндексАвторизацийИнформационныхБаз;

Перем ИмяКлючаВсеБазы;

Процедура УстановитьАвторизациюКластера(Знач Пользователь, Знач Пароль = "") Экспорт
	
	АвторизацияАдминистратораКластера = Новый Структура("Пользователь, Пароль", Пользователь, Пароль);

КонецПроцедуры

Процедура УстановитьАвторизациюИнформационнойБазы(Знач ИнформационнаяБаза, Знач Пользователь, Знач Пароль = "") Экспорт
	
	АвторизацияИБ = Новый Структура("Пользователь, Пароль", Пользователь, Пароль);

	ИндексАвторизацийИнформационныхБаз.Вставить(ИнформационнаяБаза, АвторизацияИБ);

КонецПроцедуры

Процедура УстановитьКластер(Знач АдресСерверКластера, Знач ПортСервераКластера = 1545, Знач ПринудительноСброситьИндексы = Ложь) Экспорт
	
	ИзменилсяКластер = Ложь;

	ТекущийАдресКластера = АдресСервера;
	ТекущийПортКластера = ПортСервера;

	МассивСтрок = СтрРазделить(АдресСерверКластера, ":");

	Если МассивСтрок.Количество() = 2 Тогда
		АдресСервера = МассивСтрок[0];
		ПортСервера = МассивСтрок[1];
	Иначе
		АдресСервера = АдресСерверКластера;
		ПортСервера = ПортСервераКластера;
	КонецЕсли;

	ИзменилсяКластер = НЕ ТекущийАдресКластера = АдресСервера
					   ИЛИ НЕ ТекущийПортКластера = ПортСервера;

	Если ПринудительноСброситьИндексы 
		ИЛИ ИзменилсяКластер Тогда
		
		СброситьИндексы();
		
	КонецЕсли;

КонецПроцедуры

Функция СписокЛокальныхКластеров() Экспорт
	
	Если Не ИндексЛокальныхКластеровОбновлен Тогда
		ОбновитьИндексЛокальныхКластеров();
	КонецЕсли;

	СписокКластеров = Новый Массив();

	Для каждого КлючЗначение Из ИндексЛокальныхКластеров Цикл
		СписокКластеров.Добавить(КлючЗначение.Ключ);
	КонецЦикла;

	Возврат СписокКластеров;
	
КонецФункции

Процедура Подключить() Экспорт
	ОбновитьДанные(Истина);
КонецПроцедуры

Процедура ИспользоватьВерсию(Знач ВерсияПлатформы) Экспорт

	ПутьКлиентаАдминистрирования = ПолучитьПутьКRAC(, ВерсияПлатформы);

КонецПроцедуры

Процедура ОбновитьДанные(Знач ОбновитьПринудительно = Ложь) Экспорт
	
	Если ИндексЛокальныхКластеровОбновлен
		И НЕ ОбновитьПринудительно Тогда
		Возврат
	КонецЕсли;
	
	ОбновитьИндексЛокальныхКластеров();

	МассивКластеров = Новый Массив;

	Для каждого Кластер Из ИндексЛокальныхКластеров Цикл
		МассивКластеров.Добавить(Кластер.Ключ);
	КонецЦикла;
	
	Для каждого Кластер Из МассивКластеров Цикл
		ОбновитьИндексИнформационныхБаз(Кластер, ОбновитьПринудительно);
	КонецЦикла;
	
КонецПроцедуры

Функция СписокИнформационныхБаз(Знач ИдентификаторКластера = Неопределено) Экспорт
	
	ТаблицаИнформационныхБазы = Новый ТаблицаЗначений();
	ТаблицаИнформационныхБазы.Колонки.Добавить("Имя");
	ТаблицаИнформационныхБазы.Колонки.Добавить("UID");
	ТаблицаИнформационныхБазы.Колонки.Добавить("Кластер");

	Для каждого КлючЗначение Из ИндексИнформационныхБаз Цикл

		ОписаниеИБ = КлючЗначение.Значение;

		Если ЗначениеЗаполнено(ИдентификаторКластера)
			И Не ИдентификаторКластера = ОписаниеИБ.Кластер Тогда
			Продолжить;
		КонецЕсли;

		ЗаполнитьЗначенияСвойств(ТаблицаИнформационныхБазы.Добавить(), ОписаниеИБ);
	КонецЦикла;

	Возврат ТаблицаИнформационныхБазы;

КонецФункции

Функция СписокСеансовИнформационнойБазы(Знач ИнформационнаяБаза) Экспорт

	ОписаниеИБ = ИндексИнформационныхБаз[ИнформационнаяБаза];

	Если ОписаниеИБ = Неопределено Тогда
		Возврат ПолучитьТаблицуСеансов();
	КонецЕсли;
	
	Возврат СписокСеансовКластера(ОписаниеИБ.Кластер, ОписаниеИБ.UID);
	
КонецФункции

Функция СписокСеансовКластера(Знач ИдентификаторКластера, Знач ИнформационнаяБаза = Неопределено) Экспорт
	
	ТаблицаСеансов = ПолучитьТаблицуСеансов();
	
	Параметры = СтандартныеПараметрыЗапуска();
	Параметры.Добавить("session");
	Параметры.Добавить("list");

	Если ЗначениеЗаполнено(ИнформационнаяБаза) Тогда
		Параметры.Добавить(КлючИдентификатораБазы(ИнформационнаяБаза));
	КонецЕсли;

	Параметры.Добавить(КлючИдентификатораКластера(ИдентификаторКластера));

	СписокСеансовИБ = ВыполнитьКоманду(Параметры);	
	
	Данные = РазобратьПотокВывода(СписокСеансовИБ);
	
	Для Каждого Элемент Из Данные Цикл
		
		Если НРег(Элемент["app-id"]) = "ras"
			ИЛИ НРег(Элемент["app-id"]) = "srvrconsole" Тогда
			Продолжить;
		КонецЕсли;

		ТекСтрока = ТаблицаСеансов.Добавить();
		ТекСтрока.Идентификатор = Элемент["session"];
		ТекСтрока.Пользователь  = Элемент["user-name"];
		ТекСтрока.Приложение    = Элемент["app-id"];
		ТекСтрока.НомерСеанса   = Элемент["session-id"];
		ТекСтрока.ИнформационнаяБаза = Элемент["infobase"];
		ТекСтрока.Кластер = ИдентификаторКластера;
		
	КонецЦикла;
	
	Возврат ТаблицаСеансов;
	
КонецФункции

Функция СписокСоединенийИнформационнойБазы(Знач ИнформационнаяБаза) Экспорт
	
	ТаблицаСоединений = ПолучитьСоединенийРабочегоПроцесса();
	
	Параметры = СтандартныеПараметрыЗапуска();
	Параметры.Добавить("connection");
	Параметры.Добавить("list");
	
	ОписаниеИБ = ИндексИнформационныхБаз[ИнформационнаяБаза];

	Если ОписаниеИБ = Неопределено Тогда
		Возврат ТаблицаСоединений;
	КонецЕсли;
	
	Параметры.Добавить(КлючИдентификатораБазы(ИнформационнаяБаза));

	ИдентификаторКластера = ОписаниеИБ.Кластер;

	Параметры.Добавить(КлючИдентификатораКластераБазы(ИнформационнаяБаза));

	СписокСоединенийИБ = ВыполнитьКоманду(Параметры);	
	
	Данные = РазобратьПотокВывода(СписокСоединенийИБ);
	
	Для Каждого Элемент Из Данные Цикл
		
		Если НРег(Элемент["application"]) = "ras" Тогда
			Продолжить;
		КонецЕсли;

		ТекСтрока = ТаблицаСоединений.Добавить();
		ТекСтрока.Идентификатор 		= Элемент["connection"];
		ТекСтрока.Процесс  				= Элемент["process"];
		ТекСтрока.Приложение    		= Элемент["application"];
		ТекСтрока.НомерСоединения   	= Элемент["conn-id"];
		ТекСтрока.ИнформационнаяБаза 	= Элемент["infobase"];
		ТекСтрока.Кластер 				= ИдентификаторКластера;
		
	КонецЦикла;
	
	Возврат ТаблицаСоединений;
	
КонецФункции

Процедура ОтключитьСеансыИнформационнойБазы(Знач ИнформационнаяБаза, Знач Фильтр = Неопределено) Экспорт

	Лог.Отладка("Отключаю существующие сеансы");

	СеансыБазы = СписокСеансовИнформационнойБазы(ИнформационнаяБаза);
	
	Для Каждого Сеанс Из СеансыБазы Цикл
		
		Если ВФильтре(Сеанс, Фильтр) Тогда
			Продолжить;
		КонецЕсли;
		
		Попытка
			ОтключитьСеанс(Сеанс.Идентификатор, Сеанс.Кластер);
		Исключение
			Лог.Ошибка(ОписаниеОшибки());
		КонецПопытки;
	КонецЦикла;
	
КонецПроцедуры

Процедура ОтключитьСоединенияИнформационнойБазы(Знач ИнформационнаяБаза, Знач Фильтр = Неопределено) Экспорт

	Лог.Отладка("Отключаю существующие соединения");

	СоединенияБазы = СписокСоединенийИнформационнойБазы(ИнформационнаяБаза);
	
	Для Каждого Соединение Из СоединенияБазы Цикл
		
		Если ВФильтре(Соединение, Фильтр) Тогда
			Продолжить;
		КонецЕсли;
		
		Попытка
			ОтключитьСоединение(Соединение.Идентификатор, Соединение.Процесс, Соединение.Кластер);
		Исключение
			Лог.Ошибка(ОписаниеОшибки());
		КонецПопытки;
	КонецЦикла;
	
КонецПроцедуры

Функция ПолучитьПодробноеОписаниеИнформационнойБазы(Знач ИнформационнаяБаза, Знач АвторизацияИБ = Неопределено) Экспорт
	Параметры = СтандартныеПараметрыЗапуска();
	Параметры.Добавить("infobase");
	Параметры.Добавить("info");

	Параметры.Добавить(КлючИдентификатораБазы(ИнформационнаяБаза));
	Параметры.Добавить(КлючИдентификатораКластераБазы(ИнформационнаяБаза));

	Если Не АвторизацияИБ = Неопределено Тогда

		Если ЗначениеЗаполнено(АвторизацияИБ.Пользователь) Тогда
			Параметры.Добавить(СтрШаблон("--infobase-user=%1", ОбернутьВКавычки(АвторизацияИБ.Пользователь)));
			Если ЗначениеЗаполнено(АвторизацияИБ.Пароль) Тогда
				Параметры.Добавить(СтрШаблон("--infobase-pwd=%2", ОбернутьВКавычки(АвторизацияИБ.Пароль)));
			КонецЕсли;	
		КонецЕсли;
	Иначе

		ДобавитьПараметрыАвторизацииИнформационнойБазы(Параметры, ИнформационнаяБаза);		
	
	КонецЕсли;

	ПотокДанных = ВыполнитьКоманду(Параметры);

	МассивДанных = РазобратьПотокВывода(ПотокДанных);
	ПодробноеОписаниеИБ = Новый Структура();
	
	Если МассивДанных.Количество() = 0 Тогда
		Возврат ПодробноеОписаниеИБ;
	КонецЕсли;
	Данные = МассивДанных[0];

	ОписаниеИБ = ИндексИнформационныхБаз[ИнформационнаяБаза];

	ПодробноеОписаниеИБ.Вставить("Кластер", ОписаниеИБ.Кластер);
	ПодробноеОписаниеИБ.Вставить("Наименование", Данные["name"]);
	ПодробноеОписаниеИБ.Вставить("Описание", Данные["descr"]);
	ПодробноеОписаниеИБ.Вставить("ТипСУБД", Данные["dbms"]);
	ПодробноеОписаниеИБ.Вставить("АдресСервераСУБД", Данные["db-server"]);
	ПодробноеОписаниеИБ.Вставить("БазаДанныхСУБД", Данные["db-name"]);
	ПодробноеОписаниеИБ.Вставить("ПользовательСУБД", Данные["db-user"]);
	ПодробноеОписаниеИБ.Вставить("ЗапретРегламентныхЗаданий", ?(Данные["scheduled-jobs-deny"] = "on", Истина, Ложь));
	ПодробноеОписаниеИБ.Вставить("ЗапретПодключенияСессий", ?(Данные["sessions-deny"] = "on", Истина, Ложь));

	Возврат ПодробноеОписаниеИБ;

КонецФункции

Процедура ОтключитьСеанс(Знач ИдентификаторСеанса, Знач ИдентификаторКластер) Экспорт

	Параметры = СтандартныеПараметрыЗапуска();
	Параметры.Добавить("session");
	Параметры.Добавить("terminate");
	Параметры.Добавить(КлючИдентификатораКластера(ИдентификаторКластер));

	Параметры.Добавить(СтрШаблон("--session=""%1""", ИдентификаторСеанса));
	
	ВыполнитьКоманду(Параметры);

КонецПроцедуры

Процедура ОтключитьСоединение(Знач ИдентификаторСоединения, Знач ИдентификаторПроцесса, Знач ИдентификаторКластер) Экспорт

	Параметры = СтандартныеПараметрыЗапуска();
	Параметры.Добавить("connection");
	Параметры.Добавить("disconnect");
	Параметры.Добавить(КлючИдентификатораКластера(ИдентификаторКластер));
	Параметры.Добавить(СтрШаблон("--process=%1", ИдентификаторПроцесса));
	Параметры.Добавить(СтрШаблон("--connection=%1", ИдентификаторСоединения));
	
	ВыполнитьКоманду(Параметры);

КонецПроцедуры

Процедура СнятьБлокировкуИнформационнойБазы(Знач ИнформационнаяБаза, 
											Знач ОставитьБлокировкуРеглЗаданий = Ложь,
											Знач АвторизацияИБ = Неопределено) Экспорт
	
	ПараметрыИнформационнойБазы = Новый Соответствие();

	Если Не АвторизацияИБ = Неопределено Тогда
		
		Если ЗначениеЗаполнено(АвторизацияИБ.Пользователь) Тогда
			ПараметрыИнформационнойБазы.Вставить("--infobase-user", ОбернутьВКавычки(АвторизацияИБ.Пользователь));
			Если ЗначениеЗаполнено(АвторизацияИБ.Пароль) Тогда
				ПараметрыИнформационнойБазы.Добавить("--infobase-pwd", ОбернутьВКавычки(АвторизацияИБ.Пароль));
			КонецЕсли;	
		КонецЕсли;
	
	КонецЕсли;

	ПараметрыИнформационнойБазы.Вставить("--sessions-deny", "off");

	Если НЕ ОставитьБлокировкуРеглЗаданий Тогда
		ПараметрыИнформационнойБазы.Вставить("--scheduled-jobs-deny", "off");	
	КонецЕсли;

	ПараметрыИнформационнойБазы.Вставить("--denied-message", ОбернутьВКавычки(""));
	ПараметрыИнформационнойБазы.Вставить("--permission-code", ОбернутьВКавычки(""));
	ПараметрыИнформационнойБазы.Вставить("--denied-from", ОбернутьВКавычки(""));
	ПараметрыИнформационнойБазы.Вставить("--denied-to", ОбернутьВКавычки(""));
	
	ОбновитьПараметрыИнформационнойБазы(ИнформационнаяБаза, ПараметрыИнформационнойБазы);	

КонецПроцедуры

Функция НайтиИнформационнуюБазу(Знач ИмяБазы) Экспорт
	
	ОписаниеИБ = ИндексИнформационныхБаз[ИмяБазы];
	
	Если ОписаниеИБ = Неопределено Тогда
		Возврат "";
	КонецЕсли;

	ИдентификаторБазы = ОписаниеИБ.UID;

	Возврат ИдентификаторБазы;

КонецФункции

Функция СоздатьИнформационнуюБазу(Знач Кластер,
									Знач Наименование, 
									Знач ТипСУБД,
									Знач АдресСервераСУБД,
									Знач БазаДанныхСУБД,
									Знач ПользовательСУБД = "",
									Знач ПарольСУБД = "",
									Знач ЛокальИБ = "RU",
									Знач СмещениеДат = 0,
									Знач Описание = "",
									Знач БлокировкаРеглЗаданий = Ложь,
									Знач СоздатьБазуДанных = Ложь
									) Экспорт

	Параметры = СтандартныеПараметрыЗапуска();
	Параметры.Добавить("infobase");
	Параметры.Добавить("create");

	Параметры.Добавить(КлючИдентификатораКластера(Кластер));

	Параметры.Добавить("--name=" + Наименование);

	Параметры.Добавить("--dbms=" + ТипСУБД);
	Параметры.Добавить("--db-server=" + АдресСервераСУБД);
	Параметры.Добавить("--db-name=" + БазаДанныхСУБД);
	
	Если ЗначениеЗаполнено(ПользовательСУБД) Тогда
		Параметры.Добавить("--db-user=" + ПользовательСУБД);

		Если ЗначениеЗаполнено(ПарольСУБД) Тогда
			Параметры.Добавить("--db-pwd=" + ПарольСУБД);
		КонецЕсли;

	КонецЕсли;

	Если СоздатьБазуДанных Тогда
		Параметры.Добавить("--create-database");
	КонецЕсли;

	Параметры.Добавить("--locale=" + ЛокальИБ);
	Параметры.Добавить("--scheduled-jobs-deny=" + ?(БлокировкаРеглЗаданий, "on", "off"));

	Если ЗначениеЗаполнено(Описание) Тогда
		Параметры.Добавить("--descr=" + ОбернутьВКавычки(Описание));
	КонецЕсли;
			
	Если ЗначениеЗаполнено(СмещениеДат) Тогда
		Параметры.Добавить("--date-offset=" + Строка(СмещениеДат));
	КонецЕсли;

	Данные = РазобратьПотокВывода(ВыполнитьКоманду(Параметры));

	ИдентификаторБазы = Данные[0]["infobase"];
	ОписаниеИБ = ОписаниеИнформационнойБазы(Наименование, ИдентификаторБазы, Кластер);
	ИндексИнформационныхБаз.Вставить(ИдентификаторБазы, ОписаниеИБ);
	ИндексИнформационныхБаз.Вставить(Наименование, ОписаниеИБ);

	Возврат ИдентификаторБазы;

КонецФункции

Процедура УдалитьИнформационнуюБазу(Знач ИнформационнаяБаза,
									Знач ОчиститьБазуДанных = Ложь,
									Знач УдалитьБазуДанных = Ложь,
									Знач АвторизацияИБ = Неопределено) Экспорт
	
	Параметры = СтандартныеПараметрыЗапуска();
	Параметры.Добавить("infobase");
	Параметры.Добавить("drop");

	Если УдалитьБазуДанных Тогда
		Параметры.Добавить("--drop-database");
	ИначеЕсли ОчиститьБазуДанных Тогда
		Параметры.Добавить("--clear-database");
	КонецЕсли;

	Параметры.Добавить(КлючИдентификатораБазы(ИнформационнаяБаза));
	Параметры.Добавить(КлючИдентификатораКластераБазы(ИнформационнаяБаза));

	Если Не АвторизацияИБ = Неопределено Тогда

		Если ЗначениеЗаполнено(АвторизацияИБ.Пользователь) Тогда
			Параметры.Добавить(СтрШаблон("--infobase-user=%1", ОбернутьВКавычки(АвторизацияИБ.Пользователь)));
			Если ЗначениеЗаполнено(АвторизацияИБ.Пароль) Тогда
				Параметры.Добавить(СтрШаблон("--infobase-pwd=%2", ОбернутьВКавычки(АвторизацияИБ.Пароль)));
			КонецЕсли;	
		КонецЕсли;
	Иначе

		ДобавитьПараметрыАвторизацииИнформационнойБазы(Параметры, ИнформационнаяБаза);		
	
	КонецЕсли;

	ВыполнитьКоманду(Параметры);

	ОписаниеИБ = ИндексИнформационныхБаз[ИнформационнаяБаза];
	
	Если НЕ ОписаниеИБ = Неопределено Тогда
		
		ИндексИнформационныхБаз.Удалить(ОписаниеИБ.UID);
		ИндексИнформационныхБаз.Удалить(ОписаниеИБ.Имя);

	КонецЕсли;

КонецПроцедуры

Процедура БлокировкаИнформационнойБазы(Знач ИнформационнаяБаза, 
										Знач СообщениеОБлокировке = "",
										Знач КлючРазрешенияЗапуска = "",
										Знач ДатаНачалаБлокировки = Неопределено
										Знач ДатаОкончанияБлокировки = Неопределено,
										Знач БлокировкаРеглЗаданий = Ложь,
										Знач АвторизацияИБ = Неопределено) Экспорт
	
	ПараметрыИнформационнойБазы = Новый Соответствие();

	Если Не АвторизацияИБ = Неопределено Тогда
		
		Если ЗначениеЗаполнено(АвторизацияИБ.Пользователь) Тогда
			ПараметрыИнформационнойБазы.Вставить("--infobase-user", ОбернутьВКавычки(АвторизацияИБ.Пользователь));
			Если ЗначениеЗаполнено(АвторизацияИБ.Пароль) Тогда
				ПараметрыИнформационнойБазы.Добавить("--infobase-pwd", ОбернутьВКавычки(АвторизацияИБ.Пароль));
			КонецЕсли;	
		КонецЕсли;
	
	КонецЕсли;

	ПараметрыИнформационнойБазы.Вставить("--sessions-deny", "on");

	Если БлокировкаРеглЗаданий Тогда
		ПараметрыИнформационнойБазы.Вставить("--scheduled-jobs-deny=", "on");	
	КонецЕсли;

	Если ЗначениеЗаполнено(СообщениеОБлокировке) Тогда
		ПараметрыИнформационнойБазы.Вставить("--denied-message", ОбернутьВКавычки(СообщениеОБлокировке));
	КонецЕсли;

	Если ЗначениеЗаполнено(КлючРазрешенияЗапуска) Тогда
		ПараметрыИнформационнойБазы.Вставить("--permission-code", ОбернутьВКавычки(КлючРазрешенияЗапуска));
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ДатаНачалаБлокировки) Тогда
		ПараметрыИнформационнойБазы.Вставить("--denied-from", ФорматДатыISO(ДатаНачалаБлокировки));
	КонецЕсли;

	Если ЗначениеЗаполнено(ДатаОкончанияБлокировки) Тогда
		ПараметрыИнформационнойБазы.Вставить("--denied-to", ФорматДатыISO(ДатаОкончанияБлокировки));
	КонецЕсли;

	ОбновитьПараметрыИнформационнойБазы(ИнформационнаяБаза, ПараметрыИнформационнойБазы);

КонецПроцедуры

Процедура ОбновитьПараметрыИнформационнойБазы(Знач ИнформационнаяБаза, Знач ПараметрыИнформационнойБазы)

	Параметры = СтандартныеПараметрыЗапуска();
	Параметры.Добавить("infobase");
	Параметры.Добавить("update");

	Параметры.Добавить(КлючИдентификатораБазы(ИнформационнаяБаза));
	Параметры.Добавить(КлючИдентификатораКластераБазы(ИнформационнаяБаза));

	Если ПараметрыИнформационнойБазы["--infobase-user"] = Неопределено Тогда
		ДобавитьПараметрыАвторизацииИнформационнойБазы(Параметры, ИнформационнаяБаза);		
	КонецЕсли;

	Для каждого КлючЗначение Из ПараметрыИнформационнойБазы Цикл
		Параметры.Добавить(СтрШаблон("%1=%2", КлючЗначение.Ключ, КлючЗначение.Значение));		
	КонецЦикла;

	ВыполнитьКоманду(Параметры)
	
КонецПроцедуры

Функция ВыполнитьКоманду(Знач ПараметрыКоманды) Экспорт

	КомандаВыполнения = ПутьКлиентаАдминистрирования;
	АдресСервераАдминистрирования = СтрШаблон("%1:%2", АдресСервера, ПортСервера);
	
	Команда = Новый Команда();
	Команда.УстановитьКоманду(КомандаВыполнения);
	Команда.ДобавитьПараметры(ПараметрыКоманды);

	Если ЕстьПараметр(ПараметрыКоманды, "--cluster") Тогда
		ДобавитьПараметрыАвторизацииКластера(ПараметрыКоманды);
	КонецЕсли;

	Команда.ДобавитьПараметр(АдресСервераАдминистрирования);
	Команда.УстановитьИсполнениеЧерезКомандыСистемы(Ложь);
	КодВозврата = Команда.Исполнить();

	Если КодВозврата <> 0 Тогда
		ВызватьИсключение Команда.ПолучитьВывод();
	КонецЕсли;

	Возврат Команда.ПолучитьВывод();
	
КонецФункции

#Область Поиск_версии_платформы

#КонецОбласти

#Область Вспомогательные_процедуры_и_функции

Процедура СброситьИндексы()
	
	ИндексЛокальныхКластеров = Новый Соответствие();
	ИндексИнформационныхБаз = Новый Соответствие();
	ИндексЛокальныхКластеровОбновлен = Ложь;

КонецПроцедуры

Функция ПолучитьСоединенийРабочегоПроцесса()
		
	ТаблицаСоединенийРабочегоПроцесса = Новый ТаблицаЗначений;
	ТаблицаСоединенийРабочегоПроцесса.Колонки.Добавить("Идентификатор");
	ТаблицаСоединенийРабочегоПроцесса.Колонки.Добавить("Приложение");
	ТаблицаСоединенийРабочегоПроцесса.Колонки.Добавить("Процесс");
	ТаблицаСоединенийРабочегоПроцесса.Колонки.Добавить("НомерСоединения");
	ТаблицаСоединенийРабочегоПроцесса.Колонки.Добавить("ИнформационнаяБаза");
	ТаблицаСоединенийРабочегоПроцесса.Колонки.Добавить("Кластер");
	
	Возврат ТаблицаСоединенийРабочегоПроцесса;

КонецФункции

Функция ПолучитьТаблицуСеансов()
	
	ТаблицаСеансов = Новый ТаблицаЗначений;
	ТаблицаСеансов.Колонки.Добавить("Идентификатор");
	ТаблицаСеансов.Колонки.Добавить("Приложение");
	ТаблицаСеансов.Колонки.Добавить("Пользователь");
	ТаблицаСеансов.Колонки.Добавить("НомерСеанса");
	ТаблицаСеансов.Колонки.Добавить("ИнформационнаяБаза");
	ТаблицаСеансов.Колонки.Добавить("Кластер");
	
	Возврат ТаблицаСеансов;

КонецФункции

Функция ОписаниеИнформационнойБазы(Знач ИмяБазы, Знач UID, Знач Кластер)
	
	ОписаниеИБ = Новый Структура();
	ОписаниеИБ.Вставить("Имя", ИмяБазы);
	ОписаниеИБ.Вставить("UID", UID);
	ОписаниеИБ.Вставить("Кластер", Кластер);

	Возврат ОписаниеИБ;

КонецФункции

Функция ФорматДатыISO(Знач ВходящаяДата)
	
	ФорматДаты = "ДФ='yyyy-MM-ddTHH:mm:ss'";

	Возврат Формат(ВходящаяДата, ФорматДаты);

КонецФункции

Функция ОбернутьВКавычки(Знач Строка) Экспорт

	Результат = """" + Строка + """";

	Возврат Результат;

КонецФункции

Функция ПолучитьПутьКRAC(ТекущийПуть, Знач ВерсияПлатформы = "")
	
	Если НЕ ПустаяСтрока(ТекущийПуть) Тогда 
		ФайлУтилиты = Новый Файл(ТекущийПуть);
		Если ФайлУтилиты.Существует() Тогда 
			Лог.Отладка("Текущая версия rac " + ФайлУтилиты.ПолноеИмя);
			Возврат ФайлУтилиты.ПолноеИмя;
		КонецЕсли;
	КонецЕсли;
	
	Если ПустаяСтрока(ВерсияПлатформы) Тогда 
		ВерсияПлатформы = "8.3";
	КонецЕсли;
	
	Конфигуратор = Новый УправлениеКонфигуратором;
	ПутьКПлатформе = Конфигуратор.ПолучитьПутьКВерсииПлатформы(ВерсияПлатформы);
	Лог.Отладка("Используемый путь для поиска rac " + ПутьКПлатформе);
	КаталогУстановки = Новый Файл(ПутьКПлатформе);
	Лог.Отладка(КаталогУстановки.Путь);
	
	
	ИмяФайла = ?(ЭтоWindows, "rac.exe", "rac");
	
	ФайлУтилиты = Новый Файл(ОбъединитьПути(Строка(КаталогУстановки.Путь), ИмяФайла));
	Если ФайлУтилиты.Существует() Тогда 
		Лог.Отладка("Текущая версия rac " + ФайлУтилиты.ПолноеИмя);
		Возврат ФайлУтилиты.ПолноеИмя;
	КонецЕсли;
	
	Возврат ТекущийПуть;
	
КонецФункции

Процедура ДобавитьПараметрыАвторизацииКластера(Знач ПараметрыЗапуска)
	
	Если ЗначениеЗаполнено(АвторизацияАдминистратораКластера.Пользователь) Тогда
		ПараметрыЗапуска.Добавить(СтрШаблон("--cluster-user=""%1""", АвторизацияАдминистратораКластера.Пользователь));
		Если ЗначениеЗаполнено(АвторизацияАдминистратораКластера.Пароль) Тогда
			ПараметрыЗапуска.Добавить(СтрШаблон("--cluster-pwd=""%1""", АвторизацияАдминистратораКластера.Пароль));
		КонецЕсли;	
	КонецЕсли;

КонецПроцедуры

Процедура ДобавитьПараметрыАвторизацииИнформационнойБазы(Знач ПараметрыЗапуска, Знач ИнформационнаяБаза)
	
	АвторизацияИБ = ИндексАвторизацийИнформационныхБаз[ИнформационнаяБаза];
	
	Если АвторизацияИБ = Неопределено Тогда
		АвторизацияИБ = ИндексАвторизацийИнформационныхБаз[ИмяКлючаВсеБазы];
	КонецЕсли;

	Если АвторизацияИБ = Неопределено Тогда
		Возврат;
	КонецЕсли;

	Если ЗначениеЗаполнено(АвторизацияИБ.Пользователь) Тогда
		ПараметрыЗапуска.Добавить(СтрШаблон("--infobase-user=""%1""", АвторизацияИБ.Пользователь));
		Если ЗначениеЗаполнено(АвторизацияИБ.Пароль) Тогда
			ПараметрыЗапуска.Добавить(СтрШаблон("--infobase-pwd=""%1""", АвторизацияИБ.Пароль));
		КонецЕсли;	
	КонецЕсли;

КонецПроцедуры

Функция СтандартныеПараметрыЗапуска()
	
	ПараметрыЗапуска = Новый Массив;
	
	Возврат ПараметрыЗапуска; 

КонецФункции

Функция КлючИдентификатораКластера(Знач Кластер)

	ИдентификаторКластера = Кластер;

	Возврат СтрШаблон("--cluster=%1", ИдентификаторКластера);
	
КонецФункции

Функция КлючИдентификатораБазы(Знач ИнформационнаяБаза)

	ОписаниеИБ = ИндексИнформационныхБаз[ИнформационнаяБаза];

	Если ОписаниеИБ = Неопределено Тогда
		ВызватьИсключение "Не найдена информационная база: " + ИнформационнаяБаза;
	КонецЕсли;
	
	Возврат СтрШаблон("--infobase=%1", ОписаниеИБ.UID);
	
КонецФункции

Функция КлючИдентификатораКластераБазы(Знач ИнформационнаяБаза)

	ОписаниеИБ = ИндексИнформационныхБаз[ИнформационнаяБаза];

	Если ОписаниеИБ = Неопределено Тогда
		ВызватьИсключение "Не найдена информационная база: " + ИнформационнаяБаза;
	КонецЕсли;

	Возврат СтрШаблон("--cluster=%1", ОписаниеИБ.Кластер);
	
КонецФункции

Функция ВФильтре(Данные, Фильтр)

	Результат = Истина;

	Если Не ЗначениеЗаполнено(Фильтр) Тогда
		Возврат Результат;
	КонецЕсли;

	Результат = Результат И ПараметраВФильтре(Фильтр, "Приложение", Данные.Приложение);
	Результат = Результат И ПараметраВФильтре(Фильтр, "Пользователь", Данные.Пользователь);

	Возврат Результат;
	
КонецФункции

Функция ПараметраВФильтре(Фильтр, ИмяФильтра, ПроверяемоеЗначение)
	
	Если Не ЗначениеЗаполнено(Фильтр) 
		Или Не Фильтр.Свойство(ИмяФильтра) Тогда
		Возврат Истина;
	КонецЕсли;
	
	ЗначенияФильтра = Фильтр[ИмяФильтра];
	Для Каждого ТекЗначение Из ЗначенияФильтра Цикл
		ВФильтре = ВРег(ТекЗначение)=ВРег(ПроверяемоеЗначение);
		Если ВФильтре Тогда
			Возврат Истина;
		КонецЕсли;
	КонецЦикла;

	Возврат Ложь;

КонецФункции

Процедура ОбновитьИндексИнформационныхБаз(Знач Кластер, Знач Принудительно = Ложь) 
	
	Если Не Принудительно 
		И Не ИндексЛокальныхКластеров[Кластер] = Неопределено Тогда
		Возврат;
	КонецЕсли;

	Лог.Отладка("Получаю список баз кластера");

	Параметры = СтандартныеПараметрыЗапуска();
	Параметры.Добавить("infobase");
	Параметры.Добавить("summary");
	Параметры.Добавить("list");
	Параметры.Добавить(КлючИдентификатораКластера(Кластер));

	СписокБазВКластере = СокрЛП(ВыполнитьКоманду(Параметры));

	Данные = РазобратьПотокВывода(СписокБазВКластере);
	
	ОчиститьИндексИнформационныхБазы(Кластер);
	
	ИндексИБКластера = Новый Соответствие();

	Для Каждого Элемент Из Данные Цикл
		
		ОписаниеИБ = ОписаниеИнформационнойБазы(Элемент["name"], Элемент["infobase"], Кластер);

		Лог.Отладка("База <%1> (%2) добавлена в индекс", ОписаниеИБ.Имя,  ОписаниеИБ.UID);
		
		ИндексИнформационныхБаз.Вставить(ОписаниеИБ.Имя, ОписаниеИБ);
		ИндексИнформационныхБаз.Вставить(ОписаниеИБ.UID, ОписаниеИБ);
		ИндексИБКластера.Вставить(ОписаниеИБ.UID, ОписаниеИБ);

	КонецЦикла;

	ИндексЛокальныхКластеров[Кластер] = ИндексИБКластера;

КонецПроцедуры

Процедура ОчиститьИндексИнформационныхБазы(Знач Кластер)
	
	ИндексИБКластера = ИндексЛокальныхКластеров[Кластер];

	Если ИндексИБКластера = Неопределено Тогда
		Возврат;
	КонецЕсли;

	Для каждого КлючЗначение Из ИндексИБКластера Цикл
		ОписаниеИБ = КлючЗначение.Значение;
		ИндексИнформационныхБаз.Удалить(ОписаниеИБ.Имя);
		ИндексИнформационныхБаз.Удалить(ОписаниеИБ.UID);
	КонецЦикла;

КонецПроцедуры

Процедура ОбновитьИндексЛокальныхКластеров()
	
	Лог.Отладка("Получаю список кластеров");
	ИндексЛокальныхКластеров = Новый Соответствие();

	Параметры = СтандартныеПараметрыЗапуска();
	Параметры.Добавить("cluster");
	Параметры.Добавить("list");

	СписокКластеров = ВыполнитьКоманду(Параметры);
	
	Данные = РазобратьПотокВывода(СписокКластеров);

	Для Каждого Элемент Из Данные Цикл
		
		UIDКластера = Элемент["cluster"];

		Лог.Отладка("Локальный кластер <%1> добавлена в индекс", UIDКластера);
		
		ИндексЛокальныхКластеров.Вставить(UIDКластера);

	КонецЦикла;

	ИндексКластераОбновлен = Истина;

КонецПроцедуры

Функция СтрокаЗапускаКлиента()
	
	Перем ПутьКлиентаАдминистрирования;
	
	Если ЭтоWindows Тогда 
		ПутьКлиентаАдминистрирования = ОбернутьВКавычки(ПутьКлиентаАдминистрирования);
	Иначе
		ПутьКлиентаАдминистрирования = ПутьКлиентаАдминистрирования;
	КонецЕсли;
	
	Возврат ПутьКлиентаАдминистрирования;
	
КонецФункции

Функция ИспользуетсяАвторизацияКластера()

	Возврат ЗначениеЗаполнено(АвторизацияАдминистратораКластера.Пользователь);
	
КонецФункции

Функция ЕстьПараметр(ПараметрыКоманды, ИмяПараметра)
	
	Для каждого Параметр Из ПараметрыКоманды Цикл
		
		Если СтрНайти(Параметр, ИмяПараметра) > 0 Тогда
			Возврат Истина;
		КонецЕсли
	КонецЦикла;

	Возврат Ложь;

КонецФункции

Функция РазобратьПотокВывода(Знач Поток)
	
	ТД = Новый ТекстовыйДокумент;
	ТД.УстановитьТекст(Поток);
	
	СписокОбъектов = Новый Массив;
	ТекущийОбъект = Неопределено;
	
	Для Сч = 1 По ТД.КоличествоСтрок() Цикл
		
		Текст = ТД.ПолучитьСтроку(Сч);
		Если ПустаяСтрока(Текст) или ТекущийОбъект = Неопределено Тогда
			Если ТекущийОбъект <> Неопределено и ТекущийОбъект.Количество() = 0 Тогда
				Продолжить; // очередная пустая строка подряд
			КонецЕсли;
			 
			ТекущийОбъект = Новый Соответствие;
			СписокОбъектов.Добавить(ТекущийОбъект);
		КонецЕсли;
		
		СтрокаРазбораИмя      = "";
		СтрокаРазбораЗначение = "";
		
		Если РазобратьНаКлючИЗначение(Текст, СтрокаРазбораИмя, СтрокаРазбораЗначение) Тогда
			ТекущийОбъект[СтрокаРазбораИмя] = СтрокаРазбораЗначение;
		КонецЕсли;
		
	КонецЦикла;
	
	Если ТекущийОбъект <> Неопределено и ТекущийОбъект.Количество() = 0 Тогда
		СписокОбъектов.Удалить(СписокОбъектов.ВГраница());
	КонецЕсли; 
	
	Возврат СписокОбъектов;
	
КонецФункции

Функция РазобратьНаКлючИЗначение(Знач СтрокаРазбора, Ключ, Значение)
	
	ПозицияРазделителя = Найти(СтрокаРазбора, ":");
	Если ПозицияРазделителя = 0 Тогда
		Возврат Ложь;
	КонецЕсли;
	
	Ключ     = СокрЛП(Лев(СтрокаРазбора, ПозицияРазделителя - 1));
	Значение = СокрЛП(Сред(СтрокаРазбора, ПозицияРазделителя + 1));
	
	Возврат Истина;
	
КонецФункции

Процедура ПриСозданииОбъекта()

	Лог = Логирование.ПолучитьЛог("oscript.lib.v8rac");
	// Лог = Логирование.ПолучитьЛог("oscript.lib.commands");
	// Лог.УстановитьУровень(УровниЛога.Отладка);

	СистемнаяИнформация = Новый СистемнаяИнформация;
	ЭтоWindows = Найти(НРег(СистемнаяИнформация.ВерсияОС), "windows") > 0;
	ИндексЛокальныхКластеровОбновлен = Ложь;
	
	АвторизацияАдминистратораКластера = Новый Структура("Пользователь, Пароль");

	ИндексИнформационныхБаз = Новый Соответствие();
	ИндексЛокальныхКластеров = Новый Соответствие();
	ИндексАвторизацийИнформационныхБаз = Новый Соответствие();

	ПутьКлиентаАдминистрирования = ПолучитьПутьКRAC(, "8.3");

	ИмяКлючаВсеБазы = "all";

КонецПроцедуры

#КонецОбласти

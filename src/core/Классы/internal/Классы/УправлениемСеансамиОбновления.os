#Использовать logos

Перем ВерсияПлатформы;
Перем ПараметрыКластера;

Перем УправлениеКластером;

Перем АдресСервера;
Перем ПодключениеКСервернойбазе;
Перем ПараметрыПодключения;
Перем ПараметрыБлокировкиСеансов;
Перем АвторизацияВИнформационнойБазе;

Перем ИдентификаторИнформационнойбаза;

Перем ЭтоФайловаяБаза;

Перем НачалоБлокировкиСеансов;
Перем ОкончаниеБлокировкиСеансов;
Перем СрокОжиданияЗавершенияСеансов;

Перем Лог;

Перем ЧислоПопыток;
Перем ФильтрСеансов;
Перем ИмяБазы;

Перем ИдентификаторКластера;

Перем ЭтоWindows;

Процедура УстановитьНастройки(НастройкиОбновления) Экспорт

	ЭтоФайловаяБаза = НастройкиОбновления.ЭтоФайловаяБаза();
	ВерсияПлатформы = "8.3";//НастройкиОбновления.ВерсияПлатформы(); // Всегда ставим пока 8.3
	ПараметрыКластера = НастройкиОбновления.ПараметрыКластера;
	ПараметрыПодключения = НастройкиОбновления.ПараметрыПодключения;
	ПараметрыБлокировкиСеансов = НастройкиОбновления.ПараметрыБлокировкиСеансов;
	АвторизацияВИнформационнойБазе = НастройкиОбновления.АвторизацияВИнформационнойБазе();
	ЧислоПопыток = 1;

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

	УправлениеКластером = Новый Структура("АдресСервера, ПользовательКластера, ПарольКластера",
						СтрШаблон("%1:%2", АдресСервера, ПортСервера), ПользовательКластера, ПарольКластера);


	ПутьКлиентаАдминистрирования = ПолучитьПутьКRAC(ПараметрыКластера.ПутьКлиентаАдминистрирования, ВерсияПлатформы);
	УправлениеКластером.Вставить("ПутьКлиентаАдминистрирования", ПутьКлиентаАдминистрирования);
	
	ИмяБазы = ПараметрыПодключения.СервернаяБаза.База;

	ФильтрСеансов = Новый Структура();

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

	НайтиИнформационнуюБазу(ИмяБазы);

	Если ИдентификаторИнформационнойбаза = Неопределено Тогда
		ВызватьИсключение СтрШаблон("Не удалось найти информационную базу <%1> на кластере серверов", ИмяБазы);
	КонецЕсли;

	УстановитьБлокировкуИнформационнойБазы();
	
	Если ЕстьПодключенныеСеансы() Тогда
		ОжиданиеОтключенияСеансов();
		
		Если ЕстьПодключенныеСеансы() Тогда
			ПрерватьПодключения();		
		КонецЕсли;

	КонецЕсли;

КонецПроцедуры

Процедура УстановитьБлокировкуИнформационнойБазы()
	
	Лог.Информация("Устанавливаю блокировку сеансов и регламентных заданий");
	
	ПараметрыИнформационнойбазы = Новый Структура();

	ВремяСтартаБлокировки = ТекущаяДата();
	ОкончаниеБлокировкиСеансов = ВремяСтартаБлокировки + 60*60; // Параметр в секундах

	СрокОжиданияЗавершенияСеансов = ВремяСтартаБлокировки + ПараметрыБлокировкиСеансов.ПериодОжиданияЗавершенияСеансов; // Еще ждем минуту
	
	ФорматДаты = "ДФ='yyyy-MM-ddTHH:mm:ss'";

	ПараметрыИнформационнойбазы.Вставить("БлокировкаСеансовВключена", "on");
	ПараметрыИнформационнойбазы.Вставить("БлокировкаРегламентныхЗаданийВключена", "on");
	ПараметрыИнформационнойбазы.Вставить("ВремяСтартаБлокировки", Формат(ВремяСтартаБлокировки, ФорматДаты));
	ПараметрыИнформационнойбазы.Вставить("ОкончаниеБлокировкиСеансов", Формат(ОкончаниеБлокировкиСеансов, ФорматДаты));
	ПараметрыИнформационнойбазы.Вставить("СообщениеОБлокировке", ПараметрыБлокировкиСеансов.СообщениеБлокировкиСеансов);
	ПараметрыИнформационнойбазы.Вставить("КлючРазрешенияЗапуска", ПараметрыБлокировкиСеансов.КлючРазрешенияЗапуска);
	УстановитьБлокировкуСеансов(ПараметрыИнформационнойбазы);	
	УстановитьСтатусБлокировкиРЗ(Истина);

	Лог.Информация("Установлена блокировку сеансов и регламентных заданий");

КонецПроцедуры

Процедура СнятьБлокировкуИнформационнойБазы()
	
	Лог.Информация("Снимаю блокировку сеансов и регламентных заданий");
	
	СнятьБлокировкуСеансов();
	УстановитьСтатусБлокировкиРЗ(Ложь);

	Лог.Информация("Снята блокировку сеансов и регламентных заданий");

КонецПроцедуры

Процедура ПрерватьПодключения()
	
	Лог.Информация("Прерываю сеансы и подключения");
	
	Пауза_ПолСекунды = 500;
	Пауза_ДесятьСек = 10000;

	Успешно = Ложь;

	Для Сч = 1 По ЧислоПопыток Цикл
		Попытка
			
			ОтключитьСуществующиеСеансы();
			Приостановить(Пауза_ПолСекунды);
			Сеансы = ПолучитьСписокСеансов();
			
			Если Сеансы.Количество() Тогда
				Лог.Информация("Пауза перед отключением соединений");
				Приостановить(Пауза_ДесятьСек);
				ОтключитьСоединенияСРабочимиПроцессами();
			КонецЕсли;

			Сеансы = ПолучитьСписокСеансов();
			Если Сеансы.Количество() = 0 Тогда
				Успешно = Истина;
				Прервать;
			КонецЕсли;

		Исключение
			Лог.Предупреждение("Попытка удаления сеансов не удалась. Текст ошибки:
						|%1", ИнформацияОбОшибке().Описание);
		КонецПопытки;
	
	КонецЦикла;


	Если НЕ Успешно Тогда
	
		СнятьБлокировкуИнформационнойБазы();
		
		ВызватьИсключение "Не удалось прервать соединения и сеансы в информационной базе";
	
	КонецЕсли;

	Лог.Отладка("Прерваны сеансы и подключения");
	
КонецПроцедуры

Функция ЕстьПодключенныеСеансы()
	
	СписокСеансовИБ = ПолучитьСписокСеансов();

	Возврат СписокСеансовИБ.Количество() > 0;

КонецФункции

Процедура ОжиданиеОтключенияСеансов()
	
	Лог.Информация("Ожидаю отключения сеансов и подключений до <%1>", СрокОжиданияЗавершенияСеансов);
	
	Пока СрокОжиданияЗавершенияСеансов > ТекущаяДата() Цикл

		Приостановить(10*1000); // 10 сек

		Если НЕ ЕстьПодключенныеСеансы() Тогда
			Прервать;
		КонецЕсли;
	
	КонецЦикла;

	Лог.Информация("Ожидание отключения сеансов и подключений завершено");

КонецПроцедуры

Функция НайтиИнформационнуюБазу(Знач ИмяБазы)
	
	Лог.Отладка("Поиск информационной базы с именем <%1>", ИмяБазы);
	
	ИдентификаторБазы();

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

/////////////////////////////////////////////////////////////////////////////////
// Взаимодействие с кластером

Процедура СнятьБлокировкуСеансов()
	
	КлючРазрешенияЗапуска = "";
	
	КлючЗначенияБлокировки = "off";
	
	ПараметрыЗапуска = Новый Массив();
	ПараметрыЗапуска.Добавить("infobase update");
	ПараметрыЗапуска.Добавить(СтрШаблон("--sessions-deny=%1", КлючЗначенияБлокировки));
	ПараметрыЗапуска.Добавить(СтрШаблон("--permission-code=""%1""", КлючРазрешенияЗапуска));

	ВыполнитьВИнформационнойБазе(ПараметрыЗапуска);
	
	Лог.Отладка("Сеансы разрешены");

КонецПроцедуры

Процедура УстановитьБлокировкуСеансов(Знач ПараметрыБлокировки)
	
	КлючРазрешенияЗапуска = ПараметрыБлокировки.КлючРазрешенияЗапуска;
	СообщениеОБлокировке = ПараметрыБлокировки.СообщениеОБлокировке;;
	ВремяБлокировки = ПараметрыБлокировки.ВремяСтартаБлокировки;
	
	КлючЗначенияБлокировки = "on";
	
	ПараметрыЗапуска = Новый Массив();
	ПараметрыЗапуска.Добавить("infobase");
	ПараметрыЗапуска.Добавить("update");
	
	ПараметрыЗапуска.Добавить(СтрШаблон("--sessions-deny=%1", КлючЗначенияБлокировки));
	ПараметрыЗапуска.Добавить(СтрШаблон("--denied-message=""%1""", СообщениеОБлокировке));
	ПараметрыЗапуска.Добавить(СтрШаблон("--permission-code=%1", КлючРазрешенияЗапуска));

	ПараметрыЗапуска.Добавить(СтрШаблон("--denied-from=%1", ВремяБлокировки));
	// ПараметрыЗапуска.Добавить(СтрШаблон("--denied-to=""%1""", КлючРазрешенияЗапуска);

	ВыполнитьВИнформационнойБазе(ПараметрыЗапуска);
	
	Лог.Отладка("Сеансы запрещены");
	
КонецПроцедуры

Процедура УстановитьСтатусБлокировкиРЗ(Знач Блокировать)
	
	КлючиАвторизацииВБазе = КлючиАвторизацииВБазе();
	
	ИдентификаторКластера = ИдентификаторКластера();
	ИдентификаторБазы = ИдентификаторБазы();
	КлючЗначенияБлокировки = ?(Блокировать, "on", "off");

	ПараметрыЗапуска = Новый Массив();
	ПараметрыЗапуска.Добавить("infobase");
	ПараметрыЗапуска.Добавить("update");
	ПараметрыЗапуска.Добавить(СтрШаблон("--scheduled-jobs-deny=%1", КлючЗначенияБлокировки));
	
	ВыполнитьВИнформационнойБазе(ПараметрыЗапуска);

	// КомандаВыполнения = СтрокаЗапускаКлиента() + 
	// 	СтрШаблон("infobase update --infobase=""%3""%4 --cluster=""%1""%2 --scheduled-jobs-deny=%5",
	// 		ИдентификаторКластера,
	// 		КлючиАвторизацииВКластере(),
	// 		ИдентификаторБазы,
	// 		КлючиАвторизацииВБазе,
	// 		?(Блокировать, "on", "off")
	// 	) + " "+мНастройки.АдресСервераАдминистрирования;
		
	// ЗапуститьПроцесс(КомандаВыполнения);
	
	Лог.Отладка("Регламентные задания " + ?(Блокировать, "запрещены", "разрешены"));
	
КонецПроцедуры

Функция ПолучитьИнформациюОБазеДанных()
	
	// КлючиАвторизацииВБазе = КлючиАвторизацииВБазе();
	
	// ИдентификаторКластера = ИдентификаторКластера();
	// ИдентификаторБазы = ИдентификаторБазы();
	
	// КомандаВыполнения = СтрокаЗапускаКлиента() + 
	// 	СтрШаблон("infobase info --infobase=""%3""%4 --cluster=""%1""%2",
	// 		ИдентификаторКластера,
	// 		КлючиАвторизацииВКластере(),
	// 		ИдентификаторБазы,
	// 		КлючиАвторизацииВБазе
	// 	) + " "+мНастройки.АдресСервераАдминистрирования;
		
	// Результат = ЗапуститьПроцесс(КомандаВыполнения);
	
	// Возврат Результат;
	
КонецФункции

Функция КлючиАвторизацииВБазе()
	
	КлючиАвторизацииВБазе = "";
	Если ЗначениеЗаполнено(АвторизацияВИнформационнойБазе.Пользователь) Тогда
		КлючиАвторизацииВБазе = КлючиАвторизацииВБазе + СтрШаблон("--infobase-user=""%1""", АвторизацияВИнформационнойБазе.Пользователь);
	КонецЕсли;
	
	Если ЗначениеЗаполнено(АвторизацияВИнформационнойБазе.Пароль) Тогда
		КлючиАвторизацииВБазе = КлючиАвторизацииВБазе + СтрШаблон(" --infobase-pwd=""%1""", АвторизацияВИнформационнойБазе.Пароль);
	КонецЕсли;
	
	Возврат КлючиАвторизацииВБазе;
	
КонецФункции

Функция ИдентификаторКластера()

	Если ИдентификаторКластера = Неопределено Тогда
		
		Лог.Отладка("Получаю список кластеров");
		
		ПараметрыЗапуска = Новый Массив();
		ПараметрыЗапуска.Добавить("cluster list");

		СписокКластеров = ВыполнитьКоманду(ПараметрыЗапуска, Истина);
	   
		УИДКластера = Сред(СписокКластеров, (Найти(СписокКластеров, ":") + 1), Найти(СписокКластеров, "host") - Найти(СписокКластеров, ":") - 1);	
		ИдентификаторКластера = СокрЛП(СтрЗаменить(УИДКластера, Символы.ПС, ""));
	
	КонецЕсли;
	
	Если ПустаяСтрока(ИдентификаторКластера) Тогда
		ВызватьИсключение "Кластер серверов отсутствует";
	КонецЕсли;
	
	Возврат ИдентификаторКластера;
	
КонецФункции

Функция ИдентификаторБазы()
	Если ИдентификаторИнформационнойбаза = Неопределено Тогда
		ИдентификаторИнформационнойбаза = НайтиБазуВКластере(ИмяБазы);
	КонецЕсли;
	
	Возврат ИдентификаторИнформационнойбаза;
КонецФункции

Функция КлючИдентификатораКластера()

	Возврат СтрШаблон("--cluster=%1", ИдентификаторКластера());
	
КонецФункции

Функция НайтиБазуВКластере(ИмяБазыДанных)
	
	// КомандаВыполнения = СтрокаЗапускаКлиента() + СтрШаблон("infobase summary list --cluster=""%1""%2",
	// ИдентификаторКластера(), 
	// КлючиАвторизацииВКластере()) + " " + мНастройки.АдресСервераАдминистрирования;
	НайденаБазаВКластере = Ложь;

	Лог.Отладка("Получаю список баз кластера");
	
	ПараметрыЗапуска = Новый Массив();
	ПараметрыЗапуска.Добавить("infobase");
	ПараметрыЗапуска.Добавить("summary");
	ПараметрыЗапуска.Добавить("list");
	
	СписокБазВКластере = СокрЛП(ВыполнитьКоманду(ПараметрыЗапуска));

	Данные = РазобратьПоток(СписокБазВКластере);
	
	Для Каждого Элемент Из Данные Цикл
		
		Если Нрег(Элемент["name"]) = НРег(ИмяБазыДанных) Тогда
			УИДИБ = Элемент["infobase"];
			Лог.Отладка("Получен идентификатор <%1> для базы <%2>", УИДИБ,  ИмяБазыДанных);
			НайденаБазаВКластере = Истина;
			Прервать;
		КонецЕсли;
	
	КонецЦикла;
	
	Если Не НайденаБазаВКластере Тогда
		ВызватьИсключение "База " + ИмяБазыДанных + " не найдена в кластере";
	КонецЕсли;
	
	Возврат УИДИБ;
	
КонецФункции

Функция КлючиАвторизацииВКластере()
	КомандаВыполнения = "";
	Если ЗначениеЗаполнено(УправлениеКластером.ПользовательКластера) Тогда
		КомандаВыполнения = КомандаВыполнения + СтрШаблон("--cluster-user=""%1""", УправлениеКластером.ПользовательКластера);
	КонецЕсли;
	
	Если ЗначениеЗаполнено(УправлениеКластером.ПарольКластера) Тогда
		КомандаВыполнения = КомандаВыполнения + СтрШаблон(" --cluster-pwd=""%1""", УправлениеКластером.ПарольКластера);
	КонецЕсли;
	Возврат КомандаВыполнения;
КонецФункции

Функция СтрокаЗапускаКлиента()
	
	Перем ПутьКлиентаАдминистрирования;
	
	Если ЭтоWindows Тогда 
		ПутьКлиентаАдминистрирования = ОбернутьПутьВКавычки(УправлениеКластером.ПутьКлиентаАдминистрирования);
	Иначе
		ПутьКлиентаАдминистрирования = УправлениеКластером.ПутьКлиентаАдминистрирования;
	КонецЕсли;
	
	Возврат ПутьКлиентаАдминистрирования;
	
КонецФункции

Функция ОбернутьПутьВКавычки(Знач Путь) Экспорт

	Результат = Путь;
	Если Прав(Результат, 1) = "\" ИЛИ Прав(Результат, 1) = "/" Тогда
		Результат = Лев(Результат, СтрДлина(Результат) - 1);
	КонецЕсли;

	Результат = """" + Результат + """";

	Возврат Результат;

КонецФункции

Функция КлючИдентификатораБазы()

	Возврат СтрШаблон("--infobase=""%1""", ИдентификаторБазы());
	
КонецФункции

Функция ВыполнитьВИнформационнойБазе(Знач ПараметрыКоманды)
	
	КлючиАвторизацииВБазе = КлючиАвторизацииВБазе();
	
	ПараметрыКоманды.Добавить(КлючИдентификатораБазы());
	Если Не ПустаяСтрока(КлючиАвторизацииВБазе) Тогда

		ПараметрыКоманды.Добавить(КлючиАвторизацииВБазе);

	КонецЕсли;

	Возврат ВыполнитьКоманду(ПараметрыКоманды);

КонецФункции


Функция ВыполнитьКоманду(Знач ПараметрыКоманды, Знач БезКластера = Ложь)

	КомандаВыполнения = СтрокаЗапускаКлиента();
	АдресСервераАдминистрирования = УправлениеКластером.АдресСервера;
	
	Команда = Новый Команда();
	// КомандаВыполнения = Команда.ОбернутьВКавычки(КомандаВыполнения);
	Команда.УстановитьКоманду(КомандаВыполнения);

	Команда.ДобавитьПараметры(ПараметрыКоманды);

	Если Не БезКластера Тогда

		Команда.ДобавитьПараметр(КлючИдентификатораКластера());
		КлючиАвторизацииВКластере = КлючиАвторизацииВКластере();

		Если Не ПустаяСтрока(КлючиАвторизацииВКластере) Тогда
			Команда.ДобавитьПараметр(КлючиАвторизацииВКластере);
		КонецЕсли;
	
	КонецЕсли;

	Команда.ДобавитьПараметр(АдресСервераАдминистрирования);
	Команда.УстановитьИсполнениеЧерезКомандыСистемы(Ложь);
	КодВозврата = Команда.Исполнить();

	Если КодВозврата <> 0 Тогда
		ВызватьИсключение Команда.ПолучитьВывод();
	КонецЕсли;

	Возврат Команда.ПолучитьВывод();
	
КонецФункции


Процедура ОтключитьСуществующиеСеансы()

	Лог.Отладка("Отключаю существующие сеансы");
	
	СеансыБазы = ПолучитьСписокСеансов();
	Для Каждого Сеанс Из СеансыБазы Цикл
		// Попытка
			ОтключитьСеанс(Сеанс);
		// Исключение
		// 	Лог.Ошибка(ОписаниеОшибки());
		// КонецПопытки;
	КонецЦикла;
	
КонецПроцедуры

Функция ПолучитьСписокСеансов()
	
	ТаблицаСеансов = Новый ТаблицаЗначений;
	ТаблицаСеансов.Колонки.Добавить("Идентификатор");
	ТаблицаСеансов.Колонки.Добавить("Приложение");
	ТаблицаСеансов.Колонки.Добавить("Пользователь");
	ТаблицаСеансов.Колонки.Добавить("НомерСеанса");
	
	// КомандаЗапуска = СтрокаЗапускаКлиента() + СтрШаблон("session list --cluster=""%1""%2 --infobase=""%3""",
	// 	ИдентификаторКластера(), 
	// 	КлючиАвторизацииВКластере(),
	// 	ИдентификаторБазы()) + " " + мНастройки.АдресСервераАдминистрирования;
			
	ПараметрыЗапуска = Новый Массив();
	ПараметрыЗапуска.Добавить("session list");
	ПараметрыЗапуска.Добавить(КлючИдентификатораБазы());

	СписокСеансовИБ = ВыполнитьКоманду(ПараметрыЗапуска);	
	
	Данные = РазобратьПоток(СписокСеансовИБ);
	
	Для Каждого Элемент Из Данные Цикл
		
		Если Не СеансВФильтре(Новый Структура("Приложение, Пользователь", Элемент["app-id"], Элемент["user-name"])) Тогда
			Продолжить;
		КонецЕсли;

		ТекСтрока = ТаблицаСеансов.Добавить();
		ТекСтрока.Идентификатор = Элемент["session"];
		ТекСтрока.Пользователь  = Элемент["user-name"];
		ТекСтрока.Приложение    = Элемент["app-id"];
		ТекСтрока.НомерСеанса   = Элемент["session-id"];

	КонецЦикла;
	
	Возврат ТаблицаСеансов;
	
КонецФункции

Процедура ОтключитьСеанс(Знач Сеанс)

	// СтрокаВыполнения = СтрокаЗапускаКлиента() + СтрШаблон("session terminate --cluster=""%1""%2 --session=""%3""",
	// 	ИдентификаторКластера(),
	// 	КлючиАвторизацииВКластере(),
	// 	Сеанс.Идентификатор) + " " + мНастройки.АдресСервераАдминистрирования;
	
	Лог.Отладка("Отключаю сеанс: %1 [%2] (%3 - %4)", Сеанс.НомерСеанса, Сеанс.Пользователь, Сеанс.Приложение, Сеанс.Идентификатор);

	ПараметрыЗапуска = Новый Массив();
	ПараметрыЗапуска.Добавить("session terminate");
	ПараметрыЗапуска.Добавить(СтрШаблон("--session=""%1""", Сеанс.Идентификатор));
	
	ВыполнитьКоманду(ПараметрыЗапуска);

КонецПроцедуры

Процедура ОтключитьСоединенияСРабочимиПроцессами()
	
	Процессы = ПолучитьСписокРабочихПроцессов();
	
	Для Каждого РабочийПроцесс Из Процессы Цикл
		Если РабочийПроцесс["running"] = "yes" Тогда
			
			СписокСоединений = ПолучитьСоединенияРабочегоПроцесса(РабочийПроцесс);
			Для Каждого Соединение Из СписокСоединений Цикл
				
				// Попытка
					РазорватьСоединениеСПроцессом(РабочийПроцесс, Соединение);
				// Исключение
				// 	Лог.Ошибка(ОписаниеОшибки());
				// КонецПопытки;
				
			КонецЦикла;
			
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры

Функция ПолучитьСписокРабочихПроцессов()
	
	// КомандаЗапускаПроцессы = СтрокаЗапускаКлиента() + СтрШаблон("process list --cluster=""%1""%2",
	// 	ИдентификаторКластера(), 
	// 	КлючиАвторизацииВКластере()) + " " + мНастройки.АдресСервераАдминистрирования;
		
	Лог.Отладка("Получаю список рабочих процессов...");
	// СписокПроцессов = ЗапуститьПроцесс(КомандаЗапускаПроцессы);
	
	ПараметрыЗапуска = Новый Массив();
	ПараметрыЗапуска.Добавить("process list");

	Результат = ВыполнитьКоманду(ПараметрыЗапуска);

	Возврат Результат;
	
КонецФункции

Функция ПолучитьСоединенияРабочегоПроцесса(Знач РабочийПроцесс)
	
	// КомандаЗапускаСоединения = СтрокаЗапускаКлиента() + СтрШаблон("connection list --cluster=""%1""%2 --infobase=%3%4 --process=%5",
	// 			ИдентификаторКластера(), 
	// 			КлючиАвторизацииВКластере(),
	// 			ИдентификаторБазы(),
	// 			КлючиАвторизацииВБазе(),
	// 			) + " " + мНастройки.АдресСервераАдминистрирования;
	
	
	ПараметрыЗапуска = Новый Массив();
	ПараметрыЗапуска.Добавить("connection list");
	ПараметрыЗапуска.Добавить(СтрШаблон("--process=%1", РабочийПроцесс["process"]));
	Лог.Отладка("Получаю список соединений рабочего процесса...");
	
	Соединения = РазобратьПоток(ВыполнитьВИнформационнойБазе(ПараметрыЗапуска));

	Результат = Новый Массив;
	Для Каждого ТекПроцесс Из Соединения Цикл
		Если СеансВФильтре(Новый Структура("Приложение, Пользователь", ТекПроцесс["app-id"], ТекПроцесс["user-name"])) 
				И ВРег(ТекПроцесс["app-id"])<>"RAS" Тогда
			Результат.Добавить(ТекПроцесс);
		КонецЕсли;
	КонецЦикла;

	Возврат Результат;
	
КонецФункции

Функция РазорватьСоединениеСПроцессом(Знач РабочийПроцесс, Знач Соединение)
	
	// КомандаРазрывСоединения = СтрокаЗапускаКлиента() + СтрШаблон("connection disconnect --cluster=""%1""%2 %3 --process=%4 --connection=%5",
	// 	ИдентификаторКластера(), 
	// 	КлючиАвторизацииВКластере(),
	// 	КлючиАвторизацииВБазе(),
	// 	РабочийПроцесс["process"],
	// 	Соединение["connection"]) + " " + мНастройки.АдресСервераАдминистрирования;
	
	Сообщение = СтрШаблон("Отключаю соединение %1 [%2] (%3)",
		Соединение["conn-id"],
		Соединение["app-id"],
		Соединение["user-name"]
	);
	
	Лог.Информация(Сообщение);
	
	ПараметрыЗапуска = Новый Массив();
	ПараметрыЗапуска.Добавить("connection disconnect");
	ПараметрыЗапуска.Добавить(СтрШаблон("--process=%1", РабочийПроцесс["process"]));
	ПараметрыЗапуска.Добавить(СтрШаблон("--connection=%1", Соединение["connection"]));
	
	Возврат ВыполнитьКоманду(ПараметрыЗапуска);
	
КонецФункции

Функция РазобратьПоток(Знач Поток) Экспорт
	
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

Функция РазобратьНаКлючИЗначение(Знач СтрокаРазбора, Ключ, Значение)
	
	ПозицияРазделителя = Найти(СтрокаРазбора, ":");
	Если ПозицияРазделителя = 0 Тогда
		Возврат Ложь;
	КонецЕсли;
	
	Ключ     = СокрЛП(Лев(СтрокаРазбора, ПозицияРазделителя - 1));
	Значение = СокрЛП(Сред(СтрокаРазбора, ПозицияРазделителя + 1));
	
	Возврат Истина;
	
КонецФункции

Функция СеансВФильтре(Сеанс)

	Результат = Истина;

	Если Не ЗначениеЗаполнено(ФильтрСеансов) Тогда
		Возврат Результат;
	КонецЕсли;

	Результат = Результат И ПараметрСеансаВФильтре("appid", Сеанс.Приложение);
	Результат = Результат И ПараметрСеансаВФильтре("name", Сеанс.Пользователь);

	Возврат Результат;
	
КонецФункции

Функция ПараметрСеансаВФильтре(ИмяФильтра, ПроверяемоеЗначение)
	
	Если Не ЗначениеЗаполнено(ФильтрСеансов) 
		Или Не ФильтрСеансов.Свойство(ИмяФильтра) Тогда
		Возврат Истина;
	КонецЕсли;
	
	ЗначенияФильтра = ФильтрСеансов[ИмяФильтра];
	Для Каждого ТекЗначение Из ЗначенияФильтра Цикл
		ВФильтре = ВРег(ТекЗначение)=ВРег(ПроверяемоеЗначение);
		Если ВФильтре Тогда
			Возврат Истина;
		КонецЕсли;
	КонецЦикла;

	Возврат Ложь;

КонецФункции


Процедура ПриСозданииОбъекта()

	Лог = Логирование.ПолучитьЛог("oscript.app.AutoUpdateIB.session");
	// Лог = Логирование.ПолучитьЛог("oscript.lib.commands");
	// Лог.УстановитьУровень(УровниЛога.Отладка);

	СистемнаяИнформация = Новый СистемнаяИнформация;
	ЭтоWindows = Найти(НРег(СистемнаяИнформация.ВерсияОС), "windows") > 0;
	
КонецПроцедуры

/////////////////////////////////////////////////////////////////////////////////



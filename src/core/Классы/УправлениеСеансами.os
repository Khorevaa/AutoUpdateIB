#Использовать logos
#Использовать "./internal/v8rac"

Перем ВерсияПлатформы;

Перем УправлениеКластером;

Перем ПараметрыПодключения;
Перем ПараметрыБлокировкиСеансов;
Перем ПараметрыКластера;

Перем ИдентификаторИнформационнойбаза;

Перем ЭтоФайловаяБаза;

Перем Фильтр;
Перем ЧислоПопыток;
Перем СрокОжиданияЗавершенияСеансов;
Перем Лог;


Процедура УстановитьНастройки(Знач НастройкиОбновления) Экспорт

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

	УправлениеКластером = Новый УправлениеКластером;
	УправлениеКластером.УстановитьКластер(АдресСервера, ПортСервера);
	УправлениеКластером.ИспользоватьВерсию(ВерсияПлатформы);
	Если ЗначениеЗаполнено(ПользовательКластера) Тогда
		УправлениеКластером.УстановитьАвторизациюКластера(ПользовательКластера, ПарольКластера);
	КонецЕсли;

	УправлениеКластером.Подключить();
	
	ИмяИнформационнойбазы = ПараметрыПодключения.СервернаяБаза.База;
	ИдентификаторИнформационнойбаза = УправлениеКластером.НайтиИнформационнуюБазу(ИмяИнформационнойбазы);

	Если ЗначениеЗаполнено(ПараметрыПодключения.Пользователь) Тогда
	
		УправлениеКластером.УстановитьАвторизациюИнформационнойБазы(ИдентификаторИнформационнойбаза, ПараметрыПодключения.Пользователь, ПараметрыПодключения.Пароль);
		
	КонецЕсли;

	Если НЕ ЗначениеЗаполнено(ИдентификаторИнформационнойбаза) Тогда
		ВызватьИсключение СтрШаблон("Не удалось найти информационную базы <%1> на кластере серверов 1С", ИмяИнформационнойбазы);
	КонецЕсли;

КонецПроцедуры

Процедура ДобавитьСпособВывода(ПроцессорВывода) Экспорт
	
	Лог.ДобавитьСпособВывода(ПроцессорВывода);

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

	УстановитьБлокировкуИнформационнойБазы();
	
	Если ЕстьПодключенныеСеансы() Тогда
		ОжиданиеОтключенияСеансов();
		
		Если ЕстьПодключенныеСеансы() Тогда
			ПрерватьПодключения();		
		КонецЕсли;

	КонецЕсли;

КонецПроцедуры

Процедура УстановитьБлокировкуИнформационнойБазы()
	
	ВремяСтартаБлокировки = ТекущаяДата();
	ОкончаниеБлокировкиСеансов = ВремяСтартаБлокировки + 60*60; // Параметр в секундах

	СрокОжиданияЗавершенияСеансов = ВремяСтартаБлокировки + ПараметрыБлокировкиСеансов.ПериодОжиданияЗавершенияСеансов; // Еще ждем минуту
	
	Лог.Поля("СообщениеБлокировкиСеансов", ПараметрыБлокировкиСеансов.СообщениеБлокировкиСеансов,
			"КлючРазрешенияЗапуска", ПараметрыБлокировкиСеансов.КлючРазрешенияЗапуска,
			"ВремяСтартаБлокировки", ВремяСтартаБлокировки,
			"ОкончаниеБлокировкиСеансов", ОкончаниеБлокировкиСеансов)
			.Информация("Устанавливаю блокировку сеансов и регламентных заданий");
		
	УправлениеКластером.БлокировкаИнформационнойБазы(ИдентификаторИнформационнойбаза,
													ПараметрыБлокировкиСеансов.СообщениеБлокировкиСеансов,
													ПараметрыБлокировкиСеансов.КлючРазрешенияЗапуска,
													ВремяСтартаБлокировки,
													ОкончаниеБлокировкиСеансов,
													Истина);
												
	Лог.Информация("Установлена блокировку сеансов и регламентных заданий");

КонецПроцедуры

Процедура СнятьБлокировкуИнформационнойБазы()
	
	Лог.Информация("Снимаю блокировку сеансов и регламентных заданий");
	
	УправлениеКластером.СнятьБлокировкуИнформационнойБазы(ИдентификаторИнформационнойбаза);
	
	Лог.Информация("Снята блокировку сеансов и регламентных заданий");

КонецПроцедуры

Процедура ПрерватьПодключения()
	
	Лог.Информация("Прерываю сеансы и подключения");
	
	Пауза_ПолСекунды = 500;
	Пауза_ДесятьСек = 10000;

	Успешно = Ложь;

	Для Сч = 1 По ЧислоПопыток Цикл
		Попытка
			
			УправлениеКластером.ОтключитьСеансыИнформационнойБазы(ИдентификаторИнформационнойбаза, Фильтр);

			Приостановить(Пауза_ПолСекунды);
			Сеансы = УправлениеКластером.СписокСоединенийИнформационнойБазы();
			
			Если Сеансы.Количество() Тогда
				Лог.Информация("Пауза перед отключением соединений");
				Приостановить(Пауза_ДесятьСек);
				УправлениеКластером.ОтключитьСоединенияИнформационнойБазы(ИдентификаторИнформационнойбаза, Фильтр);
			КонецЕсли;

			Сеансы = УправлениеКластером.СписокСоединенийИнформационнойБазы();
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
	
	СписокСеансовИБ = УправлениеКластером.СписокСеансовИнформационнойБазы(ИдентификаторИнформационнойбаза);

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
	// Лог = Логирование.ПолучитьЛог("oscript.lib.commands");
	// Лог.УстановитьУровень(УровниЛога.Отладка);
	
КонецПроцедуры

/////////////////////////////////////////////////////////////////////////////////



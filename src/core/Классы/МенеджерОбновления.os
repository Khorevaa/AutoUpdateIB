// #Использовать delegate
#Использовать v8runner
#Использовать tempfiles

Перем Лог;
Перем ОшибкаПроцессаВыполнения;
Перем ОписаниеОшибкиОбновления;
Перем НастройкаОбновления;
Перем РабочийКонфигуратор;
Перем ЛокальныеВременныеФайлы;
Перем УправлениемСеансами;
Перем ДоступКБазеЗаблокирован;

Функция ОбновлениеПоНастройке(Настройка) Экспорт

	ОшибкаПроцессаВыполнения = Ложь;
	НастройкаОбновления = Настройка;
	Лог = НастройкаОбновления.Лог();
	Лог.Информация("Начало обновления информационной базы");
	
	РабочийКонфигуратор = НастроитьКонфигуратор(НастройкаОбновления);

	БлокировкаСеансов = НастройкаОбновления.БлокировкаСеансов;

	Если БлокировкаСеансов Тогда
		НастроитьУправлениемСеансами();
		Блокировка();
	КонецЕсли;
	
	Если НастройкаОбновления.ПередОбновлением() Тогда
		ПередОбновлением();
	КонецЕсли;

	Обновление();

	Если НастройкаОбновления.ПослеОбновления() Тогда
		ПослеОбновления();
	КонецЕсли;

	Если ДоступКБазеЗаблокирован Тогда
		Разблокировка();
	КонецЕсли;

	Лог.Информация("Завершено обновлении информационной базы");

	РезультатВыполнения = Новый Структура;
	РезультатВыполнения.Вставить("Выполнено", НЕ ОшибкаПроцессаВыполнения);
	РезультатВыполнения.Вставить("ОписаниеОшибки", ОписаниеОшибкиОбновления);
	РезультатВыполнения.Вставить("ТаблицаЛога", НастройкаОбновления.ТаблицаЛогов());
	
	ЛокальныеВременныеФайлы.Удалить();

	Возврат РезультатВыполнения;

КонецФункции

Функция НастроитьКонфигуратор(НастройкаОбновления) Экспорт
	
	Конфигуратор = Новый УправлениеКонфигуратором;
	Конфигуратор.КаталогСборки(ЛокальныеВременныеФайлы.СоздатьКаталог());
	Конфигуратор.УстановитьКонтекст(НастройкаОбновления.СтрокаПодключения,
				НастройкаОбновления.АвторизацияВИнфомарционнойБазе.Пользователь,
				НастройкаОбновления.АвторизацияВИнфомарционнойБазе.Пароль);
	Конфигуратор.ИспользоватьВерсиюПлатформы(НастройкаОбновления.ВерсияПлатформы);
	Конфигуратор.УстановитьКлючРазрешенияЗапуска(НастройкаОбновления.КлючРазрешенияЗапуска);
	
	ЛогРаннера = Логирование.ПолучитьЛог("oscript.lib.v8runner");
	ЛогРаннера.УстановитьУровень(УровниЛога.Отладка);

	Возврат Конфигуратор;

КонецФункции

Процедура НастроитьУправлениемСеансами()

	УправлениемСеансами.УстановитьНастройки(НастройкаОбновления);
	
КонецПроцедуры

Процедура Блокировка() Экспорт

	Если ОшибкаПроцессаВыполнения Тогда
		Возврат;
	КонецЕсли;
	
	Попытка
		Лог.Информация("Блокировка доступа к информационной базе");
		УправлениемСеансами.БлокировкаДоступа();	
		ДоступКБазеЗаблокирован = Истина;

	Исключение
		Лог.КритичнаяОшибка("Ошибка блокировки доступа к информационной базе: %1", ОписаниеОшибки());
		
		ОшибкаПроцессаВыполнения = Истина;

	КонецПопытки;
	
КонецПроцедуры

Процедура Обновление()
	
	Если ОшибкаПроцессаВыполнения Тогда
		Возврат;
	КонецЕсли;
	
	Попытка
		Лог.Информация("Обновление информационной базы");	
		ВыполнитьОбновление();
	Исключение
		Лог.КритичнаяОшибка("Ошибка обновления информационной базы: %1", ОписаниеОшибки());
		ОписаниеОшибкиОбновления = СтрШаблон("Ошибка обновления информационной базы: %1", ОписаниеОшибки());
		ОшибкаПроцессаВыполнения = Истина;

	КонецПопытки;

КонецПроцедуры

Процедура ВыполнитьОбновление()

	ПутьКОбновлению = НастройкаОбновления.ПутьКОбновлению;
	ФайлОбновления = Новый Файл(ПутьКОбновлению);

	Если НЕ ФайлОбновления.Существует() Тогда
		ВызватьИсключение НоваяИнформацияОбОшибке("Файл обновления <%1> не найден", ФайлОбновления.ПолноеИмя);
	КонецЕсли;

	Если НастройкаОбновления.ЗагрузкаКонфигурацииВместоОбновления Тогда

		Если ФайлОбновления.ЭтоКаталог() Тогда
			ВызватьИсключение НоваяИнформацияОбОшибке("Файл обновления <%1> является каталогом, а не файлом", ФайлОбновления.ПолноеИмя);
		КонецЕсли;
		Лог.Информация("Загрузка конфигурации в конфигуратор информационной базы");	
		РабочийКонфигуратор.ЗагрузитьКонфигурациюИзФайла(ФайлОбновления.ПолноеИмя);
	
	Иначе

		ИспользоватьПолныйДистрибутив = НастройкаОбновления.ИспользоватьПолныйДистрибутив;
		ПутьКОбновлению = ФайлОбновления.ПолноеИмя;

		Если НЕ ФайлОбновления.ЭтоКаталог() Тогда
			
			ПутьКОбновлению = ФайлОбновления.Путь;

			Если НЕ (ИспользоватьПолныйДистрибутив
				И ВРег(ФайлОбновления.Расширение) = ВРег("cf")) Тогда

				ВызватьИсключение НоваяИнформацияОбОшибке("Не возможно использовать файл <%1> в качестве полного дистрибутива не найден", ФайлОбновления.ПолноеИмя);

			КонецЕсли;

		КонецЕсли;
		Лог.Информация("Загрузка обновления в конфигуратор информационной базы");	
		РабочийКонфигуратор.ОбновитьКонфигурацию(ПутьКОбновлению, ИспользоватьПолныйДистрибутив);

	КонецЕсли;
	
	Лог.Информация("Обновление конфигурации информационной базы");	
	РабочийКонфигуратор.ОбновитьКонфигурациюБазыДанных(НастройкаОбновления.ПредупрежденияКакОшибки,
						НастройкаОбновления.НаСервере,
						НастройкаОбновления.ДинамическоеОбновление,
						НастройкаОбновления.ИмяРасширения
						);

КонецПроцедуры

Процедура ПередОбновлением()
	
	Если ОшибкаПроцессаВыполнения Тогда
		Возврат;
	КонецЕсли;
	
	Попытка
		Лог.Информация("Выполнение обработки перед обновлением информационной базы");	
		ВыполнитьОбработку(НастройкаОбновления.ПутьКОбработкеПередОбновлением);
	Исключение
		ОписаниеОшибкиОбновления = СтрШаблон("Выполнение обработки перед обновлением информационной базы: %1", ОписаниеОшибки());
		
		Лог.КритичнаяОшибка("Выполнение обработки перед обновлением информационной базы: %1", ОписаниеОшибки());
		ОшибкаПроцессаВыполнения = Истина;
	КонецПопытки;

КонецПроцедуры

Процедура Разблокировка()
	
	Попытка
		Лог.Информация("Разблокировка доступа к информационной базе");
		УправлениемСеансами.РазблокироватьДоступ();	
	Исключение
		Лог.КритичнаяОшибка("Ошибка разблокировки к информационной базей: %1", ОписаниеОшибки());
		ОписаниеОшибкиОбновления = СтрШаблон("Ошибка разблокировки к информационной базей: %1", ОписаниеОшибки());
		ОшибкаПроцессаВыполнения = Истина;
	КонецПопытки;

КонецПроцедуры

Процедура ПослеОбновления()
	
	Если ОшибкаПроцессаВыполнения Тогда
		Возврат;
	КонецЕсли;

	Попытка
		Лог.Информация("Выполнение обработки после обновления информационной базы");	
		ВыполнитьОбработку(НастройкаОбновления.ПутьКОбработкеПослеОбновления);
	Исключение
		
		ЗафиксироватьОшибкуОбновления(СтрШаблон("Выполнение обработки после обновления информационной базы: %1", ОписаниеОшибки()));

	КонецПопытки;

КонецПроцедуры

Процедура ЗафиксироватьОшибкуОбновления(ОписаниеОшибкиВыполнения)
	Лог.КритичнаяОшибка(ОписаниеОшибкиВыполнения);
	ОписаниеОшибкиОбновления = ОписаниеОшибкиВыполнения;
	ОшибкаПроцессаВыполнения = Истина;
КонецПроцедуры

Процедура ПриСозданииОбъекта()
	
	ЛокальныеВременныеФайлы = Новый МенеджерВременныхФайлов;
	УправлениемСеансами = Новый УправлениемСеансамиОбновления;
	ДоступКБазеЗаблокирован = Ложь;

КонецПроцедуры

Функция НоваяИнформацияОбОшибке(Знач Сообщение,
	Знач Параметр1 = Неопределено, Знач Параметр2 = Неопределено, Знач Параметр3 = Неопределено,
	Знач Параметр4 = Неопределено, Знач Параметр5 = Неопределено, Знач Параметр6 = Неопределено,
	Знач Параметр7 = Неопределено, Знач Параметр8 = Неопределено, Знач Параметр9 = Неопределено)
	
	Если ЕстьЗаполненныеПараметры(Параметр1, Параметр2, Параметр3,
		Параметр4, Параметр5, Параметр6, Параметр7, Параметр8, Параметр9) Тогда
		
		Сообщение = СтрШаблон(Сообщение, Параметр1,
			Параметр2, Параметр3, Параметр4, Параметр5, Параметр6, Параметр7, Параметр8, Параметр9);
	КонецЕсли;
	
	// Возврат Новый ИнформацияОбОшибке(Сообщение);

	Возврат Сообщение;
КонецФункции

Процедура ВыполнитьОбработку(Знач ПутьКФайлуОбработки)
	
	ФайлОбработки = Новый Файл(ПутьКФайлуОбработки);

	Если НЕ ФайлОбработки.Существует() Тогда
		ВызватьИсключение НоваяИнформацияОбОшибке("Файл обработки <%1> не найден", ФайлОбработки.ПолноеИмя);
	КонецЕсли;

	ПараметрыЗапускаОбработки = СтрШаблон("/Execute ""%1""", ФайлОбработки.ПолноеИмя);
    РабочийКонфигуратор.ЗапуститьВРежимеПредприятия("", Ложь, ПараметрыЗапускаОбработки);

КонецПроцедуры

Функция ЕстьЗаполненныеПараметры(Знач Параметр1 = Неопределено, Знач Параметр2 = Неопределено, Знач Параметр3 = Неопределено,
	Знач Параметр4 = Неопределено, Знач Параметр5 = Неопределено, Знач Параметр6 = Неопределено,
	Знач Параметр7 = Неопределено, Знач Параметр8 = Неопределено, Знач Параметр9 = Неопределено)

	Если НЕ Параметр1 = Неопределено Тогда
		Возврат Истина;
	ИначеЕсли НЕ Параметр2 = Неопределено Тогда
		Возврат Истина;
	ИначеЕсли НЕ Параметр3 = Неопределено Тогда
		Возврат Истина;
	ИначеЕсли НЕ Параметр4 = Неопределено Тогда
		Возврат Истина;
	ИначеЕсли НЕ Параметр5 = Неопределено Тогда
		Возврат Истина;
	ИначеЕсли НЕ Параметр6 = Неопределено Тогда
		Возврат Истина;
	ИначеЕсли НЕ Параметр7 = Неопределено Тогда
		Возврат Истина;
	ИначеЕсли НЕ Параметр8 = Неопределено Тогда
		Возврат Истина;
	ИначеЕсли НЕ Параметр9 = Неопределено Тогда
		Возврат Истина;
	КонецЕсли;
	
	Возврат Ложь;

КонецФункции
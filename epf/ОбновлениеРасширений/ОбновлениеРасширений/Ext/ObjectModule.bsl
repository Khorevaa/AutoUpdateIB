﻿Перем ПутьКФайлуОбновленияРасширения;
Перем ПутьКФайлуЛогаОбновления;
Перем ТаблицаРасширений;
Перем ПотокЗаписиВФайл;
Перем ДанныеОбновленияРасширений;

Перем Логгер;

Функция НайтиУстановленноеРасширениеПоИмени(Знач ИмяРасширения) Экспорт
	
	МассивРасширений = РасширенияКонфигурации.Получить(Новый Структура("Имя", ИмяРасширения));
	
	Если МассивРасширений = Неопределено Тогда
		Возврат Неопределено
	ИначеЕсли МассивРасширений.Количество() = 1 Тогда
		Возврат МассивРасширений[0];
	КонецЕсли;
	
	Возврат Неопределено;
	
КонецФункции

Функция НоваяТаблицаРасширений()
	
	ОписаниеТипаБулево = Новый ОписаниеТипов("Булево");
	
	ТаблицаРасширений = Новый ТаблицаЗначений;
	ТаблицаРасширений.Колонки.Добавить("Имя");
	ТаблицаРасширений.Колонки.Добавить("Синоним");
	ТаблицаРасширений.Колонки.Добавить("Версия");
	ТаблицаРасширений.Колонки.Добавить("Активно", ОписаниеТипаБулево);
	ТаблицаРасширений.Колонки.Добавить("БезопасныйРежим", ОписаниеТипаБулево);
	ТаблицаРасширений.Колонки.Добавить("ГлавныйУзел");
	ТаблицаРасширений.Колонки.Добавить("ЗащитаОтОпасныхДействий");
	ТаблицаРасширений.Колонки.Добавить("ПредупреждатьОбОпасныхДействиях", ОписаниеТипаБулево);
	ТаблицаРасширений.Колонки.Добавить("ИспользуетсяВРаспределеннойИнформационнойБазе");
	ТаблицаРасширений.Колонки.Добавить("Назначение");
	// ТаблицаРасширений.Колонки.Добавить("ОбластьДействия");
	ТаблицаРасширений.Колонки.Добавить("УникальныйИдентификатор");
	ТаблицаРасширений.Колонки.Добавить("ХешСумма");
	ТаблицаРасширений.Колонки.Добавить("_ТолькоЧтение");
	ТаблицаРасширений.Колонки.Добавить("_Удалить", ОписаниеТипаБулево);
	ТаблицаРасширений.Колонки.Добавить("_Добавить", ОписаниеТипаБулево);
	//ТаблицаРасширений.Колонки.Добавить("_Обновить", ОписаниеТипаБулево);
	ТаблицаРасширений.Колонки.Добавить("_Изменить", ОписаниеТипаБулево);
	ТаблицаРасширений.Колонки.Добавить("_Отключить", ОписаниеТипаБулево);
	ТаблицаРасширений.Колонки.Добавить("_ПутьКФайлуРасширения");
	
	Возврат ТаблицаРасширений;
	
КонецФункции

Функция ОбновитьТаблицуРасширений()
	
	ТаблицаРасширений = НоваяТаблицаРасширений();
	
	НаборРасширенийКонфигурации = ConfigurationExtensions.Get(Undefined);
	
	Для Каждого Расширение из НаборРасширенийКонфигурации Цикл
		НоваяСтрока = ТаблицаРасширений.Добавить();
		ЗаполнитьЗначенияСвойств(НоваяСтрока, Расширение);
		
		Если ПустаяСтрока(НоваяСтрока.Синоним) Тогда
			НоваяСтрока.Синоним = НоваяСтрока.Name;
		КонецЕсли;
		
		НоваяСтрока.ПредупреждатьОбОпасныхДействиях = Расширение.ЗащитаОтОпасныхДействий.ПредупреждатьОбОпасныхДействиях;
		
		НоваяСтрока.ХешСумма = Base64Строка(Расширение.ХешСумма);
		НоваяСтрока._ТолькоЧтение = ЗначениеЗаполнено(НоваяСтрока.ГлавныйУзел) И (Расширение.ГлавныйУзел = ПланыОбмена.ГлавныйУзел());
		
	КонецЦикла;
	
	Возврат ТаблицаРасширений;
	
КонецФункции

#Область Логгер

Процедура Отладка(Знач Сообщение,
	Знач Параметр1 = Неопределено, Знач Параметр2 = Неопределено, Знач Параметр3 = Неопределено,
	Знач Параметр4 = Неопределено, Знач Параметр5 = Неопределено, Знач Параметр6 = Неопределено,
	Знач Параметр7 = Неопределено, Знач Параметр8 = Неопределено, Знач Параметр9 = Неопределено) Экспорт
	
	Вывести(Сообщение, 0, Параметр1,
	Параметр2, Параметр3, Параметр4, Параметр5, Параметр6, Параметр7, Параметр8, Параметр9);
КонецПроцедуры

Процедура Информация( Знач Сообщение,
	Знач Параметр1 = Неопределено, Знач Параметр2 = Неопределено, Знач Параметр3 = Неопределено,
	Знач Параметр4 = Неопределено, Знач Параметр5 = Неопределено, Знач Параметр6 = Неопределено,
	Знач Параметр7 = Неопределено, Знач Параметр8 = Неопределено, Знач Параметр9 = Неопределено) Экспорт
	
	Вывести(Сообщение, 1, Параметр1,
	Параметр2, Параметр3, Параметр4, Параметр5, Параметр6, Параметр7, Параметр8, Параметр9);
	
КонецПроцедуры

Процедура Предупреждение_( Знач Сообщение,
	Знач Параметр1 = Неопределено, Знач Параметр2 = Неопределено, Знач Параметр3 = Неопределено,
	Знач Параметр4 = Неопределено, Знач Параметр5 = Неопределено, Знач Параметр6 = Неопределено,
	Знач Параметр7 = Неопределено, Знач Параметр8 = Неопределено, Знач Параметр9 = Неопределено) Экспорт
	
	Вывести(Сообщение, 2, Параметр1,
	Параметр2, Параметр3, Параметр4, Параметр5, Параметр6, Параметр7, Параметр8, Параметр9);
	
КонецПроцедуры	

Процедура Ошибка( Знач Сообщение,
	Знач Параметр1 = Неопределено, Знач Параметр2 = Неопределено, Знач Параметр3 = Неопределено,
	Знач Параметр4 = Неопределено, Знач Параметр5 = Неопределено, Знач Параметр6 = Неопределено,
	Знач Параметр7 = Неопределено, Знач Параметр8 = Неопределено, Знач Параметр9 = Неопределено) Экспорт
	
	Вывести(Сообщение, 3, Параметр1,
	Параметр2, Параметр3, Параметр4, Параметр5, Параметр6, Параметр7, Параметр8, Параметр9);
	
КонецПроцедуры	

Процедура КритичнаяОшибка( Знач Сообщение,
	Знач Параметр1 = Неопределено, Знач Параметр2 = Неопределено, Знач Параметр3 = Неопределено,
	Знач Параметр4 = Неопределено, Знач Параметр5 = Неопределено, Знач Параметр6 = Неопределено,
	Знач Параметр7 = Неопределено, Знач Параметр8 = Неопределено, Знач Параметр9 = Неопределено) Экспорт
	
	Вывести(Сообщение, 4, Параметр1,
	Параметр2, Параметр3, Параметр4, Параметр5, Параметр6, Параметр7, Параметр8, Параметр9);
	
КонецПроцедуры

Функция НовыйЛоггер(Знач КлючиПараметров, Значение1, Значение2 = Неопределено, Значение3 = Неопределено)
	
	МассивКлючей = СтрРазделить(КлючиПараметров, ",");
	МассивЗначений = Новый Массив;
	МассивЗначений.Добавить(Значение1);
	Если НЕ Значение2 = Неопределено Тогда
		МассивЗначений.Добавить(Значение2);
	КонецЕсли;
	Если НЕ Значение3 = Неопределено Тогда
		МассивЗначений.Добавить(Значение3);
	КонецЕсли;
	
	ОписаниеЛоггера = Новый Структура("ДополнительныеДанные", Новый Структура());
	
	Для ИИ = 0 По Мин(МассивКлючей.ВГраница(), МассивЗначений.ВГраница()) Цикл
		
		ОписаниеЛоггера.ДополнительныеДанные.Вставить(МассивКлючей[ИИ], МассивЗначений[ИИ]);
		
	КонецЦикла;
	
	Возврат ОписаниеЛоггера;
	
КонецФункции

Процедура Вывести(Знач Сообщение, Знач УровеньСообщения,
	Знач Параметр1 = Неопределено, Знач Параметр2 = Неопределено, Знач Параметр3 = Неопределено,
	Знач Параметр4 = Неопределено, Знач Параметр5 = Неопределено, Знач Параметр6 = Неопределено,
	Знач Параметр7 = Неопределено, Знач Параметр8 = Неопределено, Знач Параметр9 = Неопределено) Экспорт
	
	Если УровеньСообщения < Уровень() Тогда
		Возврат;
	КонецЕсли;
	
	Если ЕстьЗаполненныеПараметры(Параметр1, Параметр2, Параметр3,
		Параметр4, Параметр5, Параметр6, Параметр7, Параметр8, Параметр9) Тогда
		
		Сообщение = СтрШаблон(Сообщение, Параметр1,
		Параметр2, Параметр3, Параметр4, Параметр5, Параметр6, Параметр7, Параметр8, Параметр9);
	КонецЕсли;
	
	Логгер.Вставить("УровеньСообщения", УровеньСообщения);
	Логгер.Вставить("Сообщение", Сообщение);
	
	ДобавитьДатуВремяВЛоггер(Логгер);
	
	ЗаписатьДанныеВПоток(Логгер);
	
	Логгер.Удалить("УровеньСообщения");
	Логгер.Удалить("Сообщение");
	
КонецПроцедуры

Процедура ДобавитьДатуВремяВЛоггер(Логгер)
	
	Если Логгер.Свойство("ДополнительныеДанные") Тогда
		Логгер.ДополнительныеДанные.Вставить("ДатаВремя", ТекущаяДата());
	Иначе
		ДополнительныеДанные = Новый Структура("ДатаВремя", ТекущаяДата());
		Логгер.Вставить("ДополнительныеДанные", ДополнительныеДанные);
	КонецЕсли;
	
КонецПроцедуры

Функция Уровень()
	
	Возврат 1;
	
КонецФункции

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

Функция ПодготовитьЛог() 
	
	ПараметрыЗаписиJSON = Новый ПараметрыЗаписиJSON();
	
	ЗаписьJSON = Новый ЗаписьJSON;
	ЗаписьJSON.ОткрытьФайл(ПутьКФайлуЛогаОбновления, "UTF-8",, ПараметрыЗаписиJSON);
	ЗаписьJSON.ЗаписатьНачалоМассива();
	
	ПотокЗаписиВФайл = ЗаписьJSON;
	
	Логгер = Новый Структура;
	
КонецФункции

Процедура ЗавершитьЗаписьЛога()
	
	ПотокЗаписиВФайл.ЗаписатьКонецМассива();
	ПотокЗаписиВФайл.Закрыть()
	
КонецПроцедуры

Процедура ЗаписатьДанныеВПоток(Логгер)
	
	ЗаписатьJSON(ПотокЗаписиВФайл, Логгер);
	
КонецПроцедуры

#КонецОбласти 

#Область РаботаСРасширениями

Процедура ОтключитьРасширение(РасширениеКонфигурации) 
	
	РасширениеКонфигурации.Активно = Ложь;
	
	Если ПроверитьВозможностьПрименения(РасширениеКонфигурации) Тогда
		РасширениеКонфигурации.Записать();
	КонецЕсли;
	
КонецПроцедуры

Процедура ИзменитьРасширение(РасширениеКонфигурации, СтрокаРасширения)
	
	НаименованиеРасширения = ?(ЗначениеЗаполнено(РасширениеКонфигурации.Синоним), РасширениеКонфигурации.Синоним, СтрокаРасширения.Имя);
	ВерсияРасширения = ?(ЗначениеЗаполнено(СтрокаРасширения.Версия), СтрокаРасширения.Версия, "0.0.0");
	
	РасширениеКонфигурации.Активно = СтрокаРасширения.Активно;
	РасширениеКонфигурации.БезопасныйРежим = СтрокаРасширения.БезопасныйРежим;
	РасширениеКонфигурации.ОбластьДействия = ОбластьДействияРасширенияКонфигурации["InfoBase"];
	// Сообщить(РасширениеКонфигурации.ОбластьДействия);

	Если НЕ РасширениеКонфигурации.ЗащитаОтОпасныхДействий.ПредупреждатьОбОпасныхДействиях = СтрокаРасширения.ПредупреждатьОбОпасныхДействиях Тогда
		
		ЗащитаОтОпасныхДействий = Новый ОписаниеЗащитыОтОпасныхДействий();
		ЗащитаОтОпасныхДействий.ПредупреждатьОбОпасныхДействиях = СтрокаРасширения.ПредупреждатьОбОпасныхДействиях;
		РасширениеКонфигурации.ЗащитаОтОпасныхДействий = ЗащитаОтОпасныхДействий;
		
	КонецЕсли;
	
	Если ЗначениеЗаполнено(СтрокаРасширения._ПутьКФайлуРасширения) Тогда
		
		Информация("{%1:%2}: Обновление конфигурации расширение <%3>", СтрокаРасширения.Имя, ВерсияРасширения, НаименованиеРасширения);
		ДвоичныеДанныеРасширения  = Новый ДвоичныеДанные(СтрокаРасширения._ПутьКФайлуРасширения);
		
	Иначе
		
		ДвоичныеДанныеРасширения = Неопределено;
		
	КонецЕсли;
	
	Если РасширениеКонфигурации.ИзменяетСтруктуруДанных() Тогда
		
		Информация("{%1:%2}: Расширение <%3> изменяет метаданные базы", СтрокаРасширения.Имя, ВерсияРасширения, НаименованиеРасширения);
		
	КонецЕсли; 
	
	
	Если ПроверитьВозможностьПрименения(РасширениеКонфигурации, ДвоичныеДанныеРасширения, НаименованиеРасширения, ВерсияРасширения) Тогда
		
		Информация("{%1:%2}: Записываю в базу изменения расширения <%3>", СтрокаРасширения.Имя, ВерсияРасширения, НаименованиеРасширения);
		РасширениеКонфигурации.Записать(ДвоичныеДанныеРасширения);
		
	КонецЕсли;
	
КонецПроцедуры

Функция ПроверитьВозможностьПрименения(Расширение, ДвоичныеДанныеРасширения = Неопределено, НаименованиеРасширения = "", ВерсияРасширения = "0.0.0"); 
	
	СинонимРасширения = ?(ЗначениеЗаполнено(Расширение.Синоним), Расширение.Синоним, НаименованиеРасширения);
	
	Информация("{%1:%2}: Выполняется проверка возможности применения расширения <%3>", НаименованиеРасширения, ВерсияРасширения, СинонимРасширения);
			
	МассивОшибок = Расширение.ПроверитьВозможностьПрименения(ДвоичныеДанныеРасширения);
	
	Если ЕстьКритичныеОшибки(МассивОшибок) Тогда
		ПоказатьРезультатыПроверки(МассивОшибок, НаименованиеРасширения);
		КритичнаяОшибка("{%1:%2}: Применить расширение - невозможно ", НаименованиеРасширения, ВерсияРасширения);
		Возврат Ложь;
	ИначеЕсли МассивОшибок.Количество() > 0 Тогда
		ПоказатьРезультатыПроверки(МассивОшибок, НаименованиеРасширения);
	Конецесли;
	
	Информация("{%1:%2}: Проверка возможности применения расширения <%3> - пройдена", НаименованиеРасширения, ВерсияРасширения, СинонимРасширения);
	
	Возврат Истина;
	
КонецФункции

Функция ЕстьКритичныеОшибки(ПроблемыПримененияРасширения)
	
	Для каждого ИнформацияОПроблемеПримененияРасширения Из ПроблемыПримененияРасширения Цикл
		
		Если ИнформацияОПроблемеПримененияРасширения.Важность = ВажностьПроблемыПримененияРасширенияКонфигурации.Критичная 
			ИЛИ ИнформацияОПроблемеПримененияРасширения.Важность = ВажностьПроблемыПримененияРасширенияКонфигурации.Низкая Тогда
			возврат Истина;
		КонецЕсли;

	КонецЦикла;

	Возврат Ложь;

КонецФункции


Procedure ПоказатьРезультатыПроверки(Знач ПроблемыПримененияРасширения, ЗНач ИмяТекущегоРасширения = "")
	
	For Each ИнформацияОПроблемеПримененияРасширения in ПроблемыПримененияРасширения Do
		ИмяРасширения = ?(ЗначениеЗаполнено(ИнформацияОПроблемеПримененияРасширения.Расширение.Имя),
						ИнформацияОПроблемеПримененияРасширения.Расширение.Имя,
						ИмяТекущегоРасширения);
		СинонимРасширения = ?(ЗначениеЗаполнено(ИнформацияОПроблемеПримененияРасширения.Расширение.Синоним),
							ИнформацияОПроблемеПримененияРасширения.Расширение.Синоним,
							ИмяРасширения); 
		ВерсияРасширения = ?(ЗначениеЗаполнено(ИнформацияОПроблемеПримененияРасширения.Расширение.Версия),
							ИнформацияОПроблемеПримененияРасширения.Расширение.Версия,
							"0.0.0");
		
		
		ТекстОшибки = СтрШаблон("(%1:%2): <%3> - %4",
					ИмяРасширения,
					ВерсияРасширения,
					ИнформацияОПроблемеПримененияРасширения.Важность,
					ИнформацияОПроблемеПримененияРасширения.Описание);
		
		Если ИнформацияОПроблемеПримененияРасширения.Важность = ВажностьПроблемыПримененияРасширенияКонфигурации.Критичная Тогда
			КритичнаяОшибка(ТекстОшибки);
		ИначеЕсли ИнформацияОПроблемеПримененияРасширения.Важность = ВажностьПроблемыПримененияРасширенияКонфигурации.Низкая Тогда
			Ошибка(ТекстОшибки);
		ИначеЕсли ИнформацияОПроблемеПримененияРасширения.Важность = ВажностьПроблемыПримененияРасширенияКонфигурации.Обычная Тогда
			Предупреждение_(ТекстОшибки);
		Иначе
			Информация(ТекстОшибки);
		КонецЕсли;

	EndDo;
	
EndProcedure

#КонецОбласти

Процедура ДополнитьТаблицуРасширений()
	
	Если ДанныеОбновленияРасширений.Свойство("ОтключитьВсеРасширения") 
		И ДанныеОбновленияРасширений.ОтключитьВсеРасширения Тогда
		
		ТаблицаРасширений.ЗаполнитьЗначения(Истина, "_Отключить");
		Возврат;
		
	КонецЕсли; 
	
	НаборРасширений = ДанныеОбновленияРасширений.НаборРасширений;
	
	Для Каждого ОписаниеРасширения Из НаборРасширений Цикл
		
		СтрокаТаблицаРасширения = НайтиРасширениеПоИмени(ОписаниеРасширения.Имя);
		
		Если СтрокаТаблицаРасширения = Неопределено Тогда
			
			Если НЕ ОписаниеРасширения.Свойство("ПутьКФайлуОбновления") Тогда
				Продолжить;
			КонецЕсли;
			
			ПутьКФайлуОбновления = ОписаниеРасширения.ПутьКФайлуОбновления;
			
			Если ПустаяСтрока(ПутьКФайлуОбновления) Тогда
				
				Продолжить;
				
			КонецЕсли;
			
			НоваяСтрока = ТаблицаРасширений.Добавить();
			НоваяСтрока.Имя = ОписаниеРасширения.Имя;
			НоваяСтрока._Добавить = Истина;
			НоваяСтрока.Активно = Истина;
			НоваяСтрока.БезопасныйРежим = Истина;
			// НоваяСтрока.ОбластьДействия = ОбластьДействияРасширенияКонфигурации.ИнформационнаяБаза;
			НоваяСтрока._ПутьКФайлуРасширения = ПутьКФайлуОбновления;
			ЗаполнитьЗащитаОтОпасныхДействий(НоваяСтрока);
			
			СтрокаТаблицаРасширения = НоваяСтрока;
			
			
		КонецЕсли;
		
		ОпределитьИзмененияРасширения(СтрокаТаблицаРасширения, ОписаниеРасширения);
		
	КонецЦикла; 
	
КонецПроцедуры

Процедура ЗаполнитьЗащитаОтОпасныхДействий(СтрокаТаблицы, ПредупреждатьОбОпасныхДействиях = Истина)
	
	ЗащитаОтОпасныхДействий = Новый ОписаниеЗащитыОтОпасныхДействий();
	ЗащитаОтОпасныхДействий.ПредупреждатьОбОпасныхДействиях = ПредупреждатьОбОпасныхДействиях;
	СтрокаТаблицы.ЗащитаОтОпасныхДействий = ЗащитаОтОпасныхДействий;
	СтрокаТаблицы.ПредупреждатьОбОпасныхДействиях = ПредупреждатьОбОпасныхДействиях;
	
КонецПроцедуры

Процедура ОчиститьЛоггер()
	
	Логгер = Новый Структура;
	
КонецПроцедуры

Процедура ОпределитьИзмененияРасширения(СтрокаТаблицаРасширения, ОписаниеРасширения)
	
	Если ОписаниеРасширения.Свойство("Удалить")
		И ОписаниеРасширения.Удалить Тогда
		СтрокаТаблицаРасширения._Удалить = Истина;
		Возврат;
	ИначеЕсли ОписаниеРасширения.Свойство("Отключить")
		И ОписаниеРасширения.Отключить Тогда
		
		СтрокаТаблицаРасширения._Отключить = Истина;
		Возврат;
	КонецЕсли;
	
	
	Если ОписаниеРасширения.Свойство("Активно")
		И НЕ ОписаниеРасширения.Активно = СтрокаТаблицаРасширения.Активно Тогда
		
		СтрокаТаблицаРасширения._Изменить = Истина;
		СтрокаТаблицаРасширения.Активно = ОписаниеРасширения.Активно;
		
	КонецЕсли;
	
	ПутьКФайлуОбновления = Неопределено;
	
	Если ОписаниеРасширения.Свойство("ПутьКФайлуОбновления", ПутьКФайлуОбновления)
		И ЗначениеЗаполнено(ПутьКФайлуОбновления) Тогда
		
		СтрокаТаблицаРасширения._Изменить = Истина;
		СтрокаТаблицаРасширения._ПутьКФайлуРасширения = ПутьКФайлуОбновления;
		
	КонецЕсли;
	
	БезопасныйРежим = Неопределено;
	
	Если ОписаниеРасширения.Свойство("БезопасныйРежим", БезопасныйРежим)
		И ТипЗнч(БезопасныйРежим) = Тип("Булево") Тогда
		Если НЕ БезопасныйРежим = СтрокаТаблицаРасширения.БезопасныйРежим Тогда
			
			СтрокаТаблицаРасширения._Изменить = Истина;
			СтрокаТаблицаРасширения.БезопасныйРежим = БезопасныйРежим;
		КонецЕсли;
	КонецЕсли;
	
	
	ПредупреждатьОбОпасныхДействиях = Неопределено;
	
	Если ОписаниеРасширения.Свойство("ЗащитаОтОпасныхДействий", ПредупреждатьОбОпасныхДействиях)
		И ЗначениеЗаполнено(ПредупреждатьОбОпасныхДействиях)
		И НЕ ПредупреждатьОбОпасныхДействиях = СтрокаТаблицаРасширения.ЗащитаОтОпасныхДействий.ПредупреждатьОбОпасныхДействиях Тогда
		
		СтрокаТаблицаРасширения._Изменить = Истина;
		СтрокаТаблицаРасширения.ПредупреждатьОбОпасныхДействиях = ПредупреждатьОбОпасныхДействиях;
		
	КонецЕсли;
	
	
КонецПроцедуры

Функция ОбработатьТаблицуРасширений()
	
	ОчиститьЛоггер();
	
	Для каждого СтрокаРасширения Из ТаблицаРасширений Цикл
		
		ВерсияРасширения = ?(ЗначениеЗаполнено(СтрокаРасширения.Версия), СтрокаРасширения.Версия, "0.0.0");
		
		Логгер = НовыйЛоггер("Имя, UID, Версия", СтрокаРасширения.Имя, Строка(СтрокаРасширения.УникальныйИдентификатор), ВерсияРасширения);
		
		Если СтрокаРасширения._Удалить Тогда
			
			Информация("{%1:%2}: Удаление расширение <%3> (Версия: <%2>)", СтрокаРасширения.Имя, ВерсияРасширения, СтрокаРасширения.Синоним); 
			
			РасширениеКонфигурации = НайтиУстановленноеРасширениеПоИмени(СтрокаРасширения.Имя);
			РасширениеКонфигурации.УдалитЬ();
			ОчиститьЛоггер();
			
			Продолжить;
			
		ИначеЕсли СтрокаРасширения._Отключить Тогда
			
			Информация("{%1:%2}: Отключаю расширение <%3> (Версия: <%2>)", СтрокаРасширения.Имя, ВерсияРасширения, СтрокаРасширения.Синоним); 
			
			РасширениеКонфигурации = НайтиУстановленноеРасширениеПоИмени(СтрокаРасширения.Имя);
			ОтключитьРасширение(РасширениеКонфигурации); 
			
			Продолжить;
			
		ИначеЕсли СтрокаРасширения._Добавить Тогда
			
			Информация("{%1:%2}: Добавляю новое расширение <%1>", СтрокаРасширения.Имя, ВерсияРасширения); 
			РасширениеКонфигурации = РасширенияКонфигурации.Создать();
			
			Логгер = НовыйЛоггер("Имя, UID, Версия", СтрокаРасширения.Имя, "", ВерсияРасширения);
			ИзменитьРасширение(РасширениеКонфигурации, СтрокаРасширения); 
			
		ИначеЕсли СтрокаРасширения._Изменить Тогда
			
			Информация("{%1:%2}: Изменяю расширение <%3> (Версия: <%2>)", СтрокаРасширения.Имя, ВерсияРасширения, СтрокаРасширения.Синоним); 
			РасширениеКонфигурации  = НайтиУстановленноеРасширениеПоИмени(СтрокаРасширения.Имя);
			ИзменитьРасширение(РасширениеКонфигурации, СтрокаРасширения); 
			
		КонецЕсли;
		
	КонецЦикла; 
	
	ОчиститьЛоггер();
	
КонецФункции

Функция НайтиРасширениеПоИмени(Знач ИмяРасширения)
	
	Возврат ТаблицаРасширений.Найти(ИмяРасширения, "Имя"); 
	
КонецФункции

Процедура ПрочитатьФайлОбновления()
	
	ЧтениеJSON = Новый ЧтениеJSON;
	ЧтениеJSON.ОткрытьФайл(ПутьКФайлуОбновленияРасширения);
	
	ДанныеОбновленияРасширений = ПрочитатьJSON(ЧтениеJSON, Ложь);
	
КонецПроцедуры

Процедура НачатьРаботу() Экспорт
	
	МассивПараметров = СтрРазделить(ПараметрЗапускаОбработки,"|");
	
	Если НЕ МассивПараметров.Количество() = 2 Тогда
		Сообщить("Передано не корректное количество параметров запуска");
		Возврат;
	КонецЕсли;
	
	ПутьКФайлуОбновленияРасширения = МассивПараметров[0];
	ПутьКФайлуЛогаОбновления = МассивПараметров[1];
	
	ПодготовитьЛог();
	
	Информация("Начало обновления расширений конфигурации");
	
	ОбновитьТаблицуРасширений();
	ПрочитатьФайлОбновления();
	
	ДополнитьТаблицуРасширений();
	
	ОбработатьТаблицуРасширений();
	
	Информация("Завершено обновления расширений конфигурации");
	
	ЗавершитьЗаписьЛога();
	
КонецПроцедуры


#Если ТолстыйКлиентОбычноеПриложение Тогда

ПараметрЗапускаОбработки = ПараметрЗапуска;

Попытка
	НачатьРаботу();	
Исключение
	Сообщить(ОписаниеОшибки());
КонецПопытки;

ЗавершитьРаботуСистемы(Ложь,Ложь);

#КонецЕсли


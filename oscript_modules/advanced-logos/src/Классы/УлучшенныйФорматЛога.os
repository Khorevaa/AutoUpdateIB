#Использовать logos

Перем ВыводитьМеткиЦвета;
Перем ВыводитьДату;
Перем ИспользоватьПрефиксы;
Перем КартаУровней;
Перем ФорматДатыСобытия;
Перем ЧасовойПояс;

Функция ПолучитьФорматированноеСообщение(Знач СобытиеЛога) Экспорт
   
	// СобытиеЛога - Объект с методами
	//   * ПолучитьУровень() - Число - уровень лога
	//   * ПолучитьСообщение() - Строка - текст сообщения
	//   * ПолучитьИмяЛога() - Строка - имя лога
	//   * ПолучитьВремяСобытия() - Число - Универсальная дата-время события в миллисекундах
	//   * ПолучитьДополнительныеПоля() - Соответствие - дополнительные поля события
   
	Если ТипЗнч(СобытиеЛога) = Тип("СобытиеЛога") Тогда

		РасширенноеСобытиеЛога = Новый РасширенноеСобытиеЛога;
		РасширенноеСобытиеЛога.ИзСобытияЛога(СобытиеЛога);
	
	Иначе

		РасширенноеСобытиеЛога = СобытиеЛога;

	КонецЕсли;
	
	Сообщение = РасширенноеСобытиеЛога.ПолучитьСообщение();
	УровеньСообщения = РасширенноеСобытиеЛога.ПолучитьУровень();
	ДатаСобытия = РасширенноеСобытиеЛога.ПолучитьВремяСобытия();
	ДопПоля = РасширенноеСобытиеЛога.ПолучитьДополнительныеПоля();
	ИмяЛога = РасширенноеСобытиеЛога.ПолучитьИмяЛога();

	ОбработатьДопПоля(ДопПоля, РасширенноеСобытиеЛога.ПолучитьУровеньЛога());

	ФорматированноеСообщение = СформироватьФорматированныеСообщение(ДатаСобытия, УровеньСообщения, 
																	Сообщение,
																	ДопПоля, ИмяЛога);

	Возврат ФорматированноеСообщение;
 
КонецФункции

Функция СформироватьФорматированныеСообщение(Знач ДатаСобытия, Знач УровеньСообщения, Знач Сообщение, Знач ДопПоля, Знач ИмяЛога)
	 
	МассивСтрокВывода = Новый Массив();

	ДобавитьВыводДатыСобытия(МассивСтрокВывода, ДатаСобытия);

	ДобавитьВыводУровняСообщения(МассивСтрокВывода, УровеньСообщения);

	ДобавитьВыводПрефикса(МассивСтрокВывода, ДопПоля, ИмяЛога);

	ДобавитьВыводСообщения(МассивСтрокВывода, Сообщение);
	
	ДобавитьВыводДополнительныхПолей(МассивСтрокВывода, ДопПоля, УровеньСообщения);

	СообщениеВывода = СтрСоединить(МассивСтрокВывода, " ");	

	Возврат СообщениеВывода;

КонецФункции

Процедура ДобавитьМеткуЦвета(ТекстМетки, Знач ИмяМетки)
	
	ТекстМетки = СтрШаблон("|C=%1|%2", ИмяМетки, ТекстМетки);

КонецПроцедуры

Процедура ДобавитьВыводДатыСобытия(Знач МассивСтрок, Знач ДатаСобытияВМиллисекундах)
	
	Если НЕ ВыводитьДату Тогда
		Возврат;
	КонецЕсли;
	
	СтруктураДаты = РазложитьДатуВМиллисекундах(ДатаСобытияВМиллисекундах);

    ФорматированнаяДатаСобытия = ФорматироватьДатуСобытия(СтруктураДаты.Дата, СтруктураДаты.Миллисекунды);

	Если ВыводитьМеткиЦвета Тогда
		ДобавитьМеткуЦвета(ФорматированнаяДатаСобытия, "D");
	КонецЕсли;

	МассивСтрок.Добавить(ФорматированнаяДатаСобытия);

КонецПроцедуры

Функция РазложитьДатуВМиллисекундах(УниверсальнаяДатаВМиллисекундах)
	
	ПолныеМиллисекунды = Окр(ТекущаяУниверсальнаяДатаВМиллисекундах(), 0);

	ОкругленныеМС = Окр(ПолныеМиллисекунды/1000, 0, 0) * 1000;
	Миллисекунды = ПолныеМиллисекунды - ОкругленныеМС;
	
	Если Миллисекунды < 0 Тогда
		Миллисекунды = 1000 + Миллисекунды;
	КонецЕсли;

	Секунды = (ПолныеМиллисекунды - Миллисекунды)/1000;

	ТиповаяДата = Дата("00010101") + Секунды;
    
	Возврат Новый Структура("Дата, Секунды, Миллисекунды", ТиповаяДата, Секунды, Миллисекунды);

КонецФункции

Процедура ДобавитьВыводПрефикса(Знач МассивСтрок, Знач ДопПоля, Знач ИмяЛога)
	
	Если НЕ ИспользоватьПрефиксы Тогда
		Возврат;
	КонецЕсли;

	Префикс = ПолучитьПрефикс(ИмяЛога, ДопПоля);

	СтрокаПрефикс = СтрШаблон("%1:", Префикс);

	Если ВыводитьМеткиЦвета Тогда
		ДобавитьМеткуЦвета(СтрокаПрефикс, "P");
	КонецЕсли;

	МассивСтрок.Добавить(СтрокаПрефикс);

КонецПроцедуры

Процедура ДобавитьВыводСообщения(Знач МассивСтрок, Знач СообщениеСобытия)
	
	Если ВыводитьМеткиЦвета Тогда
		ДобавитьМеткуЦвета(СообщениеСобытия, "T");
	КонецЕсли;

	МассивСтрок.Добавить(СообщениеСобытия);

КонецПроцедуры

Процедура ДобавитьВыводУровняСообщения(Знач МассивСтрок, Знач УровеньСообщения)
	
	ФорматированныйУровеньСообщения = ФорматироватьУровеньСообщения(УровеньСообщения);

	Если ВыводитьМеткиЦвета Тогда
		ДобавитьМеткуЦвета(ФорматированныйУровеньСообщения, УровеньСообщения);
	КонецЕсли;

	МассивСтрок.Добавить(ФорматированныйУровеньСообщения);

КонецПроцедуры

Процедура ОбработатьДопПоля(пДополнительныеПоля, Знач ТекущийУровеньЛога)
	
	мДополнительныеПоляЛога = Новый Соответствие();

	Для каждого ДопПоле Из пДополнительныеПоля Цикл
		
		Ключ = ДопПоле.Ключ;
		ЗначениеКлюча = ДопПоле.Значение;
	
		Если ТипЗнч(ЗначениеКлюча) = Тип("ИнформацияОбОшибке") Тогда
			
			мДополнительныеПоляЛога.Вставить(ДопПоле.Ключ, ЗначениеКлюча.Описание);
			
			Если ТекущийУровеньЛога = УровниЛога.Отладка Тогда
				
				мДополнительныеПоляЛога.Вставить(СтрШаблон("%1.%2", ДопПоле.Ключ, "ИмяМодуля"), ЗначениеКлюча.ИмяМодуля);
				мДополнительныеПоляЛога.Вставить(СтрШаблон("%1.%2", ДопПоле.Ключ, "НомерСтроки"), ЗначениеКлюча.НомерСтроки);
				
				Если ЗначениеЗаполнено(ЗначениеКлюча.Параметры) Тогда
					мДополнительныеПоляЛога.Вставить(СтрШаблон("%1.%2", ДопПоле.Ключ, "Параметры"), ЗначениеКлюча.Параметры);				
				КонецЕсли;
		
			КонецЕсли;
	
		Иначе
			мДополнительныеПоляЛога.Вставить(ДопПоле.Ключ, ЗначениеКлюча);
		
		КонецЕсли;
		
	КонецЦикла;

	пДополнительныеПоля = мДополнительныеПоляЛога;

КонецПроцедуры

Процедура ДобавитьВыводДополнительныхПолей(Знач МассивСтрок, Знач ДопПоля, Знач УровеньСообщения)
	
	Для каждого Поле Из ДопПоля Цикл
		
		ИмяПоля = Поле.Ключ;

		Если ЭтоПолеПрефикса(ИмяПоля) Тогда
			Продолжить;
		КонецЕсли;
		
		ЗначениеПоля = Поле.Значение;
		ЗначениеПоля = "=" + ЗначениеПоля;

		Если ВыводитьМеткиЦвета Тогда
			ДобавитьМеткуЦвета(ИмяПоля, УровеньСообщения);
			ДобавитьМеткуЦвета(ЗначениеПоля, "T");
		КонецЕсли;
		
		СтрокаЗначениеПоля = СтрШаблон("%1%2", ИмяПоля, ЗначениеПоля);
		
		МассивСтрок.Добавить(СтрокаЗначениеПоля);

	КонецЦикла;

КонецПроцедуры

// Отключение вывода даты сообщения события
//
Процедура ОтключитьДатуСобытия() Экспорт
	ВыводитьДату = Ложь;
КонецПроцедуры

 // Отключение вывода меток цветов
//
Процедура ОтключитьВыводМетокЦвета() Экспорт
	ВыводитьМеткиЦвета = Ложь;
КонецПроцедуры

// Отключение использования префиксов
//
Процедура ОтключитьПрефиксы() Экспорт
	ИспользоватьПрефиксы = Ложь;
КонецПроцедуры

// Устанавливает карту уровней сообщений на русском языке
//
// УровниЛога.Отладка    		= "   ОТЛАДКА"
// УровниЛога.Информация 		= "ИНФОРМАЦИЯ"
// УровниЛога.Предупреждение 	= "  ВНИМАНИЕ"
// УровниЛога.Ошибка			- "    ОШИБКА"
// УровниЛога.КритичнаяОшибка 	= " КРИТИЧНАЯ"
//
Процедура УровниСообщенияНаРусском() Экспорт
	УстановитьКартуУровней(КартаУровнейНаРусском());
КонецПроцедуры

// Устанавливает карту уровней сообщений по умолчанию 
//
// УровниЛога.Отладка    		= "DEBUG"
// УровниЛога.Информация 		= " INFO"
// УровниЛога.Предупреждение 	= " WARN"
// УровниЛога.Ошибка			- "ERROR"
// УровниЛога.КритичнаяОшибка 	= "FATAL"
//
Процедура УровниСообщенияПоУмолчанию() Экспорт
	УстановитьКартуУровней(КартаУровнейПоУмолчанию());
КонецПроцедуры

// Устанавливает произвольную карту уровней сообщений
//
// Параметры:
//   НоваяКартаУровней - Соответствие - карта соответствия уровней лога их названиям
//
Процедура УстановитьКартуУровней(Знач НоваяКартаУровней) Экспорт
	
	Для каждого КлючЗначение Из НоваяКартаУровней Цикл
		КартаУровней.Вставить(КлючЗначение.Ключ, КлючЗначение.Значение);
	КонецЦикла;

КонецПроцедуры

// Устанавливает произвольный формат вывода даты
//
// Параметры:
//   ФорматДаты - Строка - строковое представление формата для вывода даты
//
Процедура УстановитьФорматДатыСобытия(Знач ФорматДаты) Экспорт
	ФорматДатыСобытия = СтрШаблон("ДФ='%1'", ФорматДаты);
КонецПроцедуры


Функция ЭтоПолеПрефикса(Знач ИмяПоля)
	
	Возврат НРег(ИмяПоля) = "prefix"
		ИЛИ НРег(ИмяПоля) = "префикс"
		ИЛИ НРег(ИмяПоля) = "модуль";

КонецФункции

Функция ПолучитьПрефикс(Знач ИмяЛога, Знач Поля)

	Префикс = ПрефиксИзИмениЛога(ИмяЛога);
	ПрефиксПоля = "";
	Для каждого Поле Из Поля Цикл
		ИмяПоля = Поле.Ключ;

		Если ЭтоПолеПрефикса(ИмяПоля) Тогда
			ПрефиксПоля = Поле.Значение;
			Прервать;
		КонецЕсли;
		
	КонецЦикла;

	Если ЗначениеЗаполнено(ПрефиксПоля) Тогда
		Префикс = СтрШаблон("%1.%2", Префикс, ПрефиксПоля);
	КонецЕсли;

	Возврат Префикс;

КонецФункции

Функция ПрефиксИзИмениЛога(Знач ИмяЛога)

	Если СтрНачинаетсяС(НРег(ИмяЛога), "oscript.") Тогда
		ИмяЛога = Сред(ИмяЛога, 9);
	КонецЕсли;

	Возврат ИмяЛога;
	
КонецФункции

Функция КартаУровнейПоУмолчанию()
	
	КартаСтатусовИУровней = Новый Соответствие;
	КартаСтатусовИУровней.Вставить(УровниЛога.Отладка, 			"DEBUG");//  ОТЛАДКА
	КартаСтатусовИУровней.Вставить(УровниЛога.Информация, 		" INFO");//     ИНФО
	КартаСтатусовИУровней.Вставить(УровниЛога.Предупреждение,  	" WARN");// ВНИМАНИЕ 
	КартаСтатусовИУровней.Вставить(УровниЛога.Ошибка, 		   	"ERROR");//   ОШИБКА
	КартаСтатусовИУровней.Вставить(УровниЛога.КритичнаяОшибка, 	"FATAL");// КРИТИЧНА

	Возврат КартаСтатусовИУровней;

КонецФункции

Функция КартаУровнейНаРусском()
	
	КартаСтатусовИУровней = Новый Соответствие;
	КартаСтатусовИУровней.Вставить(УровниЛога.Отладка, 			"   ОТЛАДКА");//  ОТЛАДКА
	КартаСтатусовИУровней.Вставить(УровниЛога.Информация, 		"ИНФОРМАЦИЯ");//     ИНФО
	КартаСтатусовИУровней.Вставить(УровниЛога.Предупреждение, 	"  ВНИМАНИЕ");// ВНИМАНИЕ 
	КартаСтатусовИУровней.Вставить(УровниЛога.Ошибка, 			"    ОШИБКА");//   ОШИБКА
	КартаСтатусовИУровней.Вставить(УровниЛога.КритичнаяОшибка, 	" КРИТИЧНАЯ");// КРИТИЧНА

	Возврат КартаСтатусовИУровней;

КонецФункции

Функция ФорматироватьДатуСобытия(Знач ДатаСобытия, Знач МилисекундыСобытия)

	ДатаСобытияПоФормату = Формат(ДатаСобытия, ФорматДатыСобытия);

	Если СтрНайти(ФорматДатыСобытия, ".%1") > 0 Тогда
		ДатаСобытияПоФормату = СтрШаблон(ДатаСобытияПоФормату, Формат(МилисекундыСобытия, "ЧЦ=3; ЧВН="));
	КонецЕсли;

	Возврат ДатаСобытияПоФормату;
КонецФункции

Функция ФорматироватьУровеньСообщения(Знач УровеньСообщения)
	Возврат КартаУровней[УровеньСообщения];
КонецФункции

Функция ПолучитьЧасовойПояс()
	
	ЛокальнаяДата = ТекущаяДата();
	УниверсальнаяДата = Дата("00010101") + (ТекущаяУниверсальнаяДатаВМиллисекундах() / 1000);	

	Возврат ЛокальнаяДата - УниверсальнаяДата;

КонецФункции


Процедура ПриСозданииОбъекта(Знач ПВыводитьМеткиЦвета = Ложь, 
							Знач ПИспользоватьПрефиксы = Истина, 
							Знач ПВыводитьДату = Истина)

	ИспользоватьПрефиксы = Истина;//ПИспользоватьПрефиксы;
	ВыводитьМеткиЦвета = Истина;//ПВыводитьМеткиЦвета;
	ВыводитьДату = Истина;//ПВыводитьДату;

	КартаУровней = КартаУровнейПоУмолчанию();

	ФорматДаты = "[yyyy/MM/dd HH:mm:ss.%1]";
	
	ЧасовойПояс = ПолучитьЧасовойПояс();

КонецПроцедуры

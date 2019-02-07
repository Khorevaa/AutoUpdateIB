#Использовать logos

Перем ФорматДатыСобытия;
Перем КартаУровней;
Перем ПараметрыЗаписиJSON;

Функция ПолучитьФорматированноеСообщение(Знач СобытиеЛога) Экспорт
   
	// СобытиеЛога - Объект с методами
	//   * ПолучитьУровень() - Число - уровень лога
	//   * ПолучитьСообщение() - Строка - текст сообщения
	//   * ПолучитьИмяЛога() - Строка - имя лога
	//   * ПолучитьВремяСобытия() - Число - Универсальная дата-время события в миллисекундах
	//   * ПолучитьДополнительныеПоля() - Соответствие - дополнительные поля события
   
	Сообщение = СобытиеЛога.ПолучитьСообщение();
	УровеньСообщения = СобытиеЛога.ПолучитьУровень();
	ДатаСобытия = СобытиеЛога.ПолучитьВремяСобытия();
	ДопПоля = СобытиеЛога.ПолучитьДополнительныеПоля();
	ИмяЛога = СобытиеЛога.ПолучитьИмяЛога();

	ФорматированноеСообщение = СформироватьФорматированныеСообщение(ДатаСобытия, УровеньСообщения, 
																	Сообщение,
																	ДопПоля, ИмяЛога);

	Возврат ФорматированноеСообщение;
 
КонецФункции

Функция СформироватьФорматированныеСообщение(Знач ДатаСобытияВМилисекундах, Знач УровеньСообщения, Знач Сообщение, Знач ДопПоля, Знач ИмяЛога)
	
	ДатаВСекундах = ДатаСобытияВМилисекундах/1000;
	ДатаСобытия = Дата("00010101") + ДатаВСекундах;
	МилисекундыСобытия = Цел((ДатаВСекундах - Цел(ДатаВСекундах))*1000);
	
	ФорматированнаяДатаСобытия = ФорматироватьДатуСобытия(ДатаСобытия, МилисекундыСобытия);

	СтруктураЛога = Новый Структура;
	СтруктураЛога.Вставить("time", ФорматированнаяДатаСобытия);
	СтруктураЛога.Вставить("level", ФорматироватьУровеньСообщения(УровеньСообщения));
	СтруктураЛога.Вставить("msg", Сообщение);
	СтруктураЛога.Вставить("log", ИмяЛога);
	
	Для каждого ПолеЛога Из ДопПоля Цикл
		Значение = ПолеЛога.Значение;
		ТипЗначения =ТипЗнч(Значение);
		Если ТипЗначения = Тип("Строка")
			ИЛИ ТипЗначения = Тип("Число")
			ИЛИ ТипЗначения = Тип("Дата")
			ИЛИ ТипЗначения = Тип("Булево") Тогда
			// Все хорошо эти типы сериализуются
		Иначе

			Значение = Строка(Значение);
			
		КонецЕсли;

		СтруктураЛога.Вставить(ПолеЛога.Ключ, ПолеЛога.Значение);
			
	КонецЦикла;

	ЗаписьJSON = Новый ЗаписьJSON();
	ЗаписьJSON.УстановитьСтроку(ПараметрыЗаписиJSON);

	ЗаписатьJSON(ЗаписьJSON, СтруктураЛога);

	Возврат ЗаписьJSON.Закрыть();

КонецФункции

// {"animal":"walrus","level":"info","msg":"Tremendously sized cow enters the ocean.",
// "size":9,"time":"2014-03-10 19:57:38.562527896 -0400 EDT"}

// Устанавливает произвольный формат вывода даты
//
// Параметры:
//   ФорматДаты - Строка - строковое представление формата для вывода даты
//
Процедура УстановитьФорматДатыСобытия(Знач ФорматДаты)
	ФорматДатыСобытия = СтрШаблон("ДФ='%1'", ФорматДаты);
КонецПроцедуры

Функция ФорматироватьДатуСобытия(Знач ДатаСобытия, Знач МилисекундыСобытия)
	Возврат СтрШаблон(Формат(ДатаСобытия, ФорматДатыСобытия), Формат(МилисекундыСобытия, "ЧЦ=3; ЧВН="));
КонецФункции

Функция ФорматироватьУровеньСообщения(Знач УровеньСообщения)
	
	СтрокаУровня = КартаУровней[УровеньСообщения];

	Если СтрокаУровня = Неопределено Тогда
		СтрокаУровня = КартаУровней[0];
	КонецЕсли;

	Возврат СтрокаУровня;

КонецФункции

Функция КартаУровнейПоУмолчанию()
	
	КартаСтатусовИУровней = Новый Соответствие;
	КартаСтатусовИУровней.Вставить(УровниЛога.Отладка, 			"DEBUG");//  ОТЛАДКА
	КартаСтатусовИУровней.Вставить(УровниЛога.Информация, 		"INFO");//     ИНФО
	КартаСтатусовИУровней.Вставить(УровниЛога.Предупреждение,  	"WARN");// ВНИМАНИЕ 
	КартаСтатусовИУровней.Вставить(УровниЛога.Ошибка, 		   	"ERROR");//   ОШИБКА
	КартаСтатусовИУровней.Вставить(УровниЛога.КритичнаяОшибка, 	"FATAL");// КРИТИЧНА

	Возврат КартаСтатусовИУровней;

КонецФункции

Процедура ПриСозданииОбъекта()

	УстановитьФорматДатыСобытия("yyyy-MM-ddTHH:mm:ss.%1Z");
	КартаУровней = КартаУровнейПоУмолчанию();
	ПараметрыЗаписиJSON = Новый ПараметрыЗаписиJSON(ПереносСтрокJSON.Нет, ,, Истина, Истина, Истина, Истина, Истина, Истина);
	
КонецПроцедуры
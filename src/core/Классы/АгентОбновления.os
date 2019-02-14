#Использовать "./internal"
#Использовать logos
#Использовать json
#Использовать datetime

Перем Лог;
Перем ОбщийЛог;

Перем МаксимальноеКоличествоРабочихПроцессов;
Перем КомандаПроцессаАгента;
Перем ПутьКФайлуСкрипта;

Перем ТаймерПовторенияОпроса;
Перем ТаймерОпросаРабочихПроцессов;
Перем ТаймаутРабочегоПроцесса;
Перем ПараллельныеПроцессы;
Перем СчетчикПроцессов;
Перем РабочийКаталогПроцессов;
Перем ДанныеПоСистеме;

Перем НастройкаRMQ;
Перем КлиентRMQ;
Перем Идентификатор;
Перем ПользовательОС;
Перем ИмяКомпьютера;
Перем Отладка;

Процедура УстановитьКоличествоРабочихПроцессов(Знач НовоеМаксимальноеКоличествоРабочихПроцессов) Экспорт
	
	Если НовоеМаксимальноеКоличествоРабочихПроцессов = 0 Тогда
		Возврат;
	КонецЕсли;
	
	МаксимальноеКоличествоРабочихПроцессов = НовоеМаксимальноеКоличествоРабочихПроцессов;

КонецПроцедуры

Процедура УстановитьОткладку(Знач ПОтладка) Экспорт
	Отладка = ПОтладка;
КонецПроцедуры

Процедура УстановитьТаймерОпроса(Знач НовыйТаймерПовторенияОпроса) Экспорт
	ТаймерПовторенияОпроса = НовыйТаймерПовторенияОпроса;
КонецПроцедуры

Процедура УстановитьТаймерОпросаРабочихПроцессов(Знач НовыйТаймер) Экспорт
	ТаймерОпросаРабочихПроцессов = НовыйТаймер;
КонецПроцедуры

Процедура УстановитьТаймаутРабочегоПроцесса(Знач НовыйТаймаут) Экспорт
	ТаймаутРабочегоПроцесса = НовыйТаймаут;
КонецПроцедуры

Процедура УстановитьРабочийКаталогПроцессов(Знач ПутьККаталогу) Экспорт
	РабочийКаталогПроцессов = ПутьККаталогу;
КонецПроцедуры

Процедура НастроитьRMQ(Знач НовыеНастройкиПодключенияRMQ) Экспорт
	
	НастройкаRMQ = НовыеНастройкиПодключенияRMQ;

	КлиентRMQ = Новый КлиентRMQ();
	КлиентRMQ.УстановитьНастройкиПодключения(НастройкаRMQ);
	КлиентRMQ.УстановитьВиртуальныйХост(НастройкаRMQ.ВиртуальныйХост);

КонецПроцедуры

Процедура Запустить() Экспорт
	
	ПроверитьВозможностьЗапуска();

	ОтправитьСообщениеОРегистрацииАгента();

	Лог.Поля("task", "Регистрация агента").Информация("Агент запущен");

	Пока Истина Цикл

		ЦиклЗапускаРабочихПроцессов();

		Если ТаймерПовторенияОпроса = 0 Тогда
			Прервать;
		КонецЕсли;
		
		Подождать(ТаймерПовторенияОпроса);
	
	КонецЦикла;

	Лог.Поля("task", "Регистрация агента").Информация("Агент завершил работу");

КонецПроцедуры

Процедура ОтправитьСообщениеОРегистрацииАгента()

	ДатаРегистрации = ТекущаяУниверсальнаяДатаВМиллисекундах();
	
	ДатаВСекундах = ДатаРегистрации/1000;
    ДатаСобытия = Дата("00010101") + ДатаВСекундах;
    МилисекундыСобытия = Цел((ДатаВСекундах - Цел(ДатаВСекундах))*1000);
    
 	ФорматДатыСобытия = "ДФ='yyyy-MM-ddTHH:mm:ss.%1Z'";
	ФорматированнаяДатаСобытия = СтрШаблон(Формат(ДатаСобытия, ФорматДатыСобытия), Формат(МилисекундыСобытия, "ЧЦ=3; ЧВН="));

	ДанныеСообщения = Новый Структура();
	ДанныеСообщения.Вставить("msg", СтрШаблон("Агент <%1> запущен", Идентификатор));
	ДанныеСообщения.Вставить("task", "Регистрация агента");
	ДанныеСообщения.Вставить("time", ФорматированнаяДатаСобытия);
	ДанныеСообщения.Вставить("log", "oscript.app.AutoUpdateIB");
	ДанныеСообщения.Вставить("status", "success");
	ДанныеСообщения.Вставить("agent", Идентификатор);
	ДанныеСообщения.Вставить("ПользовательОС", ПользовательОС);
	ДанныеСообщения.Вставить("ИмяКомпьютера", ИмяКомпьютера);
	ДанныеСообщения.Вставить("Префикс", "agent");
	
	МеткаВремени = РаботаСДатой.ВМеткуВремени(ДатаСобытия);
		
	СообщениеRMQ = Новый СообщениеRMQ;
	СообщениеRMQ.Параметр("МоментВремени", МеткаВремени);
	
	СообщениеRMQ.КлючМаршрутизации = Строка(НастройкаRMQ.ИмяОчередиЛогов);
	
	ПарсерJSON = Новый ПарсерJSON;
	ТекстДанныхСообщения = ПарсерJSON.ЗаписатьJSON(ДанныеСообщения);

	СообщениеRMQ.ДанныеСообщения = ТекстДанныхСообщения;

	КлиентRMQ.ОтправитьСообщениеRMQ(СообщениеRMQ);

КонецПроцедуры

Процедура ЦиклЗапускаРабочихПроцессов()
	
	Пока Истина Цикл
	
		ОчиститьЗавершенныеПроцессы();

		Если КоличествоРабочихПроцессов() = МаксимальноеКоличествоРабочихПроцессов Тогда
	
			ОпроситьПроцессыПоТаймауту();
			
		Иначе 

			КоличествоСообщенийВОчереди = КоличествоСообщенийВОчереди();
			
			Если КоличествоСообщенийВОчереди > 0  Тогда
			
				КоличествоПроцессов = Мин(КоличествоСообщенийВОчереди, МаксимальноеКоличествоРабочихПроцессов - КоличествоРабочихПроцессов());

				ЗапуститьПаралельно(КоличествоПроцессов);
			
			ИначеЕсли КоличествоРабочихПроцессов() = 0 Тогда

				Прервать;
			
			Иначе

				ОпроситьПроцессыПоТаймауту();
			
			КонецЕсли;
		
		КонецЕсли;

		Подождать(Макс(ТаймерОпросаРабочихПроцессов, ТаймерПовторенияОпроса));
			
	КонецЦикла;

КонецПроцедуры

Процедура Подождать(Знач Секунды)
	Приостановить(Секунды * 1000);
КонецПроцедуры

Функция КоличествоРабочихПроцессов()
	Возврат ПараллельныеПроцессы.Количество();
КонецФункции

Процедура ПроверитьВозможностьЗапуска()
	
	Если КлиентRMQ = Неопределено Тогда
		ВызватьИсключение "Не настроена очередь RabbitMQ";
	КонецЕсли;

КонецПроцедуры

Функция КоличествоСообщенийВОчереди()
	
	КоличествоСообщенийВОчереди = КлиентRMQ.КоличествоСообщенийВОчереди(НастройкаRMQ.ИмяОчереди);
	Лог.Поля("КоличествоСообщенийВОчереди", КоличествоСообщенийВОчереди).Информация("Получаю сообщения из RMQ");
	Возврат КоличествоСообщенийВОчереди;

КонецФункции

Процедура ОпроситьПроцессыПоТаймауту()

	Если ПараллельныеПроцессы.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;

	Лог.Поля("КоличествоРабочихПроцессов", ПараллельныеПроцессы.Количество()).Информация("Опрос рабочих процессов по таймауту");

	ИзмененияЛогов = ПолучитьДатыИзмененияЛогов();

	Для каждого КлючЗначение Из ИзмененияЛогов Цикл
		
		ИдентификаторРабочегоПроцесса = КлючЗначение.Ключ;
		ДатаИзменения = КлючЗначение.Значение;

		Если ДатаИзменения + ТаймаутРабочегоПроцесса < ТекущаяДата() Тогда
			ОписаниеПроцесса = ПараллельныеПроцессы[ИдентификаторРабочегоПроцесса];
			Лог.Поля("РабочийПроцесс", ОписаниеПроцесса.Идентификатор,
					"ВремяЗапуска", ОписаниеПроцесса.ВремяЗапуска,
					"ПутьКФайлуЛога", ОписаниеПроцесса.ПутьКФайлуЛога
					).Предупреждение("Завершение рабочего процесса по таймауту");
			ЗавершитьРабочегоПроцесса(ОписаниеПроцесса.Процесс);
		КонецЕсли;

	КонецЦикла;

КонецПроцедуры

Процедура ЗавершитьРабочегоПроцесса(Знач РабочийПроцесс)

	Если Не РабочийПроцесс.Завершен Тогда
		РабочийПроцесс.Завершить();
	КонецЕсли;
	
КонецПроцедуры

Функция ПолучитьДатыИзмененияЛогов()
	
	ИзмененияЛогов = Новый Соответствие;

	Для каждого ПроцессКоманды Из ПараллельныеПроцессы Цикл
		
		ОписаниеПроцесса = ПроцессКоманды.Значение;
		ПутьКФайлуЛога = ОписаниеПроцесса.ПутьКФайлуЛога;
		ДатаИзмененияЛогаПроцесса = ПолучитьДатуИзмененияФайла(ПутьКФайлуЛога);

		ИзмененияЛогов.Вставить(ПроцессКоманды.Ключ, ДатаИзмененияЛогаПроцесса);

	КонецЦикла;

	Возврат ИзмененияЛогов;

КонецФункции

Функция ПолучитьДатуИзмененияФайла(Знач ПутьКФайлуЛога)
	
	ФайлЛога = Новый Файл(ПутьКФайлуЛога);
	
	Если Не ФайлЛога.Существует() Тогда
		Возврат Дата("00010101");
	КонецЕсли;
	
	Возврат ФайлЛога.ПолучитьВремяИзменения();

КонецФункции

Процедура ЗапуститьПаралельно(КоличествоПроцессов = 0)

	Если КоличествоПроцессов = 0 Тогда
		Возврат;
	КонецЕсли;

	ИнтервалЗапускаПроцессов = 1000*10; // 10 секунд
	Лог.Отладка("Запуск рабочих <%1> процессов", КоличествоПроцессов);

	Для Счетчик = 1 По КоличествоПроцессов Цикл
		
		МассивСообщенийRMQ = КлиентRMQ.ПолучитьСообщениеИзОчереди(НастройкаRMQ.ИмяОчереди, 1, , "base64");

		Если МассивСообщенийRMQ.Количество() = 0  Тогда
			Возврат;
		КонецЕсли;

		СообщениеRMQ = МассивСообщенийRMQ[0];

		Лог.Отладка("Ключ маршрутизации <%1>", СообщениеRMQ.КлючМаршрутизации);
		Лог.Отладка("Ключ сообщения <%1>", СообщениеRMQ.ЗначениеПараметра("КлючСообщения"));

		СчетчикПроцессов = СчетчикПроцессов + 1;

		ИдентификаторРабочегоПроцесса = СтрШаблон("worker_%1_%2", СчетчикПроцессов, Формат(ТекущаяДата(), "ДФ=yyyyMMdd_HHmmss"));

		ИмяФайлаСообщения = ПодготовитьФайлСообщенияНаРабочийПроцесс(ИдентификаторРабочегоПроцесса, СообщениеRMQ);

		Лог.Информация("Запускаю процесс <%1>", ИдентификаторРабочегоПроцесса);
		
		Команда = Новый ПараллельнаяКоманда;
		Команда.УстановитьКоманду(КомандаПроцессаАгента);
		Если КомандаПроцессаАгента = "oscript" Тогда
			//Команда.ДобавитьПараметр("-encoding=utf-8");
			Команда.ДобавитьПараметр(ПутьКФайлуСкрипта);
		КонецЕсли;
		
		Если Отладка Тогда
			Команда.ДобавитьПараметр("-v");
		КонецЕсли;

		ПутьКФайлуЛогаПроцесса = ОбъединитьПути(РабочийКаталогПроцессов, ИдентификаторРабочегоПроцесса + ".log");

		Команда.ДобавитьПараметр("--log-file");
		Команда.ДобавитьПараметр(ПутьКФайлуЛогаПроцесса);
	
		Команда.ДобавитьПараметр("worker");
		Команда.ДобавитьПараметр("--agent-id");
		Команда.ДобавитьПараметр(Идентификатор);
		
		Команда.ДобавитьПараметр(ИмяФайлаСообщения);
		Команда.ДобавитьПараметр(ИдентификаторРабочегоПроцесса);
		
		ПроцессКоманды = Команда.ЗапуститьПроцесс();

		ОписаниеПроцесса = Новый Структура();
		ОписаниеПроцесса.Вставить("Идентификатор", ИдентификаторРабочегоПроцесса);
		ОписаниеПроцесса.Вставить("ПутьКФайлуЛога", ПутьКФайлуЛогаПроцесса);
		ОписаниеПроцесса.Вставить("СообщениеRMQ", СообщениеRMQ);
		ОписаниеПроцесса.Вставить("Команда", Команда);
		ОписаниеПроцесса.Вставить("Процесс", ПроцессКоманды);
		ОписаниеПроцесса.Вставить("ВремяЗапуска", ТекущаяДата());

		ПараллельныеПроцессы.Вставить(ИдентификаторРабочегоПроцесса, ОписаниеПроцесса);

		Лог.Информация("Рабочий процесс <%1> запущен", ИдентификаторРабочегоПроцесса);
	
		Приостановить(ИнтервалЗапускаПроцессов);

	КонецЦикла;

КонецПроцедуры

Функция ПодготовитьФайлСообщенияНаРабочийПроцесс(ИдентификаторРабочегоПроцесса, СообщениеRMQ)

	ИмяФайлаСообщения = ВременныеФайлы.НовоеИмяФайла("message");
	Лог.Поля("Файл", ИмяФайлаСообщения, "РабочийПроцесс", ИдентификаторРабочегоПроцесса).Информация("Подготовка данных для рабочего процесса");

	ДанныеНаРабочийПроцесс = Новый Структура();
	ДанныеСообщенияRMQ = СообщениеRMQ.ВСоответствие();

	ДанныеНаРабочийПроцесс.Вставить("НастройкаRMQ", НастройкаRMQ);
	ДанныеНаРабочийПроцесс.Вставить("ДанныеСообщенияRMQ", ДанныеСообщенияRMQ);

	ПараметрыЗаписиJSON = Новый ПараметрыЗаписиJSON(ПереносСтрокJSON.Авто, ,, Истина, Истина, Истина, Истина, Истина, Истина);
	ЗаписьJSON = Новый ЗаписьJSON;
	ЗаписьJSON.УстановитьСтроку();
	ЗаписатьJSON(ЗаписьJSON, ДанныеНаРабочийПроцесс);
	
	ТекстФайлаСообщения = ЗаписьJSON.Закрыть();

	Лог.Отладка("Текст сообщения на рабочий процесс: <%1>", ТекстФайлаСообщения);

	ЗаписьТекста = Новый ЗаписьТекста(ИмяФайлаСообщения);
	ЗаписьТекста.Записать(ТекстФайлаСообщения);
	ЗаписьТекста.Закрыть();

	Возврат ИмяФайлаСообщения;

КонецФункции

Процедура ОчиститьЗавершенныеПроцессы()

	Если ПараллельныеПроцессы.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;

	Лог.Поля("КоличествоРабочихПроцессов", ПараллельныеПроцессы.Количество()).Информация("Обрабатываю список рабочих процессов");

	МассивОчистки = Новый Массив;

	Для каждого ПроцессКоманды Из ПараллельныеПроцессы Цикл
		
		ОписаниеПроцесса = ПроцессКоманды.Значение;
		СистемныйПроцесс = ОписаниеПроцесса.Процесс;
		
		Если Не СистемныйПроцесс.Завершен Тогда
			Продолжить;
		КонецЕсли;
		
		МассивОчистки.Добавить(ПроцессКоманды.Ключ);
		КодВозвратаПроцесса = СистемныйПроцесс.КодВозврата;

		Если КодВозвратаПроцесса <> 0 Тогда
			Лог.Поля("РабочийПроцесс", ПроцессКоманды.Ключ, "КодВозврата", КодВозвратаПроцесса).Предупреждение("Процесс завершился не с <0< кодом")
		КонецЕсли;

	КонецЦикла;

	Лог.Поля("КоличествоЗавершенныхПроцессов", МассивОчистки.Количество()).Информация("Очистка рабочих процессов");

	Для каждого ОчищаемыйПроцесс Из МассивОчистки Цикл
		ПараллельныеПроцессы.Удалить(ОчищаемыйПроцесс);
	КонецЦикла;

	Если ПараллельныеПроцессы.Количество() = 0 Тогда
		СчетчикПроцессов = 0; 
	КонецЕсли;

КонецПроцедуры

Процедура ПриСозданииОбъекта(Знач ПИдентификатор)
	
	СИ = Новый СистемнаяИнформация;
	
	Если ПИдентификатор = Неопределено Тогда
		Идентификатор = Новый УникальныйИдентификатор();
	Иначе
		Идентификатор = ПИдентификатор;
	КонецЕсли;

	МаксимальноеКоличествоРабочихПроцессов = СИ.КоличествоПроцессоров * 2 - 1;

	ТаймерПовторенияОпроса = 0;
	ТаймаутРабочегоПроцесса = 60 * 60 * 6; // 6 Часов

	ПараллельныеПроцессы = Новый Соответствие;
	ПользовательОС = СИ.ПользовательОС;
	ИмяКомпьютера = СИ.ИмяКомпьютера;
	
	ОбщийЛог =  Логирование.ПолучитьЛог("oscript.app.AutoUpdateIB");
	
	ДопПоля = Новый Соответствие();
	ДопПоля.Вставить("agent", Идентификатор);
	ДопПоля.Вставить("ПользовательОС", СИ.ПользовательОС);
	ДопПоля.Вставить("ИмяКомпьютера", СИ.ИмяКомпьютера);
	
	ОбщийЛог.ДополнительныеПоля(ДопПоля);

	Лог = ОбщийЛог.Поля("Префикс", "agent");

	ПутьКФайлуСкрипта = СтартовыйСценарий().Источник;
	СчетчикПроцессов = 0;
	ТаймерОпросаРабочихПроцессов = 10;
	ФайлИсточника = Новый Файл(ПутьКФайлуСкрипта);

	Если ФайлИсточника.Расширение = ".os" Тогда
		КомандаПроцессаАгента = "oscript";
	Иначе
		КомандаПроцессаАгента = ПутьКФайлуСкрипта;
	КонецЕсли;

	Отладка = Ложь;

КонецПроцедуры



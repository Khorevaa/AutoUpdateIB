#Использовать "./internal"
#Использовать logos
#Использовать json
#Использовать datetime

Перем Лог;

Перем МаксимальноеКоличествоАгентов;
Перем КомандаПроцессаАгента;
Перем ПутьКФайлуСкрипта;
Перем ПараметрыАгента;
Перем ТаймерПовторенияОпроса;
Перем ТаймаутПроцессаАгента;
Перем ПараллельныеПроцессы;
Перем СчетчикПроцессов;
Перем РабочийКаталогПроцессов;
Перем ДанныеПоСистеме;

Перем НастройкаRMQ;
Перем КлиентRMQ;

Перем ПользовательОС;
Перем ИмяКомпьютера;
Перем Отладка;

Процедура УстановитьКоличествоАгентов(Знач НовоеМаксимальноеКоличествоАгентов) Экспорт
	Если НовоеМаксимальноеКоличествоАгентов = 0 Тогда
		Возврат;
	КонецЕсли;
	
	МаксимальноеКоличествоАгентов = НовоеМаксимальноеКоличествоАгентов;

КонецПроцедуры

Процедура УстановитьОткладку(Знач ПОтладка) Экспорт
	Отладка = ПОтладка;
КонецПроцедуры

Процедура УстановитьПараметрыАгента(Знач НовыеПараметрыАгента) Экспорт
	ПараметрыАгента = НовыеПараметрыАгента;
КонецПроцедуры

Процедура УстановитьТаймерОпроса(Знач НовыйТаймерПовторенияОпроса) Экспорт
	ТаймерПовторенияОпроса = НовыйТаймерПовторенияОпроса;
КонецПроцедуры

Процедура УстановитьТаймаутПроцессаАгента(Знач НовыйТаймаутПроцессаАгента) Экспорт
	ТаймаутПроцессаАгента = НовыйТаймаутПроцессаАгента;
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

Функция КоличествоСообщенийВОчереди()

	КоличествоСообщенийВОчереди = КлиентRMQ.КоличествоСообщенийВОчереди(НастройкаRMQ.ИмяОчереди);

	Возврат КоличествоСообщенийВОчереди;

КонецФункции

Функция ПолучитьСообщениеИзОчереди()

	СообщениеRMQ = КлиентRMQ.ПолучитьСообщениеИзОчереди(НастройкаRMQ.ИмяОчереди, 1);

	Возврат СообщениеRMQ;

КонецФункции

Процедура ОтправитьСообщение(СообщениеRMQ)

	КлиентRMQ.ОтправитьСообщениеRMQ(СообщениеRMQ);

КонецПроцедуры

Процедура Запустить() Экспорт
	
	ПроверитьВозможностьЗапуска();

	Пока Истина Цикл

		ОчиститьЗавешенныеПроцессы();

		ОпроситьПроцессыПоТаймауту();

		КоличествоСообщенийВОчереди = КлиентRMQ.КоличествоСообщенийВОчереди(НастройкаRMQ.ИмяОчереди);

		ЗапуститьАгентовПриНеобходимости(КоличествоСообщенийВОчереди);

		Если ТаймерПовторенияОпроса <= 0 
			И КоличествоСообщенийВОчереди = 0 Тогда

			ОжидатьЗавершенияПроцессов();

			Прервать;

		Иначе

			ЛокальныйТаймер = ТаймерПовторенияОпроса;

			Если ЛокальныйТаймер = 0 Тогда

				ЛокальныйТаймер = 10;

			КонецЕсли;

			Приостановить(ЛокальныйТаймер * 1000);

		КонецЕсли;

	КонецЦикла;

КонецПроцедуры


Процедура ОжидатьЗавершенияПроцессов()

	Пока ПараллельныеПроцессы.Количество() > 0 Цикл

		ОпроситьПроцессыПоТаймауту();
			
		Приостановить(10 * 1000);

	КонецЦикла;

КонецПроцедуры

Процедура ПроверитьВозможностьЗапуска()
	
	Если КлиентRMQ = Неопределено Тогда
		ВызватьИсключение "Не настроена очередь RabbitMQ";
	КонецЕсли;

КонецПроцедуры

Процедура ЗапуститьАгентовПриНеобходимости(КоличествоСообщенийВОчереди)

	Лог.Отладка("Сервер очереди: количество сообщений в очереди <%1>", КоличествоСообщенийВОчереди);
	Если КоличествоСообщенийВОчереди = 0 Тогда
		Лог.Информация("Ожидаю следующего опроса через <%1> секунд", ТаймерПовторенияОпроса);
		Возврат;
	КонецЕсли;

	ФайлИсточника = Новый Файл(ПутьКФайлуСкрипта);

	Если ФайлИсточника.Расширение = ".os" Тогда
		КомандаПроцессаАгента = "oscript";
	Иначе
		КомандаПроцессаАгента = ПутьКФайлуСкрипта;
	КонецЕсли;

	КоличествоПроцессов = Мин(МаксимальноеКоличествоАгентов, КоличествоСообщенийВОчереди);

	ЗапуститьПаралельно(КоличествоПроцессов);

КонецПроцедуры

Процедура ОпроситьПроцессыПоТаймауту()

	ИзмененияЛогов = ПолучитьДатыИзмененияЛогов();

	Для каждого КлючЗначение Из ИзмененияЛогов Цикл
		
		ИдентификаторАгента = КлючЗначение.Ключ;
		ДатаИзменения = КлючЗначение.Значение;

		Если ДатаИзменения + ТаймаутПроцессаАгента < ТекущаяДата() Тогда
			ЗавершитьПроцессаАгента(ПараллельныеПроцессы[ИдентификаторАгента]);
		КонецЕсли;

	КонецЦикла;

КонецПроцедуры

Процедура ЗавершитьПроцессаАгента(ПроцессАгента)

	Если Не ПроцессАгента.Завершен Тогда
		ПроцессАгента.Завершить();
	КонецЕсли;
	
КонецПроцедуры

Функция ПолучитьДатыИзмененияЛогов()
	
	ИзмененияЛогов = Новый Соответствие;

	Для каждого ПроцессКоманды Из ПараллельныеПроцессы Цикл
		
		ИдентификаторАгента = ПроцессКоманды.Ключ;
		ДатаИзмененияЛогаПроцесса = ПолучитьДатуИзмененияЛогаПоКлючу(ИдентификаторАгента);

		ИзмененияЛогов.Вставить(ИдентификаторАгента, ДатаИзмененияЛогаПроцесса);

	КонецЦикла;

	Возврат ИзмененияЛогов;

КонецФункции

Функция ПолучитьДатуИзмененияЛогаПоКлючу(КлючПроцессаАгента)
	
	Возврат ПолучитьДатуИзмененияФайла(КлючПроцессаАгента);

КонецФункции

Функция ПолучитьДатуИзмененияФайла(ИмяФайла)
	
	//TODO: Сделать проверку через файл

	Возврат ТекущаяДата();

КонецФункции

Процедура ЗапуститьПаралельно(КоличествоПроцессов = 0)

	ОчиститьЗавешенныеПроцессы();

	КоличествоРаботающихПроцессов = ПараллельныеПроцессы.Количество();

	Если КоличествоРаботающихПроцессов >= КоличествоПроцессов Тогда
		Возврат;
	КонецЕсли;

	Если КоличествоПроцессов - КоличествоРаботающихПроцессов = 0 Тогда
		Возврат;
	КонецЕсли;

	ИнтервалЗапускаПроцессов = 1000*10; // 1 секунда
	Лог.Отладка("Запуск рабочих <%1> процессов", КоличествоПроцессов - КоличествоРаботающихПроцессов);

	Для Счетчик = 1 По КоличествоПроцессов - КоличествоРаботающихПроцессов Цикл
		
		МассивСообщенийRMQ = КлиентRMQ.ПолучитьСообщениеИзОчереди(НастройкаRMQ.ИмяОчереди, 1);

		Если МассивСообщенийRMQ.Количество() = 0  Тогда
			Возврат;
		КонецЕсли;

		СообщениеRMQ = МассивСообщенийRMQ[0];

		Лог.Отладка("Ключ маршрутизации <%1>", СообщениеRMQ.КлючМаршрутизации);
		Лог.Отладка("Ключ сообщения <%1>", СообщениеRMQ.ЗначениеПараметра("КлючСообщения"));

		СчетчикПроцессов = СчетчикПроцессов + 1;

		ИдентификаторРабочегоПроцесса = СтрШаблон("worker_%1_%2", СчетчикПроцессов, Формат(ТекущаяДата(), "ДФ=yyyy_MM_dd_HH_mm_ss"));

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

		Команда.ДобавитьПараметр("worker");

		Команда.ДобавитьПараметр(ИмяФайлаСообщения);
		Команда.ДобавитьПараметр(ИдентификаторРабочегоПроцесса);
		
		ПроцессКоманды = Команда.ЗапуститьПроцесс();
		
		ПараллельныеПроцессы.Вставить(ИдентификаторРабочегоПроцесса, ПроцессКоманды);

		Приостановить(ИнтервалЗапускаПроцессов);

	КонецЦикла;

КонецПроцедуры

Функция ПодготовитьФайлСообщенияНаРабочийПроцесс(ИдентификаторРабочегоПроцесса, СообщениеRMQ)

	ИмяФайлаСообщения = ВременныеФайлы.НовоеИмяФайла("message");

	ДанныеНаРабочийПроцесс = Новый Структура();
	ДанныеСообщенияRMQ = СообщениеRMQ.ВСоответствие();

	ДанныеНаРабочийПроцесс.Вставить("НастройкаRMQ", НастройкаRMQ);
	ДанныеНаРабочийПроцесс.Вставить("ДанныеСообщенияRMQ", ДанныеСообщенияRMQ);

	ПарсерJSON = Новый ПарсерJSON;
	ТекстФайлаСообщения = ПарсерJSON.ЗаписатьJSON(ДанныеНаРабочийПроцесс);
	ЗаписьТекста = Новый ЗаписьТекста(ИмяФайлаСообщения);
	ЗаписьТекста.Записать(ТекстФайлаСообщения);
	ЗаписьТекста.Закрыть();

	Возврат ИмяФайлаСообщения;

КонецФункции

Процедура ОчиститьЗавешенныеПроцессы()

	Если ПараллельныеПроцессы.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;

	МассивОчистки = Новый Массив;

	Для каждого ПроцессКоманды Из ПараллельныеПроцессы Цикл
		
		Если Не ПроцессКоманды.Значение.Завершен Тогда
			Продолжить;
		КонецЕсли;
		МассивОчистки.Добавить(ПроцессКоманды.Ключ);
		КодВозвратаПроцесса = ПроцессКоманды.Значение.КодВозврата;
		Лог.Информация("Процесс <%1> завершился с кодом <%2>", ПроцессКоманды.Ключ, КодВозвратаПроцесса)

	КонецЦикла;

	Для каждого ОчищаемыйПроцесс Из МассивОчистки Цикл
		ПараллельныеПроцессы.Удалить(ОчищаемыйПроцесс);
	КонецЦикла;

	Если ПараллельныеПроцессы.Количество() = 0 Тогда
		СчетчикПроцессов = 0; 
	КонецЕсли;

	Лог.Отладка("Очищено <%1> завершенных процессов", МассивОчистки.Количество());

КонецПроцедуры

Функция ИмяЛога() Экспорт
	
	Возврат "oscript.app.AutoUpdateIB";

КонецФункции

Функция ИмяФайлаЛога() Экспорт

	Возврат ОбъединитьПути(РабочийКаталогПроцессов, "manager.log");
	
КонецФункции

Процедура ПриСозданииОбъекта()
	
	СИ = Новый СистемнаяИнформация;
	
	МаксимальноеКоличествоАгентов = СИ.КоличествоПроцессоров * 2 - 1;

	ТаймерПовторенияОпроса = 0;
	ТаймаутПроцессаАгента = 60 * 60 * 6; // 6 Часов

	ПараллельныеПроцессы = Новый Соответствие;
	
	Лог = Логирование.ПолучитьЛог(ИмяЛога()).Поля("Префикс", "agent");
	// Лог.УстановитьУровень(УровниЛога.Отладка);
	
	СИ = Новый СистемнаяИнформация;
	ПользовательОС = СИ.ПользовательОС;
	ИмяКомпьютера = СИ.ИмяКомпьютера;

	ПутьКФайлуСкрипта = СтартовыйСценарий().Источник;
	СчетчикПроцессов = 0;

	Отладка = Ложь;

КонецПроцедуры

Процедура НастроитьЛогирование() Экспорт
	
	ФайлЖурнала = Новый ВыводЛогаВФайл;
	ФайлЖурнала.ОткрытьФайл(ИмяФайлаЛога());
	Лог.ДобавитьСпособВывода(ФайлЖурнала);

КонецПроцедуры


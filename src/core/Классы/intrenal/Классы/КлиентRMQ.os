#Использовать logos
#Использовать json
#Использовать types


Перем Лог;
Перем ВиртуальныйХост;
Перем НастройкиПодключения;

Перем HTTPСоединение;
Перем Заголовки;
Перем ДопустимыйКодСостояния;
Перем ИнициализацияВыполнена;

#Область ПрограммныйИнтерфейс

#Область Работа_по_HTTP_с_RMQ

Функция КоличествоСообщенийВОчереди(Знач ИмяОчереди) Экспорт
	
	ИнициализироватьПодключение();
	
	АдресApiОчередиСообщений = СтрШаблон("%1/get", АдресApiОчередиСообщений(ИмяОчереди));
	
	Запрос = ПолучитьHTTPЗапрос(АдресApiОчередиСообщений);
	Лог.Отладка("Адрес очереди сообщений <%1>", АдресApiОчередиСообщений);
	ДанныеОтвета = Получить(Запрос);
	
	КоличествоСообщений = ДанныеОтвета["messages_ready"];
	
	Если КоличествоСообщений = Неопределено Тогда
		КоличествоСообщений = 0;
	КонецЕсли;
	
	Возврат КоличествоСообщений;
	
КонецФункции

Функция ПолучитьСообщениеИзОчереди(Знач ИмяОчереди,
	Знач КоличествоСообщений = 1,
	Знач РежимПолучения = "reject_requeue_false",
	Знач КодировкаСообщения = "auto") Экспорт
	
	АдресApiОчередиСообщений = СтрШаблон("%1/get", АдресApiОчередиСообщений(ИмяОчереди));
	
	ТелоЗапроса = Новый Соответствие;
	ТелоЗапроса.Вставить("count", КоличествоСообщений);
	ТелоЗапроса.Вставить("ackmode", РежимПолучения); // TODO: Заменить на false иначе не очищается очередь
	ТелоЗапроса.Вставить("encoding", КодировкаСообщения);
	
	Запрос = ПолучитьHTTPЗапрос(АдресApiОчередиСообщений, ТелоЗапроса);
	
	ДанныеОтвета  = Отправить(Запрос);
	КоличествоСообщений = ДанныеОтвета.Количество();
	Если КоличествоСообщений = 0  Тогда
		Возврат Неопределено;
	ИначеЕсли КоличествоСообщений = 1 Тогда
		
		СообщениеRMQ = Новый СообщениеRMQ;
		СообщениеRMQ.ИзСоответствия(ДанныеОтвета);
		Возврат СообщениеRMQ; 
	Иначе
		
		МассивСообщений = Новый Массив();

		Для каждого ЭлементОтвета Из ДанныеОтвета Цикл
			СообщениеRMQ = Новый СообщениеRMQ;
			СообщениеRMQ.ИзСоответствия(ЭлементОтвета);
			МассивСообщений.Добавить(СообщениеRMQ);
		КонецЦикла;
		
		Возврат МассивСообщений;
	КонецЕсли;
	
КонецФункции

Функция ОтправитьСообщениеRMQ(СообщениеRMQ) Экспорт
	
	ИнициализироватьПодключение();
	
	УказанаТочкаОбмена = ЗначениеЗаполнено(СообщениеRMQ.ТочкаОбмена);
	Если УказанаТочкаОбмена Тогда
		АдресHTTPЗапроса = АдресApiОтправкиСообщенийВТочкуОбмена(СообщениеRMQ.ТочкаОбмена);
	Иначе
		АдресHTTPЗапроса = АдресApiОтправкиСообщенийВОчередь();
	КонецЕсли;
	
	ТелоЗапроса = СообщениеRMQ.ВJson();
	
	Запрос = ПолучитьHTTPЗапрос(АдресHTTPЗапроса, ТелоЗапроса);
	
	ДанныеОтвета  = Отправить(Запрос);
	
	Если Не ДанныеОтвета["routed"] Тогда
		ВызватьИсключение СтрШаблон("Не удалось отправить данные в точку обмена <%1>, ключ маршрутизации <%2>", СообщениеRMQ.ТочкаОбмена, СообщениеRMQ.КлючМаршрутизации);
	КонецЕсли;
	
	Возврат ДанныеОтвета;
	
КонецФункции

Функция ОтправитьСообщениеRMQВОчередь(СообщениеRMQ, Знач ИмяОчереди = "") Экспорт
	
	ИнициализироватьПодключение();
	
	АдресHTTPЗапроса = АдресApiОтправкиСообщенийВОчередь();
	ПодменаКлючаМаршрутизации = ЗначениеЗаполнено(ИмяОчереди);
	Если ПодменаКлючаМаршрутизации Тогда
		ТекущийКлючМаршрутизации = СообщениеRMQ.КлючМаршрутизации;
		СообщениеRMQ.КлючМаршрутизации = ИмяОчереди;
	КонецЕсли;
	
	ТелоЗапроса = СообщениеRMQ.ВJson();
	
	Если ПодменаКлючаМаршрутизации Тогда
		СообщениеRMQ.КлючМаршрутизации = ТекущийКлючМаршрутизации;
	КонецЕсли;
	
	Запрос = ПолучитьHTTPЗапрос(АдресHTTPЗапроса, ТелоЗапроса);
	
	ДанныеОтвета  = Отправить(Запрос);
	
	Если Не ДанныеОтвета["routed"] Тогда
		ВызватьИсключение СтрШаблон("Не удалось отправить данные в очередь <%1>", ИмяОчереди);
	КонецЕсли;
	
	Возврат ДанныеОтвета;
	
КонецФункции

Функция ОтправитьСообщениеВОчередь(Знач ТекстСообщение, Знач ИмяОчереди, ПараметрыСообщения = Неопределено, КодировкаСообщения = "string") Экспорт
	
	ИнициализироватьПодключение();
	
	Если ПараметрыСообщения = Неопределено Тогда
		ПараметрыСообщения = Новый Структура;
	КонецЕсли;
	
	ТелоЗапроса = Новый Соответствие;
	ТелоЗапроса.Вставить("properties", ПараметрыСообщения);
	ТелоЗапроса.Вставить("routing_key", ИмяОчереди);
	ТелоЗапроса.Вставить("payload", ТекстСообщение);
	ТелоЗапроса.Вставить("payload_encoding", КодировкаСообщения);
	
	АдресHTTPЗапроса = АдресApiОтправкиСообщенийВОчередь();
	
	Запрос = ПолучитьHTTPЗапрос(АдресHTTPЗапроса, ТелоЗапроса);
	
	ДанныеОтвета  = Отправить(Запрос);
	Если Не ДанныеОтвета["routed"] Тогда
		ВызватьИсключение СтрШаблон("Не удалось отправить данные в очередь <%1>", ТелоЗапроса["routing_key"]);
	КонецЕсли;
	
	Возврат ДанныеОтвета;
	
КонецФункции

Функция ОтправитьСообщение(Знач ТекстСообщение, Знач ТочкаОбмена, Знач КлючМаршрутизации = "", ПараметрыСообщения = Неопределено, КодировкаСообщения = "string") Экспорт
	
	ИнициализироватьПодключение();
	
	Если ПараметрыСообщения = Неопределено Тогда
		ПараметрыСообщения = Новый Структура;
	КонецЕсли;
	
	ТелоЗапроса = Новый Соответствие;
	ТелоЗапроса.Вставить("properties", ПараметрыСообщения);
	ТелоЗапроса.Вставить("routing_key", КлючМаршрутизации);
	ТелоЗапроса.Вставить("payload", ТекстСообщение);
	ТелоЗапроса.Вставить("payload_encoding", КодировкаСообщения);
	
	АдресHTTPЗапроса = АдресApiОтправкиСообщенийВТочкуОбмена(ТочкаОбмена);
	
	Запрос = ПолучитьHTTPЗапрос(АдресHTTPЗапроса, ТелоЗапроса);
	
	ДанныеОтвета  = Отправить(Запрос);
	
	Если Не ДанныеОтвета["routed"] Тогда
		ВызватьИсключение СтрШаблон("Не удалось отправить данные в точку обмена <%1>, ключ маршрутизации <%2>", ТочкаОбмена, КлючМаршрутизации);
	КонецЕсли;
	
	Возврат ДанныеОтвета;
	
КонецФункции

#КонецОбласти

#Область Установка_и_получение_настроек

Процедура УстановитьВиртуальныйХост(Знач НовыйВиртуальныйХост) Экспорт
	ВиртуальныйХост = НовыйВиртуальныйХост;
КонецПроцедуры

Процедура УстановитьНастройкиПодключения(Знач НовыеНастройкиПодключения) Экспорт
	
	НастройкиПодключения = КопированиеТипа.Скопировать(НовыеНастройкиПодключения);
	ИнициализацияВыполнена = Ложь;
	
КонецПроцедуры

Функция ПолучитьНастройкиПодключения() Экспорт
	
	Возврат КопированиеТипа.Скопировать(НастройкиПодключения);
	
КонецФункции

#КонецОбласти

#КонецОбласти

#Область Вспомогательные_процедуры_и_функции

Процедура ИнициализироватьПодключение()
	
	Если ИнициализацияВыполнена Тогда
		Возврат;
	КонецЕсли;
	
	ПроверитьНастройкиПодключения();
	
	Инициализировать();
	
КонецПроцедуры

Процедура ПроверитьНастройкиПодключения()
	// TODO: Сделать проверку 
КонецПроцедуры

Процедура Инициализировать()
	
	Если ИнициализацияВыполнена Тогда
		Возврат;
	КонецЕсли;
	
	Лог.Отладка("Сервер <%1>", НастройкиПодключения.Сервер);
	Лог.Отладка("Порт <%1>", НастройкиПодключения.Порт);
	Лог.Отладка("Пользователь <%1>", НастройкиПодключения.Пользователь);
	Лог.Отладка("Пароль <%1>", НастройкиПодключения.Пароль);
	
	HTTPСоединение = Новый HTTPСоединение(НастройкиПодключения.Сервер,
	НастройкиПодключения.Порт,
	НастройкиПодключения.Пользователь,
	НастройкиПодключения.Пароль);
	
	ИнициализацияВыполнена = Истина;
	
КонецПроцедуры


Функция АдресApiОтправкиСообщенийВОчередь()
	Возврат СтрШаблон("api/exchanges/%1/amq.default/publish", ВиртуальныйХост);
КонецФункции

Функция АдресApiОтправкиСообщенийВТочкуОбмена(Знач ТочкаОбмена)
	Возврат СтрШаблон("api/exchanges/%1/%2/publish", ВиртуальныйХост, ТочкаОбмена);
КонецФункции

Функция АдресApiОчередиСообщений(Знач ИмяОчереди)
	Возврат СтрШаблон("api/queues/%1/%2", ВиртуальныйХост, ИмяОчереди);
КонецФункции

Функция ПолучитьHTTPЗапрос(Знач АдресРесурса, ДанныеДляОтправки = Неопределено)
	
	HTTPЗапрос = НовыйHTTPЗапрос(АдресРесурса);
	
	Если ЗначениеЗаполнено(ДанныеДляОтправки)
		И (ТипЗнч(ДанныеДляОтправки) = Тип("Структура")
		ИЛИ ТипЗнч(ДанныеДляОтправки) = Тип("Соответствие") )
		Тогда
		ТелоЗапроса = ВJson(ДанныеДляОтправки);
		Лог.Отладка("Установлено тело запроса <%1>", ТелоЗапроса);
		HTTPЗапрос.УстановитьТелоИзСтроки(ТелоЗапроса,
		КодировкаТекста.UTF8NoBom);
	КонецЕсли;
	
	
	Возврат HTTPЗапрос;
	
КонецФункции

Функция НовыйHTTPЗапрос(Знач Ресурс)
	
	Возврат Новый HTTPЗапрос(Ресурс, Заголовки);
	
КонецФункции

Функция Отправить(HTTPЗапрос)
	
	HTTPОтвет = HTTPСоединение.ОтправитьДляОбработки(HTTPЗапрос);
	Ответ = ПрочитатьОтветЗапроса(HTTPОтвет);
	
	Возврат Ответ;
	
КонецФункции

Функция Получить(HTTPЗапрос)
	
	HTTPОтвет = HTTPСоединение.Получить(HTTPЗапрос);
	Ответ = ПрочитатьОтветЗапроса(HTTPОтвет);
	
	Возврат Ответ;
	
КонецФункции

Функция ВJson(Знач СтруктураЗапроса)
	
	ПарсерJSON = Новый ПарсерJSON;
	Возврат ПарсерJSON.ЗаписатьJSON(СтруктураЗапроса);
	
КонецФункции

Функция ИЗJson(ТелоОтвета)
	
	Парсер = Новый ПарсерJSON;
	Результат = Парсер.ПрочитатьJSON(ТелоОтвета);
	
	Возврат Результат;
	
КонецФункции

Функция ПрочитатьОтветЗапроса(Знач Ответ)
	
	ТелоОтвета = Ответ.ПолучитьТелоКакСтроку(КодировкаТекста.UTF8NoBom);
	Если ТелоОтвета = Неопределено Тогда
		ТелоОтвета = "";
	КонецЕсли;
	
	Лог.Отладка("Код состояния: %1", Ответ.КодСостояния);
	Лог.Отладка("Тело ответа: 
	|%1", ТелоОтвета);
	
	Если Ответ.КодСостояния <> ДопустимыйКодСостояния Тогда
		ТекстСообщения = СтрШаблон(
		"Получен код возврата: %1
		|Тело ответа: %2", 
		Ответ.КодСостояния,
		ТелоОтвета
	);
	ИнфИсключение = Новый ИнформацияОбОшибке(ТекстСообщения, Ответ);
	ВызватьИсключение ИнфИсключение;
КонецЕсли;

Результат = Новый Соответствие;
Если ЗначениеЗаполнено(ТелоОтвета) Тогда
	Результат = ИЗJson(ТелоОтвета);
КонецЕсли;

Возврат Результат;

КонецФункции

Процедура ПоказатьНастройкиВРежимеОтладки(ЗначенияПараметров, Знач Родитель = "")
	
	Если Не Лог.Уровень() = УровниЛога.Отладка Тогда
		Возврат;
	КонецЕсли;
	
	Если Родитель = "" Тогда
		Лог.Отладка("	Тип параметров %1", ТипЗнч(ЗначенияПараметров));
	КонецЕсли;
	
	Если ТипЗнч(ЗначенияПараметров) = Тип("Массив") Тогда
		
		Для ИИ = 0 По ЗначенияПараметров.ВГраница() Цикл
			ПоказатьНастройкиВРежимеОтладки(ЗначенияПараметров[ИИ], СтрШаблон("%1.%2", Родитель, ИИ));
		КонецЦикла;
		
	ИначеЕсли ТипЗнч(ЗначенияПараметров) = Тип("Структура")
		ИЛИ ТипЗнч(ЗначенияПараметров) = Тип("Соответствие") Тогда
		
		Если ЗначенияПараметров.Количество() = 0 Тогда
			Лог.Отладка("	Коллекция параметров пуста!");
		КонецЕсли;
		
		Для каждого Элемент Из ЗначенияПараметров Цикл
			
			Если Не ПустаяСтрока(Родитель) Тогда
				ПредставлениеКлюча  = СтрШаблон("%1.%2", Родитель, Элемент.Ключ);
			Иначе
				ПредставлениеКлюча = Элемент.Ключ;
			КонецЕсли;
			
			// Если ТипЗнч(Элемент.Значение) = Тип("КонструкторПараметров") Тогда
			
			// 	ПоказатьНастройкиВРежимеОтладки(Элемент.Значение.ВСтруктуру(), ПредставлениеКлюча);
			
			Если ТипЗнч(Элемент.Значение) = Тип("Структура") 
				ИЛИ ТипЗнч(Элемент.Значение) = Тип("Соответствие")  Тогда
				
				ПоказатьНастройкиВРежимеОтладки(Элемент.Значение, ПредставлениеКлюча);	
				
			ИначеЕсли ТипЗнч(Элемент.Значение) = Тип("Массив") Тогда
				
				Лог.Отладка("	параметр <%1> = Массив.<%2>", ПредставлениеКлюча, Элемент.Значение.Количество());
				
				ПоказатьНастройкиВРежимеОтладки(Элемент.Значение, ПредставлениеКлюча);	
				
			Иначе
				Лог.Отладка("	параметр <%1> = <%2>", ПредставлениеКлюча, Элемент.Значение);
				
			КонецЕсли;
			
		КонецЦикла;
		
		// ИначеЕсли ТипЗнч(ЗначенияПараметров) = Тип("КонструкторПараметров") Тогда
		
		// 	ПоказатьНастройкиВРежимеОтладки(ЗначенияПараметров.ВСтруктуру(), Родитель);
		
		
	Иначе
		
		Лог.Отладка("	параметр <%1> = <%2>", Родитель, ЗначенияПараметров);
		
	КонецЕсли;
	
КонецПроцедуры

Процедура СоздатьНастройкиПодключения(Сервер, Порт, Пользователь, Пароль)
	
	НастройкиПодключения = Новый Структура();
	НастройкиПодключения.Вставить("Сервер", Сервер);
	НастройкиПодключения.Вставить("Порт", Порт);
	НастройкиПодключения.Вставить("Пользователь", Пользователь);
	НастройкиПодключения.Вставить("Пароль", Пароль);
	
КонецПроцедуры

Процедура ПриСозданииОбъекта(Знач СерверRMQ = "", Знач ПортRMQ = 15672, Знач ПользовательRMQ = "", Знач ПарольRMQ = "", Знач ВиртуальныйХостRMQ = "")
	
	СоздатьНастройкиПодключения(СерверRMQ, ПортRMQ, ПользовательRMQ, ПарольRMQ);
	
	ВиртуальныйХост = ВиртуальныйХостRMQ;
	
	Лог = Логирование.ПолучитьЛог("oscript.lib.AutoUpdateIB.rmq");
	ИнициализацияВыполнена = Ложь;
	
	Заголовки = Новый Соответствие;
	
	ДопустимыйКодСостояния = 200;
	
КонецПроцедуры

#КонецОбласти
#Использовать logos
#Использовать configor
#Использовать 1connector

Перем Лог;

Перем ВиртуальныйХост;
Перем Аутентификация;
Перем АдресСервера;

#Область Работа_по_HTTP_с_RMQ

Процедура Аутентификация(Знач Пользователь, Знач Пароль = "") Экспорт
	
	Аутентификация = Новый Структура("Пользователь, Пароль", Пользователь, Пароль);

КонецПроцедуры

Функция КоличествоСообщенийВОчереди(Знач ИмяОчереди) Экспорт
	
	АдресЗапроса = СтрШаблон("%1/api/queues/%2/%3", АдресСервера, ВиртуальныйХост, ИмяОчереди);
	
	Лог.Отладка("Адрес очереди сообщений <%1>", АдресЗапроса);
	
	ДанныеОтвета = КоннекторHTTP.Get(
					АдресЗапроса, ,
					Новый Структура("Аутентификация", Аутентификация)).Json();

	КоличествоСообщений = ДанныеОтвета["messages_ready"];
	
	Если КоличествоСообщений = Неопределено Тогда
		КоличествоСообщений = 0;
	КонецЕсли;
	
	Возврат КоличествоСообщений;
	
КонецФункции

Функция ПолучитьСообщениеИзОчереди(Знач ИмяОчереди,
									Знач КоличествоСообщений = 1,
									Знач УдалитьИзОчереди = Истина,
									Знач КодировкаСообщения = "auto") Экспорт
	
	АдресЗапроса = СтрШаблон("%1/api/queues/%2/%3/get", АдресСервера, ВиртуальныйХост, ИмяОчереди);
		
	РежимПолучения = "reject_requeue_true";
	
	Если УдалитьИзОчереди Тогда
		РежимПолучения = "reject_requeue_false";
	КонецЕсли;

	ТелоЗапроса = Новый Соответствие;
	ТелоЗапроса.Вставить("count", КоличествоСообщений);
	ТелоЗапроса.Вставить("ackmode", РежимПолучения);
	ТелоЗапроса.Вставить("encoding", КодировкаСообщения);

	ДанныеОтвета = КоннекторHTTP.Post(
					АдресЗапроса, , ТелоЗапроса,
					Новый Структура("Аутентификация", Аутентификация)).Json();

	КоличествоСообщений = ДанныеОтвета.Количество();
	МассивСообщений = Новый Массив();

	Если КоличествоСообщений = 0  Тогда
		Возврат МассивСообщений;
	ИначеЕсли КоличествоСообщений = 1 Тогда
		
		СообщениеRMQ = Новый СообщениеRMQ;
		СообщениеRMQ.ИзСоответствия(ДанныеОтвета[0]);
		МассивСообщений.Добавить(СообщениеRMQ);
	
	Иначе	

		Для каждого ЭлементОтвета Из ДанныеОтвета Цикл
			СообщениеRMQ = Новый СообщениеRMQ;
			СообщениеRMQ.ИзСоответствия(ЭлементОтвета);
			МассивСообщений.Добавить(СообщениеRMQ);
		КонецЦикла;
		
	КонецЕсли;
	
	Возврат МассивСообщений;

КонецФункции

Функция ОтправитьСообщениеRMQ(Знач СообщениеRMQ) Экспорт
	
	УказанаТочкаОбмена = ЗначениеЗаполнено(СообщениеRMQ.ТочкаОбмена);
	Если УказанаТочкаОбмена Тогда
		АдресЗапроса = СтрШаблон("%1/api/exchanges/%2/%3/publish", АдресСервера, ВиртуальныйХост, СообщениеRMQ.ТочкаОбмена);
	Иначе
		АдресЗапроса = СтрШаблон("%1/api/exchanges/%2/amq.default/publish", АдресСервера, ВиртуальныйХост);
	КонецЕсли;
	
	Лог.Отладка("Адрес HTTPЗапроса <%1>", АдресЗапроса);
	Лог.Отладка("Ключ маршрутизации <%1>", СообщениеRMQ.КлючМаршрутизации);
	ТелоЗапроса = СообщениеRMQ.ВСоответствие();
	
	ДанныеОтвета = КоннекторHTTP.Post(
					АдресЗапроса, , ТелоЗапроса,
					Новый Структура("Аутентификация", Аутентификация)).Json();
	
	Если Не ДанныеОтвета["routed"] = Истина Тогда
		ПоказатьОшибкуRMQ(ДанныеОтвета);
		ВызватьИсключение СтрШаблон("Не удалось отправить данные в точку обмена <%1>, ключ маршрутизации <%2>",
					 СообщениеRMQ.ТочкаОбмена, СообщениеRMQ.КлючМаршрутизации);
	КонецЕсли;
	
	Возврат ДанныеОтвета;
	
КонецФункции

Функция ОтправитьСообщениеВОчередь(Знач ТекстСообщение, Знач ИмяОчереди,
									Знач ПараметрыСообщения = Неопределено, Знач ЗаголовкиСообщения = Неопределено,
									Знач КодировкаСообщения = "string") Экспорт

	Возврат ОтправитьСообщение(ТекстСообщение, "", ИмяОчереди, ПараметрыСообщения, ЗаголовкиСообщения, КодировкаСообщения);
	
КонецФункции

Функция ОтправитьСообщение(Знач ТекстСообщение, Знач ТочкаОбмена, Знач КлючМаршрутизации = "",
							Знач ПараметрыСообщения = Неопределено, Знач ЗаголовкиСообщения = Неопределено,
							Знач КодировкаСообщения = "string") Экспорт
	
	Если ПараметрыСообщения = Неопределено Тогда
		ПараметрыСообщения = Новый Соответствие;
	КонецЕсли;

	Если ЗаголовкиСообщения = Неопределено Тогда
		ЗаголовкиСообщения = Новый Соответствие;
	КонецЕсли;
	
	СообщениеRMQ = Новый СообщениеRMQ;
	СообщениеRMQ.ДанныеСообщения = ТекстСообщение;
	СообщениеRMQ.ТочкаОбмена = ТочкаОбмена;
	СообщениеRMQ.КлючМаршрутизации = КлючМаршрутизации;
	СообщениеRMQ.КодировкаКонтента = КодировкаСообщения;
	
	СообщениеRMQ.УстановитьПараметры(ПараметрыСообщения);
	СообщениеRMQ.УстановитьЗаголовки(ЗаголовкиСообщения);
	
	Возврат ОтправитьСообщениеRMQ(СообщениеRMQ);
	
КонецФункции

#КонецОбласти

#Область Установка_и_получение_настроек

Процедура УстановитьВиртуальныйХост(Знач НовыйВиртуальныйХост) Экспорт
	ВиртуальныйХост = НовыйВиртуальныйХост;
КонецПроцедуры

Процедура УстановитьНастройкиПодключения(Знач НовыеНастройкиПодключения) Экспорт
	
	Если Тип("Структура") = ТипЗнч(НовыеНастройкиПодключения) Тогда
		НастройкиПодключения = НовыеНастройкиПодключения;
	Иначе
		
		КонструкторПараметров = КонструторПараметровКлиента();
		КонструкторПараметров.ИзСоответствия(НовыеНастройкиПодключения);
		НастройкиПодключения = КонструкторПараметров.ВСтруктуру();

	КонецЕсли;
	
	Аутентификация = Новый Структура("Пользователь, Пароль", НастройкиПодключения.Пользователь, НастройкиПодключения.Пароль);
	АдресСервера = СтрШаблон("%1:%2", НастройкиПодключения.Сервер, НастройкиПодключения.Порт);
	
	Если НастройкиПодключения.Свойство("ВиртуальныйХост") 
		И ЗначениеЗаполнено(НастройкиПодключения.ВиртуальныйХост) Тогда
		УстановитьВиртуальныйХост(НастройкиПодключения.ВиртуальныйХост);
	КонецЕсли;

КонецПроцедуры

Функция КонструторПараметровКлиента() Экспорт

	КонструкторПараметров = Новый КонструкторПараметров;

	КонструкторПараметров
		.ПолеСтрока("Сервер server")
		.ПолеСтрока("Порт port")
		.ПолеСтрока("Пользователь usr user")
		.ПолеСтрока("Пароль pwd password")
		.ПолеСтрока("ВиртуальныйХост virtual-host");

	Возврат КонструкторПараметров;
	
КонецФункции

#КонецОбласти

#Область Вспомогательные_процедуры_и_функции

Процедура ПоказатьОшибкуRMQ(Знач ОтветRMQ)

	Лог.Поля("error", ОтветRMQ["error"]).Ошибка("Ошибка RMQ: %1", СериализоватьВJSON(ОтветRMQ));
	
КонецПроцедуры

Функция СериализоватьВJSON(Знач Объект) Экспорт
	
	ЗаписьJSON = Новый ЗаписьJSON;
	ЗаписьJSON.УстановитьСтроку();
	ЗаписатьJSON(ЗаписьJSON, Объект);

	Возврат ЗаписьJSON.Закрыть();
	
КонецФункции


Процедура ПриСозданииОбъекта(Знач ПАдресСервера = "", Знач ПВиртуальныйХост = "%2F")
	
	Лог = Логирование.ПолучитьЛог("oscript.lib.AutoUpdateIB.rmq");
	// Лог.УстановитьУровень(УровниЛога.Отладка);

	Аутентификация = Новый Структура("Пользователь, Пароль", "", "");
	АдресСервера = ПАдресСервера;
	ВиртуальныйХост = ПВиртуальныйХост;

КонецПроцедуры

#КонецОбласти
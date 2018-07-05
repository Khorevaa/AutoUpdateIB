#Использовать "./intrenal"

Перем ТаймерПовторения;
Перем ЧитательОчереди;
Перем ИдентификаторАгента;
Перем ВыводитьЛогВКонсоль;
Перем ФайлЖурнала;
Перем КаталогЛогов;
Перем ПровайдерОчередиRMQ;
Перем Лог;
Перем ДанныеПоСистеме;
Перем ДинамическиеПараметрыЛога;
Перем ВыводВRabbitMQ;

// Устанавливает таймер повторения пакетной синхронизации
//
// Параметры:
//   НовыйТаймерПовторения - Число - таймер повторной синхронизации, сек
//
// Возвращаемое значение:
//   Объект.МенеджерСинхронизации - ссылка на текущий объект класса <МенеджерСинхронизации>
//
Функция ТаймерПовторения(Знач НовыйТаймерПовторения) Экспорт
	ТаймерПовторения = НовыйТаймерПовторения;
	Возврат ЭтотОбъект;
КонецФункции

Функция РабочийКаталог(Знач НовыйКаталогЛогов) Экспорт
	КаталогЛогов = НовыйКаталогЛогов;
	Возврат ЭтотОбъект;
КонецФункции

// Устанавливает таймер повторения пакетной синхронизации
//
// Параметры:
//   НовыйПровайдерОчереди - Класс - таймер повторной синхронизации, сек
//
// Возвращаемое значение:
//   Объект.МенеджерСинхронизации - ссылка на текущий объект класса <МенеджерСинхронизации>
//
Функция НастроитьRMQ(Знач НовыеНастройкиПровайдера) Экспорт
	
	ПровайдерОчередиRMQ = Новый ОчередьОбновленияRMQ();
	ПровайдерОчередиRMQ.Инициализировать(НовыеНастройкиПровайдера);
	ЧитательОчереди.УстановитьПровайдер(ПровайдерОчередиRMQ);

	Возврат ЭтотОбъект;

КонецФункции

Функция Идентификатор() Экспорт

	Возврат ИдентификаторАгента;

КонецФункции

// Выполняет пакетную синхронизацию
//
Процедура Запустить() Экспорт

	НастроитьЛогирование();
	ВыполнитьПакетноеОбновления();
	ФайлЖурнала.Закрыть();

КонецПроцедуры

Процедура ВыполнитьПакетноеОбновления()

	// Возврат;

	Пока ЧитательОчереди.Следующий() Цикл

		ЭлементОчереди = ЧитательОчереди.ТекущийЭлемент;
		ДинамическиеПараметрыЛога.Вставить("КлючСообщения", ЭлементОчереди["КлючСообщения"]);
		ДинамическиеПараметрыЛога.Вставить("КлючМаршрутизации", ЭлементОчереди["КлючМаршрутизации"]);
		Лог.Информация("Настройки обновления получены из очереди");
		РезультатВыполнения = ВыполнитьОбновлениеПоНастройки(ЭлементОчереди);

		Если НЕ РезультатВыполнения.Выполнено Тогда
			Лог.Ошибка("Обновление завершено с ошибкой:
			| <%1>", РезультатВыполнения.ОписаниеОшибки);
		Иначе
			Лог.Информация("Обновление завершено успешно");
		КонецЕсли;
		
	КонецЦикла;

КонецПроцедуры

Функция ВыполнитьОбновлениеПоНастройки(СоответствиеНастройки)

	НастройкиОбновления = ПрочитатьНастройкиОбновления(СоответствиеНастройки);
	ПроцессорОбновления = Новый МенеджерОбновления();
	Результат = ПроцессорОбновления.ОбновлениеПоНастройке(НастройкиОбновления);
	Возврат Результат;

КонецФункции

Функция ПрочитатьНастройкиОбновления(СоответствиеНастройки)
	
	НастройкиОбновления = Новый НастройкаОбновления(Новый УникальныйИдентификатор);
	НастройкиОбновления.ИзСоответствия(СоответствиеНастройки);
	НастройкиОбновления.ДобавитьСпособВывода(ВыводВRabbitMQ);

	Возврат НастройкиОбновления;

КонецФункции

Функция ИмяЛога() Экспорт
	
	Возврат "oscript.app.AutoUpdateIB.agent";

КонецФункции

Функция ИмяФайлаЛога() Экспорт

	Возврат ОбъединитьПути(КаталогЛогов, Строка(ИдентификаторАгента) + ".log");
	
КонецФункции

Процедура НастроитьЛогирование()
	
	ФайлЖурнала = Новый ВыводЛогаВФайл;
	ФайлЖурнала.ОткрытьФайл(ИмяФайлаЛога());
	Лог.ДобавитьСпособВывода(ФайлЖурнала);
	ДобавитьВыводЛогаВКонсоль();
	ДобавитьВыводЛогаВRabbitMQ();

КонецПроцедуры

Функция ДобавитьВыводЛогаВКонсоль()
	
	Если ВыводитьЛогВКонсоль Тогда
	
		ВыводВКонсоль = Новый ВыводЛогаВКонсоль();
		Лог.ДобавитьСпособВывода(ВыводВКонсоль);
	
	КонецЕсли;

КонецФункции

Процедура ДобавитьВыводЛогаВRabbitMQ()
	
	Лог.Отладка("Провайдер <%1>", ПровайдерОчередиRMQ);
	ВыводВRabbitMQ = Новый ВыводЛогаВRabbitMQ(ПровайдерОчередиRMQ, ДанныеПоСистеме, ДинамическиеПараметрыЛога);
	Лог.ДобавитьСпособВывода(ВыводВRabbitMQ);

КонецПроцедуры

Процедура ПриСозданииОбъекта(ВходящийИдентификаторАгента = Неопределено)

	Если ВходящийИдентификаторАгента = Неопределено Тогда
		ИдентификаторАгента = Новый УникальныйИдентификатор;
	Иначе
		ИдентификаторАгента = ВходящийИдентификаторАгента;
	КонецЕсли;

	ЧитательОчереди = Новый ОчередьОбновлений();
	ВыводитьЛогВКонсоль = Истина;
	КаталогЛогов = ТекущийКаталог(); // TODO: Убрать 
	ТаймерПовторения = 0;

	СИ = Новый СистемнаяИнформация;
	ДанныеПоСистеме = Новый Структура;
	ДанныеПоСистеме.Вставить("ИдентификаторАгента", ИдентификаторАгента);
	ДанныеПоСистеме.Вставить("ПользовательОС", СИ.ПользовательОС);
	ДанныеПоСистеме.Вставить("ИмяКомпьютера", СИ.ИмяКомпьютера);

	ДинамическиеПараметрыЛога = Новый Структура("КлючСообщения, КлючМаршрутизации", "", "");

	Лог = Логирование.ПолучитьЛог(ИмяЛога());
	Лог.УстановитьРаскладку(ЭтотОбъект);

КонецПроцедуры

Функция Форматировать(Знач Уровень, Знач Сообщение) Экспорт
	
	Возврат СтрШаблон("[%1] %2 - %3", ИдентификаторАгента, УровниЛога.НаименованиеУровня(Уровень), Сообщение);
	
КонецФункции
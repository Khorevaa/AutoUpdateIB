﻿//////////////////////////////////////////////////////////////////////////
//
// LOGOS: реализация логирования в стиле log4j для OneScript
//
//////////////////////////////////////////////////////////////////////////

Перем мСозданныеЛоги;
Перем мИдентификаторыЛогов;
Перем мНастройкиЛогирования;

//////////////////////////////////////////////////////////////////////////
// ПРОГРАММНЫЙ ИНТЕРФЕЙС

Функция ПолучитьЛог(Знач ИмяЛога) Экспорт

	Если ИмяЛога = ИмяКорневогоЛога() Тогда
		ВызватьИсключение СтрШаблон("Имя %1 зарезервировано в подсистеме логирования и не должно использоваться явно.", ИмяЛога);
	КонецЕсли;

	Если мНастройкиЛогирования = Неопределено Тогда
		ОбновитьНастройки();
	КонецЕсли;

	ОписаниеЛога = мСозданныеЛоги[ИмяЛога];
	Если ОписаниеЛога = Неопределено Тогда
		ОписаниеЛога = НовыйДескрипторЛога();
		ОписаниеЛога.Объект = Новый Лог(ИмяЛога);
		мСозданныеЛоги[ИмяЛога] = ОписаниеЛога;
		мИдентификаторыЛогов[ОписаниеЛога.Объект.ПолучитьИдентификатор()] = ИмяЛога;
		НастроитьЛог(ИмяЛога, ОписаниеЛога.Объект);
	КонецЕсли;
	
	ОписаниеЛога.СчетчикСсылок = ОписаниеЛога.СчетчикСсылок + 1;
	
	Возврат ОписаниеЛога.Объект;

КонецФункции

Процедура ЗакрытьЛог(Знач ОбъектЛога) Экспорт

	Идентификатор = ОбъектЛога.ПолучитьИдентификатор();
	ИмяЛога = мИдентификаторыЛогов[Идентификатор];
	Если ИмяЛога = Неопределено Тогда
		ОбъектЛога.Закрыть(); // Лог не создавался менеджером
		Возврат;
	КонецЕсли;
	
	ОписаниеЛога = мСозданныеЛоги[ИмяЛога];
	Если ОписаниеЛога <> Неопределено Тогда
		ОписаниеЛога.СчетчикСсылок = ОписаниеЛога.СчетчикСсылок - 1;
		Если ОписаниеЛога.СчетчикСсылок <= 0 Тогда
			ОписаниеЛога.Объект.Закрыть();
			мСозданныеЛоги.Удалить(ИмяЛога);
			мИдентификаторыЛогов.Удалить(Идентификатор);
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

Функция СписокСозданныхЛогов(Знач СтрокаФильтр = Неопределено) Экспорт
	
	СписокЛогов = Новый Массив();

	Для каждого КлючИЗначение Из мСозданныеЛоги Цикл
		
		Если ЗначениеЗаполнено(СтрокаФильтр) Тогда

			ИмяЛога = КлючИЗначение.Ключ;
			
			Если НЕ СтрНачинаетсяС(ИмяЛога, СтрокаФильтр) Тогда
				Продолжить;
			КонецЕсли;

			СписокЛогов.Добавить(КлючИЗначение.Ключ);

		иначе

			СписокЛогов.Добавить(КлючИЗначение.Ключ);

		КонецЕсли;
		
	КонецЦикла;

	Возврат СписокЛогов;

КонецФункции

Функция СокращенноеИмяЛога(Знач ИмяЛога) Экспорт
	Возврат ФорматироватьИмяЛога(ИмяЛога);
КонецФункции

Функция ФорматироватьИмяЛога(Знач ИмяЛога)
	
	КоличествоСимволов = 20;
	Результат = "";

	ИтоговаяДлинаЛога = СтрДлина(ИмяЛога);
	Если ИтоговаяДлинаЛога <= КоличествоСимволов Тогда
		Возврат ИмяЛога;
	КонецЕсли;

	УзлыЛога = СтрРазделить(ИмяЛога, ".");
	
	Если УзлыЛога.Количество() = 1 Тогда 
		Результат = СократитьСтроку(ИмяЛога, КоличествоСимволов);
		Возврат Результат;
	КонецЕсли;
	
	НеобходимоСокращатьУзелЛога = Истина;
	сч = 0;
	Для Каждого УзелЛога Из УзлыЛога Цикл
		
		ПоследнийУзелЛога = сч = УзлыЛога.ВГраница();
		
		Если НеобходимоСокращатьУзелЛога Тогда
			Если ПоследнийУзелЛога Тогда
				РезультирующийУзелЛога = СократитьСтроку(УзелЛога, Макс(1, КоличествоСимволов - СтрДлина(Результат)));
			Иначе
				РезультирующийУзелЛога = Лев(УзелЛога, 1);
			КонецЕсли;
		Иначе
			РезультирующийУзелЛога = УзелЛога;
		КонецЕсли;
		
		Результат = Результат + РезультирующийУзелЛога + ".";
		ИтоговаяДлинаЛога = ИтоговаяДлинаЛога - (СтрДлина(УзелЛога) - 1);
		
		Если ИтоговаяДлинаЛога <= КоличествоСимволов Тогда
			НеобходимоСокращатьУзелЛога = Ложь;
		КонецЕсли;

		сч = сч + 1;
	КонецЦикла;
	
	Результат = Лев(Результат, СтрДлина(Результат) - 1);
	
	Возврат Результат;

КонецФункции

Функция СократитьСтроку(Знач ИсходнаяСтрока, Знач КоличествоСимволов)
	
	Результат = ИсходнаяСтрока;
	
	Если СтрДлина(Результат) <= КоличествоСимволов Тогда
		Возврат Результат;
	КонецЕсли;

	Результат = "~" + Прав(Результат, Макс(КоличествоСимволов - 1, 1));
	
	Возврат Результат;
	
КонецФункции

Процедура ОбновитьНастройки() Экспорт
	
	КонфигИзСреды = Неопределено;
	
	КонфигИзСреды = ПолучитьПеременнуюСреды("LOGOS_CONFIG");
	Если Не ЗначениеЗаполнено(КонфигИзСреды) Тогда
		УровеньЛогаИзСреды = ПолучитьПеременнуюСреды("LOGOS_LEVEL");
		Если ЗначениеЗаполнено(УровеньЛогаИзСреды) Тогда
			КонфигИзСреды = СтрШаблон("logger.rootLogger=%1", УровеньЛогаИзСреды);
		КонецЕсли;
	КонецЕсли;
	
	мНастройкиЛогирования = Новый НастройкиЛогирования();
	Если ЗначениеЗаполнено(КонфигИзСреды) Тогда
		КонфигИзСреды = СтрЗаменить(КонфигИзСреды, ";", Символы.ПС);
		мНастройкиЛогирования.ПрочитатьИзСтроки(КонфигИзСреды);
	Иначе
		КаталогКонфига = СтартовыйСценарий().Каталог;
		ФайлКонфига = Новый Файл(ОбъединитьПути(КаталогКонфига, "logos.cfg"));
		Если ФайлКонфига.Существует() Тогда
			мНастройкиЛогирования.Прочитать(ФайлКонфига.ПолноеИмя);
		КонецЕсли;
	КонецЕсли;

КонецПроцедуры

//////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ МОДУЛЯ

Процедура НастроитьЛог(Знач ИмяЛога, Знач ОбъектЛога)
	
	КорневаяНастройка = мНастройкиЛогирования.Получить(ИмяКорневогоЛога());
	ПрименитьНастройку(ОбъектЛога, КорневаяНастройка);

	Настройка = мНастройкиЛогирования.Получить(ИмяЛога);
	ПрименитьНастройку(ОбъектЛога, Настройка);
	
КонецПроцедуры

Процедура ПрименитьНастройку(Знач ОбъектЛога, Знач Настройка)
	
	Если Настройка = Неопределено Тогда
		Возврат;
	КонецЕсли;

	Если Настройка.Уровень <> Неопределено Тогда
		ОбъектЛога.УстановитьУровень(Настройка.Уровень);
	КонецЕсли;

	Для Каждого СпособВывода Из Настройка.СпособыВывода Цикл
		Описание = СпособВывода.Значение;
		ОбъектСпособаВывода = Новый(Описание.Класс);
		Для Каждого КлючИЗначение Из Описание.Свойства Цикл
			ОбъектСпособаВывода.УстановитьСвойство(КлючИЗначение.Ключ, КлючИЗначение.Значение);
		КонецЦикла;
		ОбъектЛога.ДобавитьСпособВывода(ОбъектСпособаВывода, Описание.Уровень);
	КонецЦикла;

КонецПроцедуры

Функция НовыйДескрипторЛога()
	
	Описание = Новый Структура;
	Описание.Вставить("Объект", Неопределено);
	Описание.Вставить("СчетчикСсылок", 0);
	
	Возврат Описание;
	
КонецФункции

Процедура Инициализация()

	мСозданныеЛоги = Новый Соответствие;
	мИдентификаторыЛогов = Новый Соответствие;

КонецПроцедуры

Функция ИмяКорневогоЛога()
	Возврат "rootLogger";
КонецФункции

///////////////////////////////////////////////////////////////////////////

Инициализация();
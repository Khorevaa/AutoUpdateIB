Перем СтруктураЭтапов; // Структура
Перем ЗавершающиеЭтапы;  // Массив

Процедура ДобавитьЭтап(Наименование, ИсполнительЭтапа, СледующийЭтап = "", ОбязательныйЭтап = "") Экспорт
	
	СтруктураЭтапов.Вставить(Наименование, ОписаниеЭтапа(Наименование, ИсполнительЭтапа, СледующийЭтап, ОбязательныйЭтап))

	Если Не ПустаяСтрока(ОбязательныйЭтап) Тогда
		ЗавершающиеЭтапы.Добавить(ОбязательныйЭтап);
	КонецЕсли;

КонецПроцедуры

Функция ВыполнитьЭтап(ИмяЭтапа, ПараметрыЭтапа = Неопределено) Экспорт
	
	ВыполняемыйЭтап = СтруктураЭтапов[ИмяЭтапа];

	РезультатВыполненияЭтапа = Новый Структура;

	РезультатВыполненияЭтапа.Вставить("ОписаниеЭтапа",  ВыполняемыйЭтап);
	РезультатВыполненияЭтапа.Вставить("ЗавершающиеЭтапы",  ЗавершающиеЭтапы);
	
	РезультатИсполненияДелегата = Истина;

	Попытка
		
		ИсполнительЭтапа.Исполнить();
			
	Исключение

		РезультатИсполненияДелегата = Ложь;
		ОшибкаВыполнения = ОписаниеОшибки();

	КонецПопытки;

	РезультатВыполненияЭтапа.Вставить("Результат",  РезультатИсполненияДелегата);
	РезультатВыполненияЭтапа.Вставить("ОшибкаВыполнения",  ОшибкаВыполнения);

	Возврат РезультатВыполненияЭтапа;

КонецФункции

Функция ОписаниеЭтапа(Наименование, ИсполнительЭтапа, СледующийЭтап, ОбязательныйЭтап)
	
	Описание = Новый Структура;
	Описание.Наименование = Наименование;
	Описание.ИсполнительЭтапа = ИсполнительЭтапа;
	Описание.СледующийЭтап = СледующийЭтап;
	Описание.ОбязательныйЭтап = ОбязательныйЭтап;

	Возврат Описание;

КонецФункции

ЗавершающиеЭтапы = Новый Массив;
СтруктураЭтапов = Новый Структура;

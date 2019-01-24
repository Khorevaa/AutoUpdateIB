#Использовать fs
#Использовать logos
#Использовать tempfiles

Перем ПутьКФайлу;
Перем ХешФайла;
Перем ХешСуммаСтрокой;

Перем Лог;

Функция ХешФайла() Экспорт
	
	Если ЗначениеЗаполнено(ХешСуммаСтрокой) Тогда
		Возврат ХешСуммаСтрокой;
	КонецЕсли;
	
	ХешСуммаСтрокой = ХешФайла.ХешСуммаСтрокой();
	
	Возврат ХешСуммаСтрокой;
	
КонецФункции

Функция ХешФункция() Экспорт
	Возврат ХешФайла.ХешФункция();
КонецФункции

Функция Используется() Экспорт
	Возврат ЗначениеЗаполнено(ПутьКФайлу);
КонецФункции

Процедура Параметры(ВходящиеПараметры) Экспорт
	
	Лог.Отладка("Устанавливаю параметры (тип: <%1>) получения файла по пути", ТипЗнч(ВходящиеПараметры));

	Если ВходящиеПараметры = Неопределено Тогда
		Лог.Отладка("Неопределенны входящие параметры получения файла по пути");
		Возврат;
	КонецЕсли;
			
	КонструкторПараметров = ПолучитьКонструкторПараметров();
	
	КонструкторПараметров.ИзСоответствия(ВходящиеПараметры);

	СтруктураПараметров = КонструкторПараметров.ВСтруктуру();

	ПутьКФайлу = СтруктураПараметров.ПутьКФайлу;
	Лог.Отладка("Установлен путь к сетевому файлу <%1>", ПутьКФайлу);
	ПараметрыХеша = СтруктураПараметров.ХешФайла;
	
	Лог.Отладка("Формирую параметры хеша получения файла по пути");
	ХешФайла = Новый ПараметрыХешаФайла();
	ХешФайла.Настроить(ПараметрыХеша);
	
КонецПроцедуры

Процедура СверитьХешФайла(ПутьКФайлуСверки)
	
	ХешированиеДанных = Новый ХешированиеДанных(ХешФайла.ХешФункция());
	ХешированиеДанных.ДобавитьФайл(ПутьКФайлуСверки);
	ТекущийХеш = НРег(ХешированиеДанных.ХешСуммаСтрокой);
	ХешированиеДанных.Очистить();
	ХешированиеДанных = Неопределено;
	Если НЕ ТекущийХеш = НРег(ХешФайла()) Тогда
		ТекстСообщения = СтрШаблон(
		"Не совпадают хеши файлов:
		|Контрольная сумма ожидаемая: %1
		|Контрольная сумма файла: %2",
		ХешФайла(),
		ТекущийХеш
	);
	ИнфИсключение = Новый ИнформацияОбОшибке(ТекстСообщения, ХешФайла());
	ВызватьИсключение ИнфИсключение;
КонецЕсли;

КонецПроцедуры

Функция Получить() Экспорт
	
	ФайлПолучения = Новый Файл(ПутьКФайлу);
	
	Если ФайлПолучения.ЭтоКаталог() Тогда
			ТекстСообщения = СтрШаблон(
			"Передан каталог вместо файла: %1",
			ФайлПолучения.ПолноеИмя
		);
		ИнфИсключение = Новый ИнформацияОбОшибке(ТекстСообщения, ХешФайла());
		ВызватьИсключение ИнфИсключение;
		
	КонецЕсли;

	ВременныйФайл = ВременныеФайлы.НовоеИмяФайла(ФайлПолучения.Расширение);

	КопироватьФайл(ФайлПолучения.ПолноеИмя, ВременныйФайл);

	Если Не ЗначениеЗаполнено(ХешФайла()) Тогда
		ХешСуммаСтрокой = РассчитатьХешФайла(ВременныйФайл);
	КонецЕсли;

	СверитьХешФайла(ВременныйФайл);

	Возврат ВременныйФайл;

КонецФункции

Функция РассчитатьХешФайла(Знач ПутьКФайлуРасчета)
	ХешированиеДанных = Новый ХешированиеДанных(ХешФункция.MD5);
	ХешированиеДанных.ДобавитьФайл(ПутьКФайлуРасчета);
	ТекущийХеш = НРег(ХешированиеДанных.ХешСуммаСтрокой);
	ХешированиеДанных.Очистить();
	Возврат ТекущийХеш;
КонецФункции

Функция ПолучитьКонструкторПараметров()
	
	КонструкторПараметров = Новый КонструкторПараметров;
	
	КонструкторПараметров 
		.ПолеСтрока("ПутьКФайлу path", "")
		.ПолеОбъект("ХешФайла hash", Новый ПараметрыХешаФайла)
		;
		
	Возврат КонструкторПараметров;
	
КонецФункции

Процедура ОписаниеПараметров(Конструктор) Экспорт
	
	Конструктор = ПолучитьКонструкторПараметров();
	
КонецПроцедуры

Процедура ПриСозданииОбъекта()
	
	ПутьКФайлу = "";
	
	Лог = Логирование.ПолучитьЛог("oscript.app.AutoUpdateIB.file-copy");
//	Лог.УстановитьУровень(УровниЛога.Отладка);
	
КонецПроцедуры
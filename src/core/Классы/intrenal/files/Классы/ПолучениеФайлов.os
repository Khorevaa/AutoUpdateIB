#Использовать "./internal"
#Использовать logos

Перем Лог;
Перем ОбработчикПолученияФайла;

Функция ХешФайла() Экспорт
	Возврат ОбработчикПолученияФайла.ХешФайла();
КонецФункции

Функция Получить(Знач ПутьККаталогу) Экспорт

	ПутьКФайлу = ОбработчикПолученияФайла.Получить(ПутьККаталогу);

	Возврат ПутьКФайлу;
	
КонецФункции

Функция Параметры(ВходящиеПараметры) Экспорт

	ПолучениеИзСетевогоФайла = Новый ПолучениеИзСетевогоФайла;
	ПолучениеИзСетевогоФайла.Параметры(ВходящиеПараметры["Файл"]);

	Если ПолучениеИзСетевогоФайла.Используется() Тогда
		Лог.Отладка("Установлено получение файла из сетового каталога");
		ОбработчикПолученияФайла = ПолучениеИзСетевогоФайла;
		Возврат ЭтотОбъект;

	КонецЕсли;

	// ПолучениеИзАртифактори = Новый ПолучениеИзАртифактори;
	// ПолучениеИзАртифактори.Параметры(ВходящиеПараметры["Артифактори"]);

	// Если ПолучениеИзАртифактори.Используется() Тогда
	// 	Лог.Отладка("Установлено получение файла из Артифактори");
	// 	ОбработчикПолученияФайла = ПолучениеИзАртифактори;
	// 	Возврат ЭтотОбъект;

	// КонецЕсли;
	
	ПолучениеИзДвоичныхДанных = Новый ПолучениеИзДвоичныхДанных;
	ПолучениеИзДвоичныхДанных.Параметры(ВходящиеПараметры["ДвоичныеДанные"]);

	Если ПолучениеИзДвоичныхДанных.Используется() Тогда
		Лог.Отладка("Установлено получение файла из двоичных данных");
		ОбработчикПолученияФайла = ПолучениеИзДвоичныхДанных;
		Возврат ЭтотОбъект;

	КонецЕсли;

	Если ОбработчикПолученияФайла = Неопределено Тогда
		ТекстСообщения = СтрШаблон(
			"Не удалось определить протокол получения файла"
			);
		ИнфИсключение = Новый ИнформацияОбОшибке(ТекстСообщения, ЭтотОбъект);
		ВызватьИсключение ИнфИсключение;
	КонецЕсли;

	Возврат ЭтотОбъект;

КонецФункции

Процедура ОписаниеПараметров(Знач Конструктор) Экспорт

	Конструктор
		.ПолеОбъект("Файл file", Новый ПолучениеИзСетевогоФайла)
		.ПолеОбъект("ДвоичныеДанные bindata", Новый ПолучениеИзДвоичныхДанных)
		//.ПолеОбъект("Артифактори artifactory", Новый ПолучениеИзАртифактори)
		// .ПолеОбъект("HTTP http", Новый ПолучениеИзАртифактори)
		// .ПолеОбъект("ГитХаб github", НастройкаАртифактори)
		;

КонецПроцедуры

Процедура ПриСозданииОбъекта()

	Лог = Логирование.ПолучитьЛог("oscript.app.AutoUpdateIB.get-file");
	Лог.УстановитьУровень(УровниЛога.Отладка);

КонецПроцедуры
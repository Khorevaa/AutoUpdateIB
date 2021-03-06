#Использовать logos

Перем Лог;
Перем ОбработчикПолученияФайла;

Функция ХешФайла() Экспорт
	Если ОбработчикПолученияФайла = Неопределено Тогда
		Возврат "";
	КонецЕсли;

	Возврат ОбработчикПолученияФайла.ХешФайла();
КонецФункции

Функция ХешФункция() Экспорт
	Если ОбработчикПолученияФайла = Неопределено Тогда
		Возврат "";
	КонецЕсли;

	Возврат ОбработчикПолученияФайла.ХешФункция();
КонецФункции

Функция Используется() Экспорт
	Если ОбработчикПолученияФайла = Неопределено Тогда
		Возврат Ложь;
	КонецЕсли;

	Возврат ОбработчикПолученияФайла.Используется();
КонецФункции

Функция Получить() Экспорт

	Если ОбработчикПолученияФайла = Неопределено Тогда
		Возврат "";
	КонецЕсли;

	ПутьКФайлу = ОбработчикПолученияФайла.Получить();

	Возврат ПутьКФайлу;
	
КонецФункции

Процедура НастроитьПолучениеИзСетевогоФайла(Знач ПараметрыНастройки)
	
	Лог.Отладка("Установлено получение файла из сетового каталога");

	ПолучениеИзСетевогоФайла = Новый ПолучениеИзСетевогоФайла;
	ПолучениеИзСетевогоФайла.Параметры(ПараметрыНастройки);

	ОбработчикПолученияФайла = ПолучениеИзСетевогоФайла;

КонецПроцедуры

Процедура НастроитьПолучениеВстроенныхФайлов(Знач ПараметрыНастройки)
	
	Лог.Отладка("Установлено получение файла из сетового каталога");

	ПолучениеВстроенныхФайлов = Новый ПолучениеВстроенныхФайлов;
	ПолучениеВстроенныхФайлов.Параметры(ПараметрыНастройки);

	ОбработчикПолученияФайла = ПолучениеВстроенныхФайлов;

КонецПроцедуры

Процедура НастроитьПолучениеИзДвоичныхДанных(Знач ПараметрыНастройки)
	
	Лог.Отладка("Установлено получение файла из двоичных данных");
	
	ПолучениеИзДвоичныхДанных = Новый ПолучениеИзДвоичныхДанных;
	ПолучениеИзДвоичныхДанных.Параметры(ПараметрыНастройки);

	ОбработчикПолученияФайла = ПолучениеИзДвоичныхДанных;

КонецПроцедуры

Функция Параметры(ВходящиеПараметры) Экспорт

	Если ВходящиеПараметры = Неопределено Тогда
		Лог.КритичнаяОшибка("Входящие параметры неопределенны");
		ВызватьИсключение "Входящие параметры неопределенны";
	КонецЕсли;

	Лог.Отладка("Загружаю параметры получения файла. Количество свойств <%1>", ВходящиеПараметры.Количество());
	
	Если ВходящиеПараметры.Свойство("Файл") Тогда

		НастроитьПолучениеИзСетевогоФайла(ВходящиеПараметры.Файл);

	ИначеЕсли ВходящиеПараметры.Свойство("ДвоичныеДанные") Тогда

		НастроитьПолучениеИзДвоичныхДанных(ВходящиеПараметры.ДвоичныеДанные);

	ИначеЕсли ВходящиеПараметры.Свойство("ВстроенныйФайл")
		И Не ПустаяСтрока(ВходящиеПараметры.ВстроенныйФайл) Тогда

		НастроитьПолучениеВстроенныхФайлов(ВходящиеПараметры.ВстроенныйФайл);

	Иначе

		Возврат Ложь

	КонецЕсли;
	
	Возврат Истина;

КонецФункции

Процедура ОписаниеПараметров(Знач КонструкторПараметров) Экспорт

	КонструкторПараметров		
		.ПолеОбъект("Файл file", Новый ПолучениеИзСетевогоФайла, Ложь)
		.ПолеОбъект("ДвоичныеДанные bindata", Новый ПолучениеИзДвоичныхДанных, Ложь)
		.ПолеСтрока("ВстроенныйФайл internal", "")
		//.ПолеОбъект("Артифактори artifactory", Новый ПолучениеИзАртифактори)
		// .ПолеОбъект("HTTP http", Новый ПолучениеИзАртифактори)
		// .ПолеОбъект("ГитХаб github", НастройкаАртифактори)
		;

КонецПроцедуры

Процедура ПриСозданииОбъекта()

	Лог = Логирование.ПолучитьЛог("oscript.app.lib.get-file");
//	Лог.УстановитьУровень(УровниЛога.Отладка);


КонецПроцедуры
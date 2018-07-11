#Использовать fs

Перем ПутьКФайлу;
Перем ХешФайла;
Перем ХешСуммаСтрокой;

Функция ХешФайла() Экспорт
	
	Если ЗначениеЗаполнено(ХешСуммаСтрокой) Тогда
		Возврат ХешСуммаСтрокой;
	КонецЕсли;

	ХешСуммаСтрокой = ХешФайла.ХешСуммаСтрокой();

	Возврат ХешСуммаСтрокой;

КонецФункции

Функция Используется() Экспорт
	Возврат ЗначениеЗаполнено(ПутьКФайлу);
КонецФункции

Процедура Параметры(ВходящиеПараметры) Экспорт
	
	ПутьКФайлу = ВходящиеПараметры["ПутьКФайлу"];
	ХешФайла = Новый ПараметрыХешаФайла();
	ХешФайла.Настроить(ВходящиеПараметры["ХешФайла"]);
	
КонецПроцедуры

Процедура Получить(Знач Каталог) Экспорт
	
	ФайлПолучения = Новый Файл(ПутьКФайлу);
	
	Если ФайлПолучения.ЭтоКаталог() Тогда
		СкопироватьКаталог(Каталог, ФайлПолучения);
	Иначе
		ПолучитьФайлВКаталог(Каталог, ФайлПолучения);
	КонецЕсли;

КонецПроцедуры

Процедура ПолучитьФайлВКаталог(Знач Каталог, ФайлПолучения)
	
	ФайлПриемник = ФС.ПолныйПуть(ОбъединитьПути(Каталог, ХешФайла()) + ФайлПолучения.Расширение);
	КопироватьФайл(ФайлПолучения.ПолноеИмя, ФайлПриемник);

КонецПроцедуры

Процедура СкопироватьКаталог(Знач Каталог, ФайлПолучения)
	
	КаталогПриемник = ФС.ПолныйПуть(ОбъединитьПути(Каталог, ХешФайла()));
	ФС.ОбеспечитьКаталог(КаталогПриемник);
	ФС.КопироватьСодержимоеКаталога(ФайлПолучения.ПолноеИмя, КаталогПриемник);

КонецПроцедуры

Процедура ОписаниеПараметров(Знач Конструктор) Экспорт
	
	Конструктор
		.ПолеСтрока("ПутьКФайлу path", "")
		.ПолеОбъект("ХешФайла hash", Новый ПараметрыХешаФайла)
		;

КонецПроцедуры

Процедура ПриСозданииОбъекта()
	ПутьКФайлу = "";
КонецПроцедуры
#Использовать logos
#Использовать tempfiles
Перем Лог;

Перем ДвоичныеДанныеФайла;
Перем ХешФайла;
Перем ХешСуммаСтрокой;
Перем РасширениеФайла;

Функция ХешФункция() Экспорт
	Возврат ХешФайла.ХешФункция();
КонецФункции

Функция ХешФайла() Экспорт
	
	Если ЗначениеЗаполнено(ХешСуммаСтрокой) Тогда
		Возврат ХешСуммаСтрокой;
	КонецЕсли;

	ХешСуммаСтрокой = ХешФайла.ХешСуммаСтрокой();

	Если НЕ ЗначениеЗаполнено(ХешСуммаСтрокой) Тогда
		РассчитатьХешФайла();
	КонецЕсли;

	Возврат ХешСуммаСтрокой;

КонецФункции

Функция Используется() Экспорт
	Возврат ЗначениеЗаполнено(ДвоичныеДанныеФайла) 
			И ЗначениеЗаполнено(РасширениеФайла);
КонецФункции

Процедура Параметры(ВходящиеПараметры) Экспорт
	
	Если ВходящиеПараметры = Неопределено Тогда
		Возврат;
	КонецЕсли;

	Если ЗначениеЗаполнено(ВходящиеПараметры["ДвоичныеДанные"]) Тогда
		ДвоичныеДанныеФайла = РаскодироватьСтроку(ПолучитьДвоичныеДанныеИзBase64Строки(ВходящиеПараметры["ДвоичныеДанные"]), СпособКодированияСтроки.КодировкаURL);
	КонецЕсли;
	
	РасширениеФайла = ВходящиеПараметры["РасширениеФайла"];
	ИсправитьРасширение();
	ХешФайла = Новый ПараметрыХешаФайла();
	ХешФайла.Настроить(ВходящиеПараметры["ХешДанных"]);
	
КонецПроцедуры

Процедура ИсправитьРасширение()
	
	Если СтрНачинаетсяС(РасширениеФайла, ".") Тогда
		Возврат;
	КонецЕсли;

	РасширениеФайла = "." + РасширениеФайла;

КонецПроцедуры

Процедура РассчитатьХешФайла()

	ХешированиеДанных = Новый ХешированиеДанных(ХешФайла.ХешФункция());
	ХешированиеДанных.Добавить(ДвоичныеДанныеФайла);
	ХешСуммаСтрокой = НРег(ХешированиеДанных.ХешСуммаСтрокой);
	ХешированиеДанных.Очистить();
	
КонецПроцедуры

Функция Получить() Экспорт
	
	ПутьКФайлуПриемнику = ВременныеФайлы.НовоеИмяФайла(РасширениеФайла);
	Лог.Отладка("Сохранение бинарных данных в файл <%1>", ПутьКФайлуПриемнику);
	ДвоичныеДанныеФайла.Записать(ПутьКФайлуПриемнику);

	Возврат ПутьКФайлуПриемнику;

КонецФункции

Процедура ОписаниеПараметров(Знач Конструктор) Экспорт
	
	Конструктор
		.ПолеСтрока("ДвоичныеДанные data", "")
		.ПолеСтрока("РасширениеФайла ext", "")
		.ПолеОбъект("ХешДанных hash", Новый ПараметрыХешаФайла)
		;

КонецПроцедуры

Процедура ПриСозданииОбъекта()

	Лог = Логирование.ПолучитьЛог("oscript.app.AutoUpdateIB.bindata");
//	Лог.УстановитьУровень(УровниЛога.Отладка);


КонецПроцедуры
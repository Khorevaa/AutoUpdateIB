#Использовать fs
#Использовать json
#Использовать logos
#Использовать tempfiles
#Использовать "./artifactory-api"

Перем ПутьКФайлу;
Перем РасширениеФайла;
Перем ХешСуммаСтрокой;
Перем ЛокальныйКлиентАртифактори;
Перем ИспользоватьПолныйДистрибутив;

Перем Лог;

Функция ХешФайла() Экспорт
	
	Если ЗначениеЗаполнено(ХешСуммаСтрокой) Тогда
		Возврат ХешСуммаСтрокой;
	КонецЕсли;

	ХешСуммаСтрокой = ПолучитьХешФайла();

	Возврат ХешСуммаСтрокой;

КонецФункции

Процедура Получить(Знач Каталог) Экспорт
	
	ВременныйФайл = ВременныеФайлы.СоздатьФайл(РасширениеФайла);
	ФайлПриемник = ФС.ПолныйПуть(ОбъединитьПути(Каталог, ХешФайла()) + РасширениеФайла);

	Лог.Отладка("Получение файла с адреса <%1> в файл <%2> ", ПутьКФайлу, ФайлПриемник);
	ЛокальныйКлиентАртифактори.ПолучитьФайл(ПутьКФайлу, ВременныйФайл);

	СверитьХешФайла(ВременныйФайл);

	КопироватьФайл(ВременныйФайл, ФайлПриемник);

	ВременныеФайлы.УдалитьФайл(ВременныйФайл);

КонецПроцедуры

Функция Используется() Экспорт
	Возврат ЗначениеЗаполнено(ПутьКФайлу);
КонецФункции

Процедура Параметры(ВходящиеНастройки) Экспорт

	ЛокальныйКлиентАртифактори = Новый КлиентАртифактори(ВходящиеНастройки.Сервер,
														ВходящиеНастройки.Порт,
														ВходящиеНастройки.ПутьНаСервере);

	Если ЗначениеЗаполнено(ВходящиеНастройки.Пользователь) Тогда
		ЛокальныйКлиентАртифактори.Авторизацию(ВходящиеНастройки.Пользователь, ВходящиеНастройки.Пароль);
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ВходящиеНастройки.Файл.ПутьКФайлу) Тогда
		ПутьКФайлу = ВходящиеНастройки.Файл.ПутьКФайлу;
	ИначеЕсли ЗначениеЗаполнено(ВходящиеНастройки.НастройкаМодуля.Репозиторий) Тогда
		ПрочитатьНастройкиМодулю(ВходящиеНастройки.НастройкаМодуля);
	КонецЕсли;
	
	ПолучитьРасширение();

КонецПроцедуры

Процедура ПолучитьРасширение()
	
	СимволТочки = СтрНайти(ПутьКФайлу, ".", НаправлениеПоиска.СКонца);

	РасширениеФайла = Сред(ПутьКФайлу, СимволТочки);

КонецПроцедуры

Процедура ПрочитатьНастройкиМодулю(НастройкаМодуля)
	 
	ПутьКФайлу = СтрШаблон("%1/%2/%3/%5/%4/%6/%2-%3-%5-%6.%7",
						НастройкаМодуля.Репозиторий,
						НастройкаМодуля.Организация,
						НастройкаМодуля.Модуль,
						НастройкаМодуля.ВидМодуля,
						НастройкаМодуля.ТипМодуля,
						НастройкаМодуля.ВерсияРелиза,
						НастройкаМодуля.Расширение);
	
	Лог.Отладка("Получене путь к файла <%1> ", ПутьКФайлу);

КонецПроцедуры

Процедура ОписаниеПараметров(Знач Конструктор) Экспорт
	
	НастройкаАртифакториМодуля = Конструктор.НовыеПараметры();
	НастройкаАртифакториМодуля
		.ПолеСтрока("Репозиторий repo", "")
		.ПолеСтрока("Организация org", "")
		.ПолеСтрока("Модуль module", "")
		.ПолеСтрока("ТипМодуля type", "")
		.ПолеСтрока("ВидМодуля revision", "")
		.ПолеСтрока("ВерсияРелиза version baseRev", "")
		.ПолеСтрока("Расширение ext", "cf")
		;
	
	НастройкаФайлаАртифактори = Конструктор.НовыеПараметры();
	НастройкаФайлаАртифактори
		.ПолеСтрока("ПутьКФайлу path", "")
		;

	Конструктор.ПолеСтрока("Сервер ИмяСервера server", "")
		.ПолеЧисло("Порт ПортСервера port", 80)
		.ПолеСтрока("ПутьНаСервере domain", "artifactory")
		.ПолеСтрока("Пользователь user usr", "")
		.ПолеСтрока("Пароль password pwd", "")
		.ПолеОбъект("НастройкаМодуля module", НастройкаАртифакториМодуля)
		.ПолеОбъект("Файл file", НастройкаФайлаАртифактори)
		;

КонецПроцедуры

Процедура СверитьХешФайла(ПутьКФайлу)
	
	ХешированиеДанных = Новый ХешированиеДанных(ХешФункция.MD5);
	ХешированиеДанных.ДобавитьФайл(ПутьКФайлу);
	ТекущийХеш = НРег(ХешированиеДанных.ХешСуммаСтрокой);
	ХешированиеДанных.Очистить();
	Если НЕ ТекущийХеш = ХешФайла() Тогда
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

Функция ПолучитьХешФайла()

	Лог.Отладка("Получение хеш суммы файла <%1>", ПутьКФайлу);
	ОписаниеФайла = ЛокальныйКлиентАртифактори.ПолучитьОписаниеФайла(ПутьКФайлу);

	Если ОписаниеФайла["checksums"] = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли;

	ПолученныйXешФайла = ОписаниеФайла["checksums"]["md5"];

	Возврат ПолученныйXешФайла;

КонецФункции

Процедура ПриСозданииОбъекта()

	Лог = Логирование.ПолучитьЛог("oscript.app.AutoUpdateIB.artifactory");
//	Лог.УстановитьУровень(УровниЛога.Отладка);


КонецПроцедуры
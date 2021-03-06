// Реализация шагов BDD-фич/сценариев c помощью фреймворка https://github.com/artbear/1bdd
#Использовать asserts
#Использовать tempfiles
#Использовать v8runner
#Использовать json
#Использовать yaml

// #Использовать "../../src/core"

Перем БДД; //контекст фреймворка 1bdd

// Метод выдает список шагов, реализованных в данном файле-шагов
Функция ПолучитьСписокШагов(КонтекстФреймворкаBDD) Экспорт
	БДД = КонтекстФреймворкаBDD;

	ВсеШаги = Новый Массив;

	ВсеШаги.Добавить("ЯУстанавливаюПутьВыполненияКомандыКТекущейБиблиотеке");
	ВсеШаги.Добавить("ЯСоздаюВременныйКаталогИСохраняюЕгоВПеременной");
	ВсеШаги.Добавить("ЯСоздаюТестовуюБазуВКаталоге");
	ВсеШаги.Добавить("ЯДобавляюПозиционныйПараметрДляКомандыИзПеременной");
	ВсеШаги.Добавить("ЯОтправляюНастройкуОбновленияВОчередьИзФайла");

	Возврат ВсеШаги;

КонецФункции

Функция ИмяЛога() Экспорт
	Возврат "bdd.AutoUpdateIB.feature";
КонецФункции

// Реализация шагов

// Процедура выполняется перед запуском каждого сценария
Процедура ПередЗапускомСценария(Знач Узел) Экспорт
КонецПроцедуры

// Процедура выполняется после завершения каждого сценария
Процедура ПослеЗапускаСценария(Знач Узел) Экспорт
	ВременныеФайлы.Удалить();
КонецПроцедуры

//Я создаю временный каталог и сохраняю его в переменной "КаталогПлагинов"
Процедура ЯСоздаюВременныйКаталогИСохраняюЕгоВПеременной(Знач ИмяПеременной) Экспорт

	ВременныйКаталог = ВременныеФайлы.СоздатьКаталог();
	
	БДД.СохранитьВКонтекст(ИмяПеременной, ВременныйКаталог);
	
КонецПроцедуры

//Я создаю тестовую базу в каталоге "ТестоваяБаза"
Процедура ЯСоздаюТестовуюБазуВКаталоге(Знач ИмяПеременной) Экспорт

	КаталогФайловойБазы = БДД.ПолучитьИзКонтекста(ИмяПеременной);
	
	УправлениеКонфигуратором = Новый УправлениеКонфигуратором;
	УправлениеКонфигуратором.КаталогСборки(ВременныеФайлы.СоздатьКаталог());
	УправлениеКонфигуратором.СоздатьФайловуюБазу(КаталогФайловойБазы);
	УправлениеКонфигуратором.УстановитьКонтекст(СтрШаблон("/F%1", КаталогФайловойБазы), "", "");
	УправлениеКонфигуратором.ЗагрузитьКонфигурациюИзФайла(ОбъединитьПути(КаталогFixtures(), "distr", "1.0/1Cv8.cf"), Истина);

КонецПроцедуры

//Я добавляю позиционный параметр для команды "gitsync" из переменной "URLРепозитория"
Процедура ЯДобавляюПозиционныйПараметрДляКомандыИзПеременной(Знач ИмяКоманды, Знач ИмяПеременной) Экспорт

	Команда = БДД.ПолучитьИзКонтекста(КлючКоманды(ИмяКоманды));
	ЗначениеПеременной = БДД.ПолучитьИзКонтекста(ИмяПеременной);

	Команда.ДобавитьПараметр(ЗначениеПеременной);

КонецПроцедуры

//Я добавляю параметры для команды "gitsync"
//|--storage-user Администратор|
//|-useVendorUnload|
Процедура ЯДобавляюПараметрыДляКоманды(Знач ИмяКоманды, Знач ТаблицаПараметров) Экспорт
	
	Команда = БДД.ПолучитьИзКонтекста(КлючКоманды(ИмяКоманды));
	Для Каждого Параметр Из ТаблицаПараметров Цикл
		Команда.ДобавитьПараметр(Параметр[0]);
	КонецЦикла;

КонецПроцедуры

//Я устанавливаю путь выполнения команды "gitsync" к текущей библиотеке
Процедура ЯУстанавливаюПутьВыполненияКомандыКТекущейБиблиотеке(Знач ИмяКоманды) Экспорт
	
	ПутьККоманде = ОбъединитьПути(КаталогПриложения(), "src", "cmd", "AutoUpdateIB.os");
	Команда = БДД.ПолучитьИзКонтекста(КлючКоманды(ИмяКоманды));
	Команда.УстановитьКоманду("oscript");
	Команда.ДобавитьПараметр("-encoding=utf-8");

	Команда.ДобавитьПараметр(ОбернутьВКавычки(ПутьККоманде));
	
КонецПроцедуры

//Я отправляю настройку обновления в очередь из файла "./fixtures/test-arfifactory.yaml"
Процедура ЯОтправляюНастройкуОбновленияВОчередьИзФайла(Знач ИмяПеременной) Экспорт
	
	ПутьКФайлу = БДД.ПолучитьИзКонтекста(ИмяПеременной);

	ЧтениеТекста = Новый ЧтениеТекста();
	ЧтениеТекста.Открыть(ПутьКФайлу, КодировкаТекста.UTF8);
	ТекстYaml = ЧтениеТекста.Прочитать();
	ЧтениеТекста.Закрыть();

	Процессор = Новый ПарсерYAML;
	Результат = Процессор.ПрочитатьYaml(ТекстYaml);

	ДанныеСообщения = РаботаСФайлами.ОбъектВJson(Результат);

	СообщениеRMQ = Новый СообщениеRMQ();
	СообщениеRMQ.ДанныеСообщения = ПолучитьДвоичныеДанныеИзСтроки(ДанныеСообщения);
	СообщениеRMQ.КлючМаршрутизации = "all.update";
	СообщениеRMQ.КодировкаКонтента = "base64";
	СообщениеRMQ.Параметр("Тип", "update");
	СообщениеRMQ.Параметр("КлючСообщения", "2d2a9915-e59f-4359-8e3c-f5b29b8a5645");
	СообщениеRMQ.Параметр("АдресОтвета", "report.update");
	СообщениеRMQ.Параметр("КодировкаКонтента", "application/json");

	КлиентRMQ = БДД.ПолучитьИзКонтекста("КлиентRMQ");
	КлиентRMQ.ОтправитьСообщениеRMQ(СообщениеRMQ);

	Приостановить(10*1000); // 10 сек задержки

КонецПроцедуры

Функция КаталогFixtures()
	Возврат ОбъединитьПути(КаталогПриложения(), "tests", "fixtures");
КонецФункции

Функция КаталогПриложения()
	Возврат ОбъединитьПути(ТекущийСценарий().Каталог, "..", "..");
КонецФункции

Функция ОбернутьВКавычки(Знач Строка);
	Возврат """" + Строка + """";
КонецФункции

Функция КлючКоманды(Знач ИмяКоманды)
	Возврат "Команда-" + ИмяКоманды;
КонецФункции

Лог = Логирование.ПолучитьЛог(ИмяЛога());
//Лог.УстановитьУровень(Логирование.ПолучитьЛог("bdd").Уровень());
// Лог.УстановитьУровень(УровниЛога.Отладка);

﻿// Реализация шагов BDD-фич/сценариев c помощью фреймворка https://github.com/artbear/1bdd
#Использовать tempfiles

Перем БДД; //контекст фреймворка 1bdd

// Метод выдает список шагов, реализованных в данном файле-шагов
Функция ПолучитьСписокШагов(КонтекстФреймворкаBDD) Экспорт
	БДД = КонтекстФреймворкаBDD;

	ВсеШаги = Новый Массив;

	ВсеШаги.Добавить("ЯСоздаюФайлНастройкиИзФайлаИСохраняюВПеременную");
	ВсеШаги.Добавить("ЯУказываюПараметрыРасширенияДляРасширения__Параметрдлятаблицы_____Параметрдлятаблицы___");

	Возврат ВсеШаги;
КонецФункции

// Реализация шагов

// Процедура выполняется перед запуском каждого сценария
Процедура ПередЗапускомСценария(Знач Узел) Экспорт
	
КонецПроцедуры

// Процедура выполняется после завершения каждого сценария
Процедура ПослеЗапускаСценария(Знач Узел) Экспорт
	
КонецПроцедуры


//Я указываю параметры расширения для расширения <Адаптация>, <tests/fixtures/cfe/Адаптация.cfe>, <Истина>
Процедура ЯУказываюПараметрыРасширенияДляРасширения__Параметрдлятаблицы_____Параметрдлятаблицы___(Знач ИмяРасширения, Знач ПутьКФайлуРасширения, Знач БезопасныйРежим) Экспорт

	ПутьКФайлу = БДД.ПолучитьИзКонтекста("FILE");

	ЧтениеТекста = Новый ЧтениеТекста();
	ЧтениеТекста.Открыть(ПутьКФайлу, КодировкаТекста.UTF8);
	ТекстФайла = ЧтениеТекста.Прочитать();
	ЧтениеТекста.Закрыть();
	
	ЧтениеТекста = Новый ЧтениеТекста();
	
	ЧтениеТекста.Открыть(ПутьКФайлуРасширения + ".md5", КодировкаТекста.UTF8);
	ХешСумма = ЧтениеТекста.Прочитать();
	ЧтениеТекста.Закрыть();

	ТекстФайла = СтрЗаменить(ТекстФайла, "<Имя>", ИмяРасширения);
	ТекстФайла = СтрЗаменить(ТекстФайла, "<ПутьКФайлуРасширения>", ПутьКФайлуРасширения);
	ТекстФайла = СтрЗаменить(ТекстФайла, "<БезопасныйРежим>", XMLСтрока(БезопасныйРежим));
	ТекстФайла = СтрЗаменить(ТекстФайла, "<ХешСумма>", ХешСумма);

	ЗаписьТекста = Новый ЗаписьТекста(ПутьКФайлу);
	ЗаписьТекста.Записать(ТекстФайла);
	ЗаписьТекста.Закрыть();
	
КонецПроцедуры

//Я создаю файл настройки из файла <tests/fixtures/one-base-extentions.yaml> и сохраняю в переменную "FILE"
Процедура ЯСоздаюФайлНастройкиИзФайлаИСохраняюВПеременную(
	Знач ПутьКФайлу, Знач ИмяПеременной) Экспорт
	
	КаталогФайловойБазы = БДД.ПолучитьИзКонтекста("ТестоваяБаза");
	КаталогФайловойБазы1 = БДД.ПолучитьИзКонтекста("ТестоваяБаза1");

	ЧтениеТекста = Новый ЧтениеТекста();
	ЧтениеТекста.Открыть(ПутьКФайлу, КодировкаТекста.UTF8);
	ТекстYaml = ЧтениеТекста.Прочитать();
	ЧтениеТекста.Закрыть();

	ТекстYaml = СтрЗаменить(ТекстYaml, "<ТестоваяБаза>", КаталогФайловойБазы);
	ТекстYaml = СтрЗаменить(ТекстYaml, "<ТестоваяБаза1>", КаталогФайловойБазы1);

	ЧтениеТекста = Новый ЧтениеТекста();
	
	ВременныйФайл = ВременныеФайлы.СоздатьФайл(".yaml");

	ЗаписьТекста = Новый ЗаписьТекста(ВременныйФайл);
	ЗаписьТекста.Записать(ТекстYaml);
	ЗаписьТекста.Закрыть();

	БДД.СохранитьВКонтекст(ИмяПеременной, ВременныйФайл);

КонецПроцедуры


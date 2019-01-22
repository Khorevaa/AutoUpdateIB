﻿#Использовать tempfiles

// Реализация шагов BDD-фич/сценариев c помощью фреймворка https://github.com/artbear/1bdd

Перем БДД; //контекст фреймворка 1bdd

// Метод выдает список шагов, реализованных в данном файле-шагов
Функция ПолучитьСписокШагов(КонтекстФреймворкаBDD) Экспорт
	БДД = КонтекстФреймворкаBDD;

	ВсеШаги = Новый Массив;

	ВсеШаги.Добавить("ЯСоздаюФайлНастройкиИзФайлаИСохраняюВПеременную");

	Возврат ВсеШаги;
КонецФункции

// Реализация шагов

// Процедура выполняется перед запуском каждого сценария
Процедура ПередЗапускомСценария(Знач Узел) Экспорт
	
КонецПроцедуры

// Процедура выполняется после завершения каждого сценария
Процедура ПослеЗапускаСценария(Знач Узел) Экспорт

КонецПроцедуры

//Я создаю файл настройки из файла <tests/fixtures/test-update.yaml> и сохранию в переменную "FILE"
Процедура ЯСоздаюФайлНастройкиИзФайлаИСохраняюВПеременную(Знач ПутьКФайлу, Знач ИмяПеременной) Экспорт

	КаталогФайловойБазы = БДД.ПолучитьИзКонтекста("ТестоваяБаза");
	КаталогФайловойБазы1 = БДД.ПолучитьИзКонтекста("ТестоваяБаза1");

	ЧтениеТекста = Новый ЧтениеТекста();
	ЧтениеТекста.Открыть(ПутьКФайлу, КодировкаТекста.UTF8);
	ТекстYaml = ЧтениеТекста.Прочитать();
	ЧтениеТекста.Закрыть();

	ТекстYaml = СтрЗаменить(ТекстYaml, "<ТестоваяБаза>", КаталогФайловойБазы);
	ТекстYaml = СтрЗаменить(ТекстYaml, "<ТестоваяБаза1>", КаталогФайловойБазы1);

	ВременныйФайл = ВременныеФайлы.СоздатьФайл(".yaml");

	ЗаписьТекста = Новый ЗаписьТекста(ВременныйФайл);
	ЗаписьТекста.Записать(ТекстYaml);
	ЗаписьТекста.Закрыть();

	БДД.СохранитьВКонтекст(ИмяПеременной, ВременныйФайл);
	
КонецПроцедуры

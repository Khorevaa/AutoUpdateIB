//    Copyright 2018 khorevaa
// 
//    Licensed under the Apache License, Version 2.0 (the "License");
//    you may not use this file except in compliance with the License.
//    You may obtain a copy of the License at
// 
//        http://www.apache.org/licenses/LICENSE-2.0
// 
//    Unless required by applicable law or agreed to in writing, software
//    distributed under the License is distributed on an "AS IS" BASIS,
//    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//    See the License for the specific language governing permissions and
//    limitations under the License.
#Использовать fs
#Использовать logos
#Использовать advanced-logos
#Использовать "./../../core/Классы/internal/cache"

Перем КаталогЛокальныхДанныхПриложения;
Перем КаталогКешаФайлов;

Перем ФайлОбщегоЛога;
Перем ФайлЖурнала;

Функция ИмяПриложения() Экспорт
	Возврат "AutoUpdateIB";
КонецФункции

Функция ИмяЛога() Экспорт
	Возврат "oscript.app.AutoUpdateIB";
КонецФункции

Функция Версия() Экспорт
	Возврат "0.0.1";
КонецФункции

Функция КаталогДанныхПриложения() Экспорт
	Возврат ПолучитьЛокальныйКаталогДанныхПриложения();
КонецФункции

Процедура УстановитьРежимОтладкиПриНеобходимости(Знач РежимОтладки) Экспорт
	
	Если Не РежимОтладки Тогда
		Возврат;
	КонецЕсли;

	МассивЛогов = ИменаЛоговПриложения();

	Для каждого ИмяЛога Из МассивЛогов Цикл
		ЛогПриложения = Логирование.ПолучитьЛог(ИмяЛога);
		ЛогПриложения.УстановитьУровень(УровниЛога.Отладка);
	КонецЦикла;


КонецПроцедуры

Процедура УстановитьФорматВыводаЛогов(Знач ОбъектФорматирования) Экспорт
	
	Если Не ЗначениеЗаполнено(ОбъектФорматирования) Тогда
		Возврат;
	КонецЕсли;

КонецПроцедуры

Процедура УстановитьФайлЛогаПриложения(Знач ПутьКФайлу) Экспорт
	
	Если Не ЗначениеЗаполнено(ПутьКФайлу) Тогда
		Возврат;
	КонецЕсли;

	ФайлОбщегоЛога = ПутьКФайлу;
	
	ФайлЖурнала = Новый ВыводЛогаВФайл;
	ФайлЖурнала.УстановитьФорматВывода("json");
	ФайлЖурнала.ОткрытьФайл(ФайлОбщегоЛога);

	ДобавитьВыводЛогаВФайл(Лог());

КонецПроцедуры

Процедура ДобавитьВыводЛогаВФайл(Знач ОбъектЛогирования) Экспорт
	
	Если Не ЗначениеЗаполнено(ФайлОбщегоЛога) Тогда
		Возврат;
	КонецЕсли;

	ОбъектЛогирования.ДобавитьСпособВывода(ФайлЖурнала);
	
КонецПроцедуры

Процедура УстановитьВыводВЦветнубКонсоль()
	
	ВыводВКонсоль = Новый ЦветнойВыводЛогаКонсоль();
	
	МассивЛогов = ИменаЛоговПриложения();
	
	Для каждого ИмяЛога Из МассивЛогов Цикл
		ЛогПриложения = Логирование.ПолучитьЛог(ИмяЛога);
		ЛогПриложения.ДобавитьСпособВывода(ВыводВКонсоль);
	КонецЦикла;
	
КонецПроцедуры

Процедура ЗакрытьФайлЛогаПриложения() Экспорт
	
	Если Не ЗначениеЗаполнено(ФайлЖурнала) Тогда
		Возврат;
	КонецЕсли;

	ФайлЖурнала.Закрыть();

КонецПроцедуры

Функция ИменаЛоговПриложения()
	
	МассивЛогов = Новый Массив();
	МассивЛогов.Добавить(ИмяЛога());
	// МассивЛогов.Добавить("oscript.app.AutoUpdateIB.config");
	// МассивЛогов.Добавить("oscript.app.AutoUpdateIB.session");
	МассивЛогов.Добавить("oscript.app.AutoUpdateIB.agent");
	// МассивЛогов.Добавить("oscript.app.AutoUpdateIB.CfeUpdater");
	// МассивЛогов.Добавить("oscript.app.AutoUpdateIB.ConfigUpdater");
	// МассивЛогов.Добавить("oscript.app.AutoUpdateIB.UpdateManager");
	// МассивЛогов.Добавить("oscript.app.AutoUpdateIB.RunEnterprise");
	// МассивЛогов.Добавить("oscript.app.AutoUpdateIB.backup");
	// МассивЛогов.Добавить("oscript.lib.v8runner");
	// МассивЛогов.Добавить("oscript.lib.AutoUpdateIB.rmq");
	
	// МассивЛогов.Добавить("oscript.app.lib.cache");
	// МассивЛогов.Добавить("oscript.app.lib.get-file");
	Возврат МассивЛогов;

КонецФункции

Процедура ОчиститьЛокальныйКеш(Знач ОчиститьКеш) Экспорт
	
	Если Не ОчиститьКеш Тогда
		Возврат;
	КонецЕсли;
	
	ЛокальныйКеш = Новый ЛокальныйКешФайлов(КаталогКешаДанныхПриложения());
	ЛокальныйКеш.ОчиститьФайлыКеша();

КонецПроцедуры

Функция Лог() Экспорт
	Возврат Логирование.ПолучитьЛог(ИмяЛога());
КонецФункции

Функция КаталогКешаДанныхПриложения() Экспорт

	Если ЗначениеЗаполнено(КаталогКешаФайлов) Тогда
		Возврат КаталогКешаФайлов;
	КонецЕсли;

	КаталогКешаФайлов = ФС.ПолныйПуть(ОбъединитьПути(ПолучитьЛокальныйКаталогДанныхПриложения(), "cache"));
	
	ФС.ОбеспечитьКаталог(КаталогКешаФайлов);

	Возврат КаталогКешаФайлов;

КонецФункции

Функция ПутьКФайлуКонфигурацииПриложения() Экспорт
	Возврат ОбъединитьПути(ПолучитьЛокальныйКаталогДанныхПриложения(), ".config.json");
КонецФункции

Функция ПолучитьЛокальныйКаталогДанныхПриложения()

	Если ЗначениеЗаполнено(КаталогЛокальныхДанныхПриложения) Тогда
		Возврат КаталогЛокальныхДанныхПриложения;
	КонецЕсли;

	СистемнаяИнформация = Новый СистемнаяИнформация;
	ОбщийКаталогДанныхПриложений = СистемнаяИнформация.ПолучитьПутьПапки(СпециальнаяПапка.ЛокальныйКаталогДанныхПриложений);

	КаталогЛокальныхДанныхПриложения = ОбъединитьПути(ОбщийКаталогДанныхПриложений, ИмяПриложения());

	ФС.ОбеспечитьКаталог(КаталогЛокальныхДанныхПриложения);

	Возврат КаталогЛокальныхДанныхПриложения;

КонецФункции

УстановитьВыводВЦветнубКонсоль();

РежимОтладки = Ложь;
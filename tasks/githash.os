


#Использовать logos
#Использовать gitrunner
#Использовать tempfiles

Перем КаталогПроекта;
Перем Лог;

Процедура ПолезнаяРабота()

	Перем Параметры, Коммит;

	ГитРепозиторий = Новый ГитРепозиторий;

	Параметры = Новый Массив;
	Параметры.Добавить("log");
	Параметры.Добавить("-1");
	Параметры.Добавить("--format='%h'");

	ГитРепозиторий.ВыполнитьКоманду(Параметры);

	Коммит = ГитРепозиторий.ПолучитьВыводКоманды();
	Если Лев(Коммит, 1) = "'" Тогда

		// windows выводит 'sha', ubuntu просто sha, ибо bash отсеивает кавычки
		Коммит = Сред(Коммит, 2, СтрДлина(Коммит) - 2);

	КонецЕсли;
	КаталогПроекта = ОбъединитьПути(ТекущийСценарий().Каталог, "..", "src","cmd");
	ПутьКФайлу = ОбъединитьПути(КаталогПроекта, "Модули", "ПараметрыПриложения.os");

	ТекстФайла = ПрочитатьФайл(ПутьКФайлу);

	ТекстФайла = СтрЗаменить(ТекстФайла, "@hash", "@"+Коммит);
	
КонецПроцедуры

Функция ПрочитатьФайл(Знач ПутьКФайлу) Экспорт
	
	ЧтениеТекста = Новый ЧтениеТекста(ПутьКФайлу, "UTF-8");
	ТекстФайла = ЧтениеТекста.Прочитать();
	ЧтениеТекста.Закрыть();

	Возврат ТекстФайла;

КонецФункции

Процедура ЗаписатьФайл(Знач ПутьКФайлу, Знач ТекстФайла) Экспорт

	ЗаписьТекста = Новый ЗаписьТекста(ПутьКФайлу);
	ЗаписьТекста.Записать(ТекстФайла);
	ЗаписьТекста.Закрыть();

КонецПроцедуры

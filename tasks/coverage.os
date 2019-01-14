#Использовать coverage
#Использовать 1commands
#Использовать fs

ФС.ОбеспечитьПустойКаталог("coverage");
ПутьКСтат = "coverage/stat.json";

Команда = Новый Команда;
Команда.УстановитьКоманду("oscript");
Команда.ДобавитьПараметр("-encoding=utf-8");
Команда.ДобавитьПараметр(СтрШаблон("-codestat=%1", ПутьКСтат));    
Команда.ДобавитьПараметр("tasks/test.os");
Команда.ПоказыватьВыводНемедленно(Истина);

КодВозврата = Команда.Исполнить();

Файл_Стат = Новый Файл(ПутьКСтат);

ИмяПакета = "AutoUpdateIB";

ПроцессорГенерации = Новый ГенераторОтчетаПокрытия();

ПроцессорГенерации.ОтносительныеПути()
				.ФайлСтатистики(Файл_Стат.ПолноеИмя)
				.GenericCoverage()
				.Cobertura()
				.Clover(ИмяПакета)
				.Сформировать();

ЗавершитьРаботу(КодВозврата);
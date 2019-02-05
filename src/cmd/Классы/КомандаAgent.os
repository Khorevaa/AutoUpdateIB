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

Процедура ОписаниеКоманды(Команда) Экспорт
	
	Команда.Опция("u user", "", "пользователь сервера RabbitMQ")
				.ВОкружении("RMQ_USER");

	Команда.Опция("p pwd password", "", "пароль пользователя сервера RabbitMQ")
				.ВОкружении("RMQ_PWD RMQ_PASSWORD");

	Команда.Опция("q queue", "", "имя очереди получения сообщений на сервере RabbitMQ")
				.ВОкружении("RMQ_QUEUE");
	
	Команда.Опция("P port", 15672, "порт сервера RabbitMQ")
				.ВОкружении("RMQ_PORT");

	Команда.Опция("e exchange-name", "", "имя точки ответа сервера RabbitMQ")
				.ВОкружении("RMQ_EXCHANGE_NAME");

	Команда.Опция("R routing-key", "", "ключ маршрутизации сервера RabbitMQ")
				.ВОкружении("RMQ_ROUTING_KEY");
	
	Команда.Опция("H virtual-host rmq-vhost", "%2F", "виртуальный хост на сервере RabbitMQ")
				.ВОкружении("RMQ_VHOST");

	Команда.Опция("t queue-timer", 60, "таймер опроса сервера очереди");

	Команда.Опция("workers-dir", "", "рабочий каталог процессов")
				.ПоУмолчанию(ПараметрыПриложения.КаталогДанныхПриложения()); 

	Команда.Опция("M workers-max-count", 0, "количество рабочих процессов агента (0 - автоматический расчет)");
	Команда.Опция("T worker-timeuot", 0, "таймаут перезапуска рабочего процесса агента при зависании");

	Команда.Аргумент("SERVER", "", "Адрес сервера RabbitMQ")
				.ВОкружении("RMQ_SERVER");

КонецПроцедуры

Процедура ВыполнитьКоманду(Знач Команда) Экспорт
	
	ПользовательRMQ = Команда.ЗначениеОпции("user");
	ПарольRMQ = Команда.ЗначениеОпции("password");

	ИмяОчереди = Команда.ЗначениеОпции("queue");
	ТочкаОбмена = Команда.ЗначениеОпции("exchange-name");
	ВиртуальныйХост = Команда.ЗначениеОпции("virtual-host");
	ПортСервера =  Команда.ЗначениеОпции("port");
	АдресСервера = Команда.ЗначениеАргумента("SERVER");

	ТаймерОпросаОчереди = Команда.ЗначениеОпции("queue-timer");
	РабочийКаталогПроцессов = Команда.ЗначениеОпции("workers-dir");
	МаксимальноеКоличествоРабочихПроцессов = Команда.ЗначениеОпции("workers-max-count");
	ТаймаутРабочегоПроцесса = Команда.ЗначениеОпции("worker-timeuot");

	Отладка =  Команда.ЗначениеОпции("-v");

	НастройкаRMQ = Новый Структура;
	НастройкаRMQ.Вставить("Сервер", АдресСервера);
	НастройкаRMQ.Вставить("Порт", ПортСервера);
	НастройкаRMQ.Вставить("Пользователь", ПользовательRMQ);
	НастройкаRMQ.Вставить("Пароль", ПарольRMQ);
	НастройкаRMQ.Вставить("ВиртуальныйХост", ВиртуальныйХост);
	НастройкаRMQ.Вставить("ИмяОчереди", ИмяОчереди);
	НастройкаRMQ.Вставить("ТочкаОбмена", ТочкаОбмена);

	МенеджерРабочийПроцессов = Новый АгентОбновления();
	МенеджерРабочийПроцессов.УстановитьОткладку(Отладка);
	МенеджерРабочийПроцессов.НастроитьRMQ(НастройкаRMQ);

	МенеджерРабочийПроцессов.УстановитьКоличествоАгентов(МаксимальноеКоличествоРабочихПроцессов);	
	МенеджерРабочийПроцессов.УстановитьТаймерОпроса(ТаймерОпросаОчереди);
	МенеджерРабочийПроцессов.УстановитьТаймаутПроцессаАгента(ТаймаутРабочегоПроцесса);
	МенеджерРабочийПроцессов.УстановитьРабочийКаталогПроцессов(РабочийКаталогПроцессов);

	ПараметрыЗапускаАгента = Новый Структура;
	ПараметрыЗапускаАгента.Вставить("НастройкаRMQ", НастройкаRMQ);
	ПараметрыЗапускаАгента.Вставить("РабочийКаталогПроцессов", РабочийКаталогПроцессов);

	МенеджерРабочийПроцессов.УстановитьПараметрыАгента(ПараметрыЗапускаАгента);
	МенеджерРабочийПроцессов.НастроитьЛогирование();

	МенеджерРабочийПроцессов.Запустить();

КонецПроцедуры
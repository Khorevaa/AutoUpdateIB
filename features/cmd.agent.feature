# language: ru

Функционал: Выполнение обновления информационной базы 
    Как специалист 1С
    Я хочу иметь инструмент пакетного обновление информационных баз
    Чтобы автоматизировать обновление при получении нового релиза конфигурации

Структура сценария: <Сценарий>
    Дано Я очищаю параметры команды "AutoUpdateIB" в контексте
    И Я устанавливаю путь выполнения команды "AutoUpdateIB" к текущей библиотеке
    И Я создаю временный каталог и сохраняю его в переменной "ТестоваяБаза"
    И Я создаю тестовую базу в каталоге "ТестоваяБаза"
    И Я включаю отладку лога с именем "oscript.lib.AutoUpdateIB.rmq"
    И Я создаю КлиентRMQ
    И Я устанавливаю настройки КлиентRMQ сервер "localhost" порт "15672" пользователь "guest" пароль "guest" виртуальный хост "%2f" очередь "all.update" 
    И Я создаю файл настройки из файла <ПутьКФайлу> с значениями <ПутьКФайлуОбновления>, <ЗагрузитьКонфигурацию>, <ПредупрежденияКакОшибки>, <ДинамическоеОбновление> и сохраняю в переменную "FILE"
    И Я отправляю настройку обновления в очередь из файла "FILE"

    Допустим Я добавляю параметр "-v --log-file ./log.log agent" для команды "AutoUpdateIB"
    И Я добавляю параметр "-u guest" для команды "AutoUpdateIB"
    И Я добавляю параметр "-p guest" для команды "AutoUpdateIB"
    И Я добавляю параметр "-q all.update" для команды "AutoUpdateIB"
    И Я добавляю параметр "--report-queue report.update" для команды "AutoUpdateIB"
    И Я добавляю параметр "-H %2f" для команды "AutoUpdateIB"
    И Я добавляю параметр "-P 15672" для команды "AutoUpdateIB"
    И Я добавляю параметр "-t 0" для команды "AutoUpdateIB"    
    И Я добавляю параметр "localhost" для команды "AutoUpdateIB"
    Когда Я выполняю команду "AutoUpdateIB"
    Тогда Вывод команды "AutoUpdateIB" содержит "Успешно выполнено задание рабочего процесса"
    И Вывод команды "AutoUpdateIB" не содержит "Внешнее исключение"
    И Код возврата команды "AutoUpdateIB" равен 0

    
Примеры:
    | Сценарий | ПутьКФайлу | ПутьКФайлуОбновления | ЗагрузитьКонфигурацию | ПредупрежденияКакОшибки | ДинамическоеОбновление | Результат |
    | Простое обновление | tests/fixtures/catalog.yaml | tests/fixtures/distr/1.1/1Cv8.cf | Ложь | Ложь| Ложь | Загрузка обновления в конфигуратор информационной базы |
    | Обновление (cfu) | tests/fixtures/catalog-cfu.yaml | tests/fixtures/distr/1.1/1Cv8.cf | Ложь | Ложь| Ложь | Загрузка обновления в конфигуратор информационной базы |
    | Загрузка из cf | tests/fixtures/catalog.yaml | tests/fixtures/distr/1.1/1Cv8.cf | Истина | Ложь| Ложь | Загрузка обновления в конфигуратор информационной базы |
    | Динамическое обновление | tests/fixtures/catalog.yaml | tests/fixtures/distr/1.1/1Cv8.cf | Ложь | Ложь| Истина | Динамическое применение конфигурации информационной базы |
    | Использование бинарных данных перед обновлением | tests/fixtures/bindata-run-before.yaml | tests/fixtures/distr/1.1/1Cv8.cf | Ложь | Ложь| Ложь | 1231 | 
    | Использование бинарных данных после обновления | tests/fixtures/bindata-run-after.yaml | tests/fixtures/distr/1.1/1Cv8.cf | Ложь | Ложь| Ложь | 1231 | 

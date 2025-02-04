﻿
#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ОбъектНаСервере = РеквизитФормыВЗначение("Объект");
	
	Элементы.ТипСУБД.СписокВыбора.ЗагрузитьЗначения(Объект.СписокДоступныхСУБД.ВыгрузитьЗначения());
	
	Если НЕ Параметры.Свойство("ТипСУБД", Объект.ТипСУБД) Тогда
		Объект.ТипСУБД = ОбъектНаСервере.ТипСУБДПоУмолчанию();
	КонецЕсли;	
	Если НЕ Параметры.Свойство("ЗапросыСКлиента", Объект.ЗапросыСКлиента) Тогда
		Объект.ЗапросыСКлиента = Ложь;
	КонецЕсли;
	
	Если НЕ Параметры.Свойство("Сервер", Объект.Сервер) Тогда
		Объект.Сервер = Неопределено;
	КонецЕсли;
	Если НЕ Параметры.Свойство("ИмяБазыДанных", Объект.ИмяБазыДанных) Тогда
		Объект.ИмяБазыДанных = Неопределено;
	КонецЕсли;
	Если НЕ Параметры.Свойство("ИмяПользователя", Объект.ИмяПользователя) Тогда
		Объект.ИмяПользователя = Неопределено;
	КонецЕсли;
	Если НЕ Параметры.Свойство("Пароль", Объект.Пароль) Тогда
		Объект.Пароль = Неопределено;
	КонецЕсли;
	
	Если НЕ Параметры.Свойство("АутентификацияNTLM", Объект.АутентификацияNTLM) Тогда
		Объект.АутентификацияNTLM = Ложь;
	КонецЕсли;
	Если НЕ Параметры.Свойство("СохранятьПароль", Объект.СохранятьПароль) Тогда
		Объект.СохранятьПароль = Ложь;
	КонецЕсли;
	Если НЕ Параметры.Свойство("ТаймаутПодключенияСекунд", Объект.ТаймаутПодключенияСекунд) Тогда
		Объект.ТаймаутПодключенияСекунд = 180;
	КонецЕсли;
	
	УстановитьВидимостьДоступность();
	
КонецПроцедуры

&НаКлиенте
Процедура ПриЗакрытии()
	
	Если ВыборСделан Тогда
		РезультатВыбора = Новый Структура;
		РезультатВыбора.Вставить("ТипСУБД", Объект.ТипСУБД);
		РезультатВыбора.Вставить("ЗапросыСКлиента", Объект.ЗапросыСКлиента);
		РезультатВыбора.Вставить("Сервер", Объект.Сервер);
		РезультатВыбора.Вставить("ИмяБазыДанных", Объект.ИмяБазыДанных);
		РезультатВыбора.Вставить("ИмяПользователя", Объект.ИмяПользователя);
		РезультатВыбора.Вставить("Пароль", Объект.Пароль);
		РезультатВыбора.Вставить("АутентификацияNTLM", Объект.АутентификацияNTLM);
		РезультатВыбора.Вставить("ТаймаутПодключенияСекунд", Объект.ТаймаутПодключенияСекунд);
		РезультатВыбора.Вставить("СохранятьПароль", Объект.СохранятьПароль);
		ОповеститьОВыборе(РезультатВыбора);
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовФормы

&НаКлиенте
Процедура ТипСУБДПриИзменении(Элемент)
	
	УстановитьВидимостьДоступность();
	
КонецПроцедуры

&НаКлиенте
Процедура АутентификацияNTLMПриИзменении(Элемент)
	
	УстановитьВидимостьДоступность();
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ОК(Команда)
	
	ВыборСделан = Истина;
	Закрыть();
	
КонецПроцедуры

&НаКлиенте
Процедура ПроверитьПодключение(Команда)
	
	Состояние("Выполняется проверка подключения...");
	
	ПодключениеУспешноУстановлено = Ложь;
	
	Если Объект.ЗапросыСКлиента Тогда
		
		ПодключениеУспешноУстановлено = ПроверитьПодключениеКБазеДанных(ЭтаФорма);
		
	Иначе	
		
		ПодключениеУспешноУстановлено = ПроверитьПодключениеНаСервере();
		
	КонецЕсли;
	
	Если ПодключениеУспешноУстановлено Тогда
		
		ПоказатьПредупреждение(, "Подключение успешно установлено!");
		
	Иначе
		
		ПоказатьПредупреждение(, "Подключение НЕ установлено! Проверьте настройки.");
		
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура УстановитьВидимостьДоступность()
	
	ФайловаяБаза = (Объект.ТипСУБД = Элементы.ТипСУБД.СписокВыбора.Получить(0).Значение);
	
	Элементы.ЗапросыСКлиента.Доступность = НЕ ФайловаяБаза;
	Элементы.Сервер.Доступность = НЕ ФайловаяБаза;
	Элементы.ИмяБазыДанных.Доступность = НЕ ФайловаяБаза;
	Элементы.ИмяПользователя.Доступность = НЕ ФайловаяБаза И НЕ Объект.АутентификацияNTLM;
	Элементы.Пароль.Доступность = НЕ ФайловаяБаза И НЕ Объект.АутентификацияNTLM;
	Элементы.АутентификацияNTLM.Доступность = НЕ ФайловаяБаза;
	Элементы.ТаймаутПодключенияСекунд.Доступность = НЕ ФайловаяБаза;
	Элементы.СохранятьПароль.Доступность = НЕ ФайловаяБаза И НЕ Объект.АутентификацияNTLM;
	Элементы.ФормаПроверитьПодключение.Доступность = НЕ ФайловаяБаза;
	
КонецПроцедуры

&НаСервере
Функция ПроверитьПодключениеНаСервере()
	
	Возврат ПроверитьПодключениеКБазеДанных(ЭтаФорма);	
	
КонецФункции

&НаКлиентеНаСервереБезКонтекста
Функция ПроверитьПодключениеКБазеДанных(Форма)
	
	СоединениеБД = СоздатьСоединениеСБазой(
		Форма.Объект.ТипСУБД, 
		Форма.Объект.Сервер, 
		Форма.Объект.ИмяБазыДанных, 
		Форма.Объект.ИмяПользователя, 
		Форма.Объект.Пароль, 
		Форма.Объект.АутентификацияNTLM);
		
	Если СоединениеБД = Неопределено Тогда
		Возврат Ложь;
	Иначе
		Возврат Истина;
	КонецЕсли;
	
КонецФункции

&НаКлиентеНаСервереБезКонтекста
Функция СоздатьСоединениеСБазой(ТипСУБД, ИмяСервера, ИмяБД, Пользователь, Пароль, АутентификацияNTLM = Ложь)
	
	Соединение = Новый COMОбъект("ADODB.Connection");
	
	Если ТипСУБД = "SQLServer" Тогда
		
		Если АутентификацияNTLM Тогда
			СтрокаСоединения = "Provider=SQLOLEDB.1;Integrated Security=SSPI;Persist Security Info=False;Initial Catalog=" + ИмяБД + ";Data Source=" + ИмяСервера;
		Иначе	
			СтрокаСоединения = "Provider=SQLOLEDB.1;Password=" + Пароль + ";Persist Security Info=True;User ID=" + Пользователь + ";Initial Catalog=" + ИмяБД + ";Data Source=" + ИмяСервера;
		КонецЕсли;
		
	ИначеЕсли ТипСУБД = "PostgreSQL" Тогда
		
		СтрокаСоединения = "Driver={PostgreSQL Unicode};Pwd=" + Пароль + ";Uid=" + Пользователь + ";Database=" + ИмяБД + ";Server=" + ИмяСервера;
		
	КонецЕсли;
	
	Попытка
	    Соединение.Open(СтрокаСоединения);
		Возврат Соединение;
	Исключение
		СообщитьПользователю(Строка(ТипСУБД) + ": Ошибка установки соединения: " + Символы.ПС + ОписаниеОшибки());
		Возврат Неопределено;
	КонецПопытки;
	
КонецФункции

&НаКлиентеНаСервереБезКонтекста
Процедура СообщитьПользователю(
		Знач ТекстСообщенияПользователю,
		Знач КлючДанных = Неопределено,
		Знач Поле = "",
		Знач ПутьКДанным = "",
		Отказ = Ложь) Экспорт
	
	Сообщение = Новый СообщениеПользователю;
	Сообщение.Текст = ТекстСообщенияПользователю;
	Сообщение.Поле = Поле;
	
	ЭтоОбъект = Ложь;
	
#Если НЕ (ТонкийКлиент ИЛИ ВебКлиент) Тогда
	Если КлючДанных <> Неопределено
	   И XMLТипЗнч(КлючДанных) <> Неопределено Тогда
		ТипЗначенияСтрокой = XMLТипЗнч(КлючДанных).ИмяТипа;
		ЭтоОбъект = Найти(ТипЗначенияСтрокой, "Object.") > 0;
	КонецЕсли;
#КонецЕсли
	
	Если ЭтоОбъект Тогда
		Сообщение.УстановитьДанные(КлючДанных);
	Иначе
		Сообщение.КлючДанных = КлючДанных;
	КонецЕсли;
	
	Если НЕ ПустаяСтрока(ПутьКДанным) Тогда
		Сообщение.ПутьКДанным = ПутьКДанным;
	КонецЕсли;
		
	Сообщение.Сообщить();
	
	Отказ = Истина;
	
КонецПроцедуры

#КонецОбласти

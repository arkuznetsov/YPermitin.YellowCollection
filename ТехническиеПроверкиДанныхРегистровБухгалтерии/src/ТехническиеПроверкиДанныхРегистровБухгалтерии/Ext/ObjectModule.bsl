﻿
#Область ОписаниеПеременных

Перем КэшДанныхБухгалтерскихСчетов;
Перем КэшИнформацииОСтруктуреРегистра;
Перем КэшМассивСсылочныхПолейРегистра;
Перем КэшОписаниеТипаВсеСсылки;
Перем КэшПроверяемыхТиповНаНаличиеСсылок;
Перем КэшПроверяемыхСсылокНаСуществование;
Перем ИмяРегистраБухгалтерии;

#КонецОбласти

#Область ПрограммныйИнтерфейс

Функция СведенияОВнешнейОбработке() Экспорт 
	
	РегистрационныеДанные = Новый Структура;
	РегистрационныеДанные.Вставить("Наименование", "Технические проверки данных регистров бухгалтерии");
	РегистрационныеДанные.Вставить("БезопасныйРежим", Ложь);
	РегистрационныеДанные.Вставить("Версия", "1.0.0.0");
	РегистрационныеДанные.Вставить("ВерсияБСП", "");
	РегистрационныеДанные.Вставить("Вид", "ДополнительныйОтчет");
	РегистрационныеДанные.Вставить("Информация", 
		"Отчет ""Технические проверки данных регистров бухгалтерии"" предназначен 
		|для проверки корректности данных в записях регистров бухгалтерии.
		|Позволяет заблаговременно найти потенциальные проблемы, которые могут привести
		|к некорректной работе итогов и расхождению данных в отчетах.");
		
	МассивНазначенийОбработки = НазначениеОбработки();
	РегистрационныеДанные.Вставить("Назначение", МассивНазначенийОбработки);
	
	ТаблицаКомандОбработки = ТаблицаКомандОбработки();
	РегистрационныеДанные.Вставить("Команды", ТаблицаКомандОбработки);
		
	Возврат РегистрационныеДанные;
	
КонецФункции

Функция НазначениеОбработки() Экспорт 
	
	МассивНазначенийОбработки = Новый Массив;
	 
	Возврат МассивНазначенийОбработки;
	
КонецФункции

Функция ТаблицаКомандОбработки() Экспорт 
	
	тзКоманд = Новый ТаблицаЗначений;
	тзКоманд.Колонки.Добавить("Идентификатор"           , Новый ОписаниеТипов("Строка"));
	тзКоманд.Колонки.Добавить("Представление"           , Новый ОписаниеТипов("Строка"));
	тзКоманд.Колонки.Добавить("ПоказыватьОповещение"    , Новый ОписаниеТипов("Булево"));
	тзКоманд.Колонки.Добавить("Модификатор"             , Новый ОписаниеТипов("Строка"));
	тзКоманд.Колонки.Добавить("Использование"           , Новый ОписаниеТипов("Строка"));
	тзКоманд.Колонки.Добавить("Скрыть"                  , Новый ОписаниеТипов("Булево"));
	
	ДобавитьКоманду(тзКоманд, 
		"ТехническиеПроверкиДанныхРегистровБухгалтерии", 
		"Технические проверки данных регистров бухгалтерии", 
		Ложь, 
		"ОткрытиеФормы", 
		"",
		Ложь);
	
	Возврат тзКоманд;
	
КонецФункции

#КонецОбласти

#Область ОбработчикиСобытий

Процедура ОбработкаПроверкиЗаполнения(Отказ, ПроверяемыеРеквизиты)
	
	ВыбранноеИмяРегистра = Неопределено;
	
	Настройки = КомпоновщикНастроек.ПолучитьНастройки();
	ПараметрИмяРегистраБухгалтерии = Настройки.ПараметрыДанных.Элементы.Найти("ИмяРегистраБухгалтерии");
	Если НЕ ПараметрИмяРегистраБухгалтерии = Неопределено Тогда
		ВыбранноеИмяРегистра = ПараметрИмяРегистраБухгалтерии.Значение;	
	КонецЕсли;
	
	ТекстДоступныеРегистры = "";
	Если Метаданные.РегистрыБухгалтерии.Количество() > 0 Тогда
		Для Каждого ОбъектРегистра Из Метаданные.РегистрыБухгалтерии Цикл
			
			ТекстДоступныеРегистры = ТекстДоступныеРегистры + "
				|- " + ОбъектРегистра.Имя + " (" + ОбъектРегистра.Синоним + ")"
				
		КонецЦикла;
	Иначе
		ТекстДоступныеРегистры = ТекстДоступныеРегистры + "
			|- Доступные регистры бухгалтерии отсутствуют.";
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(ВыбранноеИмяРегистра) Тогда
		
		ТекстСообщения = 
			"Не заполено имя регистра бухгалтерии для анализа.
			|Доступные регистры:
			|" + ТекстДоступныеРегистры;
		
		СообщитьПользователю(ТекстСообщения,,,,Отказ);	
		
	Иначе
		
		НайденныйРегистр = Метаданные.РегистрыБухгалтерии.Найти(ВыбранноеИмяРегистра);
		Если НайденныйРегистр = Неопределено Тогда
			
			ТекстСообщения = 
				"Выбранный регистр бухгалтерии """ + ВыбранноеИмяРегистра + """ не найден.";
			
			СообщитьПользователю(ТекстСообщения,,,,Отказ);	
			
		КонецЕсли;
		
	КонецЕсли;
		
КонецПроцедуры

Процедура ПриКомпоновкеРезультата(ДокументРезультат, ДанныеРасшифровки, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	Настройки = КомпоновщикНастроек.ПолучитьНастройки();
	ДанныеРасшифровки = Новый ДанныеРасшифровкиКомпоновкиДанных; 
	КомпоновщикМакета = Новый КомпоновщикМакетаКомпоновкиДанных;  
	
	ПараметрИмяРегистраБухгалтерии = Настройки.ПараметрыДанных.Элементы.Найти("ИмяРегистраБухгалтерии");
	Если НЕ ПараметрИмяРегистраБухгалтерии = Неопределено Тогда
		ИмяРегистраБухгалтерии = ПараметрИмяРегистраБухгалтерии.Значение;
	КонецЕсли;
	ИнициализацияКэша();
		
	СхемаКомпоновкиДанных = ПолучитьМакет("ОсновнаяСхемаКомпоновкиДанных");	
	ИсходныйЗапрос = СхемаКомпоновкиДанных.НаборыДанных.ДанныеРегистраБухгалтерии.Запрос;
	ИзмененныйЗапрос = СтрЗаменить(ИсходныйЗапрос, 
		"РегистрБухгалтерии.Хозрасчетный.ДвиженияССубконто", 
		"РегистрБухгалтерии." + ИмяРегистраБухгалтерии	 + ".ДвиженияССубконто");
	СхемаКомпоновкиДанных.НаборыДанных.ДанныеРегистраБухгалтерии.Запрос = ИзмененныйЗапрос;
	
	МакетКомпоновки = КомпоновщикМакета.Выполнить(СхемаКомпоновкиДанных, Настройки, ДанныеРасшифровки);
	
	ТаблицаРезультатовПроверки = ТаблицаРезультатаПроверкиЗаписейРегистраБухгалтерии(Настройки, МакетКомпоновки);
	
	НаборВнешнихИсточниковДанных = Новый Структура;
	НаборВнешнихИсточниковДанных.Вставить("ТаблицаРезультатовПроверки", ТаблицаРезультатовПроверки);
	
	ПроцессорКомпоновки = Новый ПроцессорКомпоновкиДанных;
	ПроцессорКомпоновки.Инициализировать(МакетКомпоновки, НаборВнешнихИсточниковДанных , ДанныеРасшифровки);
	
	ДокументРезультат.Очистить();
			
	ПроцессорВывода = Новый ПроцессорВыводаРезультатаКомпоновкиДанныхВТабличныйДокумент;
	ПроцессорВывода.УстановитьДокумент(ДокументРезультат);	
	ПроцессорВывода.Вывести(ПроцессорКомпоновки);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Процедура ДобавитьКоманду(ТаблицаКоманд, Идентификатор, Представление, ПоказыватьОповещение, Использование, Модификатор, Скрыть)
	
	строкаКоманды = ТаблицаКоманд.Добавить();
	строкаКоманды.Идентификатор = Идентификатор;
	строкаКоманды.Представление = Представление;
	строкаКоманды.ПоказыватьОповещение = ПоказыватьОповещение;
	строкаКоманды.Использование = Использование;
	строкаКоманды.Модификатор = Модификатор;
	строкаКоманды.Скрыть = Скрыть;
	
КонецПроцедуры

Функция ТаблицаРезультатаПроверкиЗаписейРегистраБухгалтерии(НастройкиОтчета, МакетКомпоновкиДанныхДляПроверки)
	
	КоллекцияПараметров = НастройкиОтчета.ПараметрыДанных.Элементы;
	ПараметрПроверятьНаБитыеСсылки = КоллекцияПараметров.Найти("ПроверятьНаБитыеСсылки");
	Если НЕ ПараметрПроверятьНаБитыеСсылки = Неопределено Тогда
		ПроверятьНаБитыеСсылки = ПараметрПроверятьНаБитыеСсылки.Значение;	
	Иначе
		ПроверятьНаБитыеСсылки = Ложь;
	КонецЕсли;
	ПараметрПроверитьКорректностьВидовСубконто = КоллекцияПараметров.Найти("ПроверитьКорректностьВидовСубконто");
	Если НЕ ПараметрПроверитьКорректностьВидовСубконто = Неопределено Тогда
		ПроверитьКорректностьВидовСубконто = ПараметрПроверитьКорректностьВидовСубконто.Значение;	
	Иначе
		ПроверитьКорректностьВидовСубконто = Ложь;
	КонецЕсли;
	ПараметрПроверитьКорректностьЗначенийСубконто = КоллекцияПараметров.Найти("ПроверитьКорректностьЗначенийСубконто");
	Если НЕ ПараметрПроверитьКорректностьЗначенийСубконто = Неопределено Тогда
		ПроверитьКорректностьЗначенийСубконто = ПараметрПроверитьКорректностьЗначенийСубконто.Значение;	
	Иначе
		ПроверитьКорректностьЗначенийСубконто = Ложь;
	КонецЕсли;
	ПараметрПроверитьКорректностьЗначенийНебалансовыхИзмерений = КоллекцияПараметров.Найти("ПроверитьКорректностьЗначенийНебалансовыхИзмерений");
	Если НЕ ПараметрПроверитьКорректностьЗначенийНебалансовыхИзмерений = Неопределено Тогда
		ПроверитьКорректностьЗначенийНебалансовыхИзмерений = ПараметрПроверитьКорректностьЗначенийНебалансовыхИзмерений.Значение;	
	Иначе
		ПроверитьКорректностьЗначенийНебалансовыхИзмерений = Ложь;
	КонецЕсли;
	
	ТаблицаРезультатовПроверки = ПустаяТаблицаРезультатовПроверки();
	
	ИсходныйЗапрос = МакетКомпоновкиДанныхДляПроверки.НаборыДанных.ДанныеРегистраБухгалтерии.Запрос;
	
	СхемаИсходногоЗапроса = Новый СхемаЗапроса;
	СхемаИсходногоЗапроса.УстановитьТекстЗапроса(ИсходныйЗапрос);
	ОсновнойПакетИсходногоЗапроса = СхемаИсходногоЗапроса.ПакетЗапросов.Получить(0);
	
	ОсновнойПакетИсходногоЗапроса.Порядок.Добавить("Период");
	ОсновнойПакетИсходногоЗапроса.Порядок.Добавить("Регистратор");
	ОсновнойПакетИсходногоЗапроса.Порядок.Добавить("НомерСтроки");
	
	КолонкиИсходногоЗапроса = ОсновнойПакетИсходногоЗапроса.Колонки;
	ОсновнойПакетИсходногоЗапроса.Колонки.Очистить();
	
	ПоляИсходногоЗапроса = ОсновнойПакетИсходногоЗапроса.Операторы[0].ВыбираемыеПоля;
	
	ДоступныеПоляТаблицы = ОсновнойПакетИсходногоЗапроса.ДоступныеТаблицы
		.Найти("РегистрыБухгалтерии").Состав
		.Найти("РегистрБухгалтерии." + ИмяРегистраБухгалтерии + ".ДвиженияССубконто").Поля;
	Для Каждого Поле Из ДоступныеПоляТаблицы Цикл
		ПоляИсходногоЗапроса.Добавить(Поле.Имя);		
	КонецЦикла;
	
	Для Каждого СсылочноеПоле Из КэшМассивСсылочныхПолейРегистра Цикл
		ВыражениеПредставление = "ПРЕДСТАВЛЕНИЕССЫЛКИ(" + СсылочноеПоле + ")";
		ПоляИсходногоЗапроса.Добавить(ВыражениеПредставление)
	КонецЦикла;
	
	ОсновнойПакетИсходногоЗапроса.Порядок.Добавить("Период");
	ОсновнойПакетИсходногоЗапроса.Порядок.Добавить("Регистратор");
	ОсновнойПакетИсходногоЗапроса.Порядок.Добавить("НомерСтроки");
	
	ИсходныйЗапрос = СхемаИсходногоЗапроса.ПолучитьТекстЗапроса();
	
	ЗапросИсходныеДанные = Новый Запрос;
	ЗапросИсходныеДанные.Текст = ИсходныйЗапрос;
	
	Для Каждого ИсходныйПараметр Из МакетКомпоновкиДанныхДляПроверки.ЗначенияПараметров Цикл
		ЗапросИсходныеДанные.УстановитьПараметр(ИсходныйПараметр.Имя, ИсходныйПараметр.Значение);
	КонецЦикла;
		
	ПоследниеДанныеЗаписи = Новый Структура;
	ПоследниеДанныеЗаписи.Вставить("Период");
	ПоследниеДанныеЗаписи.Вставить("Регистратор");
	ПоследниеДанныеЗаписи.Вставить("НомерСтроки");
	
	КоличествоШаговПроверки = 0;
	КоличествоПроверенныхЗаписей = 0;
	
	ЕстьДанныеДляАнализа = Истина;
	Пока ЕстьДанныеДляАнализа Цикл
		
		Если НЕ ПоследниеДанныеЗаписи.Период = Неопределено
			И НЕ ПоследниеДанныеЗаписи.Регистратор = Неопределено
			И НЕ ПоследниеДанныеЗаписи.НомерСтроки = Неопределено Тогда
			
			ЗапросИсходныеДанные.Текст = СтрЗаменить(ИсходныйЗапрос,
				"&УсловиеФильтраПорцииДанных",
				"Период = &Период_ФильтрПорции
				|		И Регистратор = &Регистратор_ФильтрПорции
				|		И НомерСтроки > &НомерСтроки_ФильтрПорции
				|	ИЛИ Период = &Период_ФильтрПорции
				|		И Регистратор > &Регистратор_ФильтрПорции
				|	ИЛИ Период > &Период_ФильтрПорции");
			
			СхемаЗапросаДляУсловий = Новый СхемаЗапроса;
			СхемаЗапросаДляУсловий.УстановитьТекстЗапроса(ЗапросИсходныеДанные.Текст );
			ОсновнойПакетЗапросаДляУсловий = СхемаЗапросаДляУсловий.ПакетЗапросов.Получить(0);
			КоллкцияФильтровЗапросаДляУсловий = ОсновнойПакетЗапросаДляУсловий.Операторы[0].Отбор;
			
			ЗапросИсходныеДанные.Текст = СхемаЗапросаДляУсловий.ПолучитьТекстЗапроса();
			
			ЗапросИсходныеДанные.УстановитьПараметр("Период_ФильтрПорции", ПоследниеДанныеЗаписи.Период);
			ЗапросИсходныеДанные.УстановитьПараметр("Регистратор_ФильтрПорции", ПоследниеДанныеЗаписи.Регистратор);
			ЗапросИсходныеДанные.УстановитьПараметр("НомерСтроки_ФильтрПорции", ПоследниеДанныеЗаписи.НомерСтроки);
			
		КонецЕсли;
		
		РезультатЗапросаИсходныеДанные = ЗапросИсходныеДанные.Выполнить();
		Если РезультатЗапросаИсходныеДанные.Пустой() Тогда
			ЕстьДанныеДляАнализа = Ложь;
			Прервать;
		КонецЕсли;
		
		ЕстьПроверенныеЗаписиНаЭтомЭтапе = Ложь;		
		ВыборкаИсходныеДанные = РезультатЗапросаИсходныеДанные.Выбрать();		
		Пока ВыборкаИсходныеДанные.Следующий() Цикл
						
			ПоследниеДанныеЗаписи.Период = ВыборкаИсходныеДанные.Период;
			ПоследниеДанныеЗаписи.Регистратор = ВыборкаИсходныеДанные.Регистратор;
			ПоследниеДанныеЗаписи.НомерСтроки = ВыборкаИсходныеДанные.НомерСтроки;
						
			// 1. Проверка на наличие "битых" ссылок в полях
			Если ПроверятьНаБитыеСсылки Тогда
				ПроверитьКорректностьСсылочныхЗначений(ТаблицаРезультатовПроверки, ВыборкаИсходныеДанные);
			КонецЕсли;
			
			// 2. Проверка небалансовых измерений
			//	* Должно ли там быть какое-то значение кроме NULL
			//	* Может ли там быть значение НЕОПРЕДЕЛЕНО или должно быть пустое значение (пустая ссылка и др.)
			Если ПроверитьКорректностьЗначенийНебалансовыхИзмерений Тогда
				ПроверитьКорректностьЗначенийНебалансовыхИзмерений(ТаблицаРезультатовПроверки, ВыборкаИсходныеДанные, ВидДвиженияБухгалтерии.Дебет);
				ПроверитьКорректностьЗначенийНебалансовыхИзмерений(ТаблицаРезультатовПроверки, ВыборкаИсходныеДанные, ВидДвиженияБухгалтерии.Кредит);
			КонецЕсли;
		
			// 3. Проверка видов субконто
			//	* Соответствуют ли указанные виды субконто текущим настройка счетов
			//	* Заполнены ли виды субконто там, где это должны быть указаны
			Если ПроверитьКорректностьВидовСубконто Тогда
				ПроверитьКорректностьВидовСубконто(ТаблицаРезультатовПроверки, ВыборкаИсходныеДанные, ВидДвиженияБухгалтерии.Дебет);
				ПроверитьКорректностьВидовСубконто(ТаблицаРезультатовПроверки, ВыборкаИсходныеДанные, ВидДвиженияБухгалтерии.Кредит);
			КонецЕсли;
			
			// 4. Проверка значений субконто
			//	* Соответствует ли тип значения доступным типам вида субконто
			//	* Наличие NULL в значениях, для которых указан вид субконто
			//	* Установлено ли пустое значение там для составных типов субконто вместо НЕОПРЕДЕЛЕНО
			Если ПроверитьКорректностьЗначенийСубконто Тогда
				ПроверитьКорректностьЗначенийСубконто(ТаблицаРезультатовПроверки, ВыборкаИсходныеДанные, ВидДвиженияБухгалтерии.Дебет);
				ПроверитьКорректностьЗначенийСубконто(ТаблицаРезультатовПроверки, ВыборкаИсходныеДанные, ВидДвиженияБухгалтерии.Кредит);
			КонецЕсли;
			
			ЕстьПроверенныеЗаписиНаЭтомЭтапе = Истина;
			КоличествоПроверенныхЗаписей = КоличествоПроверенныхЗаписей + 1;
			
		КонецЦикла;
		
		Если НЕ ЕстьПроверенныеЗаписиНаЭтомЭтапе Тогда
			ЕстьДанныеДляАнализа = Ложь;
			Продолжить;
		КонецЕсли;
		
		КоличествоШаговПроверки = КоличествоШаговПроверки + 1;
		
	КонецЦикла;
	
	Возврат ТаблицаРезультатовПроверки;
	
КонецФункции

Процедура ПроверитьКорректностьСсылочныхЗначений(ТаблицаРезультатовПроверки, ДанныеЗаписи)
	
	Для Каждого ИмяСсылочногоПоля Из КэшМассивСсылочныхПолейРегистра Цикл
		
		ЗначениеСсылочногоПоля = ДанныеЗаписи[ИмяСсылочногоПоля];
		Если ЗначениеЗаполнено(ЗначениеСсылочногоПоля)
			И ЭтоСсылка(ТипЗнч(ЗначениеСсылочногоПоля)) Тогда
			
			Если НЕ СсылкаСуществует(ЗначениеСсылочногоПоля) Тогда
				
				ТекстРезультатаПроверки = """Битая"" ссылка в поле """ + ИмяСсылочногоПоля + """";				
				ДобавитьЗаписьОРезультатеПроверки(
					ТаблицаРезультатовПроверки,
					ДанныеЗаписи.Период,
					ДанныеЗаписи.Регистратор, 
					ДанныеЗаписи.НомерСтроки,
					ТекстРезультатаПроверки);
				
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

Процедура ПроверитьКорректностьЗначенийНебалансовыхИзмерений(ТаблицаРезультатовПроверки, ДанныеЗаписи, ВидДвижения)
	
	Если ВидДвижения = ВидДвиженияБухгалтерии.Дебет Тогда
		ВидДвиженияСтрокой = "Дт";
	ИначеЕсли ВидДвижения = ВидДвиженияБухгалтерии.Кредит Тогда
		ВидДвиженияСтрокой = "Кт";
	Иначе
		Возврат;
	КонецЕсли;
	
	ИмяПоляСчета = "Счет" + ВидДвиженияСтрокой;
	ИнформацияСчета = КэшДанныхБухгалтерскихСчетов.Получить(ДанныеЗаписи[ИмяПоляСчета]);	
	Если ИнформацияСчета = Неопределено Тогда
		Возврат;	
	КонецЕсли;
	
	Для Каждого Измерение Из КэшИнформацииОСтруктуреРегистра.Измерения Цикл
		
		Если НЕ Измерение.Балансовый Тогда
			
			ПризнакУчетаИзмерения = Измерение.ПризнакУчета;
			Если НЕ ПризнакУчетаИзмерения = Неопределено Тогда
				ИмяПризнакаУчета = Измерение.ПризнакУчета.Имя;
				ПризнакУчетаВключен = ИнформацияСчета[ИмяПризнакаУчета];
			Иначе
				ИмяПризнакаУчета = "<Не установлен>";
				ПризнакУчетаВключен = Истина;
			КонецЕсли;
			
			ИмяИзмерения = Измерение.Имя + ВидДвиженияСтрокой;			
			ЗначениеИзмерение = ДанныеЗаписи[ИмяИзмерения];
			ТипЗначенияИзмерение = ТипЗнч(ЗначениеИзмерение);
			
			Если ПризнакУчетаВключен Тогда
				
				Если ТипЗначенияИзмерение = Тип("Null") Тогда
					
					ТекстРезультатаПроверки = "Значение измерения """ + ИмяИзмерения + """ имеет значение NULL."
						+ " (счет """ + ДанныеЗаписи[ИмяПоляСчета] + """ для признака учета """ 
						+ ИмяПризнакаУчета + """ не может содержать значение """ 
						+ ТипЗначенияИзмерение + """)";				
					
					ДобавитьЗаписьОРезультатеПроверки(
						ТаблицаРезультатовПроверки,
						ДанныеЗаписи.Период,
						ДанныеЗаписи.Регистратор, 
						ДанныеЗаписи.НомерСтроки,
						ТекстРезультатаПроверки);						
					
				КонецЕсли;
				
			Иначе
				
				Если НЕ ТипЗначенияИзмерение = Тип("Null") Тогда
					
					ТекстРезультатаПроверки = "Значение измерения """ + ИмяИзмерения + """ имеет значение, отличное от NULL."
						+ " (счет """ + ДанныеЗаписи[ИмяПоляСчета] + """ для признака учета """ 
						+ ИмяПризнакаУчета + """ не может содержать значение """ 
						+ ТипЗначенияИзмерение + """)";				
					
					ДобавитьЗаписьОРезультатеПроверки(
						ТаблицаРезультатовПроверки,
						ДанныеЗаписи.Период,
						ДанныеЗаписи.Регистратор, 
						ДанныеЗаписи.НомерСтроки,
						ТекстРезультатаПроверки); 						
					
				КонецЕсли;
				
			КонецЕсли;
						
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

Процедура ПроверитьКорректностьВидовСубконто(ТаблицаРезультатовПроверки, ДанныеЗаписи, ВидДвижения)
	
	Если ВидДвижения = ВидДвиженияБухгалтерии.Дебет Тогда
		ВидДвиженияСтрокой = "Дт";
	ИначеЕсли ВидДвижения = ВидДвиженияБухгалтерии.Кредит Тогда
		ВидДвиженияСтрокой = "Кт";
	Иначе
		Возврат;
	КонецЕсли;
	
	КоличествоСубконто = КэшИнформацииОСтруктуреРегистра.ПланСчетов.МаксКоличествоСубконто;
	
	ИнформацияСчета = КэшДанныхБухгалтерскихСчетов.Получить(ДанныеЗаписи["Счет" + ВидДвиженияСтрокой]);
	Если НЕ ИнформацияСчета = Неопределено Тогда
		
		Для НомерСубконто = 1 По КоличествоСубконто Цикл
			
			ИмяПоляВидаСубконто = "ВидСубконто" + ВидДвиженияСтрокой + XMLСтрока(НомерСубконто);
			ВидСубконтоЗаписи = ДанныеЗаписи[ИмяПоляВидаСубконто];
			Если ИнформацияСчета.ВидыСубконто.Количество() >= НомерСубконто Тогда
				ВидСубконтоСчет = ИнформацияСчета.ВидыСубконто[НомерСубконто - 1].ВидСубконто;
			Иначе
				ВидСубконтоСчет = Null;	
			КонецЕсли;
			
			Если НЕ ВидСубконтоЗаписи = ВидСубконтоСчет Тогда
				
				ВидСубконтоЗаписиПредставление = "";
				Если ВидСубконтоЗаписи = Null Тогда
					ВидСубконтоЗаписиПредставление = "NULL";
				ИначеЕсли ВидСубконтоЗаписи = Неопределено Тогда
					ВидСубконтоЗаписиПредставление = "НЕОПРЕДЕЛЕНО";
				Иначе
					ВидСубконтоЗаписиПредставление = Строка(ВидСубконтоЗаписи);
				КонецЕсли;
				
				ТекстРезультатаПроверки = "Вид субконто """ + ИмяПоляВидаСубконто + """ не соответствует настройке счета."
					+ " (в счете """ + ВидСубконтоСчет + """, в записи """ + ВидСубконтоЗаписиПредставление + """)";				
				ДобавитьЗаписьОРезультатеПроверки(
					ТаблицаРезультатовПроверки,
					ДанныеЗаписи.Период, 
					ДанныеЗаписи.Регистратор, 
					ДанныеЗаписи.НомерСтроки,
					ТекстРезультатаПроверки);
	
			КонецЕсли;
			
		КонецЦикла;
		
	КонецЕсли;
	
КонецПроцедуры

Процедура ПроверитьКорректностьЗначенийСубконто(ТаблицаРезультатовПроверки, ДанныеЗаписи, ВидДвижения)
	
	КоличествоСубконто = КэшИнформацииОСтруктуреРегистра.ПланСчетов.МаксКоличествоСубконто;
	
	Если ВидДвижения = ВидДвиженияБухгалтерии.Дебет Тогда
		ВидДвиженияСтрокой = "Дт";
	ИначеЕсли ВидДвижения = ВидДвиженияБухгалтерии.Кредит Тогда
		ВидДвиженияСтрокой = "Кт";
	Иначе
		Возврат;
	КонецЕсли;
	
	ИнформацияСчета = КэшДанныхБухгалтерскихСчетов.Получить(ДанныеЗаписи["Счет" + ВидДвиженияСтрокой]);
	Если НЕ ИнформацияСчета = Неопределено Тогда
		
		Для НомерСубконто = 1 По КоличествоСубконто Цикл
			
			КоличествоСубконтоСчета = ИнформацияСчета.ВидыСубконто.Количество();
			ИмяПоляВидСубконто = "ВидСубконто" + ВидДвиженияСтрокой + XMLСтрока(НомерСубконто);
			ИмяПоляСубконто = "Субконто" + ВидДвиженияСтрокой + XMLСтрока(НомерСубконто);
			ВидСубконтоЗаписи = ДанныеЗаписи[ИмяПоляВидСубконто];
			ЗначениеСубконтоЗаписи = ДанныеЗаписи[ИмяПоляСубконто];
			Если КоличествоСубконтоСчета >= НомерСубконто Тогда
				ВидСубконтоСчет = ИнформацияСчета.ВидыСубконто[НомерСубконто - 1].ВидСубконто;
			Иначе
				ВидСубконтоСчет = Null;	
			КонецЕсли;
			
			Если ВидСубконтоЗаписи = Null
				И ЗначениеСубконтоЗаписи = Null
				И ВидСубконтоСчет = Null Тогда
				Продолжить;
			КонецЕсли;
			
			Если НЕ ЗначениеЗаполнено(ВидСубконтоСчет) Тогда
				
				ТекстРезультатаПроверки = "Значение субконто поля """ + ИмяПоляСубконто + """ не должно быть заполнено."
					+ " (счет """ + ДанныеЗаписи["Счет" + ВидДвиженияСтрокой] + """ не имеет субконто №" + XMLСтрока(НомерСубконто) + ")";				
				ДобавитьЗаписьОРезультатеПроверки(
					ТаблицаРезультатовПроверки,
					ДанныеЗаписи.Период,
					ДанныеЗаписи.Регистратор, 
					ДанныеЗаписи.НомерСтроки,
					ТекстРезультатаПроверки); 
					
			Иначе
				
				ТипЗначениеСубконтоЗаписи = ТипЗнч(ЗначениеСубконтоЗаписи);
				ДопустимыйТипВидаСубконто = ВидСубконтоСчет.ТипЗначения.СодержитТип(ТипЗначениеСубконтоЗаписи);
				ВсеДопустимыеТипыСубконто = ВидСубконтоСчет.ТипЗначения.Типы();
				ЭтоСоставнойТип = (ВсеДопустимыеТипыСубконто.Количество() > 1);
				КорректноеПустоеЗначение = ВидСубконтоСчет.ТипЗначения.ПривестиЗначение(Неопределено);
				ТипКорректногоПустогоЗначения = ТипЗнч(КорректноеПустоеЗначение);
				
				Если ЗначениеЗаполнено(ЗначениеСубконтоЗаписи) Тогда
				
					Если НЕ ДопустимыйТипВидаСубконто Тогда
						
						ТекстРезультатаПроверки = "Значение субконто поля """ + ИмяПоляСубконто + """ имеет недопустимый тип значения."
							+ " (счет """ + ДанныеЗаписи["Счет" + ВидДвиженияСтрокой] + " для вида субконто """ 
							+ ВидСубконтоСчет + """ не содержит допустимый тип """ 
							+ ТипЗначениеСубконтоЗаписи + """)";				
						ДобавитьЗаписьОРезультатеПроверки(
							ТаблицаРезультатовПроверки,
							ДанныеЗаписи.Период,
							ДанныеЗаписи.Регистратор, 
							ДанныеЗаписи.НомерСтроки,
							ТекстРезультатаПроверки); 
							
					КонецЕсли;
						
				ИначеЕсли НЕ ЗначениеЗаполнено(ЗначениеСубконтоЗаписи) Тогда
					
					Если ТипЗначениеСубконтоЗаписи = Тип("Null") Тогда
						
						ТекстРезультатаПроверки = "Значение субконто поля """ + ИмяПоляСубконто + """ имеет значение NULL."
							+ " (счет """ + ДанныеЗаписи["Счет" + ВидДвиженияСтрокой] + " для вида субконто """ 
							+ ВидСубконтоСчет + """ не может содержать значение """ 
							+ ТипЗначениеСубконтоЗаписи + """)";				
							
						ДобавитьЗаписьОРезультатеПроверки(
							ТаблицаРезультатовПроверки,
							ДанныеЗаписи.Период,
							ДанныеЗаписи.Регистратор, 
							ДанныеЗаписи.НомерСтроки,
							ТекстРезультатаПроверки);
						
					ИначеЕсли НЕ ЗначениеСубконтоЗаписи = КорректноеПустоеЗначение Тогда
						
						ТекстРезультатаПроверки = "Значение субконто поля """ + ИмяПоляСубконто + """ имеет пустое значение с типом """ 
							+ ТипЗначениеСубконтоЗаписи + """."
							+ " (счет """ + ДанныеЗаписи["Счет" + ВидДвиженияСтрокой] + " для вида субконто """ 
							+ ВидСубконтоСчет + """ при заполненном значении должен содержать пустое значение с типом """ 
							+ ТипКорректногоПустогоЗначения + """)";				
							
						ДобавитьЗаписьОРезультатеПроверки(
							ТаблицаРезультатовПроверки,
							ДанныеЗаписи.Регистратор, 
							ДанныеЗаписи.Период,
							ДанныеЗаписи.НомерСтроки,
							ТекстРезультатаПроверки);
							
					КонецЕсли;
						
				КонецЕсли;				
				
			КонецЕсли;
			
		КонецЦикла;
		
	КонецЕсли;
	
КонецПроцедуры

Функция ПустаяТаблицаРезультатовПроверки()

	ТаблицаРезультатовПроверки = Новый ТаблицаЗначений;
	ТаблицаРезультатовПроверки.Колонки.Добавить("Период");
	ТаблицаРезультатовПроверки.Колонки.Добавить("Регистратор");
	ТаблицаРезультатовПроверки.Колонки.Добавить("НомерСтроки");
	ТаблицаРезультатовПроверки.Колонки.Добавить("РезультатПроверки");

	Возврат ТаблицаРезультатовПроверки;
	
КонецФункции

Процедура ДобавитьЗаписьОРезультатеПроверки(ТаблицаРезультатовПроверки, Период, Регистратор, НомерСтроки, ТекстРезультата)
	
	СтруктураПоискаРезультата = Новый Структура(
		"Период, Регистратор, НомерСтроки", 
		Период, Регистратор, НомерСтроки);
	
	РезультатПоиска = ТаблицаРезультатовПроверки.НайтиСтроки(СтруктураПоискаРезультата);
	Если РезультатПоиска.Количество() = 1 Тогда
		ЗаписьРезультат = РезультатПоиска.Получить(0);
		ЗаписьРезультат.РезультатПроверки = ЗаписьРезультат.РезультатПроверки 
			+ Символы.ПС
			+ ТекстРезультата;
	Иначе
		ЗаписьРезультат = ТаблицаРезультатовПроверки.Добавить();
		ЗаписьРезультат.Период = Период;
		ЗаписьРезультат.Регистратор = Регистратор;
		ЗаписьРезультат.НомерСтроки = НомерСтроки;
		ЗаписьРезультат.РезультатПроверки = ТекстРезультата; 
	КонецЕсли;	
	
КонецПроцедуры

Функция СсылкаСуществует(ПроверяемаяСсылка)
	
	ИнформацияИзКэша = КэшПроверяемыхСсылокНаСуществование.Получить(ПроверяемаяСсылка);
	Если ИнформацияИзКэша = Неопределено Тогда
		
		Если КэшПроверяемыхСсылокНаСуществование.Количество() > 10000 Тогда
			КэшПроверяемыхСсылокНаСуществование.Очистить();
		КонецЕсли;
		
		ТекстЗапроса = "
		|ВЫБРАТЬ ПЕРВЫЕ 1
		|	1
		|ИЗ
		|	[ИмяТаблицы]
		|ГДЕ
		|	Ссылка = &Ссылка
		|";
		
		ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "[ИмяТаблицы]", ПроверяемаяСсылка.Метаданные().ПолноеИмя());
		
		Запрос = Новый Запрос;
		Запрос.Текст = ТекстЗапроса;
		Запрос.УстановитьПараметр("Ссылка", ПроверяемаяСсылка);
		
		УстановитьПривилегированныйРежим(Истина);
	
		ИнформацияИзКэша = НЕ Запрос.Выполнить().Пустой();		
		КэшПроверяемыхСсылокНаСуществование.Вставить(ПроверяемаяСсылка, ИнформацияИзКэша);
		
	КонецЕсли;
	
	Возврат ИнформацияИзКэша;
	
КонецФункции

Функция ЭтоСсылка(ПроверяемыйТип)
	
	ИнформацияИзКэша = КэшПроверяемыхТиповНаНаличиеСсылок.Получить(ПроверяемыйТип);
	Если ИнформацияИзКэша = Неопределено Тогда
		ИнформацияИзКэша = ПроверяемыйТип <> Тип("Неопределено") 
			И ОписаниеТипаВсеСсылки().СодержитТип(ПроверяемыйТип);
		КэшПроверяемыхТиповНаНаличиеСсылок.Вставить(ПроверяемыйТип, ИнформацияИзКэша);
	КонецЕсли;
		
	Возврат ИнформацияИзКэша;	
	
КонецФункции

Функция ОписаниеТипаВсеСсылки() Экспорт
	
	Если КэшОписаниеТипаВсеСсылки = Неопределено Тогда
		КэшОписаниеТипаВсеСсылки = Новый ОписаниеТипов(
			Новый ОписаниеТипов(Новый ОписаниеТипов(
			Новый ОписаниеТипов(Новый ОписаниеТипов(
			Новый ОписаниеТипов(Новый ОписаниеТипов(
			Новый ОписаниеТипов(Новый ОписаниеТипов(
				Справочники.ТипВсеСсылки(),
				Документы.ТипВсеСсылки().Типы()),
				ПланыОбмена.ТипВсеСсылки().Типы()),
				Перечисления.ТипВсеСсылки().Типы()),
				ПланыВидовХарактеристик.ТипВсеСсылки().Типы()),
				ПланыСчетов.ТипВсеСсылки().Типы()),
				ПланыВидовРасчета.ТипВсеСсылки().Типы()),
				БизнесПроцессы.ТипВсеСсылки().Типы()),
				БизнесПроцессы.ТипВсеСсылкиТочекМаршрутаБизнесПроцессов().Типы()),
				Задачи.ТипВсеСсылки().Типы());
	КонецЕсли;
			
	Возврат КэшОписаниеТипаВсеСсылки;		
	
КонецФункции

Процедура СообщитьПользователю(
		Знач ТекстСообщенияПользователю,
		Знач КлючДанных = Неопределено,
		Знач Поле = "",
		Знач ПутьКДанным = "",
		Отказ = Ложь)
	
	Сообщение = Новый СообщениеПользователю;
	Сообщение.Текст = ТекстСообщенияПользователю;
	Сообщение.Поле = Поле;
	Сообщение.КлючДанных = КлючДанных;
	
	Если НЕ ПустаяСтрока(ПутьКДанным) Тогда
		Сообщение.ПутьКДанным = ПутьКДанным;
	КонецЕсли;
		
	Сообщение.Сообщить();
	
	Отказ = Истина;
	
КонецПроцедуры

Процедура ИнициализацияКэша()
	
	#Область Базовый
	
	КэшПроверяемыхТиповНаНаличиеСсылок = Новый Соответствие;
	
	#КонецОбласти
	
	#Область ИнформацияОСтруктуреРегистар
	
	КэшИнформацииОСтруктуреРегистра = Метаданные.РегистрыБухгалтерии[ИмяРегистраБухгалтерии];
	
	КэшМассивСсылочныхПолейРегистра = Новый Массив;
	КэшМассивСсылочныхПолейРегистра.Добавить("Регистратор");
	КэшМассивСсылочныхПолейРегистра.Добавить("СчетДт");
	КэшМассивСсылочныхПолейРегистра.Добавить("СчетКт");
	
	Для Каждого ИзмерениеРегистра Из КэшИнформацииОСтруктуреРегистра.Измерения Цикл
		
		ОписаниеТипаИзмерения = ИзмерениеРегистра.Тип;
		КоллекцияТипов = ОписаниеТипаИзмерения.Типы();
		Для Каждого ДоступныйТип Из КоллекцияТипов Цикл		
			Если ЭтоСсылка(ДоступныйТип) Тогда
				Если ИзмерениеРегистра.Балансовый Тогда
					КэшМассивСсылочныхПолейРегистра.Добавить(ИзмерениеРегистра.Имя);	
				Иначе
					КэшМассивСсылочныхПолейРегистра.Добавить(ИзмерениеРегистра.Имя + "Дт");
					КэшМассивСсылочныхПолейРегистра.Добавить(ИзмерениеРегистра.Имя + "Кт");
				КонецЕсли;
				Прервать;
			КонецЕсли;			
		КонецЦикла;
		
	КонецЦикла;
	
	Для Каждого ИзмерениеРегистра Из КэшИнформацииОСтруктуреРегистра.Реквизиты Цикл
		
		ОписаниеТипаИзмерения = ИзмерениеРегистра.Тип;
		КоллекцияТипов = ОписаниеТипаИзмерения.Типы();
		Для Каждого ДоступныйТип Из КоллекцияТипов Цикл		
			Если ЭтоСсылка(ДоступныйТип) Тогда
				КэшМассивСсылочныхПолейРегистра.Добавить(ИзмерениеРегистра.Имя);	
			КонецЕсли;			
		КонецЦикла;
		
	КонецЦикла;
	
	Для НомерСубконто = 1 По КэшИнформацииОСтруктуреРегистра.ПланСчетов.МаксКоличествоСубконто Цикл
		
		КэшМассивСсылочныхПолейРегистра.Добавить("СубконтоДт" + XMLСтрока(НомерСубконто));	
		КэшМассивСсылочныхПолейРегистра.Добавить("ВидСубконтоДт" + XMLСтрока(НомерСубконто));	
		КэшМассивСсылочныхПолейРегистра.Добавить("СубконтоКт" + XMLСтрока(НомерСубконто));	
		КэшМассивСсылочныхПолейРегистра.Добавить("ВидСубконтоКт" + XMLСтрока(НомерСубконто));	
		
	КонецЦикла;
	
	#КонецОбласти
	
	#Область ИнформацияОСчетах
	
	КэшДанныхБухгалтерскихСчетов = Новый Соответствие;
	
	ИмяПланаСчетов = КэшИнформацииОСтруктуреРегистра.ПланСчетов.Имя;
	ЗапросСчета = Новый Запрос;
	ЗапросСчета.Текст = 
		"ВЫБРАТЬ
		|	Хозрасчетный.Ссылка КАК Ссылка
		|ИЗ
		|	ПланСчетов." + ИмяПланаСчетов + " КАК Хозрасчетный";	
	РезультатЗапросаСчета = ЗапросСчета.Выполнить();	
	ВыборкаСчета = РезультатЗапросаСчета.Выбрать();
	
	Пока ВыборкаСчета.Следующий() Цикл
		
		ОбъектСчета = ВыборкаСчета.Ссылка.ПолучитьОбъект();
		
		КэшДанныхБухгалтерскихСчетов.Вставить(
			ВыборкаСчета.Ссылка,
			ОбъектСчета);
		
	КонецЦикла;
		
	#КонецОбласти
	
	#Область КэшПроверок
	
	КэшПроверяемыхСсылокНаСуществование = Новый Соответствие;
	
	#КонецОбласти
	
КонецПроцедуры

Процедура Инициализация()
	
	СписокРегистров = Новый СписокЗначений;
	
	// Регистр "Хозрасчетный" должен быть первым в списке выбора
	ОбъектРегистрХозрасчетный = Метаданные.РегистрыБухгалтерии.Найти("Хозрасчетный");
	Если НЕ ОбъектРегистрХозрасчетный = Неопределено Тогда
		СписокРегистров.Добавить(ОбъектРегистрХозрасчетный.Имя, ОбъектРегистрХозрасчетный.Синоним);	
	КонецЕсли;
	
	// Добавляем остальные регистры бухгалтерии
	Для Каждого ОбъектРегистра Из Метаданные.РегистрыБухгалтерии Цикл
		Если СписокРегистров.НайтиПоЗначению(ОбъектРегистра.Имя) = Неопределено Тогда
			СписокРегистров.Добавить(ОбъектРегистра.Имя, ОбъектРегистра.Синоним);	
		КонецЕсли;
	КонецЦикла;
	
	Если СписокРегистров.Количество() = 0 Тогда
		ВызватьИсключение 
			"В конфигурации не обнаружено регистров бухгалтерии.
			|Работа отчета не поддерживается.";
	КонецЕсли;
	
	КоллекцияПараметров = КомпоновщикНастроек.Настройки.ПараметрыДанных;
	ПараметрРегистрБухгалтерии = КоллекцияПараметров.ДоступныеПараметры.Элементы.Найти("ИмяРегистраБухгалтерии");
	
	Если НЕ ПараметрРегистрБухгалтерии = Неопределено Тогда
		ПараметрРегистрБухгалтерии.ДоступныеЗначения = СписокРегистров; 
	КонецЕсли;
	
	ЗначениеПараметра = КоллекцияПараметров.НайтиЗначениеПараметра(Новый ПараметрКомпоновкиДанных("ИмяРегистраБухгалтерии"));
	Если НЕ ЗначениеЗаполнено(ЗначениеПараметра.Значение) Тогда
		ЗначениеПараметра.Значение = СписокРегистров.Получить(0).Значение;
		ЗначениеПараметра.Использование = Истина;
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(ИмяРегистраБухгалтерии) Тогда
		ИмяРегистраБухгалтерии = СписокРегистров.Получить(0).Значение;
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область Инициализация

Инициализация();

#КонецОбласти
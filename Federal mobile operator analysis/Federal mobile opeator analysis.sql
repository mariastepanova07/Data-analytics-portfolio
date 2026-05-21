-- 1. Начнем с данных о клиентах и их тарифном плане. 
-- Выгрузим первые 20 строк с информацией о пользователях и проверим, что данные соответствуют описанию.
SELECT *
FROM telecom.users
LIMIT 20;

-- Таблица:
-- user_id	age	churn_date	city	first_name	last_name	reg_date	tariff
-- 1019	63	2018-10-05	Томск	Игнатий	Круглов	2018-05-16	ultra
-- 1020	59	2018-12-18	Чита	Тала	Костина	2018-10-22	smart
-- 1034	66	2018-11-21	Вологда	Святослав	Бондарев	2018-08-26	smart
-- 1050	44	2018-10-03	Тюмень	Рузана	Аничкина	2018-06-16	ultra
-- 1051	37	2018-10-14	Москва	Кристина	Сомова	2018-05-28	smart
-- 1056	73	2018-10-14	Иркутск	Радислав	Артемьев	2018-04-13	smart
-- 1062	24	2018-12-09	Москва	Александр	Коршунов	2018-11-16	smart
-- 1063	45	2018-12-11	Тула	Таира	Климова	2018-04-12	ultra
-- 1064	55	2018-12-26	Якутск	Динара	Алфеева	2018-03-17	smart
-- 1065	53	2018-12-09	Москва	Роза	Игнатова	2018-03-08	smart
-- 1071	20	2018-08-31	Омск	Гектор	Чумаков	2018-01-09	smart
-- 1090	54	2018-12-03	Череповец	Екатерина	Астафьева	2018-10-11	ultra
-- 1128	51	2018-12-23	Волжский	Ксения	Агаева	2018-12-15	ultra
-- 1161	65	2018-11-07	Набережные Челны	Татьяна	Голованова	2018-07-03	smart
-- 1163	21	2018-12-16	Москва	Лев	Вишневский	2018-11-03	smart
-- 1191	64	2018-10-03	Набережные Челны	Александр	Акиндинов	2018-06-30	smart
-- 1201	32	2018-12-03	Москва	Геннадий	Веселов	2018-08-06	ultra
-- 1206	35	2018-12-20	Москва	Елена	Шарапова	2018-11-03	smart
-- 1180	27		Москва	Лев	Мишин	2018-02-02	ultra
-- 1232	60	2018-11-30	Томск	Виктория	Ларина	2018-10-07	smart


-- 2. Проверим, что в данных для каждого пользователя нет пропусков. 
-- В результат запроса должны войти строки, которые содержат хотя бы один пропуск в любом поле таблицы. 
--  Выгрузим первые 10 строк итоговой таблицы.
SELECT *
FROM telecom.users
WHERE
    age IS NULL OR
    churn_date IS NULL OR churn_date = '' OR
    city IS NULL OR city = '' OR
    first_name IS NULL OR first_name = '' OR
    last_name IS NULL OR last_name = '' OR
    reg_date IS NULL OR reg_date = '' OR
    tariff IS NULL OR tariff = ''
LIMIT 10;

-- Таблица:
-- user_id	age	churn_date	city	first_name	last_name	reg_date	tariff
-- 1180	27		Москва	Лев	Мишин	2018-02-02	ultra
-- 1000	52		Краснодар	Рафаил	Верещагин	2018-05-25	ultra
-- 1001	41		Москва	Иван	Ежов	2018-11-01	smart
-- 1002	59		Стерлитамак	Евгений	Абрамович	2018-06-17	smart
-- 1003	23		Москва	Белла	Белякова	2018-08-17	ultra
-- 1004	68		Новокузнецк	Татьяна	Авдеенко	2018-05-14	ultra
-- 1005	67		Набережные Челны	Афанасий	Горлов	2018-01-25	smart
-- 1006	21		Ульяновск	Леонид	Ермолаев	2018-02-26	smart
-- 1007	65		Москва	Юна	Березина	2018-04-19	smart
-- 1008	63		Челябинск	Рустэм	Пономарёв	2018-12-19	smart

-- Обнаружены пропуски в таблице! А именно в столбце churn_date.


-- 3. Поле churn_date хранит дату отказа от услуг, и отсутствие информации говорит о том, что клиент продолжает пользоваться услугами оператора.
-- Считаем долю активных пользователей от общего числа клиентов:
SELECT COUNT(DISTINCT user_id)::real/ (SELECT COUNT(DISTINCT user_id)
                                       FROM  telecom.users) AS active_users_share
FROM telecom.users
WHERE churn_date IS NULL;

-- Таблица:
-- active_users_share
-- 0.924

-- Услугами оператора перестали пользоваться менее 8% клиентов, и в нашем распоряжении будут практически полные данные об активных клиентах


-- 4. При расчётах также будет важно, чтобы один клиент использовал только один тарифный план. 
-- Проверим, что за весь период у каждого активного клиента был только один тарифный план. 
-- Выведем ID клиентов, у которых больше одного тарифного плана и количество тарифных планов у клиентов.
SELECT
    user_id,
    COUNT(DISTINCT tariff) AS tariffs_count
FROM telecom.users
WHERE churn_date IS NULL          
GROUP BY user_id
HAVING COUNT(DISTINCT tariff) > 1;

-- К счастью, клиентов со множеством тарифов нет! Это упростит дальнейшие расчёты.


-- 5. Познакомимся с данными об услугах, которыми пользовались клиенты.
-- Для начала взглянем на данные о длительности звонков. 
-- Проверим, встречаются ли в этих данных пропуски, — выведием все строки таблицы calls, в которых встречаются пропуски в любом из полей, то есть в duration или call_date.
SELECT *
FROM telecom.calls
WHERE duration IS NULL
  OR call_date IS NULL;

-- Отсутствие данных — тоже результат. В этом случае положительный, ведь в данных нет пропусков.


-- 6. Проверим возможные аномалии в данных о длительности разговора — определим минимальное и максимальное значения. 
select min(duration) as min_duration,
max(duration) as max_duration
from telecom.calls

-- Таблица:
-- min_duration	  max_duration
-- 0	            38

-- Максимальная длительность разговора не очень большая — 38 минут.
-- А вот минимальная — ноль. Возможно, это пропущенные входящие звонки.
-- Следует оценить их долю от общего количества звонков.


-- 7. Изучим долю пропущенных звонков.
-- Посчитаем долю звонков длительностью 0 минут от общего количества звонков.
SELECT 
    COUNT(*)::real 
    / (SELECT COUNT(*) FROM telecom.calls) AS missed_calls_share
FROM telecom.calls
WHERE duration = 0;

-- Таблица:
-- missed_calls_share
-- 0.195516

-- Почти каждый пятый звонок длился ноль минут. Возможно, некоторые клиенты вообще не звонят по мобильной сети.


-- 8. Теперь изучим общую длительность разговоров каждого пользователя в день — встречаются ли случаи, когда суммарная длительность превышала 24 часа. 
-- Эта проверка поможет оценить корректность данных. 
-- Для каждого клиента посчитаем длительность всех звонков за день, переведем это значение в часы и выведем топ-10 клиентов с высокими значениями общей длительности разговоров.
SELECT
    user_id,
    call_date,
    SUM(duration) / 60.0 AS total_day_duration
FROM telecom.calls
GROUP BY user_id, call_date
ORDER BY total_day_duration DESC
LIMIT 10;

-- Таблица:
-- user_id	call_date	total_day_duration
-- 1336	2018-12-31	11.8675
-- 1140	2018-12-31	8.97983
-- 1074	2018-12-30	5.00833
-- 1485	2018-12-29	4.182
-- 1074	2018-12-31	4.12033
-- 1445	2018-12-31	3.95017
-- 1258	2018-12-31	3.41933
-- 1485	2018-12-31	2.97483
-- 1467	2018-12-09	2.49317
-- 1216	2018-12-21	2.39683

-- Самый общительный человек найден — 31 декабря клиент-лидер проговорил почти 12 часов.



-- Мы познакомились с данными и проверили их — они в хорошем качестве, и явных ошибок нет. Значит, можно приступать к анализу.
-- Следующие задачи, которые просят решить:
-- 1. выгрузить данные о клиентах с информацией о потребляемых услугах за каждый месяц активности и посчитать их месячные траты с учётом тарифного плана;
-- 2. рассчитать среднее значение трат активных клиентов (которые продолжают пользоваться услугами компании) в разрезе тарифного плана;
-- 3. найти активных клиентов, которые тратят деньги сверх абонентской платы, и посчитать, сколько в среднем они переплачивают.


-- 1. Длительность разговоров клиента в месяц
-- Суммарная длительность разговоров клиента в месяц:
WITH monthly_duration AS (
   SELECT user_id,
         -- Выделяем месяц из даты звонка: 
         DATE_TRUNC('month', call_date::timestamp)::date AS dt_month,
         CEIL(SUM(duration)) AS month_duration
   FROM telecom.calls
   GROUP BY user_id, dt_month
)
SELECT *
FROM monthly_duration
LIMIT 5;

--Таблица:
-- user_id	dt_month	month_duration
-- 1366	2018-11-01	240
-- 1366	2018-09-01	144
-- 1378	2018-05-01	498
-- 1186	2018-03-01	388
-- 1104	2018-10-01	316


--2. Количество интернет-трафика в месяц
-- Суммарная длительность разговоров клиента в месяц:
WITH monthly_duration AS (
    SELECT user_id,
           -- Выделяем месяц из даты звонка: 
           DATE_TRUNC('month', call_date::timestamp)::date AS dt_month,    
           CEIL(SUM(duration)) AS month_duration
    FROM telecom.calls
    GROUP BY user_id, dt_month
),
monthly_internet AS (
    SELECT 
        user_id,
        DATE_TRUNC('month', session_date::timestamp)::date AS dt_month,
        SUM(mb_used) AS month_mb_traffic
    FROM telecom.internet
    GROUP BY user_id, dt_month
)
SELECT *
FROM monthly_internet
LIMIT 5;

--Таблица:
-- user_id	dt_month	month_mb_traffic
-- 1366	2018-11-01	8583.74
-- 1366	2018-09-01	7545
-- 1378	2018-05-01	14269.9
-- 1186	2018-03-01	16783.9
-- 1104	2018-10-01	18642.3


-- 3. Количество сообщений в месяц
-- Суммарная длительность разговоров клиента в месяц:
WITH monthly_duration AS (
    SELECT user_id,
           -- Выделяем месяц из даты звонка: 
           DATE_TRUNC('month', call_date::timestamp)::date AS dt_month,    
           CEIL(SUM(duration)) AS month_duration
    FROM telecom.calls
    GROUP BY user_id, dt_month
),
-- Суммарное количество потраченного интернет-трафика в месяц:
monthly_internet AS (
    SELECT user_id,
           DATE_TRUNC('month', session_date::timestamp)::date AS dt_month,  
           SUM(mb_used) AS month_mb_traffic
    FROM telecom.internet
    GROUP BY user_id, dt_month
),
monthly_sms AS (
    SELECT
        user_id,
        DATE_TRUNC('month', message_date::timestamp)::date AS dt_month,
        COUNT(id) AS month_sms
    FROM telecom.messages
    GROUP BY user_id, dt_month
)
SELECT *
FROM monthly_sms
LIMIT 5;

--Таблица: 
-- user_id	dt_month	month_sms
-- 1012	2018-11-01	25
-- 1366	2018-11-01	42
-- 1366	2018-09-01	39
-- 1378	2018-05-01	14
-- 1471	2018-11-01	92

-- Три обобщённых табличных выражения рассчитали объём потребляемых услуг для каждого клиента — длительность разговоров, интернет-трафик и отправленные сообщения. 
-- Дальше можно соединить все данные в одну таблицу.

-- 4. Соединяем данные о клиентах и их месячную активность
-- Суммарная длительность разговоров клиента в месяц:
WITH monthly_duration AS (
    SELECT user_id,
           -- Выделяем месяц из даты звонка: 
           DATE_TRUNC('month', call_date::timestamp)::date AS dt_month,    
           CEIL(SUM(duration)) AS month_duration
    FROM telecom.calls
    GROUP BY user_id, dt_month
),
-- Суммарное количество потраченного интернет-трафика в месяц:
monthly_internet AS (
    SELECT user_id,
           DATE_TRUNC('month', session_date::timestamp)::date AS dt_month,  
           SUM(mb_used) AS month_mb_traffic
    FROM telecom.internet
    GROUP BY user_id, dt_month
),
-- Суммарное количество сообщений в месяц:
monthly_sms AS (
    SELECT user_id,
           DATE_TRUNC('month', message_date::timestamp)::date AS dt_month,  
           COUNT(message_date) AS month_sms
    FROM telecom.messages
    GROUP BY user_id, dt_month
),
user_activity_months AS (
    SELECT user_id, dt_month FROM monthly_duration
    UNION
    SELECT user_id, dt_month FROM monthly_internet
    UNION
    SELECT user_id, dt_month FROM monthly_sms
)
-- Проверим результат:
SELECT *
FROM user_activity_months
ORDER BY user_id, dt_month
LIMIT 5;

-- Таблица:
-- user_id	dt_month
-- 1000	2018-05-01
-- 1000	2018-06-01
-- 1000	2018-07-01
-- 1000	2018-08-01
-- 1000	2018-09-01

-- В результате для каждого клиента получен месяц активности. 
-- Дальше к этим данным можно добавить посчитанные значения длительности разговоров, интернет-трафика и количества сообщений.


-- 5. Объединяем данные о клиентах в одну таблицу
-- Суммарная длительность разговоров клиента в месяц:
WITH monthly_duration AS (
    SELECT user_id,
           -- Выделяем месяц из даты звонка: 
           DATE_TRUNC('month', call_date::timestamp)::date AS dt_month,    
           CEIL(SUM(duration)) AS month_duration
    FROM telecom.calls
    GROUP BY user_id, dt_month
),
-- Суммарное количество потраченного интернет-трафика в месяц:
monthly_internet AS (
    SELECT user_id,
           DATE_TRUNC('month', session_date::timestamp)::date AS dt_month,  
           SUM(mb_used) AS month_mb_traffic
    FROM telecom.internet
    GROUP BY user_id, dt_month
),
-- Суммарное количество сообщений в месяц:
monthly_sms AS (
    SELECT user_id,
           DATE_TRUNC('month', message_date::timestamp)::date AS dt_month,  
           COUNT(message_date) AS month_sms
    FROM telecom.messages
    GROUP BY user_id, dt_month
),
-- Формирование уникальной пары значений user_id и dt_month:
user_activity_months AS (
    -- Первое множество значений user_id и dt_month с учётом разговорной активности клиента:
    SELECT user_id, dt_month
    FROM monthly_duration
    UNION
    -- Второе множество значений user_id и dt_month с учётом интернет-активности клиента:
    SELECT user_id, dt_month
    FROM monthly_internet   
    UNION
    -- Третье множество значений user_id и dt_month с учётом активности клиента по сообщениям:
    SELECT user_id, dt_month
    FROM monthly_sms
),
-- Соединение посчитанных значений активности клиента в одну таблицу:
users_stat AS (
    SELECT u.user_id,
           u.dt_month,
           month_duration,
           month_mb_traffic,
           month_sms
    -- В качестве основной таблицы используем данные из CTE user_activity_months:
    FROM user_activity_months AS u
    -- Последовательно присоединяем данные по звонкам, интернет-трафику и сообщениям.
    -- При объединении данных используем пары значений user_id и dt_month:
    LEFT JOIN monthly_duration AS md ON u.user_id = md.user_id AND u.dt_month= md.dt_month
    LEFT JOIN monthly_internet AS mi ON u.user_id = mi.user_id AND u.dt_month= mi.dt_month
    LEFT JOIN monthly_sms AS mm ON u.user_id = mm.user_id AND u.dt_month= mm.dt_month
)
SELECT *
FROM users_stat
ORDER BY user_id, dt_month
LIMIT 10;

-- Таблица: 
-- user_id	dt_month	month_duration	month_mb_traffic	month_sms
-- 1000	2018-05-01	151	2253.49	22
-- 1000	2018-06-01	159	23233.8	62
-- 1000	2018-07-01	319	14003.6	75
-- 1000	2018-08-01	390	14055.9	81
-- 1000	2018-09-01	441	14568.9	57
-- 1000	2018-10-01	329	14702.5	73
-- 1000	2018-11-01	320	14756.5	58
-- 1000	2018-12-01	313	9817.61	70
-- 1001	2018-11-01	409	18429.3	nan
-- 1001	2018-12-01	392	14036.7	nan


-- 6. Траты клиентов вне тарифного лимита
-- Суммарная длительность разговоров клиента в месяц:
WITH monthly_duration AS (
    SELECT user_id,
           -- Выделяем месяц из даты звонка: 
           DATE_TRUNC('month', call_date::timestamp)::date AS dt_month,    
           CEIL(SUM(duration)) AS month_duration
    FROM telecom.calls
    GROUP BY user_id, dt_month
),
-- Суммарное количество потраченного интернет-трафика в месяц:
monthly_internet AS (
    SELECT user_id,
           DATE_TRUNC('month', session_date::timestamp)::date AS dt_month,  
           SUM(mb_used) AS month_mb_traffic
    FROM telecom.internet
    GROUP BY user_id, dt_month
),
-- Суммарное количество сообщений в месяц:
monthly_sms AS (
    SELECT user_id,
           DATE_TRUNC('month', message_date::timestamp)::date AS dt_month,  
           COUNT(message_date) AS month_sms
    FROM telecom.messages
    GROUP BY user_id, dt_month
),
-- Формирование уникальной пары значений user_id и dt_month:
user_activity_months AS (
    SELECT user_id, dt_month
    FROM monthly_duration
    UNION
    SELECT user_id, dt_month
    FROM monthly_internet   
    UNION
    SELECT user_id, dt_month
    FROM monthly_sms
),
-- Соединение посчитанных значений активности клиента в одну таблицу:
users_stat AS (
    SELECT 
        u.user_id,
        u.dt_month,
        month_duration,
        month_mb_traffic,
        month_sms
    FROM user_activity_months AS u
    LEFT JOIN monthly_duration AS md 
        ON u.user_id = md.user_id AND u.dt_month = md.dt_month
    LEFT JOIN monthly_internet AS mi 
        ON u.user_id = mi.user_id AND u.dt_month = mi.dt_month
    LEFT JOIN monthly_sms AS mm 
        ON u.user_id = mm.user_id AND u.dt_month = mm.dt_month
),
-- Траты клиентов вне тарифного лимита:
user_over_limits AS (
    SELECT
        us.user_id,
        us.dt_month,
        u.tariff,
        us.month_duration,
        us.month_mb_traffic,
        us.month_sms,
        -- перерасход минут
        CASE 
            WHEN us.month_duration > t.minutes_included 
                THEN us.month_duration - t.minutes_included
            ELSE 0
        END AS duration_over,
        -- перерасход интернет-трафика в ГБ
        CASE 
            WHEN us.month_mb_traffic > t.mb_per_month_included 
                THEN (us.month_mb_traffic - t.mb_per_month_included) / 1024.0
            ELSE 0
        END AS gb_traffic_over,
        -- перерасход SMS
        CASE 
            WHEN us.month_sms > t.messages_included 
                THEN us.month_sms - t.messages_included
            ELSE 0
        END AS sms_over
    FROM users_stat AS us
    JOIN telecom.users   AS u ON us.user_id = u.user_id
    JOIN telecom.tariffs AS t ON u.tariff = t.tariff_name
)
SELECT *
FROM user_over_limits
ORDER BY user_id, dt_month
LIMIT 10;

-- Таблица: 
-- user_id	dt_month	tariff	month_duration	month_mb_traffic	month_sms	duration_over	gb_traffic_over	sms_over
-- 1000	2018-05-01	ultra	151	2253.49	22	0	0	0
-- 1000	2018-06-01	ultra	159	23233.8	62	0	0	0
-- 1000	2018-07-01	ultra	319	14003.6	75	0	0	0
-- 1000	2018-08-01	ultra	390	14055.9	81	0	0	0
-- 1000	2018-09-01	ultra	441	14568.9	57	0	0	0
-- 1000	2018-10-01	ultra	329	14702.5	73	0	0	0
-- 1000	2018-11-01	ultra	320	14756.5	58	0	0	0
-- 1000	2018-12-01	ultra	313	9817.61	70	0	0	0
-- 1001	2018-11-01	smart	409	18429.3	nan	0	2.9974	0
-- 1001	2018-12-01	smart	392	14036.7	nan	0	0	0


-- Делаем расчёты для заказчика
-- Мы справились с подготовкой данных, которые понадобятся, чтобы рассчитать траты пользователей.
-- На этом этапе используем этот запрос и сделаем финальные подсчёты.

-- Напомним задачи от коллег из компании мобильного оператора:
-- 1. выгрузить данные о клиентах с информацией о потребляемых услугах за каждый месяц активности и посчитать их месячные траты с учётом тарифного плана;
-- 2. рассчитать среднее значение трат активных клиентов (которые продолжают пользоваться услугами компании) в разрезе тарифного плана;
-- 3. найти активных клиентов, которые тратят деньги сверх абонентской платы, и посчитать, сколько в среднем они переплачивают.

-- 1. Траты клиентов по месяцам
-- Суммарная длительность разговоров клиента в месяц:
WITH monthly_duration AS (
    SELECT user_id,
           -- Выделяем месяц из даты звонка: 
           DATE_TRUNC('month', call_date::timestamp)::date AS dt_month,    
           CEIL(SUM(duration)) AS month_duration
    FROM telecom.calls
    GROUP BY user_id, dt_month
),
-- Суммарное количество потраченного интернет-трафика в месяц:
monthly_internet AS (
    SELECT user_id,
           DATE_TRUNC('month', session_date::timestamp)::date AS dt_month,  
           SUM(mb_used) AS month_mb_traffic
    FROM telecom.internet
    GROUP BY user_id, dt_month
),
-- Суммарное количество сообщений в месяц:
monthly_sms AS (
    SELECT user_id,
           DATE_TRUNC('month', message_date::timestamp)::date AS dt_month,  
           COUNT(message_date) AS month_sms
    FROM telecom.messages
    GROUP BY user_id, dt_month
),
-- Формирование уникальной пары значений user_id и dt_month:
user_activity_months AS (
    -- Первое множество значений user_id и dt_month с учётом разговорной активности клиента:
    SELECT user_id, dt_month
    FROM monthly_duration
    UNION
    -- Второе множество значений user_id и dt_month с учётом интернет-активности клиента:
    SELECT user_id, dt_month
    FROM monthly_internet   
    UNION
    -- Третье множество значений user_id и dt_month с учётом активности клиента по сообщениям:
    SELECT user_id, dt_month
    FROM monthly_sms
),
-- Соединение подсчитанных значения по активности клиента в одну таблицу:
users_stat AS (
    SELECT u.user_id,
           u.dt_month,
           month_duration,
           month_mb_traffic,
           month_sms
    -- В качестве основной таблицы используем данные из CTE user_activity_months:
    FROM user_activity_months AS u
    -- Последовательно присоединяем данные по звонкам, интернет-трафику и сообщениям.
    -- При объединении данных используем пару значений user_id и dt_month:
    LEFT JOIN monthly_duration AS md ON u.user_id = md.user_id AND u.dt_month= md.dt_month
    LEFT JOIN monthly_internet AS mi ON u.user_id = mi.user_id AND u.dt_month= mi.dt_month
    LEFT JOIN monthly_sms AS mm ON u.user_id = mm.user_id AND u.dt_month= mm.dt_month
),
-- Превышение установленного лимита по каждому виду связи:
user_over_limits AS (
    SELECT us.user_id,
           us.dt_month,
           u.tariff,
           us.month_duration,
           us.month_mb_traffic,
           us.month_sms,
        -- Условие, если длительность разговоров клиента превышает установленный тарифом лимит:        
        CASE 
            WHEN us.month_duration >= t.minutes_included 
            THEN (us.month_duration - t.minutes_included)
            ELSE 0
        END AS duration_over,
        -- Условие, если количество интернет-трафика в месяц превышает установленный тарифом лимит:        
        CASE 
            WHEN us.month_mb_traffic >= t.mb_per_month_included 
            THEN (us.month_mb_traffic - t.mb_per_month_included) / 1024::real
            ELSE 0
        END AS gb_traffic_over,
        -- Условие, если количество сообщений в месяц превышает установленный тарифом лимит:        
        CASE 
            WHEN us.month_sms >= t.messages_included 
            THEN (us.month_sms - t.messages_included)
            ELSE 0
        END AS sms_over
    FROM users_stat AS us
    LEFT JOIN (SELECT tariff, user_id FROM telecom.users) AS u ON us.user_id = u.user_id
    LEFT JOIN telecom.tariffs AS t ON u.tariff = t.tariff_name
),
-- Траты клиентов по месяцам:
users_costs AS (
    SELECT
        uol.user_id,
        uol.dt_month,
        uol.tariff,
        uol.month_duration,
        uol.month_mb_traffic,
        uol.month_sms,
        t.rub_monthly_fee,
        -- Итоговая стоимость: абонентская плата + перерасход минут + перерасход ГБ + перерасход SMS
        t.rub_monthly_fee
        + uol.duration_over * t.rub_per_minute
        + uol.gb_traffic_over * t.rub_per_gb
        + uol.sms_over * t.rub_per_message
        AS total_cost
    FROM user_over_limits AS uol
    JOIN telecom.tariffs AS t
        ON uol.tariff = t.tariff_name
)

SELECT *
FROM users_costs
ORDER BY user_id, dt_month
LIMIT 10;

-- Таблица: 
-- user_id	dt_month	tariff	month_duration	month_mb_traffic	month_sms	rub_monthly_fee	total_cost
-- 1000	2018-05-01	ultra	151	2253.49	22	1950	1950
-- 1000	2018-06-01	ultra	159	23233.8	62	1950	1950
-- 1000	2018-07-01	ultra	319	14003.6	75	1950	1950
-- 1000	2018-08-01	ultra	390	14055.9	81	1950	1950
-- 1000	2018-09-01	ultra	441	14568.9	57	1950	1950
-- 1000	2018-10-01	ultra	329	14702.5	73	1950	1950
-- 1000	2018-11-01	ultra	320	14756.5	58	1950	1950
-- 1000	2018-12-01	ultra	313	9817.61	70	1950	1950
-- 1001	2018-11-01	smart	409	18429.3	nan	550	1149.48
-- 1001	2018-12-01	smart	392	14036.7	nan	550	550


-- 2. Средние траты активных клиентов
-- Суммарная длительность разговоров клиента в месяц:
WITH monthly_duration AS (
    SELECT user_id,
           -- Выделяем месяц из даты звонка: 
           DATE_TRUNC('month', call_date::timestamp)::date AS dt_month,    
           CEIL(SUM(duration)) AS month_duration
    FROM telecom.calls
    GROUP BY user_id, dt_month
),
-- Суммарное количество потраченного интернет-трафика в месяц:
monthly_internet AS (
    SELECT user_id,
           DATE_TRUNC('month', session_date::timestamp)::date AS dt_month,  
           SUM(mb_used) AS month_mb_traffic
    FROM telecom.internet
    GROUP BY user_id, dt_month
),
-- Суммарное количество сообщений в месяц:
monthly_sms AS (
    SELECT user_id,
           DATE_TRUNC('month', message_date::timestamp)::date AS dt_month,  
           COUNT(message_date) AS month_sms
    FROM telecom.messages
    GROUP BY user_id, dt_month
),
-- Формирование уникальной пары значений user_id и dt_month:
user_activity_months AS (
    SELECT user_id, dt_month
    FROM monthly_duration
    UNION
    SELECT user_id, dt_month
    FROM monthly_internet   
    UNION
    SELECT user_id, dt_month
    FROM monthly_sms
),
-- Соединение подсчитанных значений по активности клиента в одну таблицу:
users_stat AS (
    SELECT u.user_id,
           u.dt_month,
           month_duration,
           month_mb_traffic,
           month_sms
    FROM user_activity_months AS u
    LEFT JOIN monthly_duration AS md ON u.user_id = md.user_id AND u.dt_month = md.dt_month
    LEFT JOIN monthly_internet AS mi ON u.user_id = mi.user_id AND u.dt_month = mi.dt_month
    LEFT JOIN monthly_sms AS mm ON u.user_id = mm.user_id AND u.dt_month = mm.dt_month
),
-- Превышение установленного лимита по каждому виду связи:
user_over_limits AS (
    SELECT us.user_id,
           us.dt_month,
           u.tariff,
           us.month_duration,
           us.month_mb_traffic,
           us.month_sms,
        CASE 
            WHEN us.month_duration >= t.minutes_included 
            THEN (us.month_duration - t.minutes_included)
            ELSE 0
        END AS duration_over,
        CASE 
            WHEN us.month_mb_traffic >= t.mb_per_month_included 
            THEN (us.month_mb_traffic - t.mb_per_month_included) / 1024::real
            ELSE 0
        END AS gb_traffic_over,
        CASE 
            WHEN us.month_sms >= t.messages_included 
            THEN (us.month_sms - t.messages_included)
            ELSE 0
        END AS sms_over
    FROM users_stat AS us
    LEFT JOIN (SELECT user_id, tariff FROM telecom.users) AS u 
        ON us.user_id = u.user_id
    LEFT JOIN telecom.tariffs AS t 
        ON u.tariff = t.tariff_name
),
-- Траты клиента за каждый месяц:
users_costs AS (
    SELECT uol.user_id,
           uol.dt_month,
           uol.tariff,
           uol.month_duration,
           uol.month_mb_traffic,
           uol.month_sms,
           t.rub_monthly_fee, 
           t.rub_monthly_fee 
             + uol.duration_over * t.rub_per_minute
             + uol.gb_traffic_over * t.rub_per_gb 
             + uol.sms_over * t.rub_per_message AS total_cost 
    FROM user_over_limits AS uol
    LEFT JOIN telecom.tariffs AS t 
        ON uol.tariff = t.tariff_name
)
-- Средние траты активных клиентов по тарифам:
SELECT
    uc.tariff,
    COUNT(DISTINCT u.user_id) AS total_users,
    ROUND(AVG(uc.total_cost)::numeric, 2) AS avg_total_cost
FROM users_costs AS uc
JOIN telecom.users AS u
    ON uc.user_id = u.user_id
WHERE u.churn_date IS NULL               -- только активные клиенты
GROUP BY uc.tariff
ORDER BY uc.tariff;

-- Таблица:
-- tariff	total_users	avg_total_cost
-- smart	328	1206.1
-- ultra	134	2056.65

-- По средним значениям можно сделать вывод, что пользователи тарифа Smart в среднем платят в два раза больше стоимости тарифного плана, которая составляет 550 рублей. 
-- В то же время на другом тарифе средний чек превышает абонентскую плату примерно на 100 рублей.

-- 3. Активные клиенты и их траты
-- Суммарная длительность разговоров клиента в месяц:
WITH monthly_duration AS (
    SELECT user_id,
           -- Выделяем месяц из даты звонка: 
           DATE_TRUNC('month', call_date::timestamp)::date AS dt_month,    
           CEIL(SUM(duration)) AS month_duration
    FROM telecom.calls
    GROUP BY user_id, dt_month
),
-- Суммарное количество потраченного интернет-трафика в месяц:
monthly_internet AS (
    SELECT user_id,
           DATE_TRUNC('month', session_date::timestamp)::date AS dt_month,  
           SUM(mb_used) AS month_mb_traffic
    FROM telecom.internet
    GROUP BY user_id, dt_month
),
-- Суммарное количество сообщений в месяц:
monthly_sms AS (
    SELECT user_id,
           DATE_TRUNC('month', message_date::timestamp)::date AS dt_month,  
           COUNT(message_date) AS month_sms
    FROM telecom.messages
    GROUP BY user_id, dt_month
),
-- Формирование уникальной пары значений user_id и dt_month:
user_activity_months AS (
    -- Первое множество значений user_id и dt_month с учётом разговорной активности клиента:
    SELECT user_id, dt_month
    FROM monthly_duration
    UNION
    -- Второе множество значений user_id и dt_month с учётом интернет-активности клиента:
    SELECT user_id, dt_month
    FROM monthly_internet   
    UNION
    -- Третье множество значений user_id и dt_month с учётом активности клиента по сообщениям:
    SELECT user_id, dt_month
    FROM monthly_sms
),
-- Соединение подсчитанных значений по активности клиента в одну таблицу:
users_stat AS (
    SELECT u.user_id,
           u.dt_month,
           month_duration,
           month_mb_traffic,
           month_sms
    -- В качестве основной таблицы используем данные из CTE user_activity_months:
    FROM user_activity_months AS u
    -- Последовательно присоединяем данные по звонкам, интернет-трафику и сообщениям.
    -- При объединении данных используем пару значений user_id и dt_month:
    LEFT JOIN monthly_duration AS md ON u.user_id = md.user_id AND u.dt_month= md.dt_month
    LEFT JOIN monthly_internet AS mi ON u.user_id = mi.user_id AND u.dt_month= mi.dt_month
    LEFT JOIN monthly_sms AS mm ON u.user_id = mm.user_id AND u.dt_month= mm.dt_month
),
-- Превышение установленного лимита по каждому виду связи:
user_over_limits AS (
    SELECT us.user_id,
           us.dt_month,
           u.tariff,
           us.month_duration,
           us.month_mb_traffic,
           us.month_sms,
        -- Условие, если длительность разговоров клиента превышает установленный тарифом лимит:        
        CASE 
            WHEN us.month_duration >= t.minutes_included 
            THEN (us.month_duration - t.minutes_included)
            ELSE 0
        END AS duration_over,
        -- Условие, если количество интернет-трафика в месяц превышает установленный тарифом лимит:        
        CASE 
            WHEN us.month_mb_traffic >= t.mb_per_month_included 
            THEN (us.month_mb_traffic - t.mb_per_month_included) / 1024::real
            ELSE 0
        END AS gb_traffic_over,
        -- Условие, если количество сообщений в месяц превышает установленный тарифом лимит:        
        CASE 
            WHEN us.month_sms >= t.messages_included 
            THEN (us.month_sms - t.messages_included)
            ELSE 0
        END AS sms_over
    FROM users_stat AS us
    LEFT JOIN (SELECT tariff, user_id FROM telecom.users) AS u ON us.user_id = u.user_id
    LEFT JOIN telecom.tariffs AS t ON u.tariff = t.tariff_name
),
-- Траты клиента за каждый месяц:
users_costs AS (
    SELECT uol.user_id,
           uol.dt_month,
           uol.tariff,
           uol.month_duration,
           uol.month_mb_traffic,
           uol.month_sms,
           t.rub_monthly_fee, 
           t.rub_monthly_fee + uol.duration_over * t.rub_per_minute
           + uol.gb_traffic_over * t.rub_per_gb + uol.sms_over * t.rub_per_message AS total_cost 
    FROM user_over_limits AS uol
    LEFT JOIN telecom.tariffs AS t ON uol.tariff = t.tariff_name
)
SELECT
    uc.tariff,
    COUNT(DISTINCT u.user_id) AS total_users,
    ROUND(AVG(uc.total_cost)::numeric, 2) AS avg_total_cost,
    ROUND(AVG(uc.total_cost - uc.rub_monthly_fee)::numeric, 2) AS overcost
FROM users_costs AS uc
JOIN telecom.users AS u
    ON uc.user_id = u.user_id
WHERE u.churn_date IS NULL                    -- только активные клиенты
  AND uc.total_cost > uc.rub_monthly_fee      -- только те, кто тратит сверх абонплаты
GROUP BY uc.tariff
ORDER BY uc.tariff;

-- Таблица: 
-- tariff	total_users	avg_total_cost	overcost
-- smart	318	1433.42	883.42
-- ultra	40	2731.79	781.79

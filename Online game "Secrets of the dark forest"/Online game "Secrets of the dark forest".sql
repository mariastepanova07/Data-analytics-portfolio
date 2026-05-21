-- Разведочный анализ данных

-- 1. Информация о таблицах
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'fantasy'

-- Таблица:
-- table_name
-- classes
-- country
-- events
-- items
-- race
-- skills
-- users


-- 2. Данные в таблице users
-- Выводим названия полей, их тип данных и метку о ключевом поле таблицы users
SELECT c.table_schema,
       c.table_name,
       c.column_name,
       c.data_type,
       k.constraint_name
FROM information_schema.columns AS c
-- Присоединим данные с ограничениями полей
LEFT JOIN information_schema.key_column_usage AS k 
    ON c.table_name = k.table_name
    AND c.column_name = k.column_name
    AND c.table_schema = k.table_schema
-- Отфильтруем результат по названию схемы и таблицы
WHERE c.table_schema = 'fantasy'
  AND c.table_name = 'users'
ORDER BY c.table_name;

-- Таблица:
-- table_schema	table_name	column_name	data_type	constraint_name
-- fantasy	users	id	character varying	users_pkey
-- fantasy	users	tech_nickname	character varying	
-- fantasy	users	class_id	character varying	users_class_id_fkey
-- fantasy	users	ch_id	character varying	users_ch_id_fkey
-- fantasy	users	birthdate	character varying	
-- fantasy	users	pers_gender	character varying	
-- fantasy	users	registration_dt	character varying	
-- fantasy	users	server	character varying	
-- fantasy	users	race_id	character varying	users_race_id_fkey
-- fantasy	users	payer	integer	
-- fantasy	users	loc_id	character varying	users_loc_id_fkey

-- Таблица users содержит 11 полей, и большинство из них хранят текстовые данные. 
-- При этом поле id с идентификатором игрока — это первичный ключ таблицы, а четыре поля class_id, ch_id, race_id и loc_id — внешние ключи. 
-- Можно предположить, что таблица users связана с таблицами classes, skills, race и country.


-- 3. Вывод первых строк таблицы users
select *,
count(*) over() as row_count
from fantasy.users
limit 5

-- Таблица:       
-- id	tech_nickname	class_id	ch_id	birthdate	pers_gender	registration_dt	server	race_id	payer	loc_id	row_count
-- 00-0037846	DivineBarbarian4154	9RD	JJR2	6/4/1994	Male	1/20/2005	server_1	B1	0	US	22214
-- 00-0041533	BoldInvoker7693	Z3Q	HQ9N	6/29/1987	Male	4/8/2022	server_1	R2	0	US	22214
-- 00-0045747	NobleAlchemist7633	382	IXBW	7/29/1992	Male	10/12/2013	server_1	K3	0	US	22214
-- 00-0055274	SteadfastArcher8318	ZD0	QSUB	9/14/1985	Female	4/10/2008	server_1	R2	0	US	22214
-- 00-0076100	RadiantProphet353	YC8	HQ9N	4/11/1997	Female	9/29/2013	server_2	K4	1	US	22214

-- Теперь можно зафиксировать содержимое строк и отметить возможные сложности, например формат представления даты. 
-- Всего данные содержат информацию о 22214 игроках.


-- 4. Проверка пропусков в таблице users
SELECT 
    COUNT(*) AS rows_with_nulls
FROM fantasy.users
WHERE class_id   IS NULL
   OR ch_id      IS NULL
   OR pers_gender IS NULL
   OR server     IS NULL
   OR race_id    IS NULL
   OR payer      IS NULL
   OR loc_id     IS NULL;

-- Таблица:
-- rows_with_nulls
-- 0


-- 5. Знакомство с категориальными данными таблицы users
select distinct server,
count(*) as number_rows
from fantasy.users
group by server

-- Таблица:       
-- server	number_rows
-- server_1	16715
-- server_2	5499

-- Игрокам доступно два сервера. 
-- При этом на первом сервере примерно в три раза больше игроков, чем на втором.


-- 6. Знакомство с таблицей events
-- Выводим названия полей, их тип данных и метку о ключевом поле таблицы events
SELECT c.table_schema,
       c.table_name,
       c.column_name,
       c.data_type,
       k.constraint_name
FROM information_schema.columns AS c 
-- Присоединяем данные с ограничениями полей
LEFT JOIN information_schema.key_column_usage AS k 
    USING(table_name, column_name, table_schema)
-- Фильтруем результат по названию схемы и таблицы
WHERE c.table_schema = 'fantasy'
  AND c.table_name  = 'events'
ORDER BY c.table_name;

-- Таблица:
-- table_schema	table_name	column_name	data_type	constraint_name
-- fantasy	events	transaction_id	character varying	events_pkey
-- fantasy	events	id	character varying	events_id_fkey
-- fantasy	events	date	character varying	
-- fantasy	events	time	character varying	
-- fantasy	events	item_code	integer	events_item_code_fkey
-- fantasy	events	amount	real	
-- fantasy	events	seller_id	character varying	


-- 7. Выведем первые пять строк таблицы events
SELECT
    *,
    COUNT(*) OVER () AS row_count
FROM fantasy.events
LIMIT 5;

-- Таблица:
-- transaction_id	id	date	time	item_code	amount	seller_id	row_count
-- 2129235853	37-5938126	2021-01-03	16:31:49	6010	21.41	220381	1307678
-- 2129237617	37-5938126	2021-01-03	16:49:00	6010	64.98	54680	1307678
-- 2129239381	37-5938126	2021-01-03	21:05:29	6010	50.68	888909	1307678
-- 2129241145	37-5938126	2021-01-03	22:03:02	6010	46.49	888902	1307678
-- 2129242909	37-5938126	2021-01-03	22:04:26	6010	18.72	888905	1307678

-- Игроки совершили больше миллиона внутриигровых покупок — есть что анализировать. 
-- Обратим внимание, что id продавца отличается по структуре от id игрока.
-- Видимо, для продажи эпических предметов игрок должен зарегистрироваться как продавец.


-- 8. Проверка пропусков в таблице events
SELECT 
    COUNT(*) AS missing_rows
FROM fantasy.events
WHERE date IS NULL
   OR time IS NULL
   OR amount IS NULL
   OR seller_id IS NULL;

-- Таблица:
-- missing_rows
-- 508186

-- В 508186 строках из 1307678 встречаются пропуски хотя бы в одном из полей. Теперь можно проверить, что это за поля.


-- 9. Изучаем пропуски в таблице events
-- Считаем количество строк с данными в каждом поле
SELECT 
    COUNT(date)      AS data_date,
    COUNT(time)      AS data_time,
    COUNT(amount)    AS data_amount,
    COUNT(seller_id) AS data_seller_id
FROM fantasy.events
WHERE date IS NULL
   OR time IS NULL
   OR amount IS NULL
   OR seller_id IS NULL;

-- Таблица:
-- data_date	data_time	data_amount	data_seller_id
-- 508186	508186	508186	0

-- Все 508186 пропусков содержатся только в поле seller_id, то есть в данных нет информации о продавце. 
-- Видимо, в таком случае покупка совершалась в игровом магазине, а не у других продавцов.


-- Аналитические задачи
-- Часть 1. Исследовательский анализ данных
-- Задача 1. Исследование доли платящих игроков

-- 1.1. Доля платящих пользователей по всем данным:
SELECT
    COUNT(*) AS total_users,                                             
    SUM(CASE WHEN payer = 1 THEN 1 ELSE 0 END) AS paying_users,          
    SUM(CASE WHEN payer = 1 THEN 1 ELSE 0 END)::float / COUNT(*) 
        AS paying_share                                                 
FROM fantasy.users;

-- Таблица:
-- total_users  paying_users  paying_share
-- 22214	3929	0.17687044206356353


-- 1.2. Доля платящих пользователей в разрезе расы персонажа:
SELECT
    r.race AS race_name,                                    
    SUM(CASE WHEN u.payer = 1 THEN 1 ELSE 0 END) AS paying_users,  
    COUNT(*) AS total_users,                                      
    SUM(CASE WHEN u.payer = 1 THEN 1 ELSE 0 END)::float 
        / COUNT(*) AS paying_share                                
FROM fantasy.users AS u
JOIN fantasy.race AS r ON u.race_id = r.race_id
GROUP BY r.race
ORDER BY r.race;

-- Таблица:
-- race_name  paying_users  total_users  paying_share
-- Angel	229	1327	0.17256970610399397
-- Demon	238	1229	0.193653376729048
-- Elf	427	2501	0.17073170731707318
-- Hobbit	659	3648	0.1806469298245614
-- Human	1114	6328	0.17604298356510745
-- Northman	626	3562	0.17574396406513196
-- Orc	636	3619	0.17573915446255872


-- Задача 2. Исследование внутриигровых покупок
-- 2.1. Статистические показатели по полю amount:
SELECT
    COUNT(amount) AS total_purchases,                                         
    SUM(amount) AS total_amount,                                              
    MIN(amount) AS min_amount,                                                
    MAX(amount) AS max_amount,                                                
    AVG(amount) AS avg_amount,                                                
    percentile_disc(0.5) WITHIN GROUP (ORDER BY amount) AS median_amount,     
    STDDEV(amount) AS std_amount                                              
FROM fantasy.events;

-- Таблица:
-- total_amount  min_amount  max_amount  avg_amount  median_amount  std_amount
-- 686615040	0.0	486615.1	525.6919663589833	74.86	2517.345444427788


-- 2.2: Аномальные нулевые покупки:
SELECT 
    COUNT(*) AS zero_amount_count,                                           
    COUNT(*)::float / (SELECT COUNT(*) FROM fantasy.events) AS zero_amount_share
FROM fantasy.events
WHERE amount = 0;

-- Таблица:
-- zero_amount_count  zero_amount_share
-- 907	0.0006935958240484


-- 2.3: Популярные эпические предметы:
SELECT
    i.item_code,
    i.game_items,
    COUNT(*) AS total_sales,
    COUNT(*)::float / SUM(COUNT(*)) OVER () AS sales_share,
    COUNT(DISTINCT e.id) AS unique_buyers,
    COUNT(DISTINCT e.id)::float
        / (SELECT COUNT(DISTINCT id) FROM fantasy.events WHERE amount > 0)
        AS buyers_share
FROM fantasy.events e
JOIN fantasy.items i USING (item_code)
WHERE e.amount > 0
GROUP BY i.item_code, i.game_items
ORDER BY buyers_share DESC
LIMIT 10;

-- Таблица:
-- item_code  game_items  total_sales  sales_share  unique_buyers  buyers_share
-- 6010	Book of Legends	1004516	0.7687008664869361	12194	0.8841357308584686
-- 6011	Bag of Holding	271875	0.2080509898061711	11968	0.8677494199535963
-- 6012	Necklace of Wisdom	13828	0.010581808136238102	1627	0.1179669373549884
-- 6536	Gems of Insight	3833	0.0029331841615707725	926	0.06714037122969838
-- 5964	Treasure Map	3084	0.0023600156416082084	753	0.05459686774941996
-- 5411	Silver Flask	795	0.0006083697908815	633	0.0458961716937355
-- 4112	Amulet of Protection	1078	0.0008249341315349	445	0.03226508120649652
-- 5541	Glowing Pendant	563	0.0004308329462469	354	0.02566705336426914
-- 5691	Strength Elixir	580	0.0004438421115865	331	0.023999419953596286
-- 5661	Ring of Wisdom	379	0.0002900278625712	310	0.02247679814385151


-- Часть 2. Решение ad hoc-задачи
-- Задача: Зависимость активности игроков от расы персонажа:

WITH race_users AS (
    SELECT
        r.race,
        u.id,
        u.payer
    FROM fantasy.users AS u
    JOIN fantasy.race  AS r
      ON u.race_id = r.race_id
),
race_users_agg AS (
    SELECT
        race,
        COUNT(*) AS total_users          
    FROM race_users
    GROUP BY race
),
race_events AS (
    SELECT
        ru.race,
        ru.id,
        ru.payer,
        e.amount
    FROM race_users AS ru
    JOIN fantasy.events AS e
      ON e.id = ru.id
    WHERE e.amount > 0                   
),
race_buyers AS (
    SELECT
        race,
        COUNT(DISTINCT id) AS buyers_cnt,                                   
        COUNT(DISTINCT CASE WHEN payer = 1 THEN id END) AS paying_cnt       
    FROM race_events
    GROUP BY race
),
race_activity AS (
    SELECT
        race,
        id AS user_id,
        COUNT(*) AS purchases_count,   
        SUM(amount) AS total_amount       
    FROM race_events
    GROUP BY race, id
)
SELECT
    ru.race,
    ru.total_users,                                             
    rb.buyers_cnt AS buyers_count,          
    (rb.buyers_cnt::float / ru.total_users) AS share_buyers,         
    (rb.paying_cnt::float / NULLIF(rb.buyers_cnt, 0)) AS share_payers_among_buyers,
    AVG(ra.purchases_count)::float AS avg_purchases_per_buyer,
    AVG(ra.total_amount::float / ra.purchases_count) AS avg_purchase_cost_per_buyer,
    AVG(ra.total_amount)::float AS avg_total_spent_per_buyer
FROM race_users_agg AS ru
LEFT JOIN race_buyers AS rb USING (race)
LEFT JOIN race_activity AS ra USING (race)
GROUP BY
    ru.race,
    ru.total_users,
    rb.buyers_cnt,
    rb.paying_cnt
ORDER BY ru.race;

-- Таблица:
-- race  total_users  buyers_count  share_buyers  share_payers_among_buyers  avg_purchases_per_buyer  avg_purchase_cost_per_buyer  avg_total_spent_per_buyer
-- Angel	1327	820	0.6179351921627732	0.16707317073170733	106.8048780487805	775.5473936550735	48668.654069951976
-- Demon	1229	737	0.5996745321399511	0.1994572591587517	77.86974219810041	735.4793640634745	41197.38218165867
-- Elf	2501	1543	0.616953218712515	0.16267012313674659	78.79066753078419	791.8378090849076	53761.66089277907
-- Hobbit	3648	2266	0.6211622807017544	0.176963812886143	86.1288614298323	699.8950955669618	47620.91727650114
-- Human	6328	3921	0.6196270543615676	0.18005610813567968	121.40219331803111	733.6180045068687	48941.01303575012
-- Northman	3562	2229	0.6257720381807973	0.18214445939883356	82.10183938986093	781.0536167263089	62520.66007628933
-- Orc	3619	2276	0.6289030118817353	0.17398945518453426	81.73813708260106	709.4439236722243	41760.039382172305



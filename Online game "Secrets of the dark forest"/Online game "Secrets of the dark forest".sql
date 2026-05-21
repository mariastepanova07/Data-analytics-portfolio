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











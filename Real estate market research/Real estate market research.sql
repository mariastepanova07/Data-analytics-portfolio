--Задача 1: Время акивности объявлений:

WITH limits AS (
    SELECT  
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY total_area) AS total_area_limit,
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY rooms) AS rooms_limit,
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY balcony) AS balcony_limit,
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY ceiling_height) AS ceiling_height_limit_h,
        PERCENTILE_DISC(0.01) WITHIN GROUP (ORDER BY ceiling_height) AS ceiling_height_limit_l
    FROM real_estate.flats
),
filtered_id AS (
    SELECT id
    FROM real_estate.flats  
    WHERE 
        total_area < (SELECT total_area_limit FROM limits)
        AND (rooms < (SELECT rooms_limit FROM limits) OR rooms IS NULL)
        AND (balcony < (SELECT balcony_limit FROM limits) OR balcony IS NULL)
        AND (
            (ceiling_height < (SELECT ceiling_height_limit_h FROM limits)
             AND ceiling_height > (SELECT ceiling_height_limit_l FROM limits))
            OR ceiling_height IS NULL
        )
),
prep AS (
    SELECT
        CASE WHEN c.city = 'Санкт-Петербург' THEN 'Санкт-Петербург' ELSE 'ЛенОбл' END AS region,
        CASE
            WHEN a.days_exposition IS NULL THEN 'non category'
            WHEN a.days_exposition BETWEEN 1 AND 30  THEN '1-30 days'
            WHEN a.days_exposition BETWEEN 31 AND 90 THEN '31-90 days'
            WHEN a.days_exposition BETWEEN 91 AND 180 THEN '91-180 days'
            ELSE '181+ days'
        END AS activity_segment
    FROM real_estate.advertisement a
    JOIN real_estate.flats f ON f.id = a.id
    JOIN real_estate.city  c ON c.city_id = f.city_id
    JOIN real_estate.type  t ON t.type_id = f.type_id
    WHERE a.id IN (SELECT id FROM filtered_id)
      AND a.first_day_exposition >= DATE '2015-01-01'
      AND a.first_day_exposition <  DATE '2019-01-01'
      AND t.type IN ('город') 
),
cnt AS (
    SELECT
        region,
        activity_segment,
        COUNT(*) AS ads_cnt
    FROM prep
    GROUP BY region, activity_segment
),
tot AS (
    SELECT region, SUM(ads_cnt) AS total_cnt
    FROM cnt
    GROUP BY region
)
SELECT
    c.region AS "Регион",
    CASE c.activity_segment
        WHEN '1-30 days'   THEN 'до месяца'
        WHEN '31-90 days'  THEN 'до трех месяцев'
        WHEN '91-180 days' THEN 'до полугода'
        WHEN '181+ days'   THEN 'более полугода'
        ELSE 'non category'
    END AS "Категория объявлений",
    c.ads_cnt AS "Кол-во объявлений",
    ROUND((100.0 * c.ads_cnt / t.total_cnt)::numeric, 2) AS "Доля, %"
FROM cnt c
JOIN tot t ON t.region = c.region
ORDER BY
    c.region,
    c.ads_cnt DESC;



WITH limits AS (
    SELECT  
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY total_area) AS total_area_limit,
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY rooms) AS rooms_limit,
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY balcony) AS balcony_limit,
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY ceiling_height) AS ceiling_height_limit_h,
        PERCENTILE_DISC(0.01) WITHIN GROUP (ORDER BY ceiling_height) AS ceiling_height_limit_l
    FROM real_estate.flats
),
filtered_id AS(
    SELECT id
    FROM real_estate.flats  
    WHERE 
        total_area < (SELECT total_area_limit FROM limits)
        AND (rooms < (SELECT rooms_limit FROM limits) OR rooms IS NULL)
        AND (balcony < (SELECT balcony_limit FROM limits) OR balcony IS NULL)
        AND (
            (ceiling_height < (SELECT ceiling_height_limit_h FROM limits)
             AND ceiling_height > (SELECT ceiling_height_limit_l FROM limits))
            OR ceiling_height IS NULL
        )
),
prep AS (
    SELECT
        CASE WHEN c.city = 'Санкт-Петербург' THEN 'Санкт-Петербург' ELSE 'ЛенОбл' END AS region,
        CASE
            WHEN a.days_exposition IS NULL THEN 'non category'
            WHEN a.days_exposition BETWEEN 1 AND 30  THEN 'до месяца'
            WHEN a.days_exposition BETWEEN 31 AND 90 THEN 'до трех месяцев'
            WHEN a.days_exposition BETWEEN 91 AND 180 THEN 'до полугода'
            ELSE 'более полугода'
        END AS activity_segment,

        (a.last_price / f.total_area)::numeric AS price_m2,
        f.total_area::numeric AS total_area,
        f.rooms,
        COALESCE(f.balcony, 0) AS balcony,
        f.ceiling_height,
        f.floor,
        f.floors_total
    FROM real_estate.advertisement a
    JOIN real_estate.flats f ON f.id = a.id
    JOIN real_estate.city  c ON c.city_id = f.city_id
    JOIN real_estate.type  t ON t.type_id = f.type_id
    WHERE a.id IN (SELECT id FROM filtered_id)
      AND a.first_day_exposition >= DATE '2015-01-01'
      AND a.first_day_exposition <  DATE '2019-01-01'
      AND t.type = 'город'
      AND a.last_price IS NOT NULL AND a.last_price > 0
      AND f.total_area IS NOT NULL AND f.total_area > 0
)
SELECT
    region AS "Регион",
    activity_segment AS "Сегмент активности",
    COUNT(*) AS "Кол-во объявлений",

    ROUND(AVG(price_m2)::numeric, 2) AS "Средняя стоимость кв. метра",
    ROUND(AVG(total_area)::numeric, 2) AS "Средняя площадь",

    PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY rooms) AS "Медиана кол-ва комнат",
    PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY balcony) AS "Медиана кол-ва балконов",
    PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY floors_total) AS "Медиана этажности",
    ROUND(AVG(ceiling_height)::numeric, 2) AS "Средняя высота потолков"

FROM prep
GROUP BY region, activity_segment
ORDER BY
    region,
    CASE activity_segment
        WHEN 'до месяца' THEN 1
        WHEN 'до трех месяцев' THEN 2
        WHEN 'до полугода' THEN 3
        WHEN 'более полугода' THEN 4
        ELSE 5
    END;



--Задача 2: Сезонность объявлений

WITH limits AS (
    SELECT  
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY total_area) AS total_area_limit,
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY rooms) AS rooms_limit,
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY balcony) AS balcony_limit,
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY ceiling_height) AS ceiling_height_limit_h,
        PERCENTILE_DISC(0.01) WITHIN GROUP (ORDER BY ceiling_height) AS ceiling_height_limit_l
    FROM real_estate.flats     
),
filtered_id AS (
    SELECT id
    FROM real_estate.flats  
    WHERE 
        total_area < (SELECT total_area_limit FROM limits)
        AND (rooms < (SELECT rooms_limit FROM limits) OR rooms IS NULL)
        AND (balcony < (SELECT balcony_limit FROM limits) OR balcony IS NULL)
        AND (
            (ceiling_height < (SELECT ceiling_height_limit_h FROM limits)
             AND ceiling_height > (SELECT ceiling_height_limit_l FROM limits))
            OR ceiling_height IS NULL
        )
),
base AS (
    SELECT
        a.id,
        a.first_day_exposition,
        a.days_exposition,
        f.total_area,
        a.last_price,
        t.type
    FROM real_estate.advertisement a
    JOIN real_estate.flats f ON f.id = a.id
    JOIN real_estate.type  t ON t.type_id = f.type_id
    WHERE a.id IN (SELECT id FROM filtered_id)
      AND t.type = 'город'
      AND a.first_day_exposition >= DATE '2015-01-01'
      AND a.first_day_exposition <  DATE '2019-01-01'
      AND a.last_price IS NOT NULL AND a.last_price > 0
      AND f.total_area IS NOT NULL AND f.total_area > 0
),
prep AS (
    SELECT
        EXTRACT(MONTH FROM first_day_exposition)::int AS pub_month,
        CASE
            WHEN days_exposition IS NOT NULL
            THEN (first_day_exposition + days_exposition::int)
        END AS removed_date,
        (last_price / total_area)::numeric AS price_m2,
        total_area::numeric AS total_area
    FROM base
),
pub_stats AS (
    SELECT
        pub_month AS month_num,
        COUNT(*) AS published_cnt,
        ROUND(AVG(price_m2)::numeric, 2) AS pub_avg_price_m2,
        ROUND(AVG(total_area)::numeric, 2) AS pub_avg_area
    FROM prep
    GROUP BY pub_month
),
rem_stats AS (
    SELECT
        EXTRACT(MONTH FROM removed_date)::int AS month_num,
        COUNT(*) AS removed_cnt,
        ROUND(AVG(price_m2)::numeric, 2) AS rem_avg_price_m2,
        ROUND(AVG(total_area)::numeric, 2) AS rem_avg_area
    FROM prep
    WHERE removed_date IS NOT NULL
      AND removed_date >= DATE '2015-01-01'
      AND removed_date <  DATE '2019-01-01'
    GROUP BY EXTRACT(MONTH FROM removed_date)::int
)
SELECT
    m.month_num,
    TRIM(TO_CHAR(MAKE_DATE(2018, m.month_num, 1), 'TMMonth')) AS month_name,
    COALESCE(p.published_cnt, 0) AS published_cnt,
    COALESCE(r.removed_cnt, 0) AS removed_cnt,
    p.pub_avg_price_m2,
    p.pub_avg_area,
    r.rem_avg_price_m2,
    r.rem_avg_area
FROM (SELECT generate_series(1,12) AS month_num) m
LEFT JOIN pub_stats p ON p.month_num = m.month_num
LEFT JOIN rem_stats r ON r.month_num = m.month_num
ORDER BY m.month_num;








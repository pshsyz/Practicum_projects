-- Кол-во дубликатов записей
SELECT
	order_id, COUNT(*)
FROM afisha.purchases
GROUP BY
    order_id
HAVING
    COUNT(*) > 1
/*
order_id|count|
--------+-----+
Дубликатов по order_id нет
*/

    
-- общее кол-во записей в БД
    SELECT count(*)
FROM afisha.purchases
/*
count |
------+
292034|
 */

-- Кол-во мероприятий по возрастному ограничению
SELECT age_limit,
		count(*)
FROM afisha.purchases
GROUP BY age_limit
ORDER BY count(*) desc
/*
age_limit|count|
---------+-----+
       16|78864|
       12|62861|
        0|61731|
        6|52403|
       18|36175|
*/

-- Кол-во пустых значений в кол-ве билетов
SELECT count(*) - COUNT(tickets_count) AS пустые_значения
FROM afisha.purchases
/*
пустые_значения|
---------------+
              0|
 */

-- Кол-во мероприятий по видам
SELECT event_type_main,
	count(*)
FROM afisha.purchases   a
JOIN afisha.events  e ON e.event_id = a.event_id
GROUP BY event_type_main
ORDER BY count(*) DESC
/*
event_type_main|count |
---------------+------+
концерты       |115634|
театр          | 67744|
другое         | 66109|
спорт          | 22006|
стендап        | 13424|
выставки       |  4873|
ёлки           |  2006|
фильм          |   238|
*/

-- Тип устройства, с которого был оформлен заказ
SELECT device_type_canonical,
	count(*)
FROM afisha.purchases   a
GROUP BY device_type_canonical
ORDER BY count(*) DESC
/*
device_type_canonical|count |
---------------------+------+
mobile               |232679|
desktop              | 58170|
tablet               |  1180|
tv                   |     3|
other                |     2|
*/

-- Охват дат в БД
SELECT
	date(DATE_TRUNC('month', created_dt_msk)) AS год_месяц,
	count(*)
FROM afisha.purchases
GROUP BY год_месяц
/*
год_месяц |count |
----------+------+
2024-06-01| 34840|
2024-07-01| 41112|
2024-08-01| 45217|
2024-09-01| 70265|
2024-10-01|100600|
*/

--------------------------------------------------------------------------------------------------------------
-- Используемая валюта

-- Используемая валюта для оплаты билетов
SELECT
	currency_code AS валюта,
	count(*)
FROM afisha.purchases
GROUP BY currency_code
/*
валюта|count |
------+------+
kzt   |  5073|
rub   |286961|
*/

-- Статистика по полю revenue в разбивке по валюте
SELECT
	currency_code AS валюта,
	MAX(revenue) AS max_revenue,
	MIN(revenue) AS min_revenue,
	AVG(revenue) AS avg_revenue,
	count(*) - COUNT(revenue) AS null_revenue
FROM afisha.purchases 
GROUP BY currency_code

--------------------------------------------------------------------------------------------------------------

-- информация по билетным операторам
SELECT
	service_name,
	count(*) AS колво_заказов
FROM afisha.purchases a
GROUP BY service_name
ORDER BY service_name
/*
service_name          |колво_заказов|
----------------------+-------------+
Crazy ticket!         |          796|
Show_ticket           |         2208|
Билет по телефону     |           85|
Билеты без проблем    |        63932|
Билеты в интернете    |            4|
Билеты в руки         |        40500|
Быстробилет           |         2010|
Быстрый кассир        |          381|
Весь в билетах        |        16910|
Восьмёрка             |         1126|
Вперёд!               |           81|
Выступления.ру        |         1621|
Городской дом культуры|         2747|
Дом культуры          |         4514|
Дырокол               |           74|
За билетом!           |         2877|
Зе Бест!              |            5|
КарандашРУ            |          133|
Кино билет            |           67|
Край билетов          |         6238|
Лимоны                |            8|
Лови билет!           |        41338|
Лучшие билеты         |        17872|
Мир касс              |         2171|
Мой билет             |        34965|
Облачко               |        26730|
Прачечная             |        10385|
Радио ticket          |          380|
Реестр                |          130|
Росбилет              |          544|
Тебе билет!           |         5242|
Телебилет             |          321|
Тех билет             |           22|
Цвет и билет          |           61|
Шоу начинается!       |          499|
Яблоко                |         5057|
*/

-- Кол-во event_id и event_name
SELECT 
	count(DISTINCT event_id) AS event_id_count,
	count(DISTINCT event_name_code) AS event_name_code_count
FROM afisha.events
/*
event_id_count|event_name_code_count|
--------------+---------------------+
         22484|                15287|
*/


-- кол-во city_id и region_id
SELECT 
	count(DISTINCT city_id) AS city_id_count,
	count(DISTINCT region_id) AS region_id_count
FROM afisha.city
/*
city_id_count|region_id_count|
-------------+---------------+
          353|             81|
*/


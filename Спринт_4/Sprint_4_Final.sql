/* Проект «Секреты Тёмнолесья»
 * Цель проекта: изучить влияние характеристик игроков и их игровых персонажей 
 * на покупку внутриигровой валюты «райские лепестки», а также оценить 
 * активность игроков при совершении внутриигровых покупок
 * 
 * Автор: Дерновой П.В,	
 * Дата: 03.03.2025
*/

-- Часть 1. Исследовательский анализ данных
-- Задача 1. Исследование доли платящих игроков

-- 1.1. Доля платящих пользователей по всем данным:
SELECT 
	count(id) AS users_count,
	sum(payer) AS users_pay,
	ROUND(avg(payer), 5) AS users_pay_p
FROM fantasy.users;
/* Доля платящих игроков составляет 0.18 от общего колличества пользователей, которое сотавляет 22214 пользователей.
users_count|users_pay|users_pay_p|
-----------+---------+-----------+
      22214|     3929|    0.17687|
*/

-- 1.2. Доля платящих пользователей в разрезе расы персонажа:
SELECT  
	r.race,
	sum(u.payer) AS race_pay,
	count(u.id) AS race_count,
	ROUND(sum(u.payer)::numeric / count(u.id), 5) AS race_pay_p
FROM fantasy.users AS u
LEFT JOIN fantasy.race AS r ON r.race_id =u.race_id 
GROUP BY r.race
ORDER BY race_pay_p DESC;
/*Представители рассы Demon более сколнны к покупкам (0,19 от общего колличества рассы 1229 пользователей).
 *Меньш склонны к покупкам представители Elf (0,17 от общего колличества 2501 пользователей) и Angel (0,17 от общего колличества 1327 пользователей)
 * 
race    |race_pay|race_count|race_pay_p|
--------+--------+----------+----------+
Demon   |     238|      1229|   0.19365|
Hobbit  |     659|      3648|   0.18065|
Human   |    1114|      6328|   0.17604|
Orc     |     636|      3619|   0.17574|
Northman|     626|      3562|   0.17574|
Angel   |     229|      1327|   0.17257|
Elf     |     427|      2501|   0.17073|
*/

-- Задача 2. Исследование внутриигровых покупок
-- 2.1. Статистические показатели по полю amount:
SELECT 
	count(*) AS count_tran,
	sum (amount) AS sum_tran,
	min (amount) AS min_tran,
	max (amount) AS max_tran,
	round(avg(amount)::numeric,2) AS avg_tran,
	percentile_cont(0.5) WITHIN GROUP (ORDER BY amount) AS med_tran,
	round(stddev(amount)::numeric,4) AS r2_tran
FROM fantasy.events;
/*Общее число совершенных покупок сотовляет 1307678 на сумму 686615040 игровой валюты.
 * Минимальная покупка со стоимостью 0 показывает что есть аномальные значения стоимости покупок.
 * Среднее значение стоимости (525.69) выше медианного (74.86), а также стандартное отклонение (2517.35) показывает преобладание покупок с высокой стоимостью.
ount_tran|sum_tran |min_tran|max_tran|avg_tran|med_tran         |r2_tran  |
---------+---------+--------+--------+--------+-----------------+---------+
  1307678|686615040|     0.0|486615.1|  525.69|74.86000061035156|2517.3454|
 */

-- 2.2: Аномальные нулевые покупки:
SELECT 
	count(*) FILTER (WHERE amount = 0) AS count_zero_tran,
	count(*) AS count_all_tran,
	count(*)FILTER (WHERE amount = 0)::numeric/(SELECT count(*) FROM fantasy.events) AS zero_tran_p 
FROM fantasy.events;
/* Доля покупок с нулевой стоимостью составляет 0.00069 (907 транзакций).
 *
count_zero_tran|count_all_tran|zero_tran_p           |
---------------+--------------+----------------------+
            907|       1307678|0.00069359582404842782|
 */

-- 2.3: Сравнительный анализ активности платящих и неплатящих игроков:
WITH user_pay AS(
	SELECT 
		u.id AS id,
		CASE WHEN u.payer=1 THEN 'payers' ELSE 'not_payers'	END AS pay_type,
		count(e.amount) AS count_amount,
		sum (e.amount) AS avg_amount
	FROM fantasy.users AS u
	LEFT JOIN fantasy.events AS e ON e.id=u.id
	WHERE e.amount>0
	GROUP BY u.id
)
SELECT 
	pay_type,
	count(id) AS user_count,
	round(count(id)::NUMERIC/(SELECT count(*) FROM user_pay),2) AS user_count_P,
	round(avg(count_amount)::NUMERIC,2) AS count_amount,
	round(avg(avg_amount)::NUMERIC,2) AS avg_amount	
FROM user_pay
GROUP BY pay_type;
/* Среднее колличество покупок у платящих игроков сотавляет 51.02, у неплатящих 60.55 при сравнительно динаковой средней суммарной стоимости покупок
pay_type  |user_count|user_count_p|count_amount|avg_amount|
----------+----------+------------+------------+----------+
payers    |      2444|        0.18|       81.68|  55467.74|
not_payers|     11348|        0.82|       97.56|  48631.74|
 */

-- 2.4: Популярные эпические предметы:
WITH items AS (
    SELECT 
        e.item_code,
        i.game_items,
        COUNT(DISTINCT e.id) AS total_users,
        COUNT(DISTINCT e.transaction_id) AS total_orders
    FROM fantasy.events AS e
    LEFT JOIN fantasy.items AS i ON i.item_code = e.item_code
    WHERE e.amount > 0
    GROUP BY e.item_code, i.game_items
)
SELECT 
    item_code,
    game_items,
    sum(total_orders) AS sum_orders_item,
    round(sum(total_orders)::numeric/(SELECT sum(total_orders) FROM items),5) AS sum_orders_item_p,
    round(sum(total_users)::numeric/(SELECT count(DISTINCT id) FROM fantasy.events WHERE amount>0),5) AS sum_orders_users_p
FROM items
GROUP BY item_code, game_items
ORDER BY sum_orders_item desc
LIMIT 10;
/* Самым популярным предмет среди игроков является Book of Legends:
 * 	всего продано 1004516 единиц (что составляет 0.7687 от общих продаж и популярно у 0.88414 пользователей
 * 	
item_code|game_items          |sum_orders_item|sum_orders_item_p|sum_orders_users_p|
---------+--------------------+---------------+-----------------+------------------+
     6010|Book of Legends     |        1004516|          0.76870|           0.88414|
     6011|Bag of Holding      |         271875|          0.20805|           0.86775|
     6012|Necklace of Wisdom  |          13828|          0.01058|           0.11797|
     6536|Gems of Insight     |           3833|          0.00293|           0.06714|
     5964|Treasure Map        |           3084|          0.00236|           0.05460|
     4112|Amulet of Protection|           1078|          0.00082|           0.03227|
     5411|Silver Flask        |            795|          0.00061|           0.04590|
     5691|Strength Elixir     |            580|          0.00044|           0.02400|
     5541|Glowing Pendant     |            563|          0.00043|           0.02567|
     5999|Gauntlets of Might  |            514|          0.00039|           0.02037|
 */

-- Часть 2. Решение ad hoc-задач
-- Задача 1. Зависимость активности игроков от расы персонажа:
WITH race_user AS(  -- распределение игроков по расам
	SELECT 
		r.race_id AS race_id, --ключ
		r.race AS race, --имя расы
		count(u.id) AS race_user --кол-во игроков
	FROM fantasy.race AS r
	LEFT JOIN fantasy.users AS u ON r.race_id=u.race_id 
	GROUP BY r.race_id
),
race_user_payer AS( --расчет платящих игроков
	SELECT 
		r.race_id AS race_id, --ключ
		sum(u.payer) AS race_user_payer --платящие игроки	
	FROM fantasy.race AS r
	LEFT JOIN fantasy.users AS u ON r.race_id=u.race_id
	GROUP BY r.race_id
),
race_user_events AS( --расчет игроков совершающих покупки
	SELECT 
		u.race_id AS race_id, --ключ
		count(DISTINCT e.id) AS race_user, --кол-во совершивших покупки
		count(DISTINCT e.id) FILTER (WHERE u.payer = 1) AS race_user_payer, --кол-во платящих совершивших покупки
		count(e.transaction_id) AS race_trans, -- кол-во покупок
		sum(e.amount) AS race_amount_sum, -- сумма покупок
		avg(e.amount::numeric) AS race_amount_avg --средняя стоимость покупок
	FROM fantasy.users AS u
	LEFT JOIN fantasy.events AS e ON e.id=u.id 
	WHERE e.amount>0
	GROUP BY u.race_id
)
SELECT 
	u.race, -- название расы
	u.race_user AS race_user_all,--общее количество зарегистрированных игроков
	e.race_user AS race_user_events, --количество игроков, которые совершают внутриигровые покупки
	race_user_events/race_user_all AS race_user_payer, -- колличество платящих игроков
	round(e.race_user_payer::numeric/e.race_user,5) AS race_user_payer_p,--доля игроков, которые совершают внутриигровые покупки от общего количества
	round(p.race_user_payer::numeric/e.race_trans,4) AS user_payer_trans_p,--доля платящих игроков от количества игроков, которые совершили покупки
	round(e.race_trans::numeric/e.race_user,2)  AS race_user_event,-- среднее количество покупок на одного игрока
	round(e.race_amount_avg,4)  AS race_user_one_amount,--средняя стоимость одной покупки на одного игрока
	round(e.race_amount_sum::numeric/e.race_user)  AS race_user_sum_amount --средняя суммарная стоимость всех покупок на одного игрока
FROM race_user AS u
LEFT JOIN race_user_payer AS p ON p.race_id=u.race_id
LEFT JOIN race_user_events AS e ON e.race_id=u.race_id
ORDER BY race_user_payer desc
/*Игроки рассы Human чаще прибегают к покупке эпических предметов, при этом колличество платящих пользователей выше чем у игроков других расс.
race    |race_user_all|race_user_events|race_user_payer|race_user_payer_p|user_payer_trans_p|race_user_event|race_user_one_amount|race_user_sum_amount|
--------+-------------+----------------+---------------+-----------------+------------------+---------------+--------------------+--------------------+
Human   |         6328|            3921|           1114|          0.18006|            0.0023|         121.40|            403.1308|               48935|
Hobbit  |         3648|            2266|            659|          0.17696|            0.0034|          86.13|            552.9032|               47622|
Orc     |         3619|            2276|            636|          0.17399|            0.0034|          81.74|            510.9003|               41761|
Northman|         3562|            2229|            626|          0.18214|            0.0034|          82.10|            761.5013|               62518|
Elf     |         2501|            1543|            427|          0.16267|            0.0035|          78.79|            682.3348|               53762|
Demon   |         1229|             737|            238|          0.19946|            0.0041|          77.87|            529.0551|               41195|
Angel   |         1327|             820|            229|          0.16707|            0.0026|         106.80|            455.6782|               48666|
 */
-- Задача 2: Частота покупок
-- Напишите ваш запрос здесь
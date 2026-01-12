
/* Получение общих данных
Вычислите общие значения ключевых показателей сервиса за весь период:
1. общая выручка с заказов total_revenue;
2. количество заказов total_orders;
3. средняя стоимость заказа avg_revenue_per_order;
4. общее число уникальных клиентов total_users.

Напишите запрос для вычисления этих значений. 
Поскольку данные представлены в российских рублях и казахстанских тенге, то значения посчитайте в разрезе каждой валюты (поле currency_code). 
Результат отсортируйте по убыванию значения в поле total_revenue.
 */
select 
    currency_code,
    sum(revenue) as total_revenue,
    count(*) as total_orders,
    avg(revenue) as avg_revenue_per_order,
    count(distinct user_id) as total_users
from afisha.purchases
Group by currency_code
order by total_revenue DESC
/*
currency_code|total_revenue|total_orders|avg_revenue_per_order|total_users|
-------------+-------------+------------+---------------------+-----------+
rub          |    157127696|      286961|     547.570922412914|      21422|
kzt          |     25341034|        5073|    4995.309819793927|       1362|
*/

/*Изучение распределения выручки в разрезе устройств
Для заказов в рублях вычислите распределение выручки и количества заказов по типу устройства device_type_canonical. Результат должен включать поля:
1. тип устройства device_type_canonical;
2. общая выручка с заказов total_revenue;
3. количество заказов total_orders;
4. средняя стоимость заказа avg_revenue_per_order;
5. доля выручки для каждого устройства от общего значения revenue_share, округлённая до трёх знаков после точки.

Результат отсортируйте по убыванию значения в поле revenue_share.
*/
SELECT 
	device_type_canonical,
	sum(revenue) AS total_revenue,
	count(*) AS total_orders,
	avg(revenue) AS avg_revenue_per_order,
	round(sum(revenue)::numeric / (SELECT sum(revenue) FROM afisha.purchases WHERE currency_code = 'rub')::numeric,3) AS revenue_share
FROM afisha.purchases
WHERE currency_code = 'rub'
GROUP BY device_type_canonical
ORDER BY revenue_share DESC 
/*
device_type_canonical|total_revenue|total_orders|avg_revenue_per_order|revenue_share|
---------------------+-------------+------------+---------------------+-------------+
mobile               |    124633528|      229021|    544.1976894989267|        0.793|
desktop              |     31851612|       56759|    561.1687862756498|        0.203|
tablet               |     640988.7|        1176|    545.0581287524733|        0.004|
other                |    5133.7603|           2|   2566.8800659179688|        0.000|
tv                   |      1299.16|           3|    433.0533447265625|        0.000|
*/

/*Изучение распределения выручки в разрезе типа мероприятий
Для заказов в рублях вычислите распределение количества заказов и их выручку в зависимости от типа мероприятия event_type_main. Результат должен включать поля:
1. тип мероприятия event_type_main;
2. общая выручка с заказов total_revenue;
3. количество заказов total_orders;
4. средняя стоимость заказа avg_revenue_per_order;
5. уникальное число событий total_event_name (по их коду event_name_code);
6. среднее число билетов в заказе avg_tickets;
7. средняя выручка с одного билета avg_ticket_revenue;
8. доля выручки от общего значения revenue_share, округлённая до трёх знаков после точки.

Результат отсортируйте по убыванию значения в поле total_orders.
*/
SELECT 
	event_type_main,
	sum(revenue) AS total_revenue,
	count(*) AS total_orders,
	avg(revenue) AS avg_revenue_per_order,
	count(DISTINCT event_name_code) AS total_event_name,
	avg (tickets_count) AS avg_tickets,
	sum(revenue)/sum (tickets_count) AS avg_ticket_revenue,
	round(sum(revenue)::numeric / (SELECT sum(revenue) FROM afisha.purchases WHERE currency_code = 'rub')::numeric,3) AS revenue_share
FROM afisha.purchases p
JOIN afisha.events e ON p.event_id = e.event_id 
WHERE currency_code = 'rub'
GROUP BY event_type_main
ORDER BY total_orders DESC
/*
event_type_main|total_revenue|total_orders|avg_revenue_per_order|total_event_name|avg_tickets       |avg_ticket_revenue|revenue_share|
---------------+-------------+------------+---------------------+----------------+------------------+------------------+-------------+
концерты       |     88705888|      112418|    789.0850212149544|            6014|2.6570389083598712| 296.9741713229706|        0.565|
театр          |     37141508|       67733|    548.3568227249012|            4352|2.7600726381527468|198.67293578963134|        0.236|
другое         |     15579770|       64572|   241.28204110350754|            3807|2.7648361518924611| 87.26646912861072|        0.099|
спорт          |    3466692.5|       21700|   159.75414450427698|             785|3.0534101382488479|52.320326295295736|        0.022|
стендап        |    9547284.0|       13421|    711.3644202233036|             420|2.9919529096192534|237.76077698916697|        0.061|
выставки       |    1135891.2|        4873|   233.10002582614584|             279|2.5581777139339216|  91.1191440718755|        0.007|
ёлки           |    1549356.2|        2006|    772.3603511403351|             173|3.3424725822532403| 231.0747576435496|        0.010|
фильм          |    3084.8103|         238|   12.961386680603027|              19|2.6554621848739496|4.8810289600227454|        0.000|
*/

/*Динамика изменения значений
На дашборде понадобится показать динамику изменения ключевых метрик и параметров. 
Для заказов в рублях вычислите изменение выручки, количества заказов, уникальных клиентов и средней стоимости одного заказа в недельной динамике. 
Результат должен включать поля:
1. неделя week;
2. суммарная выручка total_revenue;
3. число заказов total_orders;
4. уникальное число клиентов total_users;
5. средняя стоимость одного заказа revenue_per_order.

Результат отсортируйте по возрастанию значения в поле week.
*/
SELECT 
	date(DATE_TRUNC('week', created_dt_msk)) AS week,
	sum(revenue) AS total_revenue,
	count(*) AS total_orders,
	count(DISTINCT user_id) AS total_users,
	sum(revenue)/count(*) AS revenue_per_order
FROM afisha.purchases
WHERE currency_code = 'rub'
GROUP BY week
ORDER BY week ASC
/*
week      |total_revenue|total_orders|total_users|revenue_per_order |
----------+-------------+------------+-----------+------------------+
2024-05-27|     911625.9|        2024|        805| 450.4080410079051|
2024-06-03|    3989500.5|        7589|       2238| 525.6951508762683|
2024-06-10|    4160547.8|        7431|       2153|  559.890694388373|
2024-06-17|    4612199.0|        8043|       2143| 573.4426209125947|
2024-06-24|    4243705.5|        7362|       2032| 576.4337815810921|
2024-07-01|    5159806.0|        8995|       2296| 573.6304613674264|
2024-07-08|    5511003.0|        8980|       2310| 613.6974387527839|
2024-07-15|    5580827.0|        8836|       2406| 631.6010638297872|
2024-07-22|    5457100.5|        9347|       2421| 583.8344388573873|
2024-07-29|    5846351.5|       10536|       2492|  554.892891040243|
2024-08-05|    6235606.0|        9642|       2546| 646.7129226301597|
2024-08-12|    6081589.5|        9719|       2596| 625.7423088795143|
2024-08-19|    5823015.0|       10488|       2654| 555.2073798627002|
2024-08-26|    5701570.0|       10157|       2527| 561.3439007580979|
2024-09-02|    6926391.0|       15642|       3075|  442.807249712313|
2024-09-09|    8349255.5|       15706|       3431| 531.5965554565134|
2024-09-16|    9044691.0|       16599|       3509| 544.8937285378637|
2024-09-23|    9865459.0|       17554|       3768| 562.0063233451066|
2024-09-30|     11440944|       23031|       4071|496.76279796795626|
2024-10-07|     10978287|       19420|       4118| 565.3082904222451|
2024-10-14|     12096930|       22438|       4420| 539.1269275336483|
2024-10-21|     12207004|       22810|       4475| 535.1601928978519|
2024-10-28|    6907834.5|       14612|       3019|472.75078702436355|
*/

/*Выделение топ-сегментов
Выведите топ-7 регионов по значению общей выручки, включив только заказы за рубли. Результат должен включать поля:
1. название региона region_name;
2. суммарная выручка total_revenue;
3. число заказов total_orders;
4. уникальное число клиентов total_users;
5. количество проданных билетов total_tickets;
6. средняя стоимость одного билета one_ticket_cost.

Результат отсортируйте по убыванию значения в поле total_revenue.
*/
SELECT 
	region_name,
	sum(revenue) AS total_revenue,
	count(*) AS total_orders,
	count(DISTINCT user_id) AS total_users,
	sum(tickets_count) AS total_tickets,
	sum(revenue)/sum (tickets_count) AS one_ticket_cost
FROM afisha.purchases p
JOIN afisha.events e ON p.event_id = e.event_id 
JOIN afisha.city c ON e.city_id = c.city_id 
JOIN afisha.regions r ON c.region_id = r.region_id
WHERE currency_code = 'rub'
GROUP BY region_name
ORDER BY total_revenue DESC 
LIMIT 7
/*
region_name         |total_revenue|total_orders|total_users|total_tickets|one_ticket_cost   |
--------------------+-------------+------------+-----------+-------------+------------------+
Каменевский регион  |     61555620|       91634|      10646|       253393|242.92549517942484|
Североярская область|     25453278|       44282|       6735|       125204|203.29444746174244|
Озернинский край    |    9793623.0|       10502|       2488|        29621| 330.6310725498802|
Широковская область |    9543781.0|       16538|       3278|        46977|203.15858824531153|
Малиновоярский округ|    5955931.0|        6634|       1902|        17465| 341.0209561981105|
Яблоневская область |    3692400.0|        6197|       1431|        16589|222.58122852492616|
Светополянский округ|    3425873.8|        7632|       1683|        20434|167.65556180875012|
*/


SELECT seed.id, level.name      AS level,
       item.name       AS name,
       item_seen.price AS price,
       item.class,
       item.subtype,
       item.basename
FROM item_seen
         JOIN
     seed ON item_seen.seed_id = seed.id
         JOIN
     item ON item_seen.item_id = item.id
         JOIN
     level ON item_seen.level_id = level.id
         LEFT OUTER JOIN
     artprops ON item.id = artprops.item_id
WHERE item.unrand
  AND level.id < 55
  AND item_seen.seed_id IN (2000)
--  AND price = 0
--  GROUP BY item.id, price
GROUP BY item.id, seed_id
ORDER BY seed.id, level.id
LIMIT 200
;

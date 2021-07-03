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
WHERE item.artefact
  AND level.id < 25
--  AND item_seen.seed_id IN (645, 936, 985, 1309)
  AND item.class != 'Books'
  AND price = 0
--GROUP BY item.id, seed_id
ORDER BY level.id, seed.id
;

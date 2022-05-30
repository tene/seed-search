SELECT seed.id, level.name      AS level,
       item.unrand * 999 as ur,
       item.name       AS item,
       item_seen.price AS price,
       item.plus,
       item.ego        as ego,
       item.damage,
       item.delay,
       item.weap_skill,
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
WHERE level.id < 25
  --AND item_seen.seed_id IN (723, 987, 1131, 1216)
  --AND item.name LIKE '%regen%'
  AND item.basename = 'robe of Vines'
  AND item_seen.price = 0
GROUP BY seed.id, item.id
ORDER BY level.id asc, seed_id;
;

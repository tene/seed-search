SELECT item_seen.seed_id as seed_id,
       level.name      AS level,
       item.name       AS item,
       item_seen.price AS price,
       item.plus,
       item.ego        as ego,
       item.ac as ac,
       item.encumbrance as weight,
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
WHERE item_seen.seed_id IN (10)
  AND level.id < 12
  AND class = "Armour"
  AND (
        ego is not null
        OR plus > 2
     OR item.artefact
      OR item.name like '%troll%'
      OR item.name like '%dragon%'
      OR item.name like '%crystal%'
    )
GROUP BY seed_id, item.id
ORDER BY seed_id, level.id;
;

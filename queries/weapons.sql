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
WHERE item_seen.seed_id IN (63)
  AND level.id < 25
  AND class = "Hand Weapons"

  AND (
        (item.plus > 2 AND ego is not null) OR
        item.ego IN ("electrocution", "holy wrath", "pain", "vampirism")
        OR item.basename IN
           ("quick blade", "demon whip", "demon trident", "demon blade", "double sword", "triple sword", "triple crossbow",
            "eveningstar", "executioner's axe", "lajatang", "broad axe")
      OR item.artefact
    )
GROUP BY seed.id, item.id
ORDER BY seed.id, level.id;
;

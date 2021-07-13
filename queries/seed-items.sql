SELECT level.name      AS level,
       item.name       AS item,
       item.ego,
       item_seen.price AS price,
       spell_book.spell,
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
         LEFT OUTER JOIN
     spell_book ON item.id = spell_book.item_id
WHERE seed.seed_text IN ('1999')
  AND level.id < 25
  AND (item.artefact = true OR
       item.class IN ('Jewellery') OR
--        item.class IN ('Books') OR
       item.subtype IN ("acquirement", "experience", "mutation") OR
       item.ego IN ("electrocution", "holy wrath", "pain", "vampirism")
    OR item.basename IN
       ("quick blade", "demon whip", "demon trident", "demon blade", "double sword", "triple sword",
        "triple crossbow", "eveningstar", "executioner's axe", "lajatang", "broad axe", "boots", 'gloves') OR
       item.plus > 2 OR
       (item.ego IS NOT NULL AND
        (item.plus > 0 OR
         item.basename IN ("robe")
            )))
GROUP BY item.id,
         spell_book.spell
ORDER BY level.id;
;

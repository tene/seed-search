SELECT level.name AS level,
       item.name AS item,
       item.plus,
       item.ego,
       item_seen.price AS price,
       spell_book.spell,
       item.class,
       item.subtype,
       item.basename, item.*
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
 WHERE item_seen.seed_id = 78 AND 
       level.id < 99 AND
       class = "Hand Weapons" AND
       (
           item.unrand OR
           (item.plus > 2 AND
          item.ego IN ("electrocution", "holy wrath", "pain", "vorpality", "vampirism")) OR
            item.basename IN ("quick blade", "demon whip", "demon trident", "demon blade", "triple sword", "triple crossbow", "eveningstar", "executioner's axe", "lajatang", "broad axe") OR
           item.name like '%broad%'
       )
 GROUP BY item.id,
          spell_book.spell
 ORDER BY level.id;

;

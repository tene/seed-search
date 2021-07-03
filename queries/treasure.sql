SELECT seed.id,
       level.name AS level,
       level.id AS depth,
       item.name AS item,
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
 WHERE level_id < 52 AND
 seed_text = '85' AND
        item.subtype IN ("acquirement")
--        item.subtype IN ("acquirement", "experience", "mutation")
 --GROUP BY item.id
 ORDER BY seed.id, level.id;

;

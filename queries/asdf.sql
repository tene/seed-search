SELECT seed.seed_text AS s,
                  seed.id AS id,
                  level.name AS l,
                  item.name AS item,
                  item_seen.price AS price,
				  plus, basename,
				  ego
             FROM item_seen
                  JOIN
                  seed ON item_seen.seed_id = seed.id
                  JOIN
                  item ON item_seen.item_id = item.id
                  JOIN
                  level ON item_seen.level_id = level.id
            WHERE item.basename IN (
                      SELECT name
                        FROM weapons
                  )
OR
                  (price = 0 AND
                  ego is not null AND
                   level.id < 12 AND (
                       plus > 6 OR (plus > 2 AND item.ego IN ("electrocution", "holy wrath", "pain","vampirism"))
					   OR item.basename IN ("quick blade", "demon whip", "demon trident", "demon blade", "triple sword", "triple crossbow", "eveningstar", "executioner's axe", "lajatang", "broad axe")
                   ))
            ORDER BY level.id
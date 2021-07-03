select
item.id,
                item_seen.seed_id as seed_id,
--                seed.seed_text    as seed_text,
level.name     as level,
--                level.id          as depth,
--                item_seen.price   as price,
CASE
    WHEN item_seen.price = 0
        THEN ''
    ELSE printf(" [%dG]", item_seen.price)
    END        AS price_tag,
item.name      as name,
item.basename  as basename,
artprops.prop  as prop,
artprops.value as value
--            group_concat(printf("[%s: %s]",  level.name,item_seen.seed_id)) as levels
--            group_concat(level.name, ", ") as depths,
--            "(" || group_concat(item_seen.seed_id, ", ") || ")" as seeds
from item_seen
         join seed on item_seen.seed_id = seed.id
         join item on item_seen.item_id = item.id
         join level on item_seen.level_id = level.id
         left outer join artprops on item_seen.item_id = artprops.item_id
where (item.class = 'Jewellery'
    )
  AND level.id < 12
  AND item.artefact = true
--           AND price = 0
-- order by seed.id, level.id
limit 500

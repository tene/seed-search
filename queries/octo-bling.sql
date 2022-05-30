select item.id,
       item_seen.seed_id as seed_id,
--                seed.seed_text    as seed_text,
       level.name        as level,
--                level.id          as depth,
--                item_seen.price   as price,
       CASE
           WHEN item_seen.price = 0
               THEN ''
           ELSE printf(" [%dG]", item_seen.price)
           END           AS price_tag,
       item.name         as name,
       item.basename     as basename,
       artprops.prop     as prop,
       artprops.value    as value
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
limit 500;

select --seed_id                                                               as id,
       seed_text                                                          as seed,
       level                                                              as l,
       sum(price)                                                         as total,
       count(*)                                                           as x,
       sum(artefact) as arts,
       group_concat(printf('%s%s %s', level, price_tag, label), char(13)) as items

FROM (
         select item_seen.seed_id as seed_id,
                seed.seed_text    as seed_text,
                level.name        as level,
                level.id          as depth,
                item_seen.price   as price,
                CASE
                    WHEN item_seen.price = 0
                        THEN ''
                    ELSE printf(" [%dG]", item_seen.price)
                    END           AS price_tag,
                item.name         as name,
                item.basename     as basename,
                item.class,
                item.subtype,
                item.artefact as artefact,
                CASE
                    WHEN item.unrand = true
                        THEN item.basename
                    ELSE item.name
                    END           AS label,
                item_seen.id      as item_seen_id
--            group_concat(printf("[%s: %s]",  level.name,item_seen.seed_id)) as levels
--            group_concat(level.name, ", ") as depths,
--            "(" || group_concat(item_seen.seed_id, ", ") || ")" as seeds
         from item_seen
                  join seed on item_seen.seed_id = seed.id
                  join item on item_seen.item_id = item.id
                  join level on item_seen.level_id = level.id
         where (
             item.basename = 'ring'
             --item.class = 'Jewellery'
                --OR
                --item.basename like 'hat%' OR
                --item.basename like 'shield%'
             )
           AND level.id < 6
           AND price = 0
         order by seed.id, level.id
     )
group by seed_id
order by --count(*) desc,
         count(*) desc,
         sum(artefact),
         min(depth) asc,
         avg(depth) asc
;

select * from item where class = 'Jewellery';
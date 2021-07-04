select seed_id                                                           as id,
       seed_text                                                         as seed,
       level                                                             as l,
       sum(price)                                                        as total,
       count(*)                                                          as x,
       group_concat(printf('%s%s %s', level, price_tag, name), char(13)) as items

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
                item.basename     as basename
                ,item_seen.id  as item_seen_id
--            group_concat(printf("[%s: %s]",  level.name,item_seen.seed_id)) as levels
--            group_concat(level.name, ", ") as depths,
--            "(" || group_concat(item_seen.seed_id, ", ") || ")" as seeds
         from item_seen
                  join seed on item_seen.seed_id = seed.id
                  join item on item_seen.item_id = item.id
                  join level on item_seen.level_id = level.id
         where (false
             OR item.basename IN (select name from fun)
             OR (item.unrand = true AND item_seen.price = 0)
             OR item.artefact = true
             )
           AND seed_id IN (
             select distinct(seed_id)
             from item_seen
                      join item on item_seen.item_id = item.id
             where item.basename IN
                   ('robe of Vines'
                       --,'sceptre of Torment', 'demon trident "Rift"', 'scales of the Dragon King'
                       --,'mithril axe "Arga"', 'Elemental Staff', 'lance "Wyrmbane"', 'shield of Resistance',
                       --'Vampire''s Tooth'
                       )
               AND price = 0
               AND level_id < 10
         )
           AND level.id < 52
           AND price = 0
         order by seed.id, level.id
     )
group by seed_id
order by count(*) desc, min(depth) asc, avg(depth) asc
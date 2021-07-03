select seed.seed_text,
       count(*)             as num,
       sum(item.artefact)   as num_arts,
       sum(item_seen.price) as total,
       group_concat(
               printf("%s [%d] %s", level.name, price, item.basename),
               ", "
           )
from item_seen its
         join seed on item_seen.seed_id = seed.id
         join item on item_seen.item_id = item.id
         join level on item_seen.level_id = level.id
where (
        item.basename in ('robe of Night', 'hood of the Assassin')
--        OR ( item.ego = 'shadows' and price = 0)
        OR (item.ego = 'shadows')
--        OR ( item.name = "scarf of shadows" and price = 0)
        OR item.basename = 'demon trident "Rift"'
        OR item.name like '%Umbra%'
    )
  AND level.id < 52
group by seed.id
order by num_arts desc,
--         num desc,
         avg(level.id) asc;

select printf('|%s|%s|%s|%s|%s|%s|', seed_text,
              scarfs,
              robes,
              hoods,
              rifts,
              rings
           )
from (select seed_text,
             (select printf('%s [%d]', level.name, item_seen.price)
              from item_seen
                       join item on item_seen.item_id = item.id
                       join level on item_seen.level_id = level.id
              where seed_id = S.id
                AND item.name = '+2 hood of the Assassin {Detection Stab+ Stlth++}'
              order by level_id asc
              limit 1
             ) as hoods,
             (select printf('%s [%d]', level.name, item_seen.price)
              from item_seen
                       join item on item_seen.item_id = item.id
                       join level on item_seen.level_id = level.id
              where seed_id = S.id
                AND item.name = 'scarf of shadows'
              order by level_id asc
              limit 1
             ) as scarfs,
             (select printf('%s [%d]', level.name, item_seen.price)
              from item_seen
                       join item on item_seen.item_id = item.id
                       join level on item_seen.level_id = level.id
              where seed_id = S.id
                AND item.name = '+5 robe of Night {Dark Will+ SInv}'
              order by level_id asc
              limit 1
             ) as robes,
             (select printf('%s [%d]', level.name, item_seen.price)
              from item_seen
                       join item on item_seen.item_id = item.id
                       join level on item_seen.level_id = level.id
              where seed_id = S.id
                AND item.name = 'ring of Shadows {Umbra +Inv Stlth+}'
              order by level_id asc
              limit 1
             ) as rings,
             (select printf('%s [%d]', level.name, item_seen.price)
              from item_seen
                       join item on item_seen.item_id = item.id
                       join level on item_seen.level_id = level.id
              where seed_id = S.id
                AND item.name = '+8 demon trident "Rift" {distort, reach+}'
              order by level_id asc
              limit 1
             ) as rifts
      from seed as S
      where S.id IN (select item_seen.seed_id as seed_id
                     from item_seen
                              join item on item_seen.item_id = item.id
                     where item.name IN
                           ('scarf of shadows', 'ring of Shadows {Umbra +Inv Stlth+}',
                            '+8 demon trident "Rift" {distort, reach+}',
                            '+2 hood of the Assassin {Detection Stab+ Stlth++}',
                            '+5 robe of Night {Dark Will+ SInv}'
                               )
                       AND level_id < 52
                     group by item_seen.seed_id

                     having sum(item.artefact) = 2
          order by avg(level_id) asc
      )
      group by seed_text
      having (
                     (robes is not null and hoods is not null)
                     OR (hoods is not null and scarfs is not null)
                     OR (scarfs is not null and robes is not null)
                 )
     )
;

select seed.seed_text,
       group_concat(printf('%s [%d]', level.name, its.price))
from seed
         join item_seen its on seed.id = its.seed_id
         join level on its.level_id = level.id
         left outer join item hoods
                         on its.item_id = hoods.id AND hoods.name = '+2 hood of the Assassin {Detection Stab+ Stlth++}'
         left outer join item scarfs on its.item_id = hoods.id AND scarfs.name = 'scarf of shadows'
         left outer join item rings on its.item_id = hoods.id AND rings.name = 'ring of Shadows {Umbra +Inv Stlth+}'
         left outer join item rifts
                         on its.item_id = hoods.id AND rifts.name = '"+8 demon trident ""Rift"" {distort, reach+}"'
         left outer join item robes on its.item_id = hoods.id AND robes.name = '+5 robe of Night {Dark Will+ SInv}'
group by seed_id
limit 20;
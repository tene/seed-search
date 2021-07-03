select
    seed.seed_text,
    group_concat(printf("%s %s", level.name, item.name))
from
    item_seen
    join seed on item_seen.seed_id = seed.id
    join item on item_seen.item_id = item.id
    join level on item_seen.level_id = level.id
where
    item.unrand = true
    and item_seen.level_id < 77
    and item.basename in (
        "demon trident ""Rift""",
        "robe of Night",
        "hood of the Assassin"
    )
group by
    seed.id;

select
    seed.seed_text,
    group_concat(printf("%s %s", level.name, item.name))
from
    item_seen
    join seed on item_seen.seed_id = seed.id
    join item on item_seen.item_id = item.id
    join level on item_seen.level_id = level.id
where
    item.unrand = true
    and level.id < 12
group by
    seed.id
order by
    min(level.id);

select
    seed,
    count(*) as num,
    group_concat(printf("%s %s", level, item))
from
    (
        select
            seed.seed_text as seed,
            level.name as level,
            level.id as depth,
            item.name as item
        from
            item_seen
            join seed on item_seen.seed_id = seed.id
            join item on item_seen.item_id = item.id
            join level on item_seen.level_id = level.id
        where
            item.unrand = true
            and level.id < 58
        order by
            level.id
    )
group by
    seed
order by
    min(depth),
    num;

select
    seed,
    group_concat(printf("%s %s", level, item))
from
    (
        select
            seed.seed_text as seed,
            level.name as level,
            level.id as depth,
            item.name as item
        from
            item_seen
            join seed on item_seen.seed_id = seed.id
            join item on item_seen.item_id = item.id
            join level on item_seen.level_id = level.id
        where
            item.unrand = true
            and level.id < 58
        order by
            level.id
    )
group by
    seed
order by
    min(depth),
    count(*)
limit
    20;

select
    seed,
    count(*),
    group_concat(printf("%s %s", level, item))
from
    (
        select
            seed.seed_text as seed,
            level.name as level,
            level.id as depth,
            item.name as item
        from
            item_seen
            join seed on item_seen.seed_id = seed.id
            join item on item_seen.item_id = item.id
            join level on item_seen.level_id = level.id
        where
            item_seen.price = 0
            AND item.basename = "ring"
            and level.id < 6
        order by
            depth asc
    )
group by
    seed
order by
    count(*) desc,
    min(depth)
limit
    10;

select
    seed,
    count(*),
    sum(price),
    group_concat(printf("%s %s [%d]", level, item, price))
from
    (
        select
            seed.seed_text as seed,
            level.name as level,
            level.id as depth,
            item.name as item,
            item_seen.price as price
        from
            item_seen
            join seed on item_seen.seed_id = seed.id
            join item on item_seen.item_id = item.id
            join level on item_seen.level_id = level.id
        where
            item.name like '%acquir%'
            AND level.id < 25
        order by
            level.id
    )
group by
    seed
order by
    count(*) desc,
    min(depth)
limit
    20;

select
    seed,
    level,
    price,
    name
from
    (
        select
            seed.seed_text as seed,
            level.name as level,
            level.id as depth,
            item.name as name,
            item_seen.price as price
        from
            item_seen
            join seed on item_seen.seed_id = seed.id
            join item on item_seen.item_id = item.id
            join level on item_seen.level_id = level.id
        where
            item.basename in (
                select
                    name
                from
                    fun
            )
            and price = 0
    )
order by
    depth desc;

select
    seed.seed_text,
    count(*) as num,
    sum(item_seen.price),
    group_concat(printf("%s %s", level.name, item.name))
from
    item_seen
    join seed on item_seen.seed_id = seed.id
    join item on item_seen.item_id = item.id
    join level on item_seen.level_id = level.id
where
    item.unrand = true
    and item.basename in (
        "demon trident ""Rift""",
        "robe of Night",
        "hood of the Assassin"
    )
group by
    seed.id
order by
    num asc,
    min(level.id) desc;

select
    seed,
    count(*),
    sum(price) as total,
    group_concat(printf("%s %s [%d]", level, item, price))
from
    (
        select
            seed.seed_text as seed,
            level.name as level,
            level.id as depth,
            item.name as item,
            item_seen.price as price
        from
            item_seen
            join seed on item_seen.seed_id = seed.id
            join item on item_seen.item_id = item.id
            join level on item_seen.level_id = level.id
        where
            item.basename IN (
                select
                    name
                from
                    weapons
            )
            AND level.id < 25
        order by
            level.id
    )
group by
    seed
order by
    count(*) desc,
    min(depth)
limit
    10;

select
    seed,
    count(*),
    group_concat(printf("%s %s", level, item))
from
    (
        select
            seed.seed_text as seed,
            level.name as level,
            level.id as depth,
            item.name as item,
            item_seen.price as price
        from
            item_seen
            join seed on item_seen.seed_id = seed.id
            join item on item_seen.item_id = item.id
            join level on item_seen.level_id = level.id
        where
            item.basename IN (
                select
                    name
                from
                    weapons
            )
            AND level.id < 25
            AND price = 0
        order by
            level.id
    )
group by
    seed
order by
    count(*) desc,
    min(depth)
limit
    10;

select
    seed.seed_text,
    count(*) as num,
    sum(item_seen.price),
    group_concat(
        printf("%s [%d] %s", level.name, price, item.name),
        ", "
    )
from
    item_seen
    join seed on item_seen.seed_id = seed.id
    join item on item_seen.item_id = item.id
    join level on item_seen.level_id = level.id
where
    (
        item.basename in ("robe of Night", "hood of the Assassin")
        OR item.name = "scarf of shadows"
    )
    and level.id < 25
group by
    seed.id
order by
    num asc,
    min(level.id) desc;

select
    seed.seed_text,
    count(*) as num,
    sum(item_seen.price),
    group_concat(
        printf("%s [%d] %s", level.name, price, item.name),
        ", "
    )
from
    item_seen
    join seed on item_seen.seed_id = seed.id
    join item on item_seen.item_id = item.id
    join level on item_seen.level_id = level.id
where
    (
        item.basename in ("robe of Night", "hood of the Assassin")
        OR item.name = "scarf of shadows"
    )
group by
    seed.id
order by
    num asc,
    min(level.id) desc;

select
    seed.seed_text,
    count(*) as num,
    sum(item_seen.price),
    group_concat(
        printf("%s [%d] %s", level.name, price, item.name),
        ", "
    )
from
    item_seen
    join seed on item_seen.seed_id = seed.id
    join item on item_seen.item_id = item.id
    join level on item_seen.level_id = level.id
where
    (
        item.basename in ("Black Knight's barding", "lightning scales")
        OR (
            item.name LIKE "%barding%"
            AND (
                item.artefact = true
                OR item.ego IS NOT NULL
            )
        )
    )
group by
    seed.id
order by
    num asc,
    min(level.id) desc;

select
    seed.seed_text,
    count(*) as num,
    sum(item_seen.price),
    group_concat(
        printf("%s [%d] %s", level.name, price, item.name),
        ", "
    )
from
    item_seen
    join seed on item_seen.seed_id = seed.id
    join item on item_seen.item_id = item.id
    join level on item_seen.level_id = level.id
    join artprops on artprops.item_id = item.id
where
    level.id < 12
    AND basename = "ring"
    AND prop = "Int"
    AND value > 4
group by
    seed.id
order by
    num asc,
    min(level.id) desc;

-----
create table fun_seed as
select
    distinct(item_seen.seed_id) as seed_id
from
    item_seen
    join item on item_seen.item_id = item.id
where
    item.basename in (
        select
            *
        from
            fun
    )
    AND item_seen.level_id < 25;

create table fun_seed as
select
    distinct(item_seen.seed_id) as seed_id
from
    item_seen
    join item on item_seen.item_id = item.id
where
    item.basename in (
        select
            *
        from
            fun
    )
    AND item_seen.level_id < 25;

FROM
    item_seen
    JOIN seed ON item_seen.seed_id = seed.id
    JOIN item ON item_seen.item_id = item.id
    JOIN level ON item_seen.level_id = level.id
WHERE
from
    item_seen
    join seed on item_seen.seed_id = seed.id
    join item on item_seen.item_id = item.id
    join level on item_seen.level_id = level.id
    join artprops on artprops.item_id = item.id
where
.import sweeks-fun-items.txt fun
.import sweeks-fun-weapons.txt weapons
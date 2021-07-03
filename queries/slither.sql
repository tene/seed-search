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
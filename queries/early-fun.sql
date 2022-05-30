select
    level,
    name,
    group_concat(printf("%s%s", level, price_tag), " ") as depths,
    "(" || group_concat(seed_id, ", ") || ")" as seed_ids
FROM
    (
        select
            item_seen.seed_id as seed_id,
            seed.seed_text as seed_text,
            level.name as level,
            level.id as depth,
            item_seen.price as price,
            CASE
                WHEN item_seen.price = 0 THEN ''
                ELSE printf("[%dG]", item_seen.price)
            END AS price_tag,
            item.name as name,
            item.basename as basename --            group_concat(printf("[%s: %s]",  level.name,item_seen.seed_id)) as levels
            --            group_concat(level.name, ", ") as depths,
            --            "(" || group_concat(item_seen.seed_id, ", ") || ")" as seeds
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
                    fun
            ) --AND level.id < 52
            AND price = 0 --and seed_text = '1999'
        order by
            item.name,
            level.id
    )
group by
    name
order by
    min(depth);
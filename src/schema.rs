table! {
    artprops (id) {
        id -> Integer,
        name -> Text,
        value -> Integer,
        item_id -> Integer,
    }
}

table! {
    item (id) {
        id -> Integer,
        name -> Text,
        basename -> Text,
        class -> Text,
        subtype -> Text,
        ego -> Nullable<Text>,
        ac -> Nullable<Integer>,
        accuracy -> Nullable<Integer>,
        damage -> Nullable<Integer>,
        delay -> Nullable<Integer>,
        encumbrance -> Nullable<Integer>,
        plus -> Nullable<Integer>,
        weap_skill -> Nullable<Text>,
        artefact -> Bool,
        unrand -> Bool,
    }
}

table! {
    item_seen (id) {
        id -> Integer,
        item_id -> Integer,
        level_id -> Integer,
        seed_id -> Integer,
        price -> Integer,
    }
}

table! {
    level (id) {
        id -> Integer,
        name -> Text,
    }
}

table! {
    seed (id) {
        id -> Integer,
        seed_text -> Text,
        version -> Text,
    }
}

joinable!(artprops -> item (item_id));
joinable!(item_seen -> item (item_id));
joinable!(item_seen -> level (level_id));
joinable!(item_seen -> seed (seed_id));

allow_tables_to_appear_in_same_query!(
    artprops,
    item,
    item_seen,
    level,
    seed,
);

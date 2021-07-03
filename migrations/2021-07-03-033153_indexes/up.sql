-- -- Your SQL goes here
-- CREATE TABLE item (
--     id INTEGER PRIMARY KEY NOT NULL,
--     name TEXT NOT NULL UNIQUE ON CONFLICT IGNORE,
--     basename TEXT NOT NULL,
--     class TEXT NOT NULL,
--     subtype TEXT NOT NULL,
--     ego TEXT,
--     ac INTEGER,
--     accuracy INTEGER,
--     damage INTEGER,
--     delay INTEGER,
--     encumbrance INTEGER,
--     plus INTEGER,
--     weap_skill TEXT,
--     artefact BOOLEAN NOT NULL DEFAULT false,
--     unrand BOOLEAN NOT NULL DEFAULT false
-- );
-- CREATE TABLE level (
--     id INTEGER PRIMARY KEY NOT NULL,
--     name TEXT NOT NULL UNIQUE
-- );
-- CREATE TABLE spell_book (
--     id INTEGER PRIMARY KEY NOT NULL,
--     item_id INTEGER NOT NULL REFERENCES item(id),
--     spell TEXT NOT NULL
-- );
-- CREATE TABLE artprops (
--     id INTEGER PRIMARY KEY NOT NULL,
--     item_id INTEGER NOT NULL REFERENCES item(id),
--     prop TEXT NOT NULL,
--     value INTEGER NOT NULL
-- );
-- CREATE TABLE item_seen (
--     id INTEGER PRIMARY KEY NOT NULL,
--     item_id INTEGER NOT NULL REFERENCES item(id),
--     level_id INTEGER NOT NULL REFERENCES level(id),
--     seed_id INTEGER NOT NULL REFERENCES seed(id),
--     price INTEGER NOT NULL DEFAULT 0
-- );
CREATE INDEX item_seen_seed_item ON item_seen(seed_id, item_id);

CREATE INDEX item_seen_item_seed ON item_seen(item_id, seed_id);

CREATE INDEX item_seen_seed_item_level ON item_seen(seed_id, item_id, level_id);

CREATE INDEX item_seen_item_seed_level ON item_seen(item_id, seed_id, level_id);

CREATE INDEX item_name ON item(name);

CREATE INDEX item_basename ON item(basename);

CREATE INDEX item_class ON item(class);

CREATE INDEX item_subtype ON item(subtype);

CREATE INDEX item_ego ON item(ego);

--     artefact BOOLEAN NOT NULL DEFAULT false,
--     unrand BOOLEAN NOT NULL DEFAULT false
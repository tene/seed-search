use super::schema::item;
use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, Debug, Queryable)]
pub struct Seed {
    pub id: i32,
    pub seed_text: String,
    pub version: String,
}

#[derive(Serialize, Deserialize, Debug, Queryable)]
pub struct Item {
    pub id: i32,
    pub name: String,               // TEXT NOT NULL,
    pub basename: String,           // TEXT NOT NULL,
    pub class: String,              // TEXT NOT NULL,
    pub subtype: String,            // TEXT NOT NULL,
    pub ego: Option<String>,        // TEXT,
    pub ac: Option<i32>,            // INTEGER,
    pub accuracy: Option<i32>,      // INTEGER,
    pub damage: Option<i32>,        // INTEGER,
    pub delay: Option<i32>,         // INTEGER,
    pub encumbrance: Option<i32>,   // INTEGER,
    pub plus: Option<i32>,          // INTEGER,
    pub weap_skill: Option<String>, // TEXT,
    pub artefact: bool,             // BOOLEAN NOT NULL,
    pub unrand: bool,               // BOOLEAN NOT NULL
}

#[derive(Insertable)]
#[table_name = "item"]
pub struct NewItem {
    pub name: String,               // TEXT NOT NULL,
    pub basename: String,           // TEXT NOT NULL,
    pub class: String,              // TEXT NOT NULL,
    pub subtype: String,            // TEXT NOT NULL,
    pub ego: Option<String>,        // TEXT,
    pub ac: Option<i32>,            // INTEGER,
    pub accuracy: Option<i32>,      // INTEGER,
    pub damage: Option<i32>,        // INTEGER,
    pub delay: Option<i32>,         // INTEGER,
    pub encumbrance: Option<i32>,   // INTEGER,
    pub plus: Option<i32>,          // INTEGER,
    pub weap_skill: Option<String>, // TEXT,
    pub artefact: bool,             // BOOLEAN NOT NULL,
    pub unrand: bool,               // BOOLEAN NOT NULL
}

#[derive(Serialize, Deserialize, Debug, Queryable)]
pub struct Level {
    pub id: i32,
    pub name: String,
}

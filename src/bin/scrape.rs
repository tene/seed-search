extern crate diesel;
extern crate seed_search;

use self::diesel::prelude::*;
use self::models::*;
use self::seed_search::*;

use std::collections::HashMap;
use std::process::Command;

use anyhow;
use diesel::insert_into;
use serde::{Deserialize, Serialize};
use serde_json;

#[derive(Serialize, Deserialize, Debug)]
pub struct Record {
    pub level: String,
    pub name: String,
    pub basename: String,
    pub class: String,
    pub subtype: String,
    pub ego: Option<String>,
    pub ac: Option<i32>,
    pub accuracy: Option<i32>,
    pub damage: Option<i32>,
    pub delay: Option<i32>,
    pub encumbrance: Option<i32>,
    pub plus: Option<i32>,
    pub weap_skill: Option<String>,
    #[serde(default)]
    pub artefact: bool,
    #[serde(default)]
    pub unrand: bool,
    pub price: Option<i32>,
    pub artprops: Option<HashMap<String, i32>>,
    pub spells: Option<HashMap<i32, String>>, // XXX TODO Vec<String>
}

impl Record {
    pub fn new_item(&self) -> NewItem {
        NewItem {
            name: self.name.clone(),
            basename: self.basename.clone(),
            class: self.class.clone(),
            subtype: self.subtype.clone(),
            ego: self.ego.clone(),
            ac: self.ac.clone(),
            accuracy: self.accuracy.clone(),
            damage: self.damage.clone(),
            delay: self.delay.clone(),
            encumbrance: self.encumbrance.clone(),
            plus: self.plus.clone(),
            weap_skill: self.weap_skill.clone(),
            artefact: self.artefact.clone(),
            unrand: self.unrand.clone(),
        }
    }
}

pub struct Scribe {
    conn: SqliteConnection,
    item_ids: HashMap<String, i32>,
    level_ids: HashMap<String, i32>,
}

impl Scribe {
    pub fn new() -> Self {
        use schema::{item, level};
        let mut conn = establish_connection();
        let item_ids = item::table
            .select((item::name, item::id))
            .load(&mut conn)
            .expect("Failed to load items")
            .into_iter()
            .collect();
        let level_ids = level::table
            .select((level::name, level::id))
            .load(&mut conn)
            .expect("Failed to load items")
            .into_iter()
            .collect();
        Self {
            conn,
            item_ids,
            level_ids,
        }
    }
    pub fn find_or_insert_item(&mut self, rec: &Record) -> anyhow::Result<i32> {
        match self.item_ids.get(&rec.name) {
            Some(id) => Ok(*id),
            None => {
                use schema::item::dsl::*;
                println!("New Item: {}", rec.name);
                insert_into(item)
                    .values(rec.new_item())
                    .execute(&mut self.conn)?;
                let new_id = item
                    .select(id)
                    .filter(name.eq(rec.name.as_str()))
                    .first::<i32>(&mut self.conn)?;
                self.item_ids.insert(rec.name.clone(), new_id);
                Ok(new_id)
            }
        }
    }
    pub fn allocate_seed_id(&mut self, seed: &String) -> anyhow::Result<i32> {
        // XXX TODO read version from `crawl -version`
        let version_name = "0.27-a0-1380-gf508b8f851";
        use schema::seed;
        let seed_id: i32 = match seed::table
            .select(seed::id)
            .filter(seed::seed_text.eq(seed))
            .filter(seed::version.eq(version_name))
            .first::<i32>(&mut self.conn)
        {
            // skip already-processed seeds
            Ok(id) => {
                return Ok(id);
            }
            Err(_) => {
                insert_into(seed::table)
                    .values((&seed::version.eq(version_name), &seed::seed_text.eq(seed)))
                    .execute(&mut self.conn)?;
                seed::table
                    .filter(seed::version.eq(version_name))
                    .filter(seed::seed_text.eq(seed))
                    .select(seed::id)
                    .first(&mut self.conn)?
            }
        };
        Ok(seed_id)
    }
    pub fn scrape(&mut self, seed: &String) -> anyhow::Result<()> {
        use schema::*;
        let seed_id = self.allocate_seed_id(seed)?;
        let output = Command::new("scripts/run-scrape.sh").arg(seed).output()?;
        let records = serde_json::Deserializer::from_slice(&output.stdout).into_iter::<Record>();
        for rec in records {
            let rec = match rec {
                Ok(rec) => rec,
                Err(e) => {
                    println!("Warning: {}", e);
                    continue;
                }
            };
            //println!("{:?}", rec);
            let level_id = *self.level_ids.get(&rec.level).expect("Missing level id");
            let item_id = self.find_or_insert_item(&rec)?;
            insert_into(item_seen::table)
                .values((
                    item_seen::item_id.eq(item_id),
                    item_seen::level_id.eq(level_id),
                    item_seen::seed_id.eq(seed_id),
                    item_seen::price.eq(rec.price.unwrap_or_default()),
                ))
                .execute(&mut self.conn)?;
        }
        Ok(())
    }
}

fn main() {
    let mut scribe = Scribe::new();
    for i in 0..100000 {
        println!("Starting {}", i);
        scribe.scrape(&format!("{}", i)).expect("Failed to scrape");
    }
}
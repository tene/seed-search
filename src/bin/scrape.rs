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
    item_ids: HashMap<String, i32>,
    level_ids: HashMap<String, i32>,
}

impl Scribe {
    pub fn new(conn: &SqliteConnection) -> Self {
        use schema::{item, level};
        let item_ids = item::table
            .select((item::name, item::id))
            .load(conn)
            .expect("Failed to load items")
            .into_iter()
            .collect();
        let level_ids = level::table
            .select((level::name, level::id))
            .load(conn)
            .expect("Failed to load items")
            .into_iter()
            .collect();
        Self {
            item_ids,
            level_ids,
        }
    }
    pub fn find_or_insert_item(
        &mut self,
        rec: &Record,
        conn: &SqliteConnection,
    ) -> anyhow::Result<i32> {
        match self.item_ids.get(&rec.name) {
            Some(id) => Ok(*id),
            None => {
                use schema::item::dsl::*;
                //println!("New Item: {}", rec.name);
                insert_into(item).values(rec.new_item()).execute(conn)?;
                let new_id = item
                    .select(id)
                    .filter(name.eq(rec.name.as_str()))
                    .first::<i32>(conn)?;
                self.item_ids.insert(rec.name.clone(), new_id);
                if let Some(recprops) = &rec.artprops {
                    use schema::artprops::dsl::*;
                    for (recprop, recvalue) in recprops.iter() {
                        insert_into(artprops)
                            .values((prop.eq(recprop), value.eq(recvalue), item_id.eq(new_id)))
                            .execute(conn)?;
                    }
                }
                if let Some(recspells) = &rec.spells {
                    use schema::spell_book::dsl::*;
                    for spellname in recspells.values() {
                        insert_into(spell_book)
                            .values((spell.eq(spellname), item_id.eq(new_id)))
                            .execute(conn)?;
                    }
                }
                Ok(new_id)
            }
        }
    }
    pub fn allocate_seed_id(
        &mut self,
        seed: &String,
        conn: &SqliteConnection,
    ) -> anyhow::Result<Option<i32>> {
        // XXX TODO read version from `crawl -version`
        let version_name = "0.27-a0-1548-gf8a67e7463";
        use schema::seed;
        let seed_id: i32 = match seed::table
            .select(seed::id)
            .filter(seed::seed_text.eq(seed))
            .filter(seed::version.eq(version_name))
            .first::<i32>(conn)
        {
            // skip already-processed seeds
            // XXX TODO add a flag to choose this
            Ok(id) => {
                println!("Skipping {}={}", id, seed);
                return Ok(None);
            }
            Err(_) => {
                insert_into(seed::table)
                    .values((&seed::version.eq(version_name), &seed::seed_text.eq(seed)))
                    .execute(conn)?;
                seed::table
                    .filter(seed::version.eq(version_name))
                    .filter(seed::seed_text.eq(seed))
                    .select(seed::id)
                    .first(conn)?
            }
        };
        Ok(Some(seed_id))
    }
    pub fn scrape<I: IntoIterator<Item = Record>>(
        &mut self,
        seed: &String,
        records: I,
        conn: &SqliteConnection,
    ) -> anyhow::Result<()> {
        use schema::*;

        conn.transaction::<(), anyhow::Error, _>(|| {
            //let seed_id = self.allocate_seed_id(seed, conn)?;
            let seed_id = match self.allocate_seed_id(seed, conn)? {
                Some(id) => id,
                // skip already-handled seeds.
                // XXX TODO add a flag to choose this
                None => {
                    return Ok(());
                }
            };
            println!("Recording {}", seed);

            for rec in records.into_iter() {
                // if rec.unrand {
                //     match rec.price {
                //         Some(price) => println!("{} [{}G] {}", rec.level, price, rec.name),
                //         None => println!("{} {}", rec.level, rec.name),
                //     };
                // }
                //println!("{:?}", rec);
                let level_id = *self.level_ids.get(&rec.level).expect("Missing level id");
                let item_id = self.find_or_insert_item(&rec, conn)?;
                insert_into(item_seen::table)
                    .values((
                        item_seen::item_id.eq(item_id),
                        item_seen::level_id.eq(level_id),
                        item_seen::seed_id.eq(seed_id),
                        item_seen::price.eq(rec.price.unwrap_or_default()),
                    ))
                    .execute(conn)?;
            }
            Ok(())
        })
    }
}

fn main() -> anyhow::Result<()> {
    let conn = &establish_connection();
    let mut scribe = Scribe::new(conn);
    for i in 20000..50000 {
        println!("Crawling {}", i);
        let seed = &format!("{}", i);

        let output = Command::new("scripts/run-scrape.sh").arg(seed).output()?;
        let records = serde_json::Deserializer::from_slice(&output.stdout)
            .into_iter::<Record>()
            .filter_map(Result::ok);

        scribe
            .scrape(seed, records, conn)
            .expect("Failed to scrape");
    }
    Ok(())
}

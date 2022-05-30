extern crate diesel;
extern crate seed_search;

use self::diesel::prelude::*;
use self::models::*;
use self::seed_search::*;

use std::collections::HashMap;
use std::process::Command;
use std::process::Output;

use anyhow;
use crossbeam::channel::Receiver;
use crossbeam::channel::Sender;
use dashmap::DashMap;
use diesel::insert_into;
use serde::{Deserialize, Serialize};
use serde_json;
use tracing::{debug, info, instrument};

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
    item_ids: DashMap<String, i32>,
    level_ids: DashMap<String, i32>,
}

impl Scribe {
    pub fn new(conn: &impl diesel::Connection<Backend = diesel::sqlite::Sqlite>) -> Self {
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
    #[instrument(skip(self, conn))]
    pub fn find_or_insert_item(
        &self,
        rec: &Record,
        conn: &impl diesel::Connection<Backend = diesel::sqlite::Sqlite>,
    ) -> anyhow::Result<i32> {
        self.item_ids
            .entry(rec.name.clone())
            .or_try_insert_with(|| {
                use schema::item::dsl::*;
                debug!(?rec, "New item");
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
            })
            .map(|v| *v)
    }
    #[instrument(skip(self, conn))]
    pub fn allocate_seed_id(
        &self,
        seed: &String,
        conn: &impl diesel::Connection<Backend = diesel::sqlite::Sqlite>,
    ) -> anyhow::Result<Option<i32>> {
        // XXX TODO read version from `crawl -version`
        let version_name = "0.28.0";
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
                info!("Skipping {}={}", id, seed);
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
        info!(seed = seed_id, "Scraping");
        Ok(Some(seed_id))
    }
    #[instrument(skip(self, conn, records))]
    pub fn scrape<I: IntoIterator<Item = Record>>(
        &self,
        seed: &String,
        records: I,
        conn: &impl diesel::Connection<Backend = diesel::sqlite::Sqlite>,
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
            info!(seed = seed_id, "Recording");

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
    tracing_subscriber::fmt::init();

    use rayon::prelude::*;

    let (tx, rx): (Sender<(String, Output)>, Receiver<(String, Output)>) =
        crossbeam::channel::unbounded();
    let hdl = std::thread::spawn(move || {
        let conn = &establish_traced_connection();
        let scribe = Scribe::new(conn);
        for (seed, output) in rx {
            let records = serde_json::Deserializer::from_slice(&output.stdout)
                .into_iter::<Record>()
                .filter_map(Result::ok);
            scribe
                .scrape(&seed, records, conn)
                .expect("failed to scrape?");
        }
    });

    let rv = (0..1000000).into_par_iter().try_for_each(|i: usize| {
        let seed = format!("{}", i);
        let output: Output = Command::new("scripts/run-scrape.sh").arg(&seed).output()?;
        tx.send((seed, output))?;
        Ok(())
    });

    let _ = hdl.join();
    rv
}

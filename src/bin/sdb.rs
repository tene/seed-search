extern crate diesel;
extern crate seed_search;

use self::diesel::prelude::*;
use self::models::*;
use self::seed_search::*;

// XXX TODO Rename to Akashic Record
fn main() {
    use seed_search::schema::level::dsl::*;

    let connection = establish_connection();
    let results = level
        .limit(5)
        .load::<Level>(&connection)
        .expect("Error loading levels");

    println!("Displaying {} levels", results.len());
    for post in results {
        println!("{}", post.id);
        println!("----------\n");
        println!("{}", post.name);
    }
}

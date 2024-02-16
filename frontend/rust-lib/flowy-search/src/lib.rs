pub mod entities;
pub mod event_handler;
pub mod event_map;
pub mod handlers;
pub mod protobuf;
pub mod services;

pub mod native;

pub type SearchIndexer = native::indexer::SqliteSearchIndexer;
-- Mini Travel Assistant — SQLite Schema
-- Version: 1.0
-- This file is the source of truth for the database structure.
-- DatabaseHelper must implement this schema exactly.

-- ============================================================
-- USERS
-- ============================================================
CREATE TABLE users (
    id                    INTEGER PRIMARY KEY AUTOINCREMENT,
    username              TEXT    NOT NULL,
    email                 TEXT    NOT NULL UNIQUE,
    password              TEXT    NOT NULL,  -- store hashed, never plain text
    preferred_categories  TEXT    DEFAULT '[]'  -- JSON array as string, e.g. '["restaurant","cafe"]'
);

-- ============================================================
-- PLACES
-- ============================================================
-- Cached place data from Google Places API.
-- place_id is a Google Place ID string (e.g. "ChIJN1t_tDeuEmsRUsoyG83frY4").
-- photo_reference is NOT a URL; construct the photo URL at runtime.
CREATE TABLE places (
    place_id        TEXT    PRIMARY KEY,
    name            TEXT    NOT NULL,
    category        TEXT    NOT NULL,  -- restaurant | cafe | attraction | shopping | nightlife
    rating          REAL    DEFAULT 0.0,
    price_level     INTEGER DEFAULT 0,  -- 0 = free/unknown, 1–4 = $ to $$$$
    address         TEXT,
    latitude        REAL    NOT NULL,
    longitude       REAL    NOT NULL,
    description     TEXT,
    photo_reference TEXT,
    open_now        INTEGER DEFAULT NULL  -- 0 = closed, 1 = open, NULL = unknown
);

-- ============================================================
-- ITINERARIES
-- ============================================================
CREATE TABLE itineraries (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id     INTEGER NOT NULL,
    city        TEXT    NOT NULL,
    name        TEXT,  -- user-given name, e.g. "My Tokyo Trip"
    date        TEXT    NOT NULL,  -- ISO 8601: "2025-08-15"
    created_at  TEXT    NOT NULL,  -- ISO 8601: "2025-07-20T14:30:00"
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- ============================================================
-- ITINERARY_PLACES (junction table)
-- ============================================================
-- Resolves M:N between itineraries and places.
-- time_slot determines when in the day.
-- order_index determines the order within a time slot.
CREATE TABLE itinerary_places (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    itinerary_id  INTEGER NOT NULL,
    place_id      TEXT    NOT NULL,
    time_slot     TEXT    NOT NULL CHECK(time_slot IN ('morning', 'afternoon', 'evening')),
    order_index   INTEGER NOT NULL DEFAULT 0,
    FOREIGN KEY (itinerary_id) REFERENCES itineraries(id) ON DELETE CASCADE,
    FOREIGN KEY (place_id) REFERENCES places(place_id)
);

-- ============================================================
-- INDEXES
-- ============================================================
CREATE INDEX idx_itineraries_user    ON itineraries(user_id);
CREATE INDEX idx_itin_places_itin    ON itinerary_places(itinerary_id);
CREATE INDEX idx_itin_places_place   ON itinerary_places(place_id);
CREATE INDEX idx_places_category     ON places(category);

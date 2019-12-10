DROP TABLE IF EXISTS events;
CREATE TABLE events
(
    rsvp json NOT NULL
);
DROP TABLE IF EXISTS user_count;
CREATE TABLE user_count
(
    member_id   int PRIMARY KEY,
    member_name VARCHAR,
    total_rsvps int
);

DROP TABLE IF EXISTS event_count;
CREATE TABLE event_count
(
    event_id   VARCHAR PRIMARY KEY,
    event_name VARCHAR,
    total_rsvp int
);

CREATE OR REPLACE FUNCTION process_user_rsvp_count() RETURNS TRIGGER AS
$user_rsvp_count$
begin
    if NEW.rsvp ->> 'response' = 'yes' then
        INSERT INTO user_count
        VALUES (((NEW.rsvp -> 'member') ->> 'member_id')::int, (NEW.rsvp -> 'member') ->> 'member_name', 1)
        ON CONFLICT (member_id) DO UPDATE SET total_rsvps = user_count.total_rsvps + 1;
    end if;
    RETURN NEW;
END;
$user_rsvp_count$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS user_rsvp_count ON events;
CREATE
    TRIGGER
    user_rsvp_count
    AFTER
        INSERT
    ON events
    FOR EACH ROW
EXECUTE FUNCTION process_user_rsvp_count();

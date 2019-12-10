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
    event_id   VARCHAR,
    response   VARCHAR,
    event_name VARCHAR,
    total_rsvps int,
    PRIMARY KEY (event_id, response)
);

CREATE OR REPLACE FUNCTION process_rsvp_events() RETURNS TRIGGER AS
$materialize_agg$
begin
    if NEW.rsvp ->> 'response' = 'yes' then
        INSERT INTO user_count
        VALUES (((NEW.rsvp -> 'member') ->> 'member_id')::int, (NEW.rsvp -> 'member') ->> 'member_name', 1)
        ON CONFLICT (member_id) DO UPDATE SET total_rsvps = user_count.total_rsvps + 1;
    end if;

    INSERT INTO event_count
    VALUES (((NEW.rsvp -> 'event') ->> 'event_id'), NEW.rsvp ->> 'response', (NEW.rsvp -> 'event') ->> 'event_name',
            1)
    ON CONFLICT (event_id, response) DO UPDATE SET total_rsvps = event_count.total_rsvps + 1;
    RETURN NEW;
end;
$materialize_agg$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS materialize_agg ON events;
CREATE
    TRIGGER
    materialize_agg
    AFTER
        INSERT
    ON events
    FOR EACH ROW
EXECUTE FUNCTION process_rsvp_events();
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
    event_id    VARCHAR,
    response    VARCHAR,
    event_name  VARCHAR,
    total_rsvps int,
    PRIMARY KEY (event_id, response)
);

DROP TABLE IF EXISTS event_time_count;
CREATE TABLE event_time_count
(
    event_id    VARCHAR,
    start_time  TIMESTAMP,
    end_time    TIMESTAMP,
    total_rsvps INT,
    PRIMARY KEY (event_id, start_time)
);
CREATE INDEX idx_event_time_count_inverse
    ON event_time_count (event_id, start_time, end_time DESC);

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

    if EXISTS(SELECT 1
              FROM event_time_count et
              WHERE et.event_id = (NEW.rsvp -> 'event') ->> 'event_id'
                AND et.start_time >= to_timestamp(((New.rsvp) ->> 'mtime')::bigint / 1000)
                AND to_timestamp(((New.rsvp) ->> 'mtime')::bigint / 1000) < et.end_time) then
        UPDATE event_time_count et
        SET total_rsvps = total_rsvps + 1
        WHERE et.event_id = (NEW.rsvp -> 'event') ->> 'event_id'
          AND et.start_time >= to_timestamp(((New.rsvp) ->> 'mtime')::bigint / 1000)
          AND to_timestamp(((New.rsvp) ->> 'mtime')::bigint / 1000) < et.end_time;
    else
        INSERT INTO event_time_count
        VALUES ((NEW.rsvp -> 'event') ->> 'event_id', to_timestamp(((New.rsvp) ->> 'mtime')::bigint / 1000),
                to_timestamp(((New.rsvp) ->> 'mtime')::bigint / 1000) + interval '1 minute', 1);
    end if;

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
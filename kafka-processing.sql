CREATE STREAM rsvp (venue MAP<VARCHAR, VARCHAR>,
response VARCHAR ,
guests INT,
member MAP<VARCHAR , VARCHAR>,
mtime INT, event MAP<VARCHAR , VARCHAR>,
`group` MAP<VARCHAR , VARCHAR >)
WITH (kafka_topic='meetup', value_format='json');


SELECT member['member_id'] AS member_id, count(*) AS total_rsvps
    FROM rsvp WHERE response = 'yes' GROUP BY member['member_id']
    EMIT CHANGES;

SELECT event['event_id'] AS event_id, response AS response, count(*) AS total_rsvps
    FROM rsvp GROUP BY event['event_id'], response
    EMIT CHANGES;

SELECT event['event_id'] AS event_id, count(*) AS total_rsvps FROM rsvp
  WINDOW TUMBLING (SIZE 1 MINUTE ) GROUP BY event['event_id'] EMIT CHANGES;
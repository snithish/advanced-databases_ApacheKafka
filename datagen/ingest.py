import json

from kafka import KafkaProducer
from requests import get


def main():
    producer = KafkaProducer(bootstrap_servers='localhost:9092')
    stream = get('http://stream.meetup.com/2/rsvps', stream=True)
    log_counter = 0
    for line in stream.iter_lines():
        if line:
            decoded_line = line.decode('utf-8')
            response = json.loads(decoded_line)
            producer.send(topic='meetup', value=line, timestamp_ms=response.get('mtime'))
            log_counter += 1
            if log_counter % 10 == 0:
                print("Ingested data count for this session: {log_counter}".format(log_counter=log_counter))


if __name__ == '__main__':
    main()

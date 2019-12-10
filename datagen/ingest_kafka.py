from datetime import datetime

import time
from kafka import KafkaProducer


def main():
    producer = KafkaProducer(bootstrap_servers='localhost:9092')
    with open('data.txt', 'r') as data:
        print(int(time.time()))
        for line in data:
            producer.send(topic='meetup', value=line.encode('utf-8'))
    producer.flush()
    print(int(time.time()))


if __name__ == '__main__':
    main()

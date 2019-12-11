import time

from kafka import KafkaProducer


def main():
    producer = KafkaProducer(bootstrap_servers='localhost:9092')
    with open('data.txt', 'r') as data:
        print(int(time.time_ns()))
        for line in data:
            producer.send(topic='meetup', value=line.encode('utf-8'))
        producer.flush()
        print(int(time.time_ns()))


if __name__ == '__main__':
    main()

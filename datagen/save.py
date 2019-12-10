import json

from requests import get


def main():
    stream = get('http://stream.meetup.com/2/rsvps', stream=True)
    log_counter = 0
    with open('data.txt', 'a+') as data:
        for line in stream.iter_lines():
            if line:
                data.write(line.decode('utf-8') + "\n")
                log_counter += 1
                if log_counter % 10 == 0:
                    print("Written data count for this session: {log_counter}".format(log_counter=log_counter))


if __name__ == '__main__':
    main()

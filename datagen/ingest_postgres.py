import json

import psycopg2


def main():
    sql = """INSERT INTO events(rsvp)
             VALUES(%s);"""
    with psycopg2.connect(host='localhost', port=5432, database='benchmark', user='benchmark',
                          password='benchmark') as conn:
        with conn.cursor() as cur, open('data.txt', 'r') as data:
            for line in data:
                cur.execute(sql, (line, ))
            conn.commit()


if __name__ == '__main__':
    main()

import time
import psycopg2


def main():
    sql = """INSERT INTO events(rsvp)
             VALUES(%s);"""
    with psycopg2.connect(host='localhost', port=5432, database='benchmark', user='benchmark',
                          password='benchmark') as conn:
        with conn.cursor() as cur, open('data.txt', 'r') as data:
            print(int(time.time()))
            counter = 0
            for line in data:
                cur.execute(sql, (line,))
                counter += 1
                if counter % 100 == 0:
                    conn.commit()
            conn.commit()
            print(int(time.time()))


if __name__ == '__main__':
    main()

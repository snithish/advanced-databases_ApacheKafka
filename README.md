# Stream Databases and Kafka
This repository includes artifacts required to compare an RDBMS like postgres with Kafka 
we primarily look at the cost of adding triggers to achieve CEP like a Stream processing system does
and analyze the cost to insertion speed and we then try to see how decoupling ingestion and processing is
beneficial with kafka as a storage system and KSQL (Kafka Streams) for processing. 
Thanks for [meetup.com](https://www.meetup.com/) for providing a [Streaming API for RSVPs](http://stream.meetup.com/2/rsvps)

## Data Generation
1. We use Streaming API from [meetup.com](https://www.meetup.com/) for our experiment
2. Clone this repository
3. Run `save.py` to save data from API
    ```shell script
    cd datagen
    pip3 install requests
    python3 save.py
    ```
4. Once we have sufficient data we can transfer this to a GCS bucket with name `$BUCKET_NAME` 
for use in benchmark

## Bootstrap GCP VM
PS. Ensure that the VM have sufficient cores and memory to run kafka and consumers
in parallel eg. 15 cores 50GB memory

1. Run
    ```shell script
    sudo apt update && sudo apt upgrade
    ```
2. Copy the data generated from previous step from GCS Bucket into VM
    ```shell script
    gsutil cp -R gs://$BUCKET_NAME .
    ```
3. Install `docker` as described here [Install Docker via Convenience Script](https://docs.docker.com/install/linux/docker-ce/ubuntu/#install-using-the-convenience-script)
    ```shell script
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    ```
4. Install `docker-compose`
    ```shell script
    sudo curl -L "https://github.com/docker/compose/releases/download/1.25.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    ```
5. Install pip3 to install dependencies
    ```shell script
    sudo apt install python3-pip
    ```
6. Clone this repository onto the VM
    ```shell script
    git clone https://github.com/snithish/advanced-databases_ApacheKafka.git
    ```
7. Start containers
    ```shell script
    cd advanced-databases_ApacheKafka
    docker-compose up -d
    ```
8. **(Optionally)** Setup remote port forwarding to view the control center, to be run in work station
    ensure that SSH has been setup up to connect to instances [GCP - Connecting to Instances](https://cloud.google.com/compute/docs/instances/connecting-advanced#thirdpartytools)
    ```shell script
    ssh -L 5000:localhost:9021 [USERNAME]@[EXTERNAL_IP_ADDRESS]
    ```
9. Move `datafile` to `datagen/data.txt`

***
   
## Benchmarking Postgres
1. Setup database
   ```shell script
   docker-compose exec postgres psql -Ubenchmark -f /datagen/initdb.sql
   ```
2. We need to install `psycopg2` to connect to postgres
   ```shell script
   pip3 install psycopg2-binary 
   ``` 
3. Run benchmark
   ```shell script
   python3 ingest_postgres.sql
   ```
4. Remove trigger from `initdb.sql` one at a time and repeat the steps above

***

## Benchmarking Kafka
1. Create a new topic to inject data for benchmark
    ```shell script
    docker-compose exec broker kafka-topics --create \
      --zookeeper zookeeper:2181 \
      --replication-factor 1 --partitions 60 \
      --topic meetup
    ```
2. Open multi tabs or panes, suggested to use a terminal multiplexer like [TMux](https://github.com/tmux/tmux/wiki) or open multiple SSH connections and run
    ```shell script
    docker-compose exec ksqldb-cli ksql http://ksqldb-server:8088
    ```
3. Create `stream` from `kafka topic` Refer to: `kafka-processing.sql`
4. Install `kafka-python` to act as producer for kafka
    ```shell script
    pip3 install kafka-python
    ```
5. Execute the other queries in multiple panes / windows
6. Run benchmark
    ```shell script
    python3 ingest_kafka.py
    ```
7. Multiplex and run multiple producers to see high throughput
8. Repeat steps 4 - 6 for various query combinations
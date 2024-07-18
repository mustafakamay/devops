import pika
import os
import logging
import time
import base64

# Logging yapılandırması
logging.basicConfig(level=logging.INFO)

def send_message():
    try:
        rabbitmq_host = os.environ['RABBITMQ_HOST']
        rabbitmq_port = int(os.environ['RABBITMQ_PORT'])
        rabbitmq_user_base64 = os.environ['RABBITMQ_USER']
        rabbitmq_password_base64 = os.environ['RABBITMQ_PASSWORD']
        rabbitmq_user = base64.b64decode(rabbitmq_user_base64).decode('utf-8')
        rabbitmq_password = base64.b64decode(rabbitmq_password_base64).decode('utf-8')
        
        logging.info(f"Connecting to RabbitMQ at {rabbitmq_host}:{rabbitmq_port} with user {rabbitmq_user}")
    except KeyError as e:
        logging.error(f"Environment variable {e} is missing")
        return

    try:
        credentials = pika.PlainCredentials(rabbitmq_user, rabbitmq_password)
        connection = pika.BlockingConnection(pika.ConnectionParameters(host=rabbitmq_host, port=rabbitmq_port, credentials=credentials))
        channel = connection.channel()
        channel.queue_declare(queue='hello')
        
        message = 'Hello World!'
        channel.basic_publish(exchange='', routing_key='hello', body=message)
        logging.info(f" [x] Sent '{message}'")
        
        connection.close()
    except Exception as e:
        logging.error(f"Error while connecting to RabbitMQ: {e}, {rabbitmq_host}, {rabbitmq_port}, {rabbitmq_user}, {rabbitmq_password}")

if __name__ == '__main__':
    while True:
        send_message()
        time.sleep(5)

import pika
import os
import logging
import base64
# Logging yapılandırması
logging.basicConfig(level=logging.INFO)

def callback(ch, method, properties, body):
    logging.info(f" [x] Received {body}")

def consume_message():
    try:
        rabbitmq_host = os.environ['RABBITMQ_HOST']
        rabbitmq_port = int(os.environ['RABBITMQ_PORT'])
        
        # Base64 kodlu kullanıcı adı ve şifreyi çözme
        rabbitmq_user_base64 = os.environ['RABBITMQ_USER']
        rabbitmq_password_base64 = os.environ['RABBITMQ_PASSWORD']
        rabbitmq_user = base64.b64decode(rabbitmq_user_base64).decode('utf-8')
        rabbitmq_password = base64.b64decode(rabbitmq_password_base64).decode('utf-8')
        
        print(rabbitmq_host, rabbitmq_port, rabbitmq_user, rabbitmq_password)
    except KeyError as e:
        logging.error(f"Environment variable {e} is missing")

    try:
        credentials = pika.PlainCredentials(rabbitmq_user, rabbitmq_password)
        connection = pika.BlockingConnection(pika.ConnectionParameters(host=rabbitmq_host, port=rabbitmq_port, credentials=credentials))
        channel = connection.channel()
        channel.queue_declare(queue='hello')
        channel.basic_consume(queue='hello', on_message_callback=callback, auto_ack=True)
        
        logging.info(' [*] Waiting for messages. To exit press CTRL+C')
        channel.start_consuming()
    except Exception as e:
        print(rabbitmq_host,rabbitmq_port,rabbitmq_user,rabbitmq_password)
        logging.error(f"Error while connecting to RabbitMQ: {e,rabbitmq_host,rabbitmq_port,rabbitmq_user,rabbitmq_password}")

if __name__ == '__main__':
    consume_message()

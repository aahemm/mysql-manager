import time
import logging
from behave import *

from mysql_manager.cluster import ClusterManager

logger = logging.getLogger(__name__)

@given('setup default proxysql with name: {name:w} and image: {image}')
def start_default_proxysql(context, name, image):
    context.test_env.setup_proxysql(
        {
            "name": name,
            "image": image, 
            "local_username": "admin", 
            "local_password": "pwd", 
            "remote_username": "radmin", 
            "remote_password": "pwd"
        }
    )

@given('setup default mysql with server_id {server_id:d} and image: {image}')
def start_proxysql(context, server_id, image):
    context.test_env.setup_mysql(
        {"server_id": server_id, "image": image}
    )

@given('setup mysql_manager with name {name:w}')
def start_mysql_manager(context, name):
    context.test_env.setup_mysql_manager(
        {"name": name, "image": context.mysql_manager_image}
    )
    context.test_env.start()


@when('execute mysql query with user: {user:w}, password: {password:w}, host: {host} query: {query}')
def exec_query(context, user, password, host, query):
    mysql = context.test_env.mysqls[0]
    command = f"""mysql -u{user} -p{password} -h {host} -e "{query}"
"""
    mysql.exec(command)

@then('result of query: "{query}" with user: {user:w} and password: {password: w} on host: {host} should be "{deserialized_result}"')
def evaluate_query_result(context, query, user, password, host, deserialized_result):
    mysql = context.test_env.mysqls[0]
    command = f"""mysql -u{user} -p{password} -h {host} -e "{query}"
"""
    output = mysql.exec(command).output.decode()
    output = output.split("mysql: [Warning] Using a password on the command line interface can be insecure.\n")
    output = output[1]
    deserialized_output = output.replace("\t", " ").replace("\n", " ")
    assert deserialized_output == deserialized_result

import boto3

import os
import pprint

class EC2Connection:
    """
    Ansible module which returns details of any running AWS instances.
    """

    def __init__(self):
        """
        Initialises all the AWS services needed to access and check AWS instances.
        """
        self.ec2_client = None
        self.key_id = ""
        self.secret_key = ""
        self.region = ""
        self.endpoint = "https://ec2.eu-west-2.amazonaws.com"
        self.__main()

    def __main(self):
        """
        Holds the main functionality and sequence of setting up the AWS EC2 connection
        """
        self.ec2_client = boto3.client(
            "ec2",

        )
        self.__get_running_instance_ids()



    def __get_running_instance_ids(self):
        instances = []
        paginator = self.ec2_client.get_paginator("describe_instances")
        for page in paginator.paginate():
        
            for reservation in page['Reservations']:
                for instance in reservation['Instances']:
                    if instance['State']['Name'] == "running":
                        name = ""
                        for tag in instance.get("Tags"):
                            if tag["Key"] == "Name":
                                name = tag["Value"]
                        instances.append({
                            "ID": instance["InstanceId"],
                            "Name": name,
                            "Type": instance["InstanceType"],
                            "Private IP": instance.get("PrivateIpAddress"),
                            "Public IP": instance.get("PublicIpAddress")
                        })
        pprint.pp(instances)

if __name__ == "__main__":
    EC2Connection()

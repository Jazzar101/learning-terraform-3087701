import boto3

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
        self.ec2_client = boto3.client("ec2", region="eu-west-2")
        self.instance_details = []

    def describe_instances(self):
        """
        Returns the details of any running instances.

        Returns:
            str: Running AWS Instance Details
        """
        self.__iterate_instances()
        return self.instance_details

    def __iterate_instances(self):
        """
        Iterates through all recent instances in AWS EC2
        """
        paginator = self.ec2_client.get_paginator("describe_instances")
        for page in paginator.paginate():
            for reservation in page['Reservations']:
                for instance in reservation['Instances']:
                    self.__get_running_instance_details(instance)
                    
    def __get_running_instance_details(self, instance):
        """
        Filters out any running instances and grabs the details of them

        Args:
            instance (_type_): _description_
        """
        if instance['State']['Name'] == "running":
            name = ""
            for tag in instance.get("Tags"):
                if tag["Key"] == "Name":
                    name = tag["Value"]
            details = {
                "ID": instance["InstanceId"],
                "Name": name,
                "Type": instance["InstanceType"],
                "Private IP": instance.get("PrivateIpAddress"),
                "Public IP": instance.get("PublicIpAddress")
            }
            self.instance_details.append(pprint.pp(details))

if __name__ == "__main__":
    EC2Connection().describe_instances()

from ansible.module_utils.basic import AnsibleModule
import boto3

import json
import os


class EC2Connection:
    """
    Ansible module which returns details of any running AWS instances.
    """

    def __init__(self):
        """
        Initialises all the AWS services needed to access and check AWS instances.
        """
        self.ec2_client = None
        self.instance_details = []

    def main(self):
        """
        Handles argument parsing from the ansible playbook and initialises the EC2 client.
        """
        args = {
            "aws_access_key_id": {"type": "str", "required": False, "default": ""},
            "aws_secret_key": {"type": "str", "required": False, "default": "", "no_log": True},
            "region": {"type": "str", "required": False, "default": "eu-west-2"},
        }
        module = AnsibleModule(argument_spec=args)
        aws_access_key_id = module.params["aws_access_key_id"]
        aws_secret_key = module.params["aws_secret_key"]
        aws_region = module.params["region"]

        self.__init_client(aws_access_key_id, aws_secret_key, aws_region)

        try:
            self.__iterate_instances()
            module.exit_json(
                changed=False,
                instances=self.instance_details
                )

        except Exception as e:
            module.fail_json(msg=str(e))

    def __init_client(self, aws_access_key_id="", aws_secret_key="", aws_region=""):
        """
        Initialises the AWS EC2 Client

        Args:
            aws_access_key_id (str, optional): AWS Access Key. 
                Defaults to system env variable, if set.
            aws_secret_access_key (str, optional): AWS Secret Access Key.
                Defaults to system env variable, if set.
            region (str, optional): AWS region.
                Defaults to system env variable, if set.
        """
        try:
            access_key = aws_access_key_id or os.getenv("AWS_ACCESS_KEY_ID")
            secret_key = aws_secret_key or os.getenv("AWS_SECRET_ACCESS_KEY")
            region = aws_region or os.getenv("REGION")
        except Exception as e:
            print("Could not fully validate all AWS credentials. Maybe one is missing? Error:", e)

        self.ec2_client = boto3.client(
            "ec2",
            aws_access_key_id=access_key,
            aws_secret_access_key=secret_key,
            region_name=region
        )

    def describe_instances(self):
        """
        Returns the details of any running instances.

        Returns:
            str: Running AWS Instance Details
        """
        self.__init_client()
        self.__iterate_instances()

    def __iterate_instances(self):
        """
        Iterates through all recent instances in AWS EC2
        """
        paginator = self.ec2_client.get_paginator("describe_instances")
        for page in paginator.paginate():
            for reservation in page["Reservations"]:
                for instance in reservation["Instances"]:
                    self.__get_running_instance_details(instance)
        if not self.instance_details:
            self.instance_details = [{"msg": "No running AWS EC2 instances found"}]

    def __get_running_instance_details(self, instance):
        """
        Filters out any running instances and grabs the details of them

        Args:
            instance (_type_): _description_
        """
        if instance["State"]["Name"] == "running":
            name = ""
            for tag in instance.get("Tags"):
                if tag["Key"] == "Name":
                    name = tag["Value"]
            details = {
                "ID": instance["InstanceId"],
                "Name": name,
                "Type": instance["InstanceType"],
                "Private IP": instance.get("PrivateIpAddress"),
                "Public IP": instance.get("PublicIpAddress"),
            }
            self.instance_details.append(details)


if __name__ == "__main__":
    EC2Connection().main()

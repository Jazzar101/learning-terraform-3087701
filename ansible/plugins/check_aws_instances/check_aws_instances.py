# from ansible.module_utils.basic import AnsibleModule

import boto3

import os

class CheckAWSInstances:
    """
    Ansible module which returns details of any running AWS instances.
    """
    def __init__(
            self,
            ssm_client = boto3.client,
            remote_exec = False

    ):
        """
        Initialises all the AWS services needed to access and check AWS instances.
        """

        self.ssm_client = ssm_client
        self.remote_exec = remote_exec
        self.key_id = ""
        self.secret_key = ""
        self.region = ""

    def main(self):
        """
        Performs the main functionality
        """
        self.parse_credentials()
        self.init_client()
        ec2_client = boto3.client('ec2', region="eu-west-2")
        response = ec2_client.describe_instances(Filters=[{
            'Name': 'instance-state-name',
            'Values': 'running'
            }])
        print(response)

    def init_client(self):
        """
        Initialises the boto3 client with the required variables
        """
        self.ssm_client = boto3.client(
            "ec2",
            aws_access_key_id=self.key_id,
            aws_secret_access_key=self.secret_key,
            region_name=self.region
        )

    def parse_credentials(self):
        """
        Gets the credentials from the .aws credentials file for that user
        """
        aws_creds_file = os.path.join(os.path.expanduser("~"), ".aws", "credentials")
        os.
        if os.path.isfile(aws_creds_file):
            raise FileNotFoundError(f"AWS Credentials file not found. Path provided: {aws_creds_file}")

        with open(aws_creds_file, "r", encoding="utf-8") as file:
            lines = file.read()
            for line in lines:
                if "aws_access_key_id=" in line.lower():
                    self.key_id = line.split("=")[1]
                elif "aws_secret_access_key=" in line.lower():
                    self.secret_key = line.split("=")[1]
                elif "region=" in line.lower():
                    self.region = line.split("=")[1]


if __name__ == "__main__":
    CheckAWSInstances().main()

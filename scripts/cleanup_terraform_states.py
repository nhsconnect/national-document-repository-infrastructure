import sys

import boto3
from botocore.exceptions import ClientError


class CleanupTerraformStates:
    def __init__(self):
        self.env_folder = "env:/"
        self.client = boto3.client("s3")
        self.paginator = self.client.get_paginator('list_objects_v2')

    def get_terraform_bucket(self) -> str:
        response = self.client.list_buckets()
        buckets = response.get("Buckets")
        for bucket in buckets:
            if "ndr-dev-terraform-state" in bucket.get("Name"):
                bucket_name = bucket.get("Name")
                if not bucket_name:
                    break
                return bucket_name
        print("Failed to find terraform bucket")
        sys.exit(1)

    def remove_folder_objects(self, bucket_name:str, folder_prefix: str):
        print(f"Deleting all objects under: {folder_prefix}")
        pages = self.paginator.paginate(Bucket=bucket_name, Prefix=folder_prefix)

        objects_to_delete = []
        for page in pages:
            for obj in page.get('Contents', []):
                objects_to_delete.append({'Key': obj['Key']})

        if objects_to_delete:
            self.client.delete_objects(Bucket=bucket_name, Delete={'Objects': objects_to_delete})


    def empty_folder_check(self, bucket_name:str, folder_prefix: str):
        try:
            self.client.head_object(Bucket=bucket_name, Key=folder_prefix)
            self.client.delete_object(Bucket=bucket_name, Key=folder_prefix)
            print(f"Deleted empty folder for: {folder_prefix}")
        except ClientError as e:
            if e.response['Error']['Code'] != "404":
                print(f"No empty folder found to remove for: {folder_prefix}")

    def main(self, sandbox: str):
        tf_bucket = self.get_terraform_bucket()
        pages = self.paginator.paginate(Bucket=tf_bucket, Prefix=self.env_folder)

        for page in pages:
            for obj in page.get('Contents', []):
                key = obj['Key']
                parent_folder = key[len(self.env_folder):].split("/", 1)[0]
                if parent_folder == sandbox:
                    print(parent_folder)
                    folder_prefix = f"{self.env_folder}{parent_folder}/"
                    self.remove_folder_objects(bucket_name=tf_bucket, folder_prefix=folder_prefix)
                    self.empty_folder_check(bucket_name=tf_bucket, folder_prefix=folder_prefix)

if __name__ == '__main__':
    sandbox = sys.argv[1]
    exclude_list = ['ndr-dev']

    if sandbox in exclude_list:
        print("Cleanup failed. Cannot delete protected environment")
        sys.exit(1)

    print(f"Attempting to cleanup the terraform states for: {sandbox}")
    CleanupTerraformStates().main(sandbox=sandbox)

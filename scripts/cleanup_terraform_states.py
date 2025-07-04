import sys

import boto3
from botocore.exceptions import ClientError


class CleanupTerraformStates:
    def __init__(self):
        self.env_folder = "env:/"
        self.s3_client = boto3.client("s3")
        self.dynamo_client = boto3.client("dynamodb")
        self.objects_paginator = self.s3_client.get_paginator('list_objects_v2')
        self.object_versions_paginator = self.s3_client.get_paginator('list_object_versions')

    def get_terraform_bucket(self) -> str:
        response = self.s3_client.list_buckets()
        buckets = response.get("Buckets")
        for bucket in buckets:
            if "ndr-dev-terraform-state" in bucket.get("Name"):
                bucket_name = bucket.get("Name")
                if not bucket_name:
                    break
                return bucket_name
        print("Failed to find terraform bucket")
        sys.exit(1)

    def remove_object_versions(self, tf_bucket: str, folder_prefix: str) -> None:
        print(f"Deleting all object versions under: {folder_prefix}")
        pages = self.object_versions_paginator.paginate(Bucket=tf_bucket, Prefix=folder_prefix)

        objects_to_delete = []
        for page in pages:
            for version in page.get('Versions', []) + page.get('DeleteMarkers', []):
                objects_to_delete.append(
                    {
                        'Key': version['Key'],
                        'VersionId': version['VersionId']
                    }
                )
        print(f"Found {len(objects_to_delete)} objects and object versions to delete")
        if objects_to_delete:
            for i in range(0, len(objects_to_delete), 1000):
                chunk = objects_to_delete[i:i + 1000]
                self.s3_client.delete_objects(
                    Bucket=tf_bucket,
                    Delete={'Objects': chunk}
                )
            print("All object versions deleted.")

    def delete_record_in_dynamo(self, tf_bucket: str, file_key: str):
        print(f"Deleting sandbox tfstate DynamoDB record")
        table_name = "ndr-terraform-locks"
        lock_id = f'{tf_bucket}/{file_key}-md5'

        self.dynamo_client.delete_item(
            TableName=table_name,
            Key={'LockID': {'S': lock_id}},
            ConditionExpression="attribute_exists(LockID)"
        )
        print("DynamoDB record deleted successfully")


    def main(self, sandbox: str):
        tf_bucket = self.get_terraform_bucket()
        pages = self.objects_paginator.paginate(Bucket=tf_bucket, Prefix=self.env_folder)

        for page in pages:
            for obj in page.get('Contents', []):
                key = obj['Key']
                parent_folder = key[len(self.env_folder):].split("/", 1)[0]
                if parent_folder == sandbox:
                    folder_prefix = f"{self.env_folder}{parent_folder}/"
                    self.remove_object_versions(tf_bucket=tf_bucket, folder_prefix=folder_prefix)
                    self.delete_record_in_dynamo(tf_bucket, key)

if __name__ == '__main__':
    sandbox = sys.argv[1]
    exclude_list = ['ndr-dev']

    if sandbox in exclude_list:
        print("Cleanup failed. Cannot delete protected environment")
        sys.exit(1)

    print(f"Attempting to cleanup the terraform states for: {sandbox}")
    CleanupTerraformStates().main(sandbox=sandbox)

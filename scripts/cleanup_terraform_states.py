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

    def remove_folder_objects(self, bucket_name:str, folder_prefix: str):
        #TODO - Make sure we remove version history too
        print(f"Deleting all objects under: {folder_prefix}")
        pages = self.objects_paginator.paginate(Bucket=bucket_name, Prefix=folder_prefix)

        objects_to_delete = []
        for page in pages:
            for obj in page.get('Contents', []):
                objects_to_delete.append({'Key': obj['Key']})

        if objects_to_delete:
            #TODO - Check values before deleting
            print(objects_to_delete)
            # self.s3_client.delete_objects(Bucket=bucket_name, Delete={'Objects': objects_to_delete})

    def remove_folder_object_versions(self, bucket_name:str, folder_prefix: str):
        print(f"Deleting all object versions under: {folder_prefix}")
        pages = self.object_versions_paginator.paginate(Bucket=bucket_name, Prefix=folder_prefix)

        objects_to_delete = []
        for page in pages:
            for version in page.get('Versions', []) + page.get('DeleteMarkers', []):
                objects_to_delete.append(
                    {
                        'Key': version['Key'],
                        'VersionId': version['VersionId']
                    }
                )

        if objects_to_delete:
            # DELETE ALL OBJECT VERSIONS
            for i in range(0, len(objects_to_delete), 1000):
                chunk = objects_to_delete[i:i + 1000]
                response = self.s3_client.delete_objects(
                    Bucket=bucket_name,
                    Delete={'Objects': chunk}
                )
                print(f"Deleted {len(chunk)} versions/delete markers")

            print("All object versions deleted.")

    def empty_folder_check(self, bucket_name:str, folder_prefix: str):
        try:
            self.s3_client.head_object(Bucket=bucket_name, Key=folder_prefix)
            self.s3_client.delete_object(Bucket=bucket_name, Key=folder_prefix)
            print(f"Deleted empty folder for: {folder_prefix}")
        except ClientError as e:
            if e.response['Error']['Code'] != "404":
                print(f"No empty folder found to remove for: {folder_prefix}")

    def delete_record_in_dynamo(self, tf_bucket: str, file_key: str):
        #TODO - query dynamo for matching tf state path based on your sandbox workspace
        # Print out values first before deleting to confirm it is correct

        table_name = "ndr-terraform-locks"
        lock_id = f'{tf_bucket}/{file_key}-md5'
        print(f"LockID: {lock_id}")

        # Query TODO: Remove below query when delete_item() works
        # response = self.dynamo_client.get_item(
        #     TableName=table_name,
        #     Key={
        #         'LockID': {'S': lock_id}
        #     }
        # )
        #
        # item = response.get('Item')
        # if item:
        #     print("Item found:", item)
        # else:
        #     print("Item not found.")

        # Delete
        self.dynamo_client.delete_item(
            TableName=table_name,
            Key={'LockID': {'S': lock_id}},
            ConditionExpression="attribute_exists(LockID)"
        )
        print("DynamoDB record deleted successfully")


    def main(self, sandbox: str):
        tf_bucket = self.get_terraform_bucket()
        print(f"tf_bucket: {tf_bucket}")
        pages = self.objects_paginator.paginate(Bucket=tf_bucket, Prefix=self.env_folder)

        for page in pages:
            for obj in page.get('Contents', []):
                key = obj['Key']
                print(f"Key: {key}")
                parent_folder = key[len(self.env_folder):].split("/", 1)[0]
                if parent_folder == sandbox:
                    print(f"parent_folder: {parent_folder}")
                    folder_prefix = f"{self.env_folder}{parent_folder}/"
                    print(f"folder_prefix: {folder_prefix}")
                    self.remove_folder_object_versions(bucket_name=tf_bucket, folder_prefix=folder_prefix)
                    self.delete_record_in_dynamo(tf_bucket, key)
                    # self.remove_folder_objects(bucket_name=tf_bucket, folder_prefix=folder_prefix) # TODO: Check if deleting the object also deletes the folder. If not, proceed to delete folder
                    #self.empty_folder_check(bucket_name=tf_bucket, folder_prefix=folder_prefix)

if __name__ == '__main__':
    sandbox = sys.argv[1]
    exclude_list = ['ndr-dev']

    if sandbox in exclude_list:
        print("Cleanup failed. Cannot delete protected environment")
        sys.exit(1)

    print(f"Attempting to cleanup the terraform states for: {sandbox}")
    CleanupTerraformStates().main(sandbox=sandbox)

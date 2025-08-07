import sys
import boto3


class SandboxNotActiveException(Exception):
    pass


class CleanupVersions:
    def __init__(self):
        self.lambda_client = boto3.client("lambda")
        self.appconfig_client = boto3.client("appconfig")
        self.sandbox = sys.argv[1]

    def start(self):
        self.delete_hosted_configuration_versions()
        self.delete_lambda_layer_versions()

    def get_app_config_application_id(self) -> str:
        current_applications = self.appconfig_client.list_applications()
        for app in current_applications["Items"]:
            if f"-{self.sandbox}" in app["Name"]:
                return app["Id"]

    def get_app_config_profile_id(self, application_id: str) -> str:
        config_profiles = self.appconfig_client.list_configuration_profiles(
            ApplicationId=application_id
        )
        for profile in config_profiles["Items"]:
            if f"-{self.sandbox}" in profile["Name"]:
                return profile["Id"]

    def get_hosted_configuration_versions(self):
        print(f"Gathering AppConfig hosted configuration versions on {self.sandbox}...")
        application_id = self.get_app_config_application_id()
        config_profile_id = self.get_app_config_profile_id(application_id)

        current_hosted_configuration_versions = (
            self.appconfig_client.list_hosted_configuration_versions(
                ApplicationId=application_id, ConfigurationProfileId=config_profile_id
            )
        )

        return current_hosted_configuration_versions["Items"]

    def delete_hosted_configuration_versions(self):
        try:
            excess_hosted_config_versions = self.get_hosted_configuration_versions()
        except Exception:
            raise SandboxNotActiveException(
                "Failed to retrieve hosted configuration versions"
            )

        total_untracked_versions = len(excess_hosted_config_versions)
        print(
            f"\n{total_untracked_versions} hosted configuration versions require deletion"
        )

        if not total_untracked_versions:
            return

        successful_deletes = 0
        print("\nDeleting configuration versions...")
        for version in excess_hosted_config_versions:
            response = self.appconfig_client.delete_hosted_configuration_version(
                ApplicationId=version["ApplicationId"],
                ConfigurationProfileId=version["ConfigurationProfileId"],
                VersionNumber=version["VersionNumber"],
            )
            if response["ResponseMetadata"]["HTTPStatusCode"] == 204:
                successful_deletes += 1

        if successful_deletes == total_untracked_versions:
            print("\nSuccessfully deleted all untracked hosted configuration versions!")
        else:
            print(
                "\nWARNING! All untracked hosted configuration versions were not successfully deleted, please "
                "manually remove these from AppConfig using the AWS console or using AWS CLI"
            )

    def get_lambda_layers(self):
        print(f"\nGathering Lambda Layer versions on {self.sandbox}...")
        response = self.lambda_client.list_layers()

        environment_layers = []
        for layer in response["Layers"]:
            if f"{self.sandbox}_" in layer["LayerName"]:
                environment_layers.append(layer)
        return environment_layers

    def get_lambda_layer_versions(self, lambda_layers: list[dict]) -> dict:
        layer_versions = {}
        for layer in lambda_layers:
            response = self.lambda_client.list_layer_versions(
                LayerName=layer["LayerName"]
            )
            print(response)
            versions_to_remove = [
                layer_version["Version"]
                for layer_version in response["LayerVersions"][:-1]
            ]
            layer_versions.update({layer["LayerName"]: versions_to_remove})
            print(layer_versions)
        return layer_versions

    def delete_lambda_layer_versions(self):
        lambda_layers = self.get_lambda_layers()
        lambda_layer_versions = self.get_lambda_layer_versions(lambda_layers)
        total_untracked_versions = sum(
            len(versions) for versions in lambda_layer_versions.values()
        )
        print(f"\n{total_untracked_versions} lambda layer versions require deletion\n")

        if not total_untracked_versions:
            return

        successful_deletes = 0
        for lambda_layer, versions in lambda_layer_versions.items():
            print(f"Deleting {len(versions)} version/s from {lambda_layer}...")

            for version in versions:
                response = self.lambda_client.delete_layer_version(
                    LayerName=lambda_layer, VersionNumber=version
                )
                if response["ResponseMetadata"]["HTTPStatusCode"] == 204:
                    successful_deletes += 1

        if successful_deletes == total_untracked_versions:
            print("\nSuccessfully deleted all untracked lambda layer versions!")
        else:
            print(
                "\nWARNING! All untracked lambda layer versions were not successfully deleted, please manually "
                "remove these using the AWS console or using AWS CLI"
            )


if __name__ == "__main__":
    try:
        cleanup_versions = CleanupVersions()
        cleanup_versions.start()
        print("\nCleanup Process Complete.")
    except SandboxNotActiveException:
        print("\nExiting Cleanup Process! Sandbox resources not found")

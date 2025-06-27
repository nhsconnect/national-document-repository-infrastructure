import boto3, os, requests, sys

from botocore.exceptions import ClientError


def trigger_delete_workflow(token: str, sandbox: str):
    owner = "nhsconnect"
    repo = "national-document-repository-infrastructure"
    workflow = "terraform-destroy-environment-manual.yml"

    url = f"https://api.github.com/repos/{owner}/{repo}/actions/workflows/{workflow}/dispatches"
    headers = {
        "Accept": "application/vnd.github+json",
        "Authorization": f"Bearer {token}",
        "X-GitHub-Api-Version": "2022-11-28",
    }

    inputs = {
        "build_branch": "PRMT-439",  # TODO: change to main when ready to merge
        "sandbox_workspace": sandbox,
        "terraform_vars": "dev.tfvars",
        "environment": "development",
        "backend": "backend.conf",
    }

    resp = requests.post(
        url, headers=headers, json={"ref": "main", "inputs": inputs}
    )
    resp.raise_for_status()


def get_workspaces() -> list[str]:
    client = boto3.client("appconfig")
    try:
        applications = client.list_applications().get("Items")
        if not applications:
            print("Failed to extract AppConfig applications")
            sys.exit(0)

        workspaces = []
        for application in applications:
            name = application.get("Name")
            if not name:
                print("Failed to extract TF workspace from AppConfig application")
                sys.exit(1)
            workspaces.append(name.replace("RepositoryConfiguration-", ""))
        return workspaces
    except ClientError as e:
        print(f"Failed to extract TF workspace from AppConfig applications: {str(e)}")
        sys.exit(1)


if __name__ == "__main__":
    gh_pat = os.getenv("GIT_WORKFLOW_PAT")
    if not gh_pat:
        sys.exit("GIT_WORKFLOW_PAT not set")

    #Add persisting environments here
    excluded = ["ndr-dev"]

    # workspaces = get_workspaces()
    workspaces = ["delete1", "delete2"] # TODO: To switch to above when ready to merge
    for workspace in workspaces:
        if workspace not in excluded:
            trigger_delete_workflow(token=gh_pat, sandbox=workspace)

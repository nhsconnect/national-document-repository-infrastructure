# National Document Repository Infrastructure 



## Prerequisite
Ensure the following Prereqs are installed first (can use brew on Mac/Linux or Chocolatey on Windows)
- [Terraform Docs](https://terraform-docs.io/) - for formmating terraform documentation
```bash
brew install terraform-docs
```
- [findutils](https://www.gnu.org/software/findutils/) - Needed for scripts running on MacOSX
```bash
brew install findutils
```

## Repository best practices

We provide a makefile to ensure consistency and provide simplicity. It is strongly advised, both when planning and applying terraform, that this is done via the makefile.

The `make pre-commit` command this will format all terraform code, and re-create all README.md files. This should be run before every commit to keep the code base clean.

## Using Workspaces
To initialise the S3 backend, cd to infrastructure folder and run 
```bash
terraform init -backend-config=backend.conf
```

### The makefile

The following commands currently exist in the make file:

- `make pre-commit` -> runs both the `make generate-docs` and `make format-all` commands.


### Deploying to a new AWS Account

The details on how to run this terraform process on a new AWS account can be found on our confluence guides found [here](https://gpitbjss.atlassian.net/wiki/spaces/TW/pages/12581568619/Infrastructure+-+Deploy+to+a+new+Account)
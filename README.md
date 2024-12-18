# Import Project Script

## Overview
The **Import Project** is an application implemented in Shell/Bash (a Python version is on the works to be released at a later time). It's designed to automate the process of importing external/remote GitHub Repositories into a project's GitHub Actions as a mechanism to simplify dependencies management.

**Note**: Nevertheless, this is not a recommended practice as it makes features updates an overwhelming endeavor to maintain. Forking is the correct approach to deal with external/remote dependencies but it's critical to know exactly what's your technology footprint to manage.

This automation by default imports the default/latest version that is published. If a specific hash commit is present/provided as either a configuration or an execution parameter, then this commit is extracted and remains as the intended/targeted version to be used.

It dynamically processes a project-specific JSON-based configuration file, making it highly adaptable and reusable for DevOps and CI/CD workflows.
At execution time, these custom JSON-driven configurations can be override (see: execution examples).
**Note**: There is an effort in place to extend this JSON config file to include all targeted imports into a single data-structure to better manage these for a future Automated Updates functionality.

## Features
- **Dynamic Configuration**: Parses a JSON-based configuration file to set up vendor and project-specific parameters.
- **Positionless Parameter Parsing**: Flexible parameter handling with `--key=value` syntax and dynamic parameter override is available.
- **Git Repository Management**: Automates cloning, extracting, purging, and reconfiguring GitHub Action repositories.
- **Content Processing**: Finds and modifies files to update references based on the configuration to self-references are updated.
- **Verbose Output**: Provides detailed feedback for debugging and tracking operations plus override/remove existing data-imports.
- **Error Handling**: Displays clear warnings and exits gracefully under failure conditions with standardized error types.

## Requirements
- Bash (version 4.0/5.0+ or later)
- [jq](https://stedolan.github.io/jq/) (JSON processor) -> version: jq-1.7.1
- Git (version 2.47.0 or later)

---

## Installation
1. Clone this repository:
```console
$ local_bin="${HOME}/.local/bin" ;
$ project="${local_bin}/import-projects" ;
$ mkdir -p "${project}" ;
$ git clone https://github.com/<organization>/${project}.git "${project}" ;
```

---

2. Ensure the script has executable permissions:
```console
$ export PATH="${PATH}:${project}" ;
$ cd "${project}" ;
$ chmod +x ./import-project.shell ;
$ ln -sv ./import-project.shell ./import-project ;
```
**Note**: Please, make sure that both the Shell/Bash script and the JSON-based configuration file for the script are named the same.
The application does expect both components to exist in the same location unless a custom configuration's path is provided.

---

3. Performing operations in a safe-environment:
```console
$ cd ./prime-reportstream ;
$ import-project --help ;
```

---

4. Creating custom project-specific configurations for different imports.
If a full-path for this GitHub Actions' configurations is not provided, the application will seek by default for configurations into the `~/.local/.github/configs/` folder:

```console
$ github_configs="${HOME}/.local/.github/configs" ;
$ configs="${github_configs}/<github-owner>/<github-repo>" ;
$ mkdir -p "${configs}" ;
$ export PATH="${PATH}:${configs}" ;
$ # echo -e "\nPath:" && echo "${PATH}" | tr ':' '\n' ;
```

---

5. Create this file structure for the GitHub-Vendor and Repository:
```console
$ mkdir -p 'josiahsiegel' ;
$ touch josiahsiegel/azviz-action.json ;
```

```console
$ tree ~/.local/.github/configs/ ;
└── josiahsiegel
    └── azviz-action.json

1 directories, 1 file
```

### Example
#### JSON Configuration File (`josiahsiegel/azviz-action.json`)
```json
{
  "vendor": {
    "name": "JosiahSiegel",
    "repo": "AzViz-action",
    "version": "v1.0.3",
    "commit": "663e24299a6336f1ff8dbddadfac1ba5d462f731aaa"
  },
  "project": {
    "owner": "CDCgov",
    "repo": "prime-reportstream",
    "team": "devsecops",
    "author": "emvaldes",
    "action": "azviz"
  },
  "reload": false,
  "verbose": true,
  "changes": [
    {
      "search": "${vendor_name}/${vendor_repo}/actions/",
      "replace": "${project_owner}/${project_path}/"
    },
    {
      "search": "${vendor_name}/${vendor_repo}",
      "replace": "${project_owner}/${project_path}"
    },
    {
      "search": "${vendor_version}",
      "replace": "${vendor_commit}"
    },
    {
      "search": "actions/${project_action}/workflows/",
      "replace": "workflows/${project_action}--"
    }
  ]
}
```

These environment variables will be transformed in-realtime during execution:

```console
Content Changes: [
  {
    "search": "JosiahSiegel/AzViz-action/actions/",
    "replace": "CDCgov/prime-reportstream/.github/actions/azviz/"
  },
  {
    "search": "JosiahSiegel/AzViz-action",
    "replace": "CDCgov/prime-reportstream/.github/actions/azviz"
  },
  {
    "search": "v1.0.3",
    "replace": "663e24299a6336f1ff8dbddadfac1ba5d462f731aaa"
  },
  {
    "search": "actions/azviz/workflows/",
    "replace": "workflows/azviz--"
  }
]
```

### JSON Configuration Attributes
The JSON configuration file must include the following sections:

| Vendor | Type | Description |
|-|-|-|
| --**name** | String | GitHub project organization or owner. |
| --**repo** | String | GitHub target repository name to be imported. |
| --**version** | String | GitHub version or tag (e.g., `v1.0.3`) to be imported. |
| --**commit** | String | GitHub hash-commit to be extracted (if required). |

| Project | Type | Description |
|-|-|-|
| --**owner** | String | GitHub project organization or owner. |
| --**repo** | String | GitHub target project hosting imported GitHub Action. |
| --**team** | String | DevOps Team operating these project's Action imports. |
| --**author** | String | DevOps Engineer performing these import operations. |
| --**action** | String | Optional parameter to rename the imported repository. |

| Custom | Type | Description |
|-|-|-|
| --**config** | String | Path to a custom JSON configuration file (optional). |
| --**reload** | Boolean | Purge existing repository content (pre-cloning). |
| --**verbose** | Boolean | Enables detailed output for debugging and tracking. |

| Changes | Type | Description |
|-|-|-|
| --**search** | Custom | Define patterns to be replaced (text, variables, regex). |
| --**replace** | Custom | Define replace patterns (text, variables, regex). |

### Output
- The script clones the GitHub repository defined in the JSON file or other parameters can be provided in real-time during execution/invocation.
- Processes files to update references based on vendor and project configuration.
- Displays logs for each action when `--verbose` is enabled or otherwise is ignored. The JSON-based configuration is supposed to pre-define this behavior but the script will need to be adjusted.

---

6. Create a prototyping/testing environment to evaluate the process:

```console
$ testing="prime-reportstream/.github/actions" ;
$ mkdir -p "${testing}" ;
$ touch ${testing}/.gitignore ;
```

This will allow you to import the target GitHub Repository (Action) into a fake environment (does not contain an actual project).
- Testing your workflow and determine if the imported GitHub Repository (Action) will require further changes other than those included by default.
- Once you are done, then make sure to switch to an actual local repository for your project and perform the actual importing and publishing operations.

```console
$ alias ctree='tree -FCla --prune -I .git' ;
$ devops: prime-reportstream (master) $ ctree ;
./
└── prime-reportstream/
    └── .github/
        └── actions/
            └── .gitignore

3 directories, 1 file
```

---

This automated framework has a built-in helper (assistant) that handles all help related requests.
It uses a set of predefined built-in features `help`, `examples`, `wizard` and `info`. See example:

``` console
$ import-project --help ;
Script-name: import-project

Required    --git-owner         Vendor GitHub Project owner
            --git-name          Vendor GitHub Repo name
            --git-version       Vendor GitHub Action's version
            --git-commit        Vendor GitHub Action's commit-id

Optional    --config            GitHub Import Project configuration
            --git-org           GitHub Organization name
            --git-repo          GitHub project repository
            --git-action        GitHub import project's name
            --examples          Display script's execution options
            --wizard            Parse user-input to execute command
            --info              Project credits and online references
            --help              Show this help message and exits

Usage:

import-project.shell --config="josiashsiegel/azviz-action" \
                     --git-owner="JosiahSiegel" \
                     --git-name="AzViz-action" \
                     --git-version="v1.0.3" \
                     --git-commit="663e24299a6336f1ff8dbddadfac1ba5d462f731" \
                     --git-org="CDCgov" \
                     --git-repo="prime-reportstream" \
                     --git-action="azviz" \
;
```

#### This JSON-file configuration drives these support features:

``` json
{
    "script": {
        "headers": {
            "interview": "Please, answer the following questions"
        },
        "required": [
            "git-owner",
            "git-name",
            "git-version",
            "git-commit"
        ],
        "optional": [
            "git-org",
            "git-repo",
            "git-action"
        ],
        "examples": [
            [
                "git-owner",
                "git-name",
                "git-version",
                "git-commit",
                "git-org",
                "git-repo",
                "git-action"
            ]
        ],
        "info": {
            "service": {
                "id": "github.com",
                "domain": "CDCgov",
                "repo": "prime-reportstream",
                "path": "blob/master/devsecops/import-project.shell"
            },
            "team": {
                "id": "devsecops",
                "name": "DevSecOps Team"
            },
            "devsecops": [
                {
                    "name": "Matt Szubrycht",
                    "email": "matt.szubrycht@aquia.io",
                    "role": "Director of DevSecOps & SRE"
                },
                {
                    "name": "Eduardo Valdes",
                    "email": "eduardo.valdes@aquia.io",
                    "role": "DevSecOps Engineer"
                },
                {
                    "name": "Scott Zimmerman",
                    "email": "scott.zimmerman@aquia.io",
                    "role": "Senior GRC Engineer"
                },
                {
                    "name": "Beth Beza",
                    "email": "beth.beza@aquia.io",
                    "role": "Mid-Level Security Analyst"
                }
            ]
        }
    },
    "params": {
        "config": {
            "value": "josiahsiegel/azviz-action",
            "query": "Project Configuration",
            "message": "GitHub Import Project configuration"
        },
        "git-owner": {
            "value": "JosiahSiegel",
            "query": "Project Owner",
            "message": "Vendor GitHub Project owner"
        },
        "git-name": {
            "value": "AzViz-action",
            "query": "GitHub Repo Name",
            "message": "Vendor GitHub Repo name"
        },
        "git-version": {
            "value": "v1.0.3",
            "query": "Action Version",
            "message": "Vendor GitHub Action's version"
        },
        "git-commit": {
            "value": "663e24299a6336f1ff8dbddadfac1ba5d462f731",
            "query": "Action Commit-ID",
            "message": "Vendor GitHub Action's commit-id"
        },
        "git-org": {
            "value": "CDCgov",
            "query": "Project Organization",
            "message": "GitHub Organization name"
        },
        "git-repo": {
            "value": "prime-reportstream",
            "query": "Project Repository",
            "message": "GitHub project repository"
        },
        "git-action": {
            "value": "azviz",
            "query": "Project Name",
            "message": "GitHub import project's name"
        },
        "verbose": {
            "message": "Enabling output's verbosity"
        }
    },
    "helper": {
        "help": {
            "message": "Show this help message and exits"
        },
        "info": {
            "message": "Project credits and online references"
        },
        "examples": {
            "message": "Display script's execution options"
        },
        "wizard": {
            "message": "Parse user-input to execute command"
        }
    }
}
```

---

## Usage
### Command Syntax
```bash
$ import-project \
  --config="josiahsiegel/azviz-action" \
  --git-owner="JosiahSiegel" \
  --git-name="AzViz-action" \
  --git-version="v1.0.3" \
  --git-commit="663e24299a6336f1ff8dbddadfac1ba5d462f731";
  --git-org="CDCgov" \
  --git-repo="prime-reportstream"  \
  --git-action="azviz" \
  --reload \
  --verbose
;
```
or just execute one-liner command (JSON-based configuration).
``` bash
$ import-project ;
```

## Workflow
The script follows these execution steps:

``` bash
## Backing-up Application Input-params:
export params="${@}";

export script_file="$(pwd)/${0#*\/}";
export script_path="$( dirname "${0}" )";
## echo -e "Script Path: ${script_path}";

export script_name="$( basename "${0}" )";
## echo -e "Script Name: ${script_name}";

export script_helper="${script_path}/script-helper.shell";
## echo -e "Script Helper: ${script_helper}";

export project_configs="${HOME}/.local/.github/configs";
## echo -e "Project Configs: ${project_configs}";

## Executing script's workflow:
import_config "${@}";
import_project "${@}";
```

1. **Configuration Loading**:
  - The script dynamically corrects the use of `~/` as reference to the ${HOME} environment variable.
  - Reads the JSON file specified by the `--config` argument or loads default configuration. A custom JSON file will be used at any time if none is provided which makes this a very adaptable tool.
  - Validates the JSON file exists if not found then the application expects execution parameters.
  - Validates the presence and structure of the JSON file (expected attributes).

2. **Environment Variable Initialization**:
  - Dynamically extracts vendor and project information from the JSON configuration or dynamically provided during execution/invokation.
  - Sets environment variables dynamically for later use across the script.

3. **Evaluate custom parameters**:
  - Validates all execution params to override JSON-based configurations.
  - The application lists the final configuration to document which default/custom parameters are used.
  - Dynamically constructs source GitHub Repository path.
  - Configures project path location to be use in updating content.

4. **Evaluate current working directory**:
  - The system determines if the current path is correct to import project.
  - Determine if current working path is a valid GitHub Repository to proceed.

5. **Repository Management**:
  - Evaluates if the active Git branch is "master" or "main" to determine if it should checkout a correct branch. This behavior ensures that it will never work on neither "master" nor "main".
  - If the `--reload` attribute is set to `true`, the script purges previous import's content; otherwise, exits if not empty aborting the process to make sure that current work is not lost/erased.
  - Clone the source GitHub Repository (Action) into the .github/actions/<package> folder.
  - Determines if a **Hash Commit** is referenced/provided and extracts it from cloned repo.
  - Provides a one-liner summary of all the imported repo's log entries (reference).

6. **Environment Management**:
  - Disables the `.git` and `.github` folders to ensure they are not operational.
  - Appends these as entries to a `.gitignore` file (create one if none exists).
  - Initialize a baseline as a local commit to ensure a revert point exists to reset.

7. **Processing Updates/Changes**:
  - Identifies all files in the project directory, excluding `.git` and `.github` directories.
  - Updates external references with the provided configuration (e.g., owner, names, versions).
  - Finally, the application creates a second commit with these basic configuration changes.

8. **Completion**:
  - Outputs logs for each processed file and successful operations.
  - Exits gracefully, displaying any warnings if applicable.

**Note**: At any point in time, the script will abort if a warning function is used to ensure consistency in safety of using this script and avoid any un-expected behaviors.

## Functions
#### `warning`
Displays a warning message with optional error handling. Defines a consistent behavior and leverages the use of the `display_message` function to pass `--prefix` (`Warning: `), `--message` and `--suffix`. It results in the execution of printing an error code if `--verbose` is defined as `true`.

#### `import_config`
Parses the JSON configuration file and sets environment variables. This is the core of the application as it's defining the configuration sources. If none is provided or the default configuration is missing the script will abort. The script will dynamically generate new settings based on this loaded configuration.
The use of `jq` is present to ensure these environment variables are imported.

#### `download_repository`
Manages cloning and purging of the GitHub repository. This specific functionality will ensure that current working path is within the expected repository or otherwise will abort exiting the script.
If the JSON configuration is set to reload (override) the existing content, it will do so and let you know it did.

#### `import_project`
This is the core functionality in the script as it orchestrates all operations and workflow. It processes the repository files and updates content based on the configuration.

## Error Handling
The script includes robust error handling:
- **Missing JSON Configuration**: Displays a warning and exits with a specific error code.
- **Invalid JSON Format**: Displays an error message and exits.
- **Git Failures**: Logs detailed error output for failed `git` commands.
- **Abort Execution**: It will abort at any time a warning (caused by an error) is encountered.

## Best Practices
- Ensure the JSON configuration file is correctly formatted and includes all required fields.
- Use the `--verbose` flag during the first run to understand the script's behavior.
- Regularly update dependencies such as `jq` and `git` to avoid compatibility issues.

## Contributing
Contributions are welcome!
We aim to eventually make these functionalities part of their own internal/public repositories. Please fork the repository and create a pull request with your improvements or fixes.

## License
This script is licensed under the [MIT License](LICENSE).

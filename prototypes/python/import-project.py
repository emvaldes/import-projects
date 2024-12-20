import os
import json
import argparse
import shutil

# Utility Functions
def display_message(message='', prefix='', suffix='', verbose=True):
    if verbose:
        print(f"{prefix}{message}{suffix}")

def warning(message='', error_id=None, verbose=True):
    if verbose:
        display_message(message=message, prefix='Warning: ')
    if error_id is not None:
        raise SystemExit(error_id)

def newline(verbose=True):
    if verbose:
        print()

def import_config(config_file, verbose=True):
    if not config_file.endswith('.json'):
        config_file += '.json'
    if not os.path.exists(config_file):
        warning(f"Configuration file {config_file} is missing!", error_id=1, verbose=verbose)
    with open(config_file, 'r') as file:
        config = json.load(file)
    for key, value in config.items():
        os.environ[key] = str(value)
    if verbose:
        display_message(message=f"Imported configuration from {config_file}")

def apply_transformations(config_file, target_dir, verbose=True):
    with open(config_file, 'r') as file:
        config = json.load(file)

    for filename, replacements in config.items():
        target_file = os.path.join(target_dir, filename)
        if not os.path.exists(target_file):
            warning(f"Target file {target_file} does not exist!", verbose=verbose)
            continue

        # Read the content of the file
        with open(target_file, 'r') as f:
            content = f.read()

        # Apply replacements
        for placeholder, value in replacements.items():
            content = content.replace(f"${{{placeholder}}}", value)

        # Write the updated content back to the file
        with open(target_file, 'w') as f:
            f.write(content)

        if verbose:
            display_message(f"Applied transformations to {target_file}")

def setup_project_structure(source_dir, destination_dir, verbose=True):
    if not os.path.exists(source_dir):
        warning(f"Source directory {source_dir} does not exist!", error_id=2, verbose=verbose)
    if os.path.exists(destination_dir):
        shutil.rmtree(destination_dir)
    shutil.copytree(source_dir, destination_dir)
    if verbose:
        display_message(f"Copied project structure from {source_dir} to {destination_dir}")

def parse_arguments():
    parser = argparse.ArgumentParser(description='Process some parameters.')
    parser.add_argument('--config', type=str, required=True, help='Configuration file')
    parser.add_argument('--target-dir', type=str, required=True, help='Target directory for transformations')
    parser.add_argument('--source-dir', type=str, required=True, help='Source directory for project structure')
    parser.add_argument('--destination-dir', type=str, required=True, help='Destination directory for project setup')
    parser.add_argument('--verbose', action='store_true', help='Enable verbose output')
    return parser.parse_args()

def main():
    args = parse_arguments()

    # Import environment variables from the configuration file
    import_config(args.config, verbose=args.verbose)
    newline(verbose=args.verbose)

    # Set up project structure
    setup_project_structure(args.source_dir, args.destination_dir, verbose=args.verbose)
    newline(verbose=args.verbose)

    # Apply transformations to files in the target directory
    apply_transformations(args.config, args.target_dir, verbose=args.verbose)
    newline(verbose=args.verbose)

if __name__ == '__main__':
    main()

import os
from pathlib import Path
from ruamel.yaml import YAML

def rename_key_in_yaml(file_path, old_key='data', new_key='extra'):
    yaml = YAML()
    yaml.preserve_quotes = True  # optional, preserves quotes
    yaml.indent(mapping=2, sequence=4, offset=2)

    with open(file_path, 'r', encoding='utf-8') as f:
        data = yaml.load(f)

    if not isinstance(data, dict):
        return False  # Skip files that don't have a YAML dict at top level

    if old_key in data:
        # Rename key while preserving order and comments
        data[new_key] = data.pop(old_key)
        with open(file_path, 'w', encoding='utf-8') as f:
            yaml.dump(data, f)
        print(f"Updated key in: {file_path}")
        return True

    return False

def process_yaml_files_in_directory(directory):
    directory = Path(directory)
    yaml_files = directory.rglob('*.yml')  # also handles *.yaml next
    yaml_files = list(yaml_files) + list(directory.rglob('*.yaml'))

    for file_path in yaml_files:
        try:
            rename_key_in_yaml(file_path)
        except Exception as e:
            print(f"Error processing {file_path}: {e}")

if __name__ == "__main__":
    import sys
    if len(sys.argv) != 2:
        print("Usage: python rename_yaml_key.py <directory>")
        sys.exit(1)

    directory = sys.argv[1]
    process_yaml_files_in_directory(directory)

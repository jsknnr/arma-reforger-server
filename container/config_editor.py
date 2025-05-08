#!/usr/bin/env python3
# Quick helper script to edit update server_config.json file
import json
import base64
import sys
import argparse

def update_config_file(file_path: str, key: str, new_value: str) -> None:
    """
    Update a key in a nested configuration file with a new value.
    :param file_path: The path to the configuration file
    :param key: The key to update (supports dot notation for nested keys)
    :param new_value: The new value for the key
    :return: None
    """
    try:
        with open(file_path, 'r') as file:
            config = json.load(file)

        # Support nested keys using dot notation
        keys = key.split('.')
        current = config

        # Convert string representations of bool and int to their respective types
        if new_value.lower() == 'true':
            new_value = True
        elif new_value.lower() == 'false':
            new_value = False
        elif new_value.isdigit():
            new_value = int(new_value)

        # Traverse the configuration dictionary to find and validate the key
        for k in keys[:-1]:
            if k in current:
                current = current[k]
            else:
                raise KeyError(f"Key '{key}' not found in configuration at {file_path}")

        # special case for mods key
        if key == 'game.mods':
            # Decode the base64 string
            decoded_value = base64.b64decode(new_value).decode('utf-8')
            try:
                # Attempt to load the decoded string as JSON
                mods = json.loads(decoded_value)
                # Check if the decoded value is a list
                if isinstance(mods, list):
                    # Update the mods key with the new list
                    current[keys[-1]] = mods
                else:
                    raise ValueError("Decoded value is not a valid list")
            except json.JSONDecodeError:
                raise ValueError("Decoded value is not valid JSON")
        # If not mods, is our key a list?
        elif isinstance(current[keys[-1]], list):
            # Convert comma-separated string to list and set the value
            current[keys[-1]] = new_value.split(',')
        # If not a list, set the new value directly
        else:
            current[keys[-1]] = new_value 

        # Write the updated configuration back to the file
        with open(file_path, 'w') as file:
            json.dump(config, file, indent=4)

        print(f"Updated '{key}' in '{file_path}' to: {new_value}")
        sys.exit(0)

    except Exception as error:
        print(f"ERROR updating key '{key}' at '{file_path}' due to: {error}")
        sys.exit(1)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Update configuration files')
    parser.add_argument('-c', '--config', type=str, required=True, help='The path to the configuration file')
    parser.add_argument('-k', '--key', type=str, required=True, help='The key to update (use dot notation for nested keys)')
    parser.add_argument('-v', '--value', type=str, required=True, help='The new value for the key')
    args = parser.parse_args()

    update_config_file(args.config, args.key, args.value)

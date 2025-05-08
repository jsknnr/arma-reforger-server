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

    except Exception as error:
        print(f"ERROR updating key '{key}' at '{file_path}' due to: {error}")
        sys.exit(1)

def __recursive_dict_update(data_dict):
    """
    Recursively update a nested dictionary, removing any keys that contain empty strings or None values.
    :param dict: The dictionary to update
    :return: The updated dictionary
    """
    for key, value in list(data_dict.items()):
        if isinstance(value, dict):
            data_dict[key] = __recursive_dict_update(value)
        elif value in ["", None]:
            del data_dict[key]
    return data_dict

def sanitize_config(file_path: str) -> None:
    """
    Sanitize the configuration file by removing any keys that contain empty stings or None values.
    :param file_path: The path to the configuration file
    :return: None
    """
    try:
        with open(file_path, 'r') as file:
            config = json.load(file)

        # Remove keys with empty strings or None values
        sanitized_config = __recursive_dict_update(config)

        # Final pass for rcon key because it's a pain in the ass
        if not sanitized_config['rcon'].get('password'):
            # Remove the rcon key if password is empty
            del sanitized_config['rcon']

        # Write the sanitized configuration back to the file
        with open(file_path, 'w') as file:
            json.dump(sanitized_config, file, indent=4)

        print(f"Sanitized '{file_path}'")

    except Exception as error:
        print(f"ERROR sanitizing '{file_path}' due to: {error}")
        sys.exit(1)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Update configuration files')
    parser.add_argument('-c', '--config', type=str, required=True, help='The path to the configuration file')
    parser.add_argument('-k', '--key', type=str, help='The key to update (use dot notation for nested keys)')
    parser.add_argument('-v', '--value', type=str, help='The new value for the key')
    parser.add_argument('-s', '--sanitize', action='store_true', help='Sanitize the configuration file by removing empty keys')
    args = parser.parse_args()

    if args.sanitize:
        sanitize_config(args.config)
    elif args.key and args.value:
        update_config_file(args.config, args.key, args.value)
    else:
        print("ERROR: Please provide a configuration file, key, and value to update or a configuration file and the sanitize flag.")
        parser.print_help()
        sys.exit(1)

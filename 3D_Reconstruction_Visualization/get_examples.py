#!/usr/bin/env python3

from pathlib import Path
from urllib import request
import os

endpoint = 'https://api.figshare.com/v2/file/download/'
ex_list = {'oct_snr_lin.npz': '57374797',
           'tangent_modulus_xyz.npz': '57374800'
           }


def download_examples():
    """
    Download all example files from figshare
    """
    # Prepare result folder
    example_folder = Path("3D_Reconstruction_Visualization/example_data")
    example_folder.mkdir(parents=True, exist_ok=True)

    # Download each file
    for filename, file_id in ex_list.items():
        file_path = example_folder / filename

        if not file_path.is_file():
            print(f"Downloading {filename}...")
            try:
                req = request.Request(endpoint + file_id)
                file_path.write_bytes(request.urlopen(req).read())
                print(f"Successfully downloaded {filename}")
            except Exception as e:
                print(f"Error downloading {filename}: {e}")
        else:
            print(f"{filename} already exists, skipping download")

    return example_folder


if __name__ == '__main__':
    download_examples()
#!/usr/bin/env python
from __future__ import absolute_import, division, print_function

import sys
import json
import os
from collections import defaultdict

import numpy as np
from PIL import Image

import imagehash

hashfuncs = [
    ("ahash", imagehash.average_hash),
    ("phash", imagehash.phash),
    ("dhash", imagehash.dhash),
    ("whash", imagehash.whash),
    # ("whash-db4", lambda img: imagehash.whash(img, mode="db4")),
    # ("colorhash", imagehash.colorhash),
]


def alpharemover(image):
    if image.mode != "RGBA":
        return image
    canvas = Image.new("RGBA", image.size, (255, 255, 255, 255))
    canvas.paste(image, mask=image)
    return canvas.convert("RGB")


def image_loader(hashfunc, hash_size=8):
    def function(path):
        image = alpharemover(Image.open(path))
        return hashfunc(image)

    return function


def with_ztransform_preprocess(hashfunc, hash_size=8):
    def function(path):
        image = alpharemover(Image.open(path))
        image = image.convert("L").resize((hash_size, hash_size), Image.LANCZOS)
        data = image.getdata()
        quantiles = np.arange(100)
        quantiles_values = np.percentile(data, quantiles)
        zdata = (np.interp(data, quantiles_values, quantiles) / 100 * 255).astype(
            np.uint8
        )
        image.putdata(zdata)
        return hashfunc(image)

    return function


hashfuncopeners = [(name, image_loader(func)) for name, func in hashfuncs]
hashfuncopeners += [
    (name + "-z", with_ztransform_preprocess(func))
    for name, func in hashfuncs
    if name != "colorhash"
]


def generate_json_output(files):
    """Generate JSON output for demo website"""
    # Process all images and collect hash data
    algorithm_clusters = {
        "ahash": [],
        "phash": [],
        "dhash": [],
        "whash": [],
        "ahash-z": [],
        "phash-z": [],
        "dhash-z": [],
        "whash-z": [],
    }

    # Store all hash results
    image_hashes = {}

    for path in files:
        try:
            hashes = {}
            for name, hashfuncopener in hashfuncopeners:
                try:
                    hash_value = str(hashfuncopener(path))
                    hashes[name] = hash_value
                except Exception as e:
                    print(f"Error processing {path} with {name}: {e}", file=sys.stderr)
                    hashes[name] = "ERROR"
            image_hashes[path] = hashes
        except Exception as e:
            print(f"Error processing {path}: {e}", file=sys.stderr)

    # Group images by hash for each algorithm
    for algorithm in [
        "ahash",
        "phash",
        "dhash",
        "whash",
        "ahash-z",
        "phash-z",
        "dhash-z",
        "whash-z",
    ]:
        hash_groups = defaultdict(list)

        for path, hashes in image_hashes.items():
            hash_value = hashes.get(algorithm)

            if (
                hash_value
                and hash_value != "ERROR"
                and hash_value != "0000000000000000"
            ):
                hash_groups[hash_value].append(path)

        # Create clusters for groups with more than one image
        for hash_value, paths in hash_groups.items():
            if len(paths) > 1:
                images = []
                for path in paths:
                    file_name = os.path.basename(path).replace(".png", ".svg")

                    # Generate GitHub URL based on repository pattern
                    repo_url = None
                    image_url = None

                    # Extract repo info from the path structure
                    parts = path.split("/")
                    if parts:
                        repo_dir = parts[0]
                        file_path = "/".join(parts[1:]).replace(".png", ".svg")

                        # Try to guess repo from directory name
                        if "eva-icons" in repo_dir:
                            repo_url = "https://github.com/akveo/eva-icons"
                            image_url = f"https://raw.githubusercontent.com/akveo/eva-icons/master/{file_path}"
                        elif "feather" in repo_dir:
                            repo_url = "https://github.com/feathericons/feather"
                            image_url = f"https://raw.githubusercontent.com/feathericons/feather/master/{file_path}"
                        elif "heroicons" in repo_dir:
                            repo_url = "https://github.com/tailwindlabs/heroicons"
                            image_url = f"https://raw.githubusercontent.com/tailwindlabs/heroicons/master/{file_path}"
                        elif "lucide" in repo_dir:
                            repo_url = "https://github.com/lucide-icons/lucide"
                            image_url = f"https://raw.githubusercontent.com/lucide-icons/lucide/master/{file_path}"
                        # Skip entries that don't match known repositories

                    # Only add if we have valid GitHub URLs
                    if repo_url and image_url:
                        images.append(
                            {
                                "name": file_name,
                                "url": image_url,
                                "repoUrl": repo_url,
                            }
                        )

                # Only add cluster if we have valid images
                if images:
                    algorithm_clusters[algorithm].append(
                        {
                            "hash": hash_value,
                            "count": len(images),
                            "images": images,
                        }
                    )

    # Create final JSON structure
    json_output = {
        "algorithm": "python",
        "clusters": algorithm_clusters,
    }

    # Write to example website directory
    output_path = "../example-website/src/lib/data/github-icons-python.json"

    # Create directories if they don't exist
    os.makedirs(os.path.dirname(output_path), exist_ok=True)

    with open(output_path, "w") as f:
        json.dump(json_output, f, indent=2)

    print(f"Generated {output_path} with {len(files)} images processed")
    for algorithm, clusters in algorithm_clusters.items():
        print(f"  {algorithm}: {len(clusters)} clusters")


def read_png_files():
    """Read PNG files from the text file"""
    try:
        with open("png_files.txt", "r") as f:
            lines = f.readlines()
        return [line.strip() for line in lines if line.strip()]
    except FileNotFoundError:
        print("Error: png_files.txt not found. Run the shell script first.")
        sys.exit(1)


def main():
    # Read PNG files from the text file
    files = read_png_files()

    if not files:
        print("Error: No PNG files found in png_files.txt")
        sys.exit(1)

    print(f"Found {len(files)} PNG files for hashing")
    generate_json_output(files)


if __name__ == "__main__":
    main()

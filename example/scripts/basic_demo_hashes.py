#!/usr/bin/env python
from __future__ import absolute_import, division, print_function

import sys
import json
import os
from PIL import Image
import imagehash

hashfuncs = [
    ("ahash", imagehash.average_hash),
    ("phash", imagehash.phash),
    ("dhash", imagehash.dhash),
    ("whash", imagehash.whash),
]


def alpharemover(image):
    if image.mode != "RGBA":
        return image
    canvas = Image.new("RGBA", image.size, (255, 255, 255, 255))
    canvas.paste(image, mask=image)
    return canvas.convert("RGB")


def main():
    if len(sys.argv) < 2:
        print("Usage: python basic_demo_hashes.py <image_file1> [image_file2] ...")
        sys.exit(1)

    files = sys.argv[1:]
    image_hashes = []

    for path in files:
        try:
            image = alpharemover(Image.open(path))
            file_name = os.path.basename(path)

            # Generate GitHub URL for the image
            image_url = f"https://raw.githubusercontent.com/vaibhavhrt/dart_imagehash/main/sample_images/{file_name}"

            hashes = {}

            # Calculate all hash types
            for name, hashfunc in hashfuncs:
                try:
                    hash_value = str(hashfunc(image))
                    hashes[name] = hash_value
                except Exception as e:
                    print(f"Error processing {path} with {name}: {e}", file=sys.stderr)
                    hashes[name] = "ERROR"

            image_hashes.append(
                {
                    "name": file_name,
                    "url": image_url,
                    "hashes": hashes,
                }
            )
        except Exception as e:
            print(f"Error processing {path}: {e}", file=sys.stderr)

    # Create final JSON structure
    json_output = {
        "algorithm": "python",
        "images": image_hashes,
    }

    # Write to example website directory
    output_path = "../example-website/src/lib/data/basic-demo-python.json"

    # Create directories if they don't exist
    os.makedirs(os.path.dirname(output_path), exist_ok=True)

    with open(output_path, "w") as f:
        json.dump(json_output, f, indent=2)

    print(f"Generated {output_path} with {len(files)} images processed")


if __name__ == "__main__":
    main()

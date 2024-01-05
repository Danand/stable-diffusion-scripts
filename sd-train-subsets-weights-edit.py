#!/usr/bin/env python3
#
# Interactive editor for training image subset weights.

from os import rename
from os.path import basename, dirname
from sys import argv
from typing import List
from math import floor, gcd
from glob import glob
from json import dumps

class Subset:
    def __init__(self):
        self.path: str = ""
        self.image_count: int = 0
        self.repeats: int = 0
        self.weight: float = 0.0

def get_image_count_max(subsets: List[Subset]) -> int:
    return max(subsets, key=lambda subset: subset.image_count).image_count

def load_subsets(images_dir: str) -> List[Subset]:
    subset_dirs = glob(f"{images_dir}/*")

    subsets: List[Subset] = []

    for subset_dir in subset_dirs:
        subset_image_paths = glob(f"{subset_dir}/**.jpg")

        subset = Subset()

        subset.path = subset_dir
        subset.image_count = len(subset_image_paths)

        subsets.append(subset)

    image_count_max = get_image_count_max(subsets)

    for subset in subsets:
        subset.weight = float(subset.image_count) / float(image_count_max)

    return subsets

def print_weights(subsets: List[Subset]) -> None:
    print()
    print("Current weights:")

    subsets_json_serializable = [{ "repeats": subset.repeats } for subset in subsets]
    print(dumps(subsets_json_serializable, indent=4))

    print()

def parse_subset_name(subset_basename: str) -> str:
    if ("_" in subset_basename):
        parts = subset_basename.split("_")

        if (parts[0].isnumeric()):
            return "_".join(parts[1:])

    return subset_basename

def apply_subsets_changes(subsets: List[Subset]) -> None:
    for subset in subsets:
        subset_basename = basename(subset.path)
        subset_name = parse_subset_name(subset_basename)
        subset_dirname = dirname(subset.path)

        rename(subset.path, f"{subset_dirname}/{subset.repeats}_{subset_name}")

def get_list_gcd(numbers: List[int]) -> int:
    result = numbers[0]

    for num in numbers[1:]:
        result = gcd(result, num)

    return result

def fill_subsets_repeats(subsets: List[Subset]) -> None:
    image_count_max = get_image_count_max(subsets)

    for subset in subsets:
        subset.repeats = floor((image_count_max * subset.weight) / subset.image_count)

    repeats_gcd = get_list_gcd([subset.repeats for subset in subsets])

    for subset in subsets:
        subset.repeats = floor(subset.repeats / float(repeats_gcd))

images_dir = argv[1] if len(argv) > 1 else "./images"

subsets = load_subsets(images_dir)

print_weights(subsets)

for subset in subsets:
    weight_input = input(f"Input weight for {subset.path}, current is {subset.weight:0.2f}\n> ")
    subset.weight = float(weight_input)
    print_weights(subsets)

fill_subsets_repeats(subsets)

print("Proposed changes:")

subsets_json_serializable = [subset.__dict__ for subset in subsets]
print(dumps(subsets_json_serializable, indent=4))

print()

answer = input("Confirm changes? [Y/n]: ")

if answer == "Y":
    apply_subsets_changes(subsets)

    print()
    print(dumps(glob(f"{images_dir}/*"), indent=4))

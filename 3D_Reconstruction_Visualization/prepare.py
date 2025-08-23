#!/usr/bin/env python3

from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
from scipy.ndimage import gaussian_filter
from skimage.morphology import dilation, disk, erosion
from skimage.segmentation import chan_vese


def get_data(data_path):
    # Load the raw data
    # Note: this example data is already roughly cut to size and compressed to reduce the example file size
    data_path = Path(data_path)
    print(f"Loading example file {data_path.name}")
    data = np.load(data_path)['content']
    print(f"\tApplying gaussian filter (SD=8)")
    data = gaussian_filter(data, sigma=8)
    print(f"\tLoading complete")
    return data


def get_top_view_mask(data, result_folder):
    # Find the outer perimeter (from a top-down view)
    print("Create top view mask")

    # Create a max intensity projection
    print("\tCreating max intensity projection")
    top_view = np.max(data, axis=0)

    # Apply the Chan-Vese algorithm for segmentation
    print("\tApplying Chan-Vese algorithm")
    top_view_mask = chan_vese(
        top_view,
        mu=0.8,
        lambda1=1,
        lambda2=1,
        tol=1e-3,
        max_num_iter=200,
        dt=0.5,
        init_level_set="checkerboard",
        extended_output=True,
    )[0]

    # Optimizing the mask
    print("\tRemoving holes and islands from the mask")
    footprint = disk(15)
    # Remove holes (dilation -> erosion)
    top_view_mask = dilation(top_view_mask, footprint)
    top_view_mask = erosion(top_view_mask, footprint)
    # Remove islands (erosion -> dilation)
    top_view_mask = erosion(top_view_mask, footprint)
    top_view_mask = dilation(top_view_mask, footprint)

    # Visualize the mask
    plot_path = result_folder / "top_view_mask.pdf"
    fig, axes = plt.subplots(1, 2, figsize=(8, 4))

    axes[0].imshow(top_view, vmax=np.max(data), vmin=0)
    axes[0].set_title("max intensity projection")
    axes[1].imshow(top_view_mask)
    axes[1].set_title("top view mask")
    fig.savefig(plot_path, bbox_inches="tight")
    print(f"\tVisualisation of the top view mask generated at {plot_path}")
    return top_view_mask


def generate_volumetric_mask(data, top_view_mask, result_folder):
    # Produce the volumetric mask and save it for use in visualize_data.py
    volumetric_mask_path = Path(result_folder / "mask.npz")
    print("Generating volumetric mask")
    volumetric_mask = np.zeros_like(data, dtype=bool)

    print("\tFinding the ceiling of the volumetric mask")
    # The out-most layer shows the highest values
    ceiling = np.argmax(data, axis=0)
    # Set all ceiling values to "ground" that are covered by the top-view mask
    ceiling[top_view_mask == 0] = volumetric_mask.shape[0]
    # Smooth the surface, including the transition from the top-view mask
    ceiling = gaussian_filter(ceiling, sigma=8)
    # Set all values back to "ground" that are covered by the top-view mask
    ceiling[top_view_mask == 0] = volumetric_mask.shape[0]

    # Visualize the volumetric mask ceiling
    plot_path = result_folder / "volumetric_mask_ceiling.pdf"
    fig, ax = plt.subplots(figsize=(4, 4))
    # Invert the ceiling values for a more natural height value
    im = ax.imshow(np.abs(ceiling-volumetric_mask.shape[0]))
    ax.set_title("volumetric mask ceiling")
    cb = fig.colorbar(im)
    cb.set_label("height")
    fig.savefig(plot_path, bbox_inches="tight")
    print(f"\tVisualisation of the volumetric mask ceiling generated at {plot_path}")

    # Set the values in the volumetric mask based on the ceiling values
    print("\tSetting volumetric mask values based on the found ceiling")
    # iterating over the 2D space
    for idx_x in range(ceiling.shape[0]):
        for idx_y in range(ceiling.shape[1]):
            # setting all values from ceiling to ground to True at idx_x, idx_y
            volumetric_mask[ceiling[idx_x, idx_y]:, idx_x, idx_y] = True

    # Saving the volumetric mask
    print(f"\tSaving the volumetric mask to {volumetric_mask_path}")
    np.savez_compressed(volumetric_mask_path, volumetric_mask=volumetric_mask)


if __name__ == '__main__':
    # Prepare result folder
    result_folder = Path("results")
    result_folder.mkdir(parents=True, exist_ok=True)

    # Load the necessary raw data
    data = get_data("example_data/oct_snr_lin.npz")
    # Generate the top view mask
    top_view_mask = get_top_view_mask(data, result_folder)
    # Generate the volumetric mask
    generate_volumetric_mask(data, top_view_mask, result_folder)





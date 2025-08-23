#!/usr/bin/env python3

import sys
from pathlib import Path

import numpy as np
from scipy.ndimage import gaussian_filter
from vedo import Volume, Video, Plotter


def get_data_mask(data_path, result_folder):
    # Load the raw data and volumetric mask generate with prepare.py
    # Note: this example data is already roughly cut to size and compressed to reduce the example file size
    print("Loading necessary raw data")
    data_path = Path(data_path)
    volumetric_mask_path = Path(result_folder / "mask.npz")
    print(f"\tLoading example file {data_path.name}")
    data = np.load(data_path)['content']
    print(f"\tLimiting the data range")
    data[data > 20] = 20
    data[data < 0] = -1
    print(f"\tLoading volumetric mask file {data_path.name}")
    volumetric_mask = np.load(volumetric_mask_path)['volumetric_mask']
    print(f"\tApplying the volumetric mask")
    data[volumetric_mask == 0] = -1
    print(f"\tApplying gaussian filter (SD=4)")
    data = gaussian_filter(data, sigma=4)
    return data

def setup_volume(data):
    # Create Volume and set the mode to maximum projection and the colormap to jet
    vol = Volume(data)
    vol.mode(1).cmap("jet")

    # Set the alpha levels
    vol.alpha((0.1, 0.3, 0.9, 1.0))

    # Flip it right side up
    vol.rotate_z(270)

    return vol


def visualize_interactive(data):
    # Open a window with a maximum projection rendering utilizing vedo (https://vedo.embl.es/)
    print("Show volume")

    # Prepare the volume to be rendered
    vol = setup_volume(data)

    # Create the Plotter
    plt = Plotter(bg="black", bg2="black", axes=6, offscreen=False, interactive=False,size=(1200, 800))
    # Add the volume
    plt += [vol]

    # Show the volume
    plt.show(elevation=15, zoom=1.8)
    plt.interactive().close()
    plt.close()


def visualize_animation(data, result_folder):
    # Create an animation with a maximum projection rendering utilizing vedo (https://vedo.embl.es/)
    print("Rendering an animation")
    # Prepare the volume to be rendered
    vol = setup_volume(data)

    # Create the Plotter
    plt = Plotter(bg="black", bg2="black", axes=0, offscreen=False, interactive=False, size=(1920, 1088))
    # Add the volume
    plt += [vol]

    # Prepare the video file
    video = Video(str(result_folder / "animation.mp4"))
    # Render the frames and add them to the video
    plt.show(elevation=15, zoom=2)
    video.add_frame()
    for i in range(179):
        plt.show(azimuth=2, zoom=2)
        video.add_frame()
    # Finalize the video
    video.close()
    plt.interactive().close()


if __name__ == '__main__':
    # Prepare result folder
    result_folder = Path("results")
    if not result_folder.exists():
        exit("Run prepare.py first!")

    # Load the necessary raw data
    data = get_data_mask("example_data/tangent_modulus_xyz.npz", result_folder)

    if sys.argv[1] == "--interactive":
        # Interactive view
        visualize_interactive(data)
    elif sys.argv[1] == "--animation":
        # Create an animation
        visualize_animation(data, result_folder)
    else:
        exit("Either choose --interactive or --animation")




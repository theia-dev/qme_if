#@ File(label="Input Directory", style="directory") inDir
#@ String(label="Input File Extension", value=".tif") fileExt
#@ File(label="Output Directory", style="directory") outputDir
#@ Integer(label="Rolling Ball Radius", value=50) rolling_ball_radius
#@ Integer(label="Median Filter Radius", value=2) median_radius
#@ Double(label="Gaussian Blur Sigma", value=0.5) gaussian_sigma

import os
import time
from ij import IJ, ImagePlus, ImageStack, WindowManager
from ij.io import FileSaver
from ij.plugin import Duplicator
from ij.plugin import ImageCalculator

# Initialise plugins
duplicator = Duplicator()
calculator = ImageCalculator()

# Create main output directory for the processed images
if not outputDir.exists():
    outputDir.mkdir()

# Create subdirectories for the different processing steps
# organises the output into 'background_subtracted' and 'filtered' folders
bgSubDir = os.path.join(outputDir.getAbsolutePath(), "1_background_subtracted")
filteredDir = os.path.join(outputDir.getAbsolutePath(), "2_filtered")

if not os.path.exists(bgSubDir):
    os.mkdir(bgSubDir)
if not os.path.exists(filteredDir):
    os.mkdir(filteredDir)

def saveAsTiff(image, outputFile):
    """Saves the Image as a TIFF file."""
    FileSaver(image).saveAsTiff(outputFile)

# Pre-processes multi-channel TIFFs: background subtraction + noise reduction. Saves channels individually.
for filename in os.listdir(inDir.getPath()):
    if not filename.endswith(fileExt):
        continue  # Skip non-TIFF files

    print "Processing: " + filename
    baseName = filename.replace(fileExt, "")  # Get filename without extension

    # Open the original multi-channel image
    originalImage = IJ.openImage(os.path.join(inDir.getPath(), filename))
    # Short pause, I added this because it avoids errors when reading for research storage, sometimes slow
    time.sleep(3)

    # get channel count
    numChannels = originalImage.getNChannels()

    # Loop through each channel for processing
    for channel in range(1, numChannels + 1):
        print " Processing channel " + str(channel)

        # 1. DUPLICATE CHANNEL
        # Isolate the current channel for processing
        channelImage = duplicator.run(originalImage, channel, channel, 1, 1, 1, 1)

        # 2. BACKGROUND SUBTRACTION
        # Create a copy to apply the rolling ball algorithm to
        backgroundImage = channelImage.duplicate()
        # Run Subtract Background on the copy to *create* the background profile
        IJ.run(backgroundImage, "Subtract Background...", "rolling=" + str(rolling_ball_radius) + " create")
        # Subtract the background profile from the original channel image
        resultImage = calculator.run("Subtract create", channelImage, backgroundImage)
        # Save the background-subtracted result
        outputFilename = baseName + "_Ch-" + str(channel) + "_bg-sub.tif"
        saveAsTiff(resultImage, os.path.join(bgSubDir, outputFilename))

        # 3. NOISE REDUCTION
        # Apply Median and Gaussian Blur to the background-subtracted image
        IJ.run(resultImage, "Median...", "radius=" + str(median_radius))
        IJ.run(resultImage, "Gaussian Blur...", "sigma=" + str(gaussian_sigma) + " scaled")
        # Save the final filtered image
        outputFilename = baseName + "_Ch-" + str(channel) + "_filtered.tif"
        saveAsTiff(resultImage, os.path.join(filteredDir, outputFilename))

        # 4. MEMORY MANAGEMENT
        # Close the intermediate images for this channel to free up memory
        backgroundImage.close()
        channelImage.close()
        resultImage.close()

    # Close the original image before moving to the next file
    originalImage.close()

print "All done!"
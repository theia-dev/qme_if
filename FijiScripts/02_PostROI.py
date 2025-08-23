#@ File(label="Directory of Processed Images", style="directory") imageDir
#@ String(label="Input File Extension", value=".tif") fileExt
#@ File(label="Directory of ROI ZIP files", style="directory") roiDir
#@ String(label="ROI file suffix", value="_roiset.zip") roiSuffix
#@ File(label="Output Directory for Results", style="directory") outputDir

import os
from ij import IJ, ImagePlus
from ij.io import FileSaver
from ij.plugin.frame import RoiManager
from ij.measure import ResultsTable

# Initialise the RoiManager and resultstable
rm = RoiManager.getInstance()
if not rm:
    rm = RoiManager()
rm.reset()
rt = ResultsTable.getResultsTable()

# Set measurements to include Area Fraction (critical for analysis)
IJ.run("Set Measurements...", "area mean min area_fraction display redirect=None decimal=3")
IJ.setBackgroundColor(0,0,0)

def saveAsTiff(image, outputFile):
    """Saves the Image as a TIFF file."""
    FileSaver(image).saveAsTiff(outputFile)

# Create output subdirectories
cl_roi_dir = os.path.join(outputDir.getAbsolutePath(), "CL_ROI")
cl_binary_dir = os.path.join(outputDir.getAbsolutePath(), "CL_binary")

if not os.path.exists(cl_roi_dir):
    os.mkdir(cl_roi_dir)
if not os.path.exists(cl_binary_dir):
    os.mkdir(cl_binary_dir)


# 1. PRE-LOAD ROI FILENAMES
# Get a list of all ROI zip files and create a dictionary mapping base names to full paths
roi_file_map = {}
for roi_file in os.listdir(roiDir.getAbsolutePath()):
    if roi_file.lower().endswith(roiSuffix):
        # Extract the base name by removing the '_ROISet.zip' suffix
        base_name = roi_file.lower().replace(roiSuffix, "")
        roi_file_map[base_name] = os.path.join(roiDir.getAbsolutePath(), roi_file)

# 2. PROCESS EACH IMAGE
for filename in os.listdir(imageDir.getAbsolutePath()):
    if not filename.endswith(fileExt):
        continue  # Skip non-TIFF files

    print "Processing: " + filename
    image_path = os.path.join(imageDir.getAbsolutePath(), filename)
    base_image_name = filename.replace(fileExt, "")  # Remove extension

    # 3. FIND MATCHING ROI FILE
    # Look for a ROI base name that is contained within the full image name
    matching_roi_key = None
    for roi_key in roi_file_map:
        if roi_key in base_image_name.lower():
            matching_roi_key = roi_key
            break # Found a match, stop searching

    if not matching_roi_key:
        print "  No matching ROI set found for: " + base_image_name + ". Skipping."
        continue

    roi_path = roi_file_map[matching_roi_key]
    print "  Found matching ROI: " + roi_path

    # Open the image and the ROIs
    img = IJ.openImage(image_path)
    rm.reset()
    rm.open(roi_path)

    num_rois = rm.getCount()
    if num_rois == 0:
        print "  No ROIs found in the set. Skipping."
        img.close()
        continue

    # Select all ROIs and combine them into a single selection
    roi_indices = list(range(num_rois))
    rm.setSelectedIndexes(roi_indices)
    rm.runCommand(img, "Combine") # Creates one selection from all ROIs

    # Remove signal outside the combined ROI area
    IJ.run(img, "Make Inverse", "")
    IJ.run(img, "Clear", "slice")
    IJ.run(img, "Select None", "")

    # Save the image with the ROI area kept
    output_path = os.path.join(cl_roi_dir, base_image_name + "ROIonly.tiff")
    saveAsTiff(img, output_path)

    # Apply Auto Threshold (Otsu) to create a binary image
    IJ.run(img, "Auto Threshold", "method=Otsu white")
    IJ.run(img, "Grays", "")
    # Save the binary image
    output_path = os.path.join(cl_binary_dir, base_image_name + "ROIonly_binary.tiff")
    saveAsTiff(img, output_path)

    # 4. MEASURE EACH INDIVIDUAL ROI ON THE BINARY IMAGE
    # Reset ROI manager selection and measure each ROI individually
    rm.reset()
    rm.open(roi_path) # Re-open the ROIs to get the original list
    for i in range(rm.getCount()):
        rm.select(i) # Select a single ROI
        rm.runCommand(img, "Measure") # Measure area fraction in the binary image

    # Clean up
    img.close()

# 5. SAVE ALL RESULTS
if rt.size() > 0:
    results_path = os.path.join(outputDir.getAbsolutePath(), "Results.csv")
    IJ.saveAs("Results", results_path)
    print "All done! Results saved to: " + results_path
else:
    print "All done! No results were generated. No CSV file saved."
IJ.run("Clear Results")
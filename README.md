# Scripts for the Protocol "Quantitative microelastography with co-registered microscopy: an integrated approach to study murine ovarian elasticity and composition *in situ*"

This repository contains a collection of scripts developed for the analysis described in [ref].  

- **Volume and Elasticity Extraction** (`MATLAB`)  
- **Automated Image Analysis** (ImageJ/Fiji - `Jython`)  
- **3D Reconstruction and Visualization** (`Python`)  

---

## QME Co-Registration  
This folder contains MATLAB scripts (developed using MATLAB 2023a) to extract the volume and elasticity of ovarian structures of interest, such as follicles and corpora lutea. The segmentation of follicles and corpora lutea was performed using light microscopy.  

Scripts provided by Dr Matt S Hepburn ([Google Scholar](https://scholar.google.com/citations?user=JVlWwAEAAAAJ&hl=en) | [ORCID](https://orcid.org/0000-0001-5953-4478))

---

## IF Area Ratio Quantification
This folder contains `Jython` scripts for `ImageJ/Fiji` to automate the quantification of immunofluorescence stained images. These scripts quantify the area ratio of specific markers within a given region of interest (ROI), such as the corpus luteum.


### Workflow

1. **Pre-processing (`01_Preprocess.py`):**
    * **Input:** A directory containing multi-channel TIFF files (2D images).
    * **Process:** For each channel in every image, the script performs:
        * Background subtraction (Rolling Ball algorithm).
        * Noise reduction (Median filter + Gaussian blur).
        * All parameters (radius, sigma) are set when starting the script.
    * **Output:** Saves processed single-channel TIFFs into subfolders (`1_background_subtracted/`, `2_filtered/`).

2. **Manual ROI Definition:**
    * Using the pre-processed images, manually draw ROIs in `ImageJ/Fiji` and save each set. The ROI set for an image must be named `[image_basename]_ROISet.zip`.
    * For easy processing, it is advisable to name the ROI set using the original image base name plus a consistent suffix (e.g., `_ROISet`). `02_Post_ROI.py` will automatically find the matching ROIs and images.

3. **Measurement (`02_Post_ROI.py`):**
    * **Input:**
        *   A directory of pre-processed, single-channel TIFFs from Step 1 (`2_filtered/`).
        *   A directory of the corresponding ROI `.zip` files.
   * **Process:** For each image, the script:
        * Finds its matching ROI set (see naming advise above).
        * Combines all ROIs, clears signal outside the combined area, and applies an Otsu threshold to create a binary image.
        * Measures the area fraction of the binary signal within each individual original ROI.
   * **Output:**
     * `Results.csv`: A table containing the area fraction measurement for every ROI in every image.
     * `CL_ROI/`: Images cropped to the ROIs.
     * `CL_binary/`: Binary masks of the cropped ROIs.


An immunofluorescence image (ExampleImg_IF_quant.tif) and a corresponding set of manually drawn regions of interest (ExampleImg_IF_quant_ROISet.zip) to test the script are available on [FigShare](https://figshare.com/s/1451cf0c2cf6d57b4b15).


---

## 3D Reconstruction and Visualization
This workflow uses `Python` to generate a 3D visualization of QME data.  

* `get_examples.py` download example OCT and QME data from figshare
* `prepare.py` Create a volumetric mask to segment the ovary for use in `visualize.py`
* `visualize.py` Interactive visualization of the QME data in 3D using `vedo`.  

### Libraries Used  
- **[vedo](https://vedo.embl.es/)**: Interactive 3D visualization.  
- **SciPy**: Image processing and numerical computations.  
- **scikit-image**: Advanced segmentation and image processing.  

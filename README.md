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
This folder contains scripts written in `Jython` for automated image analysis in ImageJ/Fiji. These scripts calculate the area ratio of specific markers within a region of interest (ROI), such as the corpus luteum.  


---

## 3D Reconstruction and Visualization
This workflow uses Python to generate a 3D visualization of QME data. The workflow involves:  

1. **Create volumetric mask**: Segment the ovary from OCT data using the `scikit-image` library.  
2. **Interactive inspection**: Explore the QME data in 3D using `vedo`.  
3. **Export**: Export the 3D representation in multiple formats.  

### Libraries Used  
- **[vedo](https://vedo.embl.es/)**: Interactive 3D visualization.  
- **SciPy**: Image processing and numerical computations.  
- **scikit-image**: Advanced segmentation and image processing.  

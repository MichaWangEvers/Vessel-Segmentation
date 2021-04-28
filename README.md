# Vessel-Segmentation Scientific Reports 2021
#                                                                      
# Michael Wang-Evers & Malte Casper



  If you use this software, please cite the following 2 article:

[1]Casper, M. et al. Optimization-based vessel segmentation pipeline for robust quantification of capillary networks
   in skin with optical coherence tomography angiography. Journal of biomedical optics 24, 046005 (2019).

[2]Wang-Evers, M. et al. Assessing the impact of aging and blood pressure on dermal microvasculature by reactive 
   hyperemia optical coherence tomography angiography. Scientific Reports in Review

-------------------------------------------------------------------
 Requirements
-------------------------------------------------------------------

*) Matlab v.7.1 or later with installed:

   -- Image Processing Toolbox 
   
   -- Wavelet Toolbox (optional)


-------------------------------------------------------------------
 How To Analyze Example Images
-------------------------------------------------------------------
Add selected Folders and Subfolders to Path

*) Open Main.m

   -- Select '0' or '1' to remove moving artifacts (requires Wavelet Toolbox) 
   
   -- Run the script and select samples images (Subject1_Baseline.tiff, Subject1_ReactiveHyperemia.tiff) 
   
   -- Images need to be the same size if more than one image is selected
   
   -- Initial image might take a while to process due to graph cutting procedure
   
   -- Results are saved to 'Output' folder

*) Open Parameters.m

   -- To improve vessel segmentation change any of the parameters that have the comment '%change'


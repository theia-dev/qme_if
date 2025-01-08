%% segment_structures_main.m
% This script will read in arbitrary three-dimensional arrays and use
% free-hand selection and masking to segment user-generated subregions.
% Example optical coherence tomography and elasticity datasets of a
% 9-week-old ovary for use with this script have been made available 
% online. Please refer to the "QME co-registration and quantification" 
% section of starProtocols publication "Quantitative microelastography 
% with co-registered microscopy: an integrated approach to study murine 
% ovarian elasticity and composition in situ" for more information.

% Specify input directory
input_directory = 'Your_directory';

% Define important sample metadata
sample_age = '9';
scan_date = '20230221';
sample_number = '1';

% Define information region type and number
region_type = 'Follicle';
region_number = '1';

% Caxis limits
clim_E = [0 20];
cmap_E = pmkmp(256,'cubicl');
clim_oct_snr = [0 40];
cmap_oct_snr = gray(256);

% Define window size for sliding window average to smooth the OCT SNR data
windowSize = 20;

% Create output directory
output_directory = fullfile([input_directory, '-segmented-elasticity-arb-vol-', datestr(now, 'yyyymmdd')]);
mkdir(output_directory);

%% OCT SNR
fprintf('Loading OCT SNR\n');

% Locate OCT SNR data
oct_snr_lin_data = dir((fullfile(input_directory,'*oct_intensity_signal_to_noise_ratio_xyz.mat'))); 

% Create scan handle
oct_snr_lin_handle = matfile(fullfile(input_directory, oct_snr_lin_data.name));

% Load in linear OCT SNR
oct_snr_lin_xyz = oct_snr_lin_handle.oct_snr_lin_xyz;

% Calculate the sliding window average
fprintf('Averaging OCT SNR along x\n');
tic
oct_snr_lin_x_avg_xyz = slidingWindowAverage_x(oct_snr_lin_xyz, windowSize);
toc

% Calculate the sliding window average
fprintf('Averaging OCT SNR along y\n');
tic
oct_snr_lin_y_avg_xyz = slidingWindowAverage_y(oct_snr_lin_xyz, windowSize);
toc

% Calculate the sliding window average
fprintf('Averaging OCT SNR along z\n');
tic
oct_snr_lin_z_avg_xyz = slidingWindowAverage_z(oct_snr_lin_xyz, windowSize);
toc

% Convert to dB
oct_snr_dB_x_xyz = 10.*log10(oct_snr_lin_x_avg_xyz);
oct_snr_dB_y_xyz = 10.*log10(oct_snr_lin_y_avg_xyz);
oct_snr_dB_z_xyz = 10.*log10(oct_snr_lin_z_avg_xyz);

% Clear unused arrays to conserve memory
clear oct_snr_lin_xyz;
clear oct_snr_lin_x_avg_xyz;
clear oct_snr_lin_y_avg_xyz;
clear oct_snr_lin_z_avg_xyz;

%% Elasticity
fprintf('Loading elasticity\n');

% Load in elasticity
tic
load(fullfile(input_directory, '9_week_old_mouse_ovary_elasticity_xyz.mat'));
toc

%% Display OCT SNR using GUI to locate regions
% Call GUI script on OCT SNR
display_3D_volume_GUI_three_volumes(oct_snr_dB_z_xyz, oct_snr_dB_y_xyz, oct_snr_dB_x_xyz, 'gray', clim_oct_snr);

%% Display one plane of OCT SNR and elasticity
% Specify index for initial display
z_idx_display = 250;
y_idx_display = 615;
x_idx_display = 428;

% Extract OCT SNR
oct_snr_dB_display_zx = squeeze(oct_snr_dB_y_xyz(:,y_idx_display,:));
oct_snr_dB_display_zy = squeeze(oct_snr_dB_x_xyz(x_idx_display,:,:));
oct_snr_dB_display_xy = squeeze(oct_snr_dB_z_xyz(:,:,z_idx_display));
       
%% Freehand region selection 1
% Figure
ffr1 = figure; set(gcf, 'Position', get(0, 'Screensize')); 
        imagesc(oct_snr_dB_display_xy');
        caxis(clim_oct_snr);
        colormap(gca,cmap_oct_snr);
        colorbar;
        axis image
        title_string = 'Select region';
        title(title_string);
        xlabel('x');
        ylabel('y');  
        
% Begin freehand selection of region of interest (ROI)
begin_freehand_drawing_1 = imfreehand;

% Double click within the selected freehand area to continue execution
elasticity_position_1 = wait(begin_freehand_drawing_1);

% Create logical mask to select only values inside ROI
region_mask_2D_1 = createMask(begin_freehand_drawing_1);       

% Close image
close(ffr1);

%% Freehand region selection 2
ffr2 = figure; set(gcf, 'Position', get(0, 'Screensize')); 
        imagesc(oct_snr_dB_display_zx');
        caxis(clim_oct_snr);
        colormap(gca,cmap_oct_snr);
        colorbar;
        axis image
        title_string = 'Select region';
        title(title_string);
        xlabel('x');
        ylabel('z');  
        
% Begin freehand selection of region of interest (ROI)
begin_freehand_drawing_2 = imfreehand;

% Double click within the selected freehand area to continue execution
elasticity_position_2 = wait(begin_freehand_drawing_2);

% Create logical mask to select only values inside ROI
region_mask_2D_2 = createMask(begin_freehand_drawing_2);       

% Close image
close(ffr2);

%% Freehand region selection 3
ffr3 = figure; set(gcf, 'Position', get(0, 'Screensize')); 
        imagesc(oct_snr_dB_display_zy');
        caxis(clim_oct_snr);
        colormap(gca,cmap_oct_snr);
        colorbar;
        axis image
        title_string = 'Select region';
        title(title_string);
        xlabel('y');
        ylabel('z');  
        
% Begin freehand selection of region of interest (ROI)
begin_freehand_drawing_3 = imfreehand;

% Double click within the selected freehand area to continue execution
elasticity_position_3 = wait(begin_freehand_drawing_3);

% Create logical mask to select only values inside ROI
region_mask_2D_3 = createMask(begin_freehand_drawing_3);       

% Close image
close(ffr3);

%% Create 3-D mask from the 2-D cross-sections
% Create mask
tic
mask_xyz = create_3D_mask_from_cross_sections(double(region_mask_2D_1), double(region_mask_2D_2),double(region_mask_2D_3));
toc

% Replace zeros with NaNs
mask_NaN_xyz = mask_xyz;
mask_NaN_xyz(mask_NaN_xyz == 0) = NaN;

%% Find centre point for display purposes
% Find indices of first and last occurrences of '1' in x y and z
[rowIndices_1, colIndices_1] = find(region_mask_2D_1 == 1);
[rowIndices_2, colIndices_2] = find(region_mask_2D_2 == 1);

% Determine min and max extents
x_min = min(colIndices_1);
x_max = max(colIndices_1);
y_min = min(rowIndices_1);
y_max = max(rowIndices_1);
z_min = min(rowIndices_2);
z_max = max(rowIndices_2);

% Compute radii
x_radius = round(0.5*(x_max - x_min));
y_radius = round(0.5*(y_max - y_min));
z_radius = round(0.5*(z_max - z_min));

% Compute centre point
x_centre = x_min + x_radius;
y_centre = y_min + y_radius;
z_centre = z_min + z_radius;

%% Plot isosurface to verify volume looks correct
% Define additional pixels in each dimension
extra_pix = 50;

% Create cropped limits to save memory
x_cropped = x_min-extra_pix: x_max+extra_pix;
y_cropped = y_min-extra_pix: y_max+extra_pix;
z_cropped = z_min-extra_pix: z_max+extra_pix;

% Crop 3-D mask
mask_cropped_xyz = mask_xyz(x_cropped, y_cropped, z_cropped);

% Rearrange dimensions to agree with meshgrid output
mask_cropped_yxz = permute(mask_cropped_xyz, [2 1 3]);

% Create 3-D indices
[xx, yy, zz] = meshgrid(x_cropped, y_cropped , z_cropped);

% Define the isovalue for the isosurface
isovalue = 0.5;

% Create the isosurface
f3D = figure; 
       isosurface(xx, yy, zz, mask_cropped_yxz, isovalue);
       xlabel('x (pix)');
       ylabel('y (pix)');
       zlabel('z (pix)');
       ylim([0 1000]);
       xlim([0 1000]);
       zlim([0 1024]);       
       grid on;
       camlight;
       lighting gouraud;
       set(gca, 'Zdir', 'reverse');
       title('3-D visualisation of segmented volume');
       view(3);
       fig = f3D;
       fig_name = sprintf(sprintf('%s%s_3D_visual_%s_%s_%s', region_type, region_number, sample_age, scan_date, sample_number));
       export_fig(fig, fullfile(output_directory, [fig_name, '.png']));      
                     
%% Segment data 
% OCT SNR
oct_snr_dB_segmented_xyz = mask_NaN_xyz.*oct_snr_dB_z_xyz;

% Elasticity
tangent_modulus_segmented_xyz = mask_NaN_xyz(:,:,1:size(tangent_modulus_xyz,3)).*tangent_modulus_xyz;

% Display ROI
fROI = figure; set(gcf, 'Position', get(0, 'Screensize'));  
       subplot(2,3,1)
       imagesc(squeeze(oct_snr_dB_segmented_xyz(:,:,z_centre))');
       caxis(clim_oct_snr);
       colormap(gca,cmap_oct_snr);
       colorbar;
       axis image;
       xlabel('x');
       ylabel('y');  
       title(sprintf('OCT SNR (dB), z-index %i', z_centre));
       %
       subplot(2,3,2)
       imagesc(squeeze(oct_snr_dB_segmented_xyz(:,y_centre,:))');
       caxis(clim_oct_snr);
       colormap(gca,cmap_oct_snr);
       colorbar;
       axis image;
       xlabel('x');
       ylabel('z');  
       title(sprintf('OCT SNR (dB), y-index %i', y_centre));
       %
       subplot(2,3,3)
       imagesc(squeeze(oct_snr_dB_segmented_xyz(x_centre,:,:))');
       caxis(clim_oct_snr);
       colormap(gca,cmap_oct_snr);
       colorbar;
       axis image;
       xlabel('y');
       ylabel('z');  
       title(sprintf('OCT SNR (dB), x-index %i', x_centre));
       %
       subplot(2,3,4)
       imagesc(squeeze(tangent_modulus_segmented_xyz(:,:,z_centre))');
       caxis(clim_E);
       colormap(gca,cmap_E);
       colorbar;
       axis image;
       xlabel('x');
       ylabel('y');  
       title(sprintf('Elasticity (kPa), z-index %i', z_centre));
       %
       subplot(2,3,5)
       imagesc(squeeze(tangent_modulus_segmented_xyz(:,y_centre,:))');
       caxis(clim_E);
       colormap(gca,cmap_E);
       colorbar;
       axis image;
       xlabel('x');
       ylabel('z');  
       title(sprintf('Elasticity (kPa), y-index %i', y_centre));
       %
       subplot(2,3,6)
       imagesc(squeeze(tangent_modulus_segmented_xyz(x_centre,:,:))');
       caxis(clim_E);
       colormap(gca,cmap_E);
       colorbar;
       axis image;
       xlabel('y');
       ylabel('z');  
       title(sprintf('Elasticity (kPa), x-index %i', x_centre));
       fig = fROI;
       fig_name = sprintf(sprintf('%s%s_segmented_volume_%s_%s_%s', region_type, region_number, sample_age, scan_date, sample_number));
       export_fig(fig, fullfile(output_directory, [fig_name, '.png']));       
       
% Display original
forig = figure; set(gcf, 'Position', get(0, 'Screensize'));  
       subplot(2,3,1)
       imagesc(squeeze(oct_snr_dB_z_xyz(:,:,z_centre))');
       caxis(clim_oct_snr);
       colormap(gca,cmap_oct_snr);
       colorbar;
       axis image;
       xlabel('x');
       ylabel('y');  
       title(sprintf('OCT SNR (dB), z-index %i', z_centre));
       %
       subplot(2,3,2)
       imagesc(squeeze(oct_snr_dB_y_xyz(:,y_centre,:))');
       caxis(clim_oct_snr);
       colormap(gca,cmap_oct_snr);
       colorbar;
       axis image;
       xlabel('x');
       ylabel('z');  
       title(sprintf('OCT SNR (dB), y-index %i', y_centre));
       %
       subplot(2,3,3)
       imagesc(squeeze(oct_snr_dB_x_xyz(x_centre,:,:))');
       caxis(clim_oct_snr);
       colormap(gca,cmap_oct_snr);
       colorbar;
       axis image;
       xlabel('y');
       ylabel('z');  
       title(sprintf('OCT SNR (dB), x-index %i', x_centre));
       %
       subplot(2,3,4)
       imagesc(squeeze(tangent_modulus_xyz(:,:,z_centre))');
       caxis(clim_E);
       colormap(gca,cmap_E);
       colorbar;
       axis image;
       xlabel('x');
       ylabel('y');  
       title(sprintf('Elasticity (kPa), z-index %i', z_centre));
       %
       subplot(2,3,5)
       imagesc(squeeze(tangent_modulus_xyz(:,y_centre,:))');
       caxis(clim_E);
       colormap(gca,cmap_E);
       colorbar;
       axis image;
       xlabel('x');
       ylabel('z');  
       title(sprintf('Elasticity (kPa), y-index %i', y_centre));
       %
       subplot(2,3,6)
       imagesc(squeeze(tangent_modulus_xyz(x_centre,:,:))');
       caxis(clim_E);
       colormap(gca,cmap_E);
       colorbar;
       axis image;
       xlabel('y');
       ylabel('z');  
       title(sprintf('Elasticity (kPa), x-index %i', x_centre));
       fig = forig;
       fig_name = sprintf(sprintf('%s%s_original_volume_%s_%s_%s', region_type, region_number, sample_age, scan_date, sample_number));
       export_fig(fig, fullfile(output_directory, [fig_name, '.png']));         

%% Save data       
% Create data names
data_name_snr = sprintf('%s%s_OCT_SNR_ROI_volume_%s_%s_%s', region_type, region_number, sample_age, scan_date, sample_number);
data_name_E = sprintf('%s%s_E_ROI_volume_%s_%s_%s', region_type, region_number, sample_age, scan_date, sample_number);
       
% Save values
save(fullfile(output_directory, data_name_snr),'oct_snr_dB_segmented_xyz','-v7.3');  
save(fullfile(output_directory, data_name_E),'tangent_modulus_segmented_xyz','-v7.3');       
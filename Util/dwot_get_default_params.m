% param.azimuth_discretization 	= daz;
% param.elevation_discretization  = del;
% param.yaw_discretization		= dyaw;
% param.fov_discretization		= dfov;

param.azimuths 		= azs;
param.elevations 	= els;
param.yaws 			= yaws;
param.fovs 			= fovs;

param.azs = azs;
param.els = els;

%Turn on image flips for detection/training. If enabled, processing
%happes on each image as well as its left-right flipped version.
% param.detect_add_flip = 0;

param.sbin = sbin;
param.rendering_sbin = 8;

%Levels-per-octave defines how many levels between 2x sizes in pyramid
%(denser pyramids will have more windows and thus be slower for
%detection/training)
param.detect_levels_per_octave = n_level;
param.n_level = n_level;
%By default dont save feature vectors of detections (training turns
%this on automatically)
% default_params.detect_save_features = 0;

%Default detection threshold (negative margin makes most sense for
%SVM-trained detectors).  Only keep detections for detection/training
%that fall above this threshold.
% default_params.detect_keep_threshold = -1;

%Maximum #windows per exemplar (per image) to keep
% default_params.detect_max_windows_per_exemplar = 10;

%Determines if NMS (Non-maximum suppression) should be used to
%prune highly overlapping, redundant, detections.
%If less than 1.0, then we apply nms to detections so that we don't have
%too many redundant windows [defaults to 0.5]
%NOTE: mining is much faster if this is turned off!

param.nms_threshold = 0.5;

param.min_overlap = 0.5;

param.max_view_difference = 22.5; % degree



%How much we pad the pyramid (to let detections fall outside the image)
param.detect_pyramid_padding = 15;

% minimum image hog length that we use for convolution
param.min_hog_length = 7;

%The maximum scale to consdider in the feature pyramid
param.detect_max_scale = 1.0;

%The minimum scale to consider in the feature pyramid
param.detect_min_scale = .02;
param.detection_threshold = detection_threshold;


param.skip_criteria = skip_criteria;
skip_name = cellfun(@(x) x(1), skip_criteria); % get the first character of the criteria
param.skip_name = skip_name;

%Initialize framing function
init_params.features = @esvm_features;
init_params.sbin = sbin;
% init_params.goal_ncells = 100;

param.init_params = init_params;

%% WHO setting
% TEMPLATE_INITIALIZATION_MODE == 0
%     Creates templates that have approximately same number of cells
% and decorrelate cells with non zero HOG values
% TEMPLATE_INITIALIZATION_MODE == 1
%     Creates templates that have approxmiately same number of active cells
% Active cells are the HOG cells whose absolute values is above the
% HOG_CELL_THRESHOLD
% TEMPLATE_INITIALIZATION_MODE == 2
%     Create templates that have approximately same number of cells but
% decorrelate all cells even including zero HOG cells
% TEMPLATE_INITIALIZATION_MODE == 3
%     Create templates that have approximately same number of cells and
%     decorrelate only non-zero cells. But normalized by the number of
%     non-zero cells
% TEMPLATE_INITIALIZATION_MODE == 4
%     Create templates that have approximately same number of cells and 
%     center the HOG feature but do not decorrelate
param.template_initialization_mode = 0; 
param.image_padding       = 50;
param.lambda              = lambda;
param.n_level_per_octave  = n_level;
param.detection_threshold = detection_threshold;
param.n_cell_limit        = n_cell_limit;
param.class               = CLASS;
param.sub_class           = SUB_CLASS;
param.type                = TEST_TYPE;
param.hog_cell_threshold  = 1.0;
param.feature_dim         = 31;

% Statistics
stats = load('Statistics/sumGamma_N1_40_N2_40_sbin_4_nLevel_10_nImg_3601_napoli3_gamma.mat');

param.hog_mu          = stats.mu;
param.hog_gamma       = stats.Gamma;
param.hog_gamma_gpu   = gpuArray(single(param.hog_gamma));
param.hog_gamma_dim   = size(param.hog_gamma);
param.hog_gamma_cell_size = size(param.hog_gamma)/31;

%% GPU Setting
param.device_id = DEVICE_ID;

%% CG setting
param.N_THREAD_H = 32;
param.N_THREAD_W = 32;

param.scramble_gamma_to_sigma_file = 'scramble_gamma_to_sigma';
scramble_kernel = parallel.gpu.CUDAKernel(['./bin/', param.scramble_gamma_to_sigma_file '.ptx'],...
                                          ['./CUDA/', param.scramble_gamma_to_sigma_file '.cu']);
scramble_kernel.ThreadBlockSize  = [param.N_THREAD_H , param.N_THREAD_W , 1];
param.scramble_kernel = scramble_kernel;
  
param.cg_threshold        = 10^-3;
param.cg_max_iter         = 60;

param.computing_mode = COMPUTING_MODE;

%% Region Extraction
param.region_extraction_padding_ratio = 0.2;
param.region_extraction_levels = 0;
% MCMC Setting
param.mcmc_max_iter = 20;

%% Cuda Convolution Params
% THREAD_PER_BLOCK_H, THREAD_PER_BLOCK_W, THREAD_PER_BLOCK_D, THREAD_PER_BLOCK_2D
param.cuda_conv_n_threads = [8, 8, 4, 32];


%% Binary Search params
param.binary_search_max_depth = 1;

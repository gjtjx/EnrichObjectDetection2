function curfeats = esvm_initialize_goalsize_exemplar_ncell(I, bbox, ncell)
%% Initialize the exemplar (or scene) such that the representation
% which tries to choose a region which overlaps best with the given
% bbox and contains roughly init_params.goal_ncells cells, with a
% maximum dimension of init_params.MAXDIM
%
% Copyright (C) 2011-12 by Tomasz Malisiewicz
% All rights reserved.
% 
% This file is part of the Exemplar-SVM library and is made
% available under the terms of the MIT license (see COPYING file).
% Project homepage: https://github.com/quantombone/exemplarsvm

sbin = 8;
init_params.sbin = sbin;
init_params.MAXNCELL = ncell;

%Expand the bbox to have some minimum and maximum aspect ratio
%constraints (if it it too horizontal, expand vertically, etc)
bbox = expand_bbox(bbox,I);
bbox = max(bbox,1);
bbox([1 3]) = min(size(I,2),bbox([1 3]));
bbox([2 4]) = min(size(I,1),bbox([2 4]));

bboxWidth = bbox(4) - bbox(2);
bboxHeight = bbox(3) - bbox(1);

%Create a blank image with the exemplar inside
Ibox = zeros(size(I,1), size(I,2));    
Ibox(bbox(2):bbox(4), bbox(1):bbox(3)) = 1;

%Get the hog feature pyramid for the entire image
interval = 10;

%Hardcoded maximum number of levels in the pyramid
MAXLEVELS = 200;

%Get the levels per octave from the parameters
sc = 2 ^(1/interval);

scale = zeros(1,MAXLEVELS);
feat = {};


for i = 1:MAXLEVELS
  scaler = 1 / sc^(i-1);
    
  if ceil(bboxWidth * scaler / sbin) * ceil(bboxHeight * scaler / sbin) >= 1.2 * ncell
    continue;
  end
  
  if floor(bboxWidth * scaler / sbin) * floor(bboxHeight * scaler / sbin) < 0.5 * ncell
    break;
  end
  
  scale(i) = scaler;
  scaled = resizeMex(I,scale(i));
  
  feat{i} = features_pedro(scaled,sbin);

  %if we get zero size feature, backtrack one, and dont produce any
  %more levels
  if numel(feat{i}) == 0
    feat = feat(1:i-1);
    scale = scale(1:i-1);
    break;
  end

  %recover lost bin!!!
  feat{i} = padarray(feat{i}, [1 1 0], 0);
end
featIdx = find(cellfun(@(x) ~isempty(x), feat));
feat = feat(featIdx);
scale = scale(featIdx);
%Extract the regions most overlapping with Ibox from each level in the pyramid
% [masker,sizer] = get_matching_bbox(feat, bbox, size(I) );
% [masker,sizer] = get_matching_masks(feat, Ibox, bbox);
[bndX, bndY, tgtLevel] = get_matching_bbox(feat, bbox, size(I), ncell);

%Now choose the mask which is closest to N cells
curfeats = feat{tgtLevel}(bndY(1):bndY(2),bndX(1):bndX(2),:);

hg_size = size(curfeats);

fprintf(1,'initialized with HOG_size = [%d %d]\n',hg_size(1),hg_size(2));

%Fire inside self-image to get detection location
% [model.bb, model.x] = get_target_bb(model, I, init_params);

%Normalized-HOG initialization
% model.w = reshape(model.x,size(model.w)) - mean(model.x(:));
% 
% if isfield(init_params,'wiggle_number') && ...
%       (init_params.wiggle_number > 1)
%   savemodel = model;
%   model = esvm_get_model_wiggles(I, model, init_params.wiggle_number);
% end


function [bndX, bndY, tgtLevel] = get_matching_bbox(f_real, bbox, imSize, n_max_cell)
%Given a feature pyramid, and a segmentation mask inside Ibox, find
%the best matching region per level in the feature pyramid

for a = 1:length(f_real)  
    
  bndX = round((size(f_real{a},2)-1)*[bbox(1)-1 bbox(3)-1]/(imSize(2)-1)) + 1;
  bndY = round((size(f_real{a},1)-1)*[bbox(2)-1 bbox(4)-1]/(imSize(1)-1)) + 1;
%   bndX(1) = floor(bndX(1));
%   bndX(2) = ceil(bndX(2));
%   bndY(1) = floor(bndY(1));
%   bndY(2) = ceil(bndY(2));
  
  if (bndX(2) - bndX(1) + 1) * (bndY(2) - bndY(1) + 1) <= n_max_cell
    tgtLevel = a;
    return;
  end
end
disp('didnt find a match returning the closest level');


function bbox = expand_bbox(bbox,I)
%Expand region such that is still within image and tries to satisfy
%these constraints best
%requirements: each dimension is at least 50 pixels, and max aspect
%ratio os (.25,4)
for expandloop = 1:10000
  % Get initial dimensions
  w = bbox(3)-bbox(1)+1;
  h = bbox(4)-bbox(2)+1;
  
  if h > w*4 || w < 50
    %% make wider
    bbox(3) = bbox(3) + 1;
    bbox(1) = bbox(1) - 1;
  elseif w > h*4 || h < 50
    %make taller
    bbox(4) = bbox(4) + 1;
    bbox(2) = bbox(2) - 1;
  else
    break;
  end
  
  bbox([1 3]) = cap_range(bbox([1 3]), 1, size(I,2));
  bbox([2 4]) = cap_range(bbox([2 4]), 1, size(I,1));      
end


function [target_bb,target_x] = get_target_bb(model, I, init_params)
%Get the bounding box of the top detection

mmm{1}.model = model;
mmm{1}.model.hg_size = size(model.w);
localizeparams.detect_keep_threshold = -100000.0;
localizeparams.detect_max_windows_per_exemplar = 1;
localizeparams.detect_levels_per_octave = 10;
localizeparams.detect_save_features = 1;
localizeparams.detect_add_flip = 0;
localizeparams.detect_pyramid_padding = 5;
localizeparams.dfun = 0;
localizeparams.init_params = init_params;

[rs,t] = esvm_detect(I,mmm,localizeparams);
target_bb = rs.bbs{1}(1,:);
target_x = rs.xs{1}{1};


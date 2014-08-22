function resultIm = dwot_draw_overlap_detection(im, bbsNMS, renderings, maxNDrawBox, drawPadding, box_text)

if nargin < 3
  maxNDrawBox = 5;
end

if nargin  < 4
  drawPadding = 25;
end

if nargin < 5
  box_text = false;
end

paddedIm = pad_image(im2double(im), drawPadding, 1);
resultIm = paddedIm;

NDrawBox = min(size(bbsNMS, 1),maxNDrawBox);

% Create overlap image
for bbsIdx = NDrawBox:-1:1
  if iscell(renderings)
    rendering = renderings{bbsNMS(bbsIdx, 11)};
  else
    rendering = renderings;
  end
  bnd = round(bbsNMS(bbsIdx, 1:4)) + drawPadding;
  bboxWidth  = bnd(3) - bnd(1);
  bboxHeight = bnd(4) - bnd(2);
  szPadIm  = size(paddedIm);
  clip_bnd = [ min(bnd(1),szPadIm(2)),...
      min(bnd(2), szPadIm(1)),...
      min(bnd(3), szPadIm(2)),...
      min(bnd(4), szPadIm(1))];
  clip_bnd = [max(clip_bnd(1),1),...
      max(clip_bnd(2),1),...
      max(clip_bnd(3),1),...
      max(clip_bnd(4),1)];
  renderingSz = size(rendering);
  cropRegion = round((bnd - clip_bnd) ./ [bboxWidth, bboxHeight, bboxWidth, bboxHeight] .* [renderingSz(2), renderingSz(1), renderingSz(2), renderingSz(1)]);
  resizeRendering = imresize(rendering(...
              (1 - cropRegion(2)):(end - cropRegion(4)),...
              (1 - cropRegion(1)):(end - cropRegion(3)),:),...
       [clip_bnd(4) - clip_bnd(2) + 1, clip_bnd(3) - clip_bnd(1) + 1]);
  % resizeRendering = resizeRendering(1:(clip_bnd(4) - clip_bnd(2) + 1), 1:(clip_bnd(3) - clip_bnd(1) + 1), :);
  bndIm = paddedIm( clip_bnd(2):clip_bnd(4), clip_bnd(1):clip_bnd(3), :);
  blendIm = bndIm/3 + im2double(resizeRendering)/3 + resultIm( clip_bnd(2):clip_bnd(4), clip_bnd(1):clip_bnd(3), :)/3;
  resultIm(clip_bnd(2):clip_bnd(4), clip_bnd(1):clip_bnd(3),:) = blendIm;
end

if box_text
  cla;
  imagesc(resultIm);
% 
%   % Draw bounding box.
%   for bbsIdx = NDrawBox:-1:1
%     bnd = round(bbsNMS(bbsIdx, 1:4)) + drawPadding;
%     titler = {['score ' num2str( bbsNMS(bbsIdx,12))], ...
%       [' overlap ' num2str( bbsNMS(bbsIdx,9))], ...
%       [' detector ' num2str( bbsNMS(bbsIdx,11))] };
% 
%     plot_bbox(bnd,cell2mat(titler),[1 1 1]);
%   end
  axis equal;
  axis tight;
  drawnow;
end
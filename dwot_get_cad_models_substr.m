function [ model_names, file_paths ]= dwot_get_cad_models_substr(CAD_ROOT_DIR, CLASS, SUB_CLASSES, CAD_FORMATS)
    % Directory path can be arbitrary deep for each sub classes.
    % Get all possible sub-classes
    subclass_defined = false;
    if nargin > 2
        subclass_defined = true; 
    end

    SEARCH_PATH = CAD_ROOT_DIR;
    lists = dir(SEARCH_PATH);
    directories = lists([lists.isdir]);
    nDir = numel(directories);
    model_names = {};
    file_paths = {};
    if nDir > 2
        for dir_idx = 3:nDir
            if isempty(regexpi(directories(dir_idx).name,CLASS))
              continue;
            end
            [ model_names, file_paths ] = recurse_find_models(fullfile(SEARCH_PATH,directories(dir_idx).name), model_names, file_paths, CAD_FORMATS);
        end
    
    end
%    detector_model_name = ['each_' strjoin(strrep(CAD_ROOT_DIR, '/','_'),'_')];
%    model_files = cellfun(@(x) [model_paths strrep([x '.3ds'], '/', '_')], model_names, 'UniformOutput', false);
end
   
function [ model_names, file_paths ] = recurse_find_models(PATH, model_names, file_paths, CAD_FORMATS)
    lists = dir(PATH);
    directories = lists([lists.isdir]);
    % the default directories are . and ..
    nDir = numel(directories);
    if nDir > 2
        for dir_idx = 3:nDir
            [ model_names, file_paths ] = recurse_find_models(fullfile(PATH, directories(dir_idx).name), model_names, file_paths, CAD_FORMATS);
        end
    end
    
    files = lists(~[lists.isdir]);
    for file_idx = 1:numel(files)
        file = files(file_idx); 
        substrs = regexp(file.name, '^(?<name>[a-zA-Z0-9-_ ]+)\.(?<ext>\w{3})$','names');
        if isempty(substrs) || nnz( ismember(CAD_FORMATS, substrs.ext ) ) == 0 || nnz( ismember(model_names, substrs.name ) ) ~= 0
          continue;
        end
        model_names = { model_names{:}, substrs.name};
        file_paths = { file_paths{:}  fullfile(PATH,file.name) };
    end
end


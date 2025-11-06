% save_results.m
% Standardized saving of results: .mat + optional CSV export
% Usage:
% save_results(filename, data_struct, meta)
% filename: path to .mat to create
% data_struct: structure with fields (arrays, maps)
% meta: optional struct with fields: description, author, date

function save_results(fname, data_struct, meta)
if nargin < 3
    meta = struct();
end
if ~isfield(meta,'date')
    meta.date = datestr(now,'yyyy-mm-dd HH:MM:SS');
end
if ~isfield(meta,'author')
    meta.author = 'ProDIS_user';
end

S.data = data_struct;
S.meta = meta;

% ensure output directory exists
[outdir, ~, ~] = fileparts(fname);
if ~isempty(outdir) && ~exist(outdir,'dir')
    mkdir(outdir);
end

save(fname, '-struct', 'S', '-v7.3'); % -v7.3 for large arrays support

% Optional: also export a small CSV summary if top-level scalar fields exist
try
    csvname = regexprep(fname, '\.mat$', '.csv');
    fid = fopen(csvname, 'w');
    fprintf(fid, 'key,value\n');
    fns = fieldnames(data_struct);
    for i=1:length(fns)
        key = fns{i};
        val = data_struct.(key);
        if isscalar(val)
            fprintf(fid, '%s,%g\n', key, val);
        end
    end
    fclose(fid);
catch
    % ignore csv export errors
end

end
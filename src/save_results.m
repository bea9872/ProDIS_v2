function save_results(fname, data_struct, meta)
% save_results: standardized saving (.mat). Creates parent dir if needed.
% Usage: save_results('examples/sample_output.mat', results, meta)
if nargin < 3; meta = struct(); end
if ~isfield(meta,'date'); meta.date = datestr(now,'yyyy-mm-dd HH:MM:SS'); end
if ~isfolder(fileparts(fname))
    mkdir(fileparts(fname));
end
S.results = data_struct;
S.meta = meta;
save(fname, '-struct', 'S', '-v7.3');
fprintf('Saved results to %s\n', fname);
end
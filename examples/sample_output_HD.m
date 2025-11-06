% generate_sample_output_MRI.m
% Convenience wrapper: runs a compact non-ideal MRI test and saves sample output
% Uses MRI_nonideal_run internally

fprintf('Generating sample output for MRI (this may take a while depending on grid size)...\n');
run('MRI_nonideal_run.m'); % this script itself saves sample_output_MRI.mat
fprintf('Done. Check examples/sample_output_MRI.mat\n');
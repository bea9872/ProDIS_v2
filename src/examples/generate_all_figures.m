% generate_all_figures.m
% Run all example scripts and save figures to ../figures/

addpath('..');
if ~exist('../figures','dir'); mkdir('../figures'); end

run('MRI_ideal_run.m');
saveas(gcf, fullfile('..','figures','MRI_ideal.png'));

run('MRI_nonideal_run.m');
saveas(gcf, fullfile('..','figures','MRI_nonideal.png'));

run('HD_cooling_run.m');
saveas(gcf, fullfile('..','figures','HD_cooling.png'));

fprintf('All figures generated in ../figures/\n');
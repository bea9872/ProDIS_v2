% ProDIS_main.m
% Main entry point for ProDIS_v2 (placed in src/)
% ProDIS_main
%

clear; clc; close all;

% ---------------------------
% Path setup (robust)
% ---------------------------
% this file is inside .../ProDIS_v2/src
thisFile = mfilename('fullpath');
srcDir = fileparts(thisFile); % path to src
rootDir = fileparts(srcDir); % path to ProDIS_v2

% set current folder to srcDir (ensures relative calls work)
cd(srcDir);

% add relevant paths
addpath(srcDir);
addpath(fullfile(srcDir,'examples'));

fprintf('[ProDIS] Root: %s\n', rootDir);
fprintf('[ProDIS] Src: %s\n', srcDir);

% ---------------------------
% Simple menu
% ---------------------------
fprintf('\nProDIS v2 — select example to run:\n');
fprintf(' 1) MRI ideal benchmark\n');
fprintf(' 2) MRI non-ideal sweep (Ohmic + Hall placeholder)\n');
fprintf(' 3) Hydrodynamic cooling sweep (VSI-like)\n');
fprintf(' 4) Generate all example figures\n');
fprintf(' 0) Exit\n');
choice = input('Enter choice [1-4]: ');

switch choice
    case 1
        run(fullfile('examples','MRI_ideal_run.m'));
    case 2
        run(fullfile('examples','MRI_nonideal_run.m'));
    case 3
        run(fullfile('examples','HD_cooling_run.m'));
    case 4
        run(fullfile('examples','generate_all_figures.m'));
    otherwise
        fprintf('Exit.\n');
end
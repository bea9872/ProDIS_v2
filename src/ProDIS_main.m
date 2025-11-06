% ==============================================================
% ProDIS_v2: Protoplanetary Disk Instability Solver
% Main launcher for MRI and hydrodynamic instability solvers
% ==============================================================
clear; clc; close all;

addpath('src'); addpath('examples'); addpath('figures'); addpath('docs');

disp('=== ProDIS_v2: Protoplanetary Disk Instability Solver ===');
disp('Select mode: 1 = MRI Ideal, 2 = MRI Non-Ideal, 3 = HD Cooling');
mode = input('Enter mode number: ');

switch mode
    case 1
        disp('Running Ideal MRI Benchmark...');
        run('examples/MRI_ideal_run.m');
    case 2
        disp('Running Non-Ideal MRI Benchmark...');
        run('examples/MRI_nonideal_run.m');
    case 3
        disp('Running Hydrodynamic Cooling Instability...');
        run('examples/HD_cooling_run.m');
    otherwise
        disp('Invalid mode.');
end

disp('=== Simulation complete ===');
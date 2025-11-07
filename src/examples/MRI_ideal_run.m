% MRI_ideal_run.m
% Example: ideal MRI benchmark using MRI_quartic_solver

addpath('..'); % ensure src on path if executed from examples folder
% configure
params = struct();
params.Omega = 1.0;
params.q = 1.5;
params.rho0 = 1.0;
params.B0 = 5e-3;
params.eta = 0.0;

kz_list = logspace(-2, 1, 200);

sweep_spec = struct();
sweep_spec.kz_list = kz_list;
sweep_spec.fixed_params = params;

% call generic sweep
results = param_sweep(@MRI_quartic_solver, sweep_spec);

% plot
figure; plot_growth_map(results, 'xlabel','k_z','title','MRI ideal growth (imag(omega))');

% save sample output
save_results(fullfile('..','examples','sample_output_MRI.mat'), results, struct('description','MRI ideal sample'));
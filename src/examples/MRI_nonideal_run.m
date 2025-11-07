% MRI_nonideal_run.m
% Example: non-ideal MRI sweep across Ohmic diffusivity (eta)

addpath('..');

% base params
params = struct();
params.Omega = 1.0;
params.q = 1.5;
params.rho0 = 1.0;
params.B0 = 5e-3;

kz_list = linspace(0.1, 6.0, 150);

% sweep over eta
eta_vals = logspace(-6, -1, 12);

sweep_spec = struct();
sweep_spec.kz_list = kz_list;
sweep_spec.fixed_params = params;
sweep_spec.sweep_var_name = 'eta';
sweep_spec.sweep_vals = eta_vals;

results = param_sweep(@MRI_quartic_solver, sweep_spec);

% plot as image
figure; plot_growth_map(results, 'xlabel','k_z','ylabel','eta','title','MRI growth vs kz and eta');
% save
save_results(fullfile('..','examples','sample_output_MRI_nonideal.mat'), results, struct('description','MRI non-ideal sample'));
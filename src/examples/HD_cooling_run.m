% HD_cooling_run.m
% Example: sweep in cooling timescale for HD compressible solver

addpath('..');

params = struct();
params.Omega = 1.0;
params.q = 1.5;
params.cs = 0.05;
params.rho0 = 1.0;
params.tau_cool = 1.0;
params.kx = 1.0;

kz_list = linspace(0.1,5.0,150);
tau_vals = logspace(-1, 1.5, 60); % from 0.1 to ~31

sweep_spec = struct();
sweep_spec.kz_list = kz_list;
sweep_spec.fixed_params = params;
sweep_spec.sweep_var_name = 'tau_cool';
sweep_spec.sweep_vals = tau_vals;

results = param_sweep(@HD_compressible_solver, sweep_spec);

figure; plot_growth_map(results, 'xlabel','k_z','ylabel','tau_{cool}','title','HD growth vs kz and tau_{cool}');
save_results(fullfile('..','examples','sample_output_HD.mat'), results, struct('description','HD cooling sample'));
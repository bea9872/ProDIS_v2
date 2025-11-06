% ==============================================================
% MRI_ideal_run.m
% Validates MRI in ideal MHD (Balbus & Hawley 1991)
% ==============================================================
Omega = 1;
vA = linspace(0.01, 1, 50);
kz = linspace(0.1, 5, 200);

[results] = param_sweep(@MRI_quartic_solver, struct('Omega',Omega,'vA',vA,'kz',kz));
plot_growth_map(results, 'Ideal MRI growth map');
% ==============================================================
% HD_cooling_run.m
% Thermal relaxation instability example
% ==============================================================
Omega = 1;
kx = 1;
kz = linspace(0.1, 5, 100);
tau_cool = linspace(0.1, 10, 80);

gamma_map = zeros(length(tau_cool), length(kz));

for i = 1:length(tau_cool)
    gamma_map(i,:) = HD_compressible_solver(Omega, tau_cool(i), kx, kz);
end

results.gamma_map = gamma_map;
results.kz_vec = kz;
results.vA_vec = tau_cool; % reusing label
plot_growth_map(results, 'Hydrodynamic instability (cooling timescale)');
ylabel('\tau_{cool} \Omega');
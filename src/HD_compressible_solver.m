% ==============================================================
% HD_compressible_solver.m
% Linear analysis of hydrodynamic instability with cooling
% ==============================================================
function gamma = HD_compressible_solver(Omega, tau_cool, kx, kz)
% Simple linear cooling model: growth from vertical shear-like instability

gamma = zeros(size(kz));
for i = 1:length(kz)
    k = sqrt(kx^2 + kz(i)^2);
    N2 = -Omega^2 * 0.05; % mild stratification (unstable)
    gamma(i) = real(0.5 * ( -1/tau_cool + sqrt((1/tau_cool)^2 - 4*N2) ));
end
end
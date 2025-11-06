% ==============================================================
% MRI_quartic_solver.m
% Solves the ideal MRI dispersion relation (Balbus & Hawley 1991)
% ==============================================================
function [gamma_max, kz_opt, roots_all] = MRI_quartic_solver(Omega, vA, kz)
% Inputs:
% Omega - angular velocity
% vA - Alfven velocity (B / sqrt(mu0 * rho))
% kz - vector of vertical wavenumbers
%
% Outputs:
% gamma_max - maximum growth rate (1/s)
% kz_opt - wavenumber of max growth
% roots_all - matrix of complex roots (each column = kz)

n = numel(kz);
roots_all = zeros(4,n);

for i = 1:n
    k = kz(i);
    a4 = 1;
    a3 = 0;
    a2 = k^2 * vA^2 + 2 * (Omega^2);
    a1 = 0;
    a0 = (k^2 * vA^2) * ((k^2 * vA^2) - 3 * Omega^2);

    r = roots([a4 a3 a2 a1 a0]);
    roots_all(:,i) = r;
end

gamma = max(real(sqrt(-1i .* roots_all)),[],1); % extract positive growth
[gamma_max, idx] = max(gamma);
kz_opt = kz(idx);
end
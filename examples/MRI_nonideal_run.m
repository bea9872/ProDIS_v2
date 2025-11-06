% MRI_nonideal_run.m
% Example script: non-ideal MRI parameter exploration and save sample output
% Requires: src/MRI_quartic_solver.m, src/param_sweep.m, src/save_results.m

clear; close all; clc;
addpath('../src');

% --- physical / numerical parameters (dimensionless, Omega=1) ---
Omega = 1.0;
q = 1.5; % shear (Keplerian)
rho0 = 1.0;

% wavenumbers
kx = 0; % axisymmetric
kz_list = linspace(0.1,6,200);

% parameter sweep: test effect of Ohmic diffusivity eta and Hall term omegaH
B0 = 5e-3; % background vertical field (example)
vA = B0/sqrt(rho0);

eta_list = logspace(-6, -1, 10); % Ohmic diffusivity (dimensionless)
omegaH_list = linspace(-0.5, 0.5, 9); % Hall term (signed)

% prepare storage
results = struct();
idx = 0;
fprintf('Starting non-ideal MRI runs: [%d eta values] x [%d Hall values]\n', length(eta_list), length(omegaH_list));
for i = 1:length(eta_list)
    for j = 1:length(omegaH_list)
        idx = idx + 1;
        eta = eta_list(i);
        omegaH = omegaH_list(j);
        % perform sweep over kz for fixed (eta, omegaH)
        gamma_kz = zeros(size(kz_list));
        for kk = 1:length(kz_list)
            kz = kz_list(kk);
            % MRI_quartic_solver should accept non-ideal params (see its signature)
            lambda = MRI_quartic_solver(Omega, q, rho0, B0, kx, kz, eta, 0.0, omegaH);
            % lambda is a vector of roots (complex omega). Instability when Im(omega)>0
            % pick max growth rate:
            % convention check: if MRI_quartic_solver returns omega with Im(omega)>0 => growth
            gamma_kz(kk) = max(imag(lambda));
        end
        results(idx).eta = eta;
        results(idx).omegaH = omegaH;
        results(idx).kz = kz_list;
        results(idx).gamma = gamma_kz;
        % simple progress
        if mod(idx,10)==0
            fprintf('Completed %d/%d runs\n', idx, length(eta_list)*length(omegaH_list));
        end
    end
end

% save a compact sample output for the paper
outfname = fullfile('..','examples','sample_output_MRI.mat');
save_results(outfname, results, struct('description','Sample output: non-ideal MRI sweep (eta vs Hall)'));

fprintf('Non-ideal MRI sample output saved to %s\n', outfname);
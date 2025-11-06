% generate_sample_output_HD.m
% Generate and save sample output for HD cooling instability
clear; close all; clc;
addpath('../src');

Omega = 1.0;
kx = 1.0;
kz = linspace(0.1,5,150);
tau_cool_list = logspace(-1, 1.5, 60); % from 0.1 to ~31

gamma_map = zeros(length(tau_cool_list), length(kz));

for i = 1:length(tau_cool_list)
    tau = tau_cool_list(i);
    gamma_map(i,:) = HD_compressible_solver(Omega, tau, kx, kz);
end

results.gamma_map = gamma_map;
results.kz = kz;
results.tau_cool = tau_cool_list;

outfname = fullfile('..','examples','sample_output_HD.mat');
save_results(outfname, results, struct('description','Sample output: HD cooling instability (tau_cool vs kz)'));

fprintf('HD sample output saved to %s\n', outfname);
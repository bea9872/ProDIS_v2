% non_dimensionalize.m
% Helper to nondimensionalize physical quantities for ProDIS (user-friendly)
% Usage:
% params_nd = non_dimensionalize(params_phys, opts)
%
% Inputs:
% params_phys: struct with physical quantities in SI (e.g., Mstar, r0, B0, rho0)
% opts: optional struct with choices (e.g., normalize_by = 'Omega' or 'Keplerian')
%
% Output:
% params_nd: struct with nondimensionalized numbers (Omega, vA, cs, H, etc.)

function params_nd = non_dimensionalize(params_phys, opts)
if nargin < 2
    opts = struct();
end

% default: use local Keplerian normalization at radius r0
if ~isfield(params_phys,'r0') || ~isfield(params_phys,'Mstar')
    error('params_phys must contain fields r0 (m) and Mstar (kg).');
end

G = 6.67430e-11;
r0 = params_phys.r0;
Mstar = params_phys.Mstar;

Omega = sqrt(G*Mstar / r0^3); % Keplerian angular velocity
params_nd.Omega = Omega;

% density
if isfield(params_phys,'rho0')
    rho0 = params_phys.rho0;
else
    rho0 = 1.0;
end
params_nd.rho0 = rho0;

% Alfven speed
if isfield(params_phys,'B0')
    vA = params_phys.B0 / sqrt(params_nd.rho0 * 4*pi*1e-7); % SI mu0 approximated
    params_nd.vA = vA;
end

% sound speed and scale height
if isfield(params_phys,'cs')
    cs = params_phys.cs;
    params_nd.cs = cs;
    params_nd.H = cs / Omega;
end

% outputs are SI; user may choose to re-normalize to Omega=1 by dividing times by Omega
if isfield(opts,'norm_time')
    if strcmpi(opts.norm_time,'Omega')
        params_nd.t_unit = 1 / Omega;
    end
end

% attach original struct for traceability
params_nd._orig = params_phys;

end
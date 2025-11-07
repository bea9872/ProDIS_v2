function params_nd = non_dimensionalize(params_phys, opts)
% non_dimensionalize: simple helper to compute Omega, vA, cs, H from physical SI inputs
% Inputs:
% params_phys: struct with fields Mstar (kg), r0 (m), B0 (T), rho0 (kg/m^3), cs (m/s)
% Output:
% params_nd: struct with fields Omega, vA, cs, H, rho0, B0

if nargin < 2; opts = struct(); end
if ~isfield(params_phys,'Mstar') || ~isfield(params_phys,'r0')
    error('params_phys must include Mstar and r0');
end
G = 6.67430e-11;
r0 = params_phys.r0; Mstar = params_phys.Mstar;
Omega = sqrt(G * Mstar / r0^3);
params_nd.Omega = Omega;

if isfield(params_phys,'rho0'); params_nd.rho0 = params_phys.rho0; else params_nd.rho0 = 1.0; end
if isfield(params_phys,'B0'); params_nd.B0 = params_phys.B0; params_nd.vA = params_phys.B0 / sqrt(params_nd.rho0 * 4*pi*1e-7); end
if isfield(params_phys,'cs'); params_nd.cs = params_phys.cs; params_nd.H = params_phys.cs / Omega; end
params_nd._orig = params_phys;
end
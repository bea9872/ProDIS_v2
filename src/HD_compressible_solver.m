function omegas = HD_compressible_solver(params, kz)
% HD_compressible_solver
% Linearized compressible hydrodynamic solver with Newtonian cooling.
% State: [rho'; vx; vy; vz; p'] -> 5x5 system, returns omegas (complex)
%
% Signature:
% omegas = HD_compressible_solver(params, kz)
% params must contain Omega, q, cs, rho0, tau_cool
% kz can be scalar or vector

if ~isfield(params,'Omega'); params.Omega = 1; end
if ~isfield(params,'q'); params.q = 1.5; end
if ~isfield(params,'cs'); params.cs = 0.05; end
if ~isfield(params,'rho0'); params.rho0 = 1.0; end
if ~isfield(params,'tau_cool'); params.tau_cool = 1.0; end
if ~isfield(params,'kx'); params.kx = 0; end

Omega = params.Omega; q = params.q; cs = params.cs; rho0 = params.rho0;
tau = params.tau_cool; kx = params.kx;

kz_vec = kz(:).';
nK = numel(kz_vec);
omegas = zeros(5, nK);

gamma_gas = 1.4;

for idx = 1:nK
    kz0 = kz_vec(idx);
    k = sqrt(kx^2 + kz0^2);

    % 5x5 linear operator A for dX/dt = A X, variables order:
    % [rho'; vx; vy; vz; p']
    A = zeros(5,5);

    % Continuity: drho/dt + rho0 * i(kx vx + kz vz) = 0 -> in frequency domain: d/dt term
    A(1,2) = -1i * rho0 * kx;
    A(1,4) = -1i * rho0 * kz0;

    % Momentum x: dvx/dt - 2 Omega vy = - (1/rho0) i kx p'
    A(2,3) = 2*Omega;
    A(2,5) = -(1/rho0) * 1i * kx;

    % Momentum y: dvy/dt + (2 - q) Omega vx = 0
    A(3,2) = -(2 - q) * Omega;

    % Momentum z: dvz/dt = - (1/rho0) i kz p'
    A(4,5) = -(1/rho0) * 1i * kz0;

    % Energy/pressure: dp/dt + gamma p0 i (k · v) = - p'/tau
    % Using isothermal-ish linearization: dp/dt = cs^2 * drho/dt - p'/tau
    % Implement simplified form: dp/dt + cs^2 * rho0 i (kx vx + kz vz) = - p'/tau
    A(5,2) = -1i * cs^2 * rho0 * kx;
    A(5,4) = -1i * cs^2 * rho0 * kz0;
    A(5,5) = -1 / tau;

    % small viscous damping (not physical detailed)
    nu = 1e-6;
    if k > 0
        damp = -nu * k^2;
        A(2,2) = A(2,2) + damp;
        A(3,3) = A(3,3) + damp;
        A(4,4) = A(4,4) + damp;
    end

    lambda = eig(A);
    omegas(:,idx) = lambda; % eigenvalues of dX/dt = A X; growth when real(lambda)>0 (since here no -i mapping)
end
end
function omegas = MRI_quartic_solver(params, kz)
% MRI_quartic_solver
% Solve the axisymmetric MRI quartic dispersion relation for vertical B0.
%
% Signature:
% omegas = MRI_quartic_solver(params, kz)
%
% Inputs:
% params: struct with fields
% Omega : angular velocity (scalar)
% q : shear parameter (positive, Keplerian q=1.5)
% rho0 : density
% B0 : vertical magnetic field amplitude (same units as used)
% eta : Ohmic diffusivity (optional, default 0)
% % NOTE: Hall and ambipolar can be added later (placeholders)
% kz : scalar (single k_z) OR vector => function returns matrix columns
%
% Output:
% omegas: complex roots omega for each kz. If kz is vector of length N,
% omegas is 4xN matrix (each column contains 4 roots).
%
% Convention: temporal dependence exp(-i omega t). Instability when imag(omega)>0.

if nargin < 2
    error('MRI_quartic_solver requires params and kz input.');
end
if ~isfield(params,'Omega'); error('params.Omega missing'); end
if ~isfield(params,'B0'); error('params.B0 missing'); end
if ~isfield(params,'rho0'); params.rho0 = 1.0; end
if ~isfield(params,'q'); params.q = 1.5; end
if ~isfield(params,'eta'); params.eta = 0; end

Omega = params.Omega;
B0 = params.B0;
rho0 = params.rho0;
q = params.q;
eta = params.eta;

% Ensure kz is row vector
kz_vec = kz(:).';
nK = numel(kz_vec);
omegas = zeros(4, nK);

% Epicyclic freq squared (for general rotation: kappa^2 = 2(2 - q) Omega^2)
kappa2 = 2*(2 - q) * Omega^2;

for idx = 1:nK
    kz0 = kz_vec(idx);
    k2 = kz0^2; % here axisymmetric, kx=0 chosen (vertical modes)
    vA = B0 / sqrt(rho0);
    % Ideal quartic (no non-ideal terms) in omega (see Balbus & Hawley):
    % omega^4 - omega^2*(kappa^2 + 2 k^2 vA^2) + k^2 vA^2*(k^2 vA^2 + dOmega^2/dln r) = 0
    % For Keplerian-like, dOmega^2/dln r = -2 q Omega^2
    dO2dlnr = -2 * q * Omega^2;
    % Non-ideal Ohmic diffusivity enters as replacement: omega -> omega + i eta k^2
    % A pragmatic way: define s = -i omega; but here we include eta by building
    % polynomial in omega with complex coefficients approximating damping.
    % For robustness we construct coefficients for polynomial in omega:
    % Use ideal coefficients then add small imaginary shifts for eta (approx).
    a4 = 1;
    a3 = 1i * 0; % no cubic term in ideal case
    a2 = -(kappa2 + 2 * k2 * vA^2);
    a1 = 1i * 0;
    a0 = k2 * vA^2 * (k2 * vA^2 + dO2dlnr);
    % include Ohmic diffusion approx: add -2i*eta*k^2*omega^3? Simpler: shift omega->omega + i*eta*k^2/2
    % Instead of a sophisticated nonideal model, include simple damping of field: a0 <- a0 + i*eta*k^2*(...)
    % We will add a phenomenological damping term to a1,a3 to suppress growth when eta large.
    gamma_eta = eta * k2;
    % Adjust coefficients modestly (phenomenological; good for exploring effect)
    a3 = a3 + 2i * gamma_eta;
    a1 = a1 + 2i * gamma_eta * (k2 * vA^2);
    coeffs = [a4, a3, a2, a1, a0];
    r = roots(coeffs);
    omegas(:,idx) = r;
end
end
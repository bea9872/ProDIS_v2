function omegas = MHD_matrix_solver(params, kz)
% MHD_matrix_solver
% Build and solve the linear 6x6 matrix for incompressible local MHD
% State vector: [vx; vy; vz; bx; by; bz] (Fourier modes ~ exp(i k·x - i omega t))
%
% Signature:
% omegas = MHD_matrix_solver(params, kz)
% If kz is vector length N, returns 6xN matrix of eigenvalues (omega).
%
% Inputs params: Omega, q, rho0, B0, kx (default 0), ky (default 0), eta (default 0), nu (default small)
% Output: omegas (6 x N) complex

if ~isfield(params,'Omega'); error('params.Omega missing'); end
if ~isfield(params,'B0'); params.B0 = 0; end
if ~isfield(params,'rho0'); params.rho0 = 1; end
if ~isfield(params,'q'); params.q = 1.5; end
if ~isfield(params,'kx'); params.kx = 0; end
if ~isfield(params,'ky'); params.ky = 0; end
if ~isfield(params,'eta'); params.eta = 0; end
if ~isfield(params,'nu'); params.nu = 1e-6; end

Omega = params.Omega; q = params.q; rho0 = params.rho0;
B0 = params.B0; kx = params.kx; ky = params.ky; eta = params.eta; nu = params.nu;

kz_vec = kz(:).';
nK = numel(kz_vec);
omegas = zeros(6, nK);

for idx = 1:nK
    kz0 = kz_vec(idx);
    kvec = [kx; ky; kz0];
    k2 = sum(kvec.^2);
    if k2 == 0
        omegas(:,idx) = NaN;
        continue;
    end
    vA = B0 / sqrt(rho0);

    % Build 6x6 linear operator L such that dX/dt = L*X and eigenvalues are lambda.
    % We use temporal convention exp(-i omega t) -> eigenvalues are -i*omega if operator used in that form.
    % For simplicity we build operator as i*omega * X = M * X and compute eigenvalues accordingly.
    % Here we will build A so that dX/dt = A*X, then eig(A) gives lambda where solution ~ exp(lambda t).
    % To map to omega: omega = -i * lambda. We will return omegas = -1i * lambda.

    A = zeros(6,6);

    % Indices
    IVX=1; IVY=2; IVZ=3; IBX=4; IBY=5; IBZ=6;

    % Coriolis & shear (momentum)
    A(IVX, IVY) = 2*Omega;
    A(IVY, IVX) = -(2 - q)*Omega;

    % Lorentz force approx: (i k·B0) b / rho - projection term for pressure
    % For vertical field B0 e_z:
    % coupling factor = i * kz0 * B0 / rho0
    coeff = 1i * kz0 * B0 / rho0;
    % momentum <- b
    A(IVX, IBX) = A(IVX, IBX) + coeff;
    A(IVY, IBY) = A(IVY, IBY) + coeff;
    A(IVZ, IBZ) = A(IVZ, IBZ) + coeff;

    % Induction: db/dt = i (k·B0) v - q Omega b_x e_y - eta k^2 b
    A(IBX, IVX) = 1i * kz0 * B0;
    A(IBY, IVY) = 1i * kz0 * B0;
    A(IBZ, IVZ) = 1i * kz0 * B0;
    A(IBY, IBX) = A(IBY, IBX) - q * Omega; % shear stretch

    % Resistivity damping
    if eta > 0
        A(IBX, IBX) = A(IBX, IBX) - eta * k2;
        A(IBY, IBY) = A(IBY, IBY) - eta * k2;
        A(IBZ, IBZ) = A(IBZ, IBZ) - eta * k2;
    end

    % small viscous damping on velocities
    A(IVX, IVX) = A(IVX, IVX) - nu * k2;
    A(IVY, IVY) = A(IVY, IVY) - nu * k2;
    A(IVZ, IVZ) = A(IVZ, IVZ) - nu * k2;

    % compute eigenvalues of A (time-evolution operator), then convert to omega
    lambda = eig(A);
    omegas(:,idx) = -1i * lambda; % omega = -i * lambda
end
end
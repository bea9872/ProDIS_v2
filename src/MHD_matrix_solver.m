% MHD_matrix_solver.m
% Build linear operator A for local incompressible MHD in shearing box
% State vector: [vx; vy; vz; bx; by; bz]
%
% Usage:
% A = MHD_matrix_solver(Omega, q, rho0, B0, kx, ky, kz, eta)
%
% Notes:
% - Axisymmetric typical use: ky = 0, ky small for non-axisymmetric
% - Incompressibility enforced approximately by projecting pressure gradient
% - Resistivity eta acts as -eta*k^2 on magnetic components

function A = MHD_matrix_solver(Omega, q, rho0, B0, kx, ky, kz, eta)
if nargin < 9
    eta = 0;
end
% derived
k2 = kx^2 + ky^2 + kz^2;
kvec = [kx; ky; kz];

% Alfvén speed (mu0 normalized out; assume units where mu0=1)
vA = B0 / sqrt(rho0);

% indices
IVX = 1; IVY = 2; IVZ = 3; IBX = 4; IBY = 5; IBZ = 6;

A = zeros(6,6);

% ----- Momentum equations (linearized) -----
% dv/dt = 2 Omega x v + q Omega vx ey - i k p / rho + (i (k·B0) b)/rho
% in Fourier space pressure term ~ -i k (p)/rho; eliminate p by projection:
% projection operator P_ij = delta_ij - k_i k_j / k^2
% so effective pressure gradient is removed by applying P to RHS
% We'll assemble the momentum forcing Fm = Coriolis + Lorentz and then apply P.

% Coriolis and shear terms (Coriolis: 2 Omega cross v; tidal shear term in vy)
% dvx/dt <- 2 Omega vy
A(IVX, IVY) = 2*Omega;
% dvy/dt <- -(2 - q) Omega vx
A(IVY, IVX) = -(2 - q)*Omega;
% dvz no direct coriolis-shear linear term apart from pressure projection

% Lorentz force terms: (1/rho) (i k x (B0 x b)?) Equivalent to i (k·B0) b / rho - i k (B0·b)/rho
% For uniform vertical B0 = (0,0,B0): k·B0 = kz*B0
% So Lorentz approximate contribution to dv/dt: i*kz*B0/rho * b - i*k*(B0*b)/rho
% Implement a practical simplified operator that captures main coupling:
% dv_i/dt += i*(kz*B0/rho0) * b_i - i*(k_i / k2)*(kz*B0/rho0)*(k·b)
% Note: this mimics projection after pressure elimination.

coeff = 1i * kz * B0 / rho0; % common factor
for vi = 1:3
    for bi = 1:3
        % direct coupling
        A(vi, 3+bi) = A(vi, 3+bi) + coeff * (vi==bi);
    end
end
% subtract projected parallel part: -i*(k_i/k2)*(k·b)*coeff
% implement - (k_i/k2) * coeff * (k · b) coupling to every b component
for vi = 1:3
    for bi = 1:3
        A(vi, 3+bi) = A(vi, 3+bi) - (kvec(vi)/k2) * coeff * kvec(bi);
    end
end

% ----- Induction equations (linearized) -----
% db/dt = i (k·B0) v - q Omega b_x e_y - eta k^2 b
% For vertical B0 only, (k·B0) = kz*B0 -> coupling i kz B0 v
% Shear term: -q Omega b_x contributes to db_y/dt

for bi = 1:3
    for vi = 1:3
        A(3+bi, vi) = 1i * kz * B0 * (bi==vi);
    end
end
% shear term (stretching of field): db_y/dt <- - q Omega b_x
A(IBY, IBX) = - q * Omega;

% Resistive damping on magnetic components
if eta > 0
    A(IBX, IBX) = A(IBX, IBX) - eta * k2;
    A(IBY, IBY) = A(IBY, IBY) - eta * k2;
    A(IBZ, IBZ) = A(IBZ, IBZ) - eta * k2;
end

% ----- Small viscous damping for velocity (numerical) -----
nu = 1e-6;
if k2>0
    damp = -nu * k2;
    A(IVX, IVX) = A(IVX, IVX) + damp;
    A(IVY, IVY) = A(IVY, IVY) + damp;
    A(IVZ, IVZ) = A(IVZ, IVZ) + damp;
end

% ----- Notes -----
% - This operator is practical and captures key couplings (Coriolis, magnetic tension,
% shear stretching, resistivity). It is suitable for parameter scans and eigenvalue analysis.
% - For publication-grade quantitative work, users should carefully compare results
% with the analytic quartic dispersion relation (axisymmetric case) and, if needed,
% derive the full linear operator including pressure elimination analytically.

end
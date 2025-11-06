% param_sweep.m
% Generic parameter sweep utility for ProDIS_v2
% Usage:
% results = param_sweep(func_handle, sweep_spec)
% where func_handle is a function that returns eigenvalues/ growth rates, and
% sweep_spec is a struct that contains fields for parameters to vary.
%
% Example sweep_spec for MRI_quartic_solver:
% sweep_spec.model = 'MRI_quartic';
% sweep_spec.Omega = 1;
% sweep_spec.q = 1.5;
% sweep_spec.rho0 = 1;
% sweep_spec.B0 = 1e-3;
% sweep_spec.kx = 0;
% sweep_spec.kz_list = linspace(0.1,6,200);
% sweep_spec.eta_list = logspace(-6,-1,10);
% sweep_spec.omegaH_list = linspace(-0.5,0.5,9);

function results = param_sweep(func_handle, sweep_spec)
% initialize outputs
results = struct();
tic;

% Determine which sweep dimensions exist (example supports up to 2D nested sweep)
if isfield(sweep_spec,'kz_list')
    kz_list = sweep_spec.kz_list;
else
    error('sweep_spec must contain kz_list');
end

% Build parameter grids:
% Support optional lists: B0_list, eta_list, omegaH_list, tau_cool_list, etc.
% We'll detect numeric arrays in sweep_spec and iterate accordingly.

% Identify sweep fields (vectors) among possible known names:
sweep_fields = {};
possible_fields = {'B0_list','vA_list','eta_list','omegaH_list','tau_cool_list','tau_list','param1_list','param2_list'};

for f = possible_fields
    fname = f{1};
    if isfield(sweep_spec, fname)
        sweep_fields{end+1} = fname; %#ok<AGROW>
    end
end

% If no sweep_fields found, search for any field that ends with _list
all_fields = fieldnames(sweep_spec);
for i = 1:length(all_fields)
    if endsWith(all_fields{i},'_list') && ~ismember(all_fields{i}, sweep_fields)
        sweep_fields{end+1} = all_fields{i};
    end
end

% If still empty, assume single run with given params
if isempty(sweep_fields)
    % single evaluation
    gamma_map = zeros(1,length(kz_list));
    for kk = 1:length(kz_list)
        kz = kz_list(kk);
        lambda = feval(func_handle, sweep_spec, kz); % user func must accept (sweep_spec,kz)
        % choose growth: max(imag(lambda))
        gamma_map(kk) = max(imag(lambda));
    end
    results.gamma_map = gamma_map;
    results.kz = kz_list;
    results.meta = sweep_spec;
    return;
end

% For up to 2 sweep dimensions, do nested loops
% We'll support 1D (one sweep list) or 2D (two lists)
sf = sweep_fields;
if length(sf) == 1
    list1 = sweep_spec.(sf{1});
    n1 = length(list1);
    gamma_map = zeros(n1, length(kz_list));
    for i1 = 1:n1
        sweep_spec.(strrep(sf{1},'_list','')) = list1(i1); % set param without '_list'
        for kk = 1:length(kz_list)
            kz = kz_list(kk);
            lambda = feval(func_handle, sweep_spec, kz);
            gamma_map(i1, kk) = max(imag(lambda));
        end
    end
    results.gamma_map = gamma_map;
    results.kz = kz_list;
    results.param1_name = sf{1};
    results.param1_vals = list1;
elseif length(sf) >= 2
    list1 = sweep_spec.(sf{1});
    list2 = sweep_spec.(sf{2});
    n1 = length(list1); n2 = length(list2);
    gamma_map = zeros(n1, n2, length(kz_list)); % 3D: param1 x param2 x kz
    for i1 = 1:n1
        sweep_spec.(strrep(sf{1},'_list','')) = list1(i1);
        for i2 = 1:n2
            sweep_spec.(strrep(sf{2},'_list','')) = list2(i2);
            for kk = 1:length(kz_list)
                kz = kz_list(kk);
                lambda = feval(func_handle, sweep_spec, kz);
                gamma_map(i1, i2, kk) = max(imag(lambda));
            end
        end
    end
    results.gamma_map = gamma_map;
    results.kz = kz_list;
    results.param1_name = sf{1};
    results.param1_vals = list1;
    results.param2_name = sf{2};
    results.param2_vals = list2;
else
    error('Too many sweep dimensions for current implementation.');
end

results.meta = sweep_spec;
toc;
end
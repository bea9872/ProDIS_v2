function results = param_sweep(solver_handle, sweep_spec)
% param_sweep - generic parameter sweep driver
%
% Usage:
% results = param_sweep(solver_handle, sweep_spec)
%
% solver_handle: function handle, called as solver_handle(params, kz)
% sweep_spec: struct with fields:
% kz_list - vector of kz to evaluate
% fixed_params - struct with physical parameters used by solver_handle
% sweep_name - string (optional)
% sweep_var_name - name of swept parameter in fixed_params (optional)
% sweep_vals - vector of values to sweep (optional)
%
% If sweep_vals is present -> nested sweep: for each sweep_vals(i) set fixed_params.(sweep_var_name)=sweep_vals(i)

if ~isfield(sweep_spec,'kz_list')
    error('sweep_spec.kz_list is missing or empty');
end
kz_list = sweep_spec.kz_list;
np = numel(kz_list);

% defaults
if ~isfield(sweep_spec,'fixed_params')
    error('sweep_spec.fixed_params must be provided');
end

params0 = sweep_spec.fixed_params;

% determine if sweeping a parameter
if isfield(sweep_spec,'sweep_var_name') && isfield(sweep_spec,'sweep_vals')
    varname = sweep_spec.sweep_var_name;
    vals = sweep_spec.sweep_vals;
    nvals = numel(vals);
    gamma_map = zeros(nvals, np); % store dominant growth measure (real or imag depending solver)
    raw = cell(nvals,1);
    for i=1:nvals
        params = params0;
        params.(varname) = vals(i);
        % evaluate over kz
        gr_kz = zeros(1, np);
        raw_kz = cell(1,np);
        for kidx = 1:np
            kz = kz_list(kidx);
            omegas = solver_handle(params, kz); % vector of roots or eigenvalues
            % Determine growth measure:
            % If omegas is complex (omega form): growth = max(imag(omega))
            % If omegas is result of linear dX/dt eigenvalues: growth = max(real(lambda))
            if ~isempty(omegas) && any(imag(omegas(:))~=0)
                % assume omega-modes (imag positive => growth)
                gr_kz(kidx) = max(imag(omegas(:)));
            else
                % assume lambda (growth if real positive)
                gr_kz(kidx) = max(real(omegas(:)));
            end
            raw_kz{kidx} = omegas;
        end
        gamma_map(i,:) = gr_kz;
        raw{i}.params = params;
        raw{i}.kz = kz_list;
        raw{i}.omegas = raw_kz;
    end
    results.gamma_map = gamma_map;
    results.kz_list = kz_list;
    results.sweep_var_name = varname;
    results.sweep_vals = vals;
    results.raw = raw;
else
    % no sweep var, single set of params
    params = params0;
    gamma_map = zeros(1,np);
    raw_kz = cell(1,np);
    for kidx = 1:np
        kz = kz_list(kidx);
        omegas = solver_handle(params, kz);
        if ~isempty(omegas) && any(imag(omegas(:))~=0)
            gamma_map(kidx) = max(imag(omegas(:)));
        else
            gamma_map(kidx) = max(real(omegas(:)));
        end
        raw_kz{kidx} = omegas;
    end
    results.gamma_map = gamma_map;
    results.kz_list = kz_list;
    results.raw = raw_kz;
    results.fixed_params = params;
end
end
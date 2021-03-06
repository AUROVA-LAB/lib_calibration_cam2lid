clear, clc, close all

disp('*** init program: load parameters (only Matlab functions) ***');
[data, params, experiments] = getConfigurationParams();
M = experiments.num_datasets;
ext_obs = {};
ext_stt = {};
ext_meas = {};
ext_id = {};
[data.input.tf_err, state, gt] = generateMisscalibration();
load('noise_model.mat')

t = tic;
for j = [10]
    N = experiments.num_samples(j);
    for i = 1:N       
        experiments.id_dataset = j;
        experiments.id_sample = i;  
        
        disp([j i])
        disp('*** reading data (only Matlab functions) ***')
        [data, params] = readFileData(data, params, experiments);

        disp('*** init extrinsic targetless calibration (library) ***')
        data = extTargetlessCalibration(data, params);
        
        disp('*** plot results (only Matlab functions) ***')
        plotResults(data, params, experiments);
        
        if data.matches.num >= data.matches.max
            ext_obs = [ext_obs data.output];
            [yaw, pitch, roll] = dcm2angle(data.output.orientation);
            measure = [data.output.location, yaw, pitch, roll];
            ext_meas = [ext_meas measure];
            ext_id = [ext_id j];
            %observation = setObservation(data.output, noise_model);
            %state = updateState(observation, state);
            %ext_stt = [ext_stt state];
        end
    end
end
disp(toc(t))
classdef pspm_convert_au2unit_test < pspm_testcase
% ● Description
% unittest class for the pspm_convert_au2unit function
% ● Authorship
% (C) 2019 Eshref Yozdemir (University of Zurich)
% Updated in 2026 by Bernhard von Raußendorf

methods (Test)

%% data mode
%   [sts, converted_data] = pspm_convert_au2unit(data, unit, distance, record_method,
%                           multiplicator, reference_distance, reference_unit, options)
function testDiameterSameUnits(testCase)
    [sts, out] = pspm_convert_au2unit(20, 'mm', 60, 'diameter', 0.1, 50, 'mm');
    testCase.verifyEqual(sts, 1);
    testCase.verifyEqual(out, 2.4);
end
function testDiameterUnitConversion(testCase)
    [sts, out] = pspm_convert_au2unit(30, 'cm', 6, 'diameter', 0.2, 50, 'mm');
    testCase.verifyEqual(sts, 1);
    testCase.verifyEqual(out, 0.72);
end
function testAreaSameUnits(testCase)
    data = 100;
    [sts, out] = pspm_convert_au2unit(data, 'mm', 60, 'area', 0.1, 50, 'mm');
    testCase.verifyEqual(sts, 1);
    
    % expected with formula diameter = 2.*sqrt(area./pi);
    expected_from_formula = 0.1 * (60 / 50) * 2*sqrt(data./pi);
    testCase.verifyEqual(out, expected_from_formula);

    % expected with [sts, diameter] = pspm_convert_area2diameter(area)
    [sts, diam] = pspm_convert_area2diameter(data);
    expected_from_pspm = 0.1 * (60 / 50) * diam;
    testCase.verifyEqual(out, expected_from_pspm);

end
function testAreaUnitConversion(testCase)
    data = 400;
    [sts, out] = pspm_convert_au2unit(data, 'mm', 100, 'area', 0.1, 100, 'm'); % reference_unit in m
    testCase.verifyEqual(sts, 1);

    
    % expected with formula diameter = 2.*sqrt(area./pi);
    % ref. units in m: Dconv 100mm -> 0.1 m and A(Dconv/Dref) m -> mm (*1000)
    expected_from_formula = 0.1 * (0.1 / 100) * 2 * sqrt(data ./ pi) * 1000;
    testCase.verifyEqual(out, expected_from_formula);

    % expected with [sts, diameter] = pspm_convert_area2diameter(area)
    [sts, diam] = pspm_convert_area2diameter(data);
    expected_from_pspm = 0.1 * (0.1 / 100) * diam * 1000;
    testCase.verifyEqual(out, expected_from_pspm);


    
end
function testVectorAreaSameUnits(testCase)
    data = [25 36 49]
    [sts, out] = pspm_convert_au2unit(data, 'mm', 80, 'area', 0.05, 40, 'mm');
    testCase.verifyEqual(sts, 1);


    % expected with formula diameter = 2.*sqrt(area./pi);
    expected_from_formula = 0.05 * (80 / 40) * 2 * sqrt(data ./ pi) ;
    testCase.verifyEqual(out, expected_from_formula);

    % expected with [sts, diameter] = pspm_convert_area2diameter(area)
    [sts, diam] = pspm_convert_area2diameter(data);
    expected_from_pspm = 0.05 * (80 / 40) * diam ;
    testCase.verifyEqual(out, expected_from_pspm);

end
function testVectorAreaUnitConversion(testCase)
    data = [100 400 900];
    [sts,out]=pspm_convert_au2unit(data,'mm',100,'area',0.1,50,'m'); 
    testCase.verifyEqual(sts,1); 

    % expected with formula diameter = 2.*sqrt(area./pi);
    expected_from_formula = 0.1 * (0.1 / 50) * 2 * sqrt(data ./ pi) * 1000 ;
    testCase.verifyEqual(out, expected_from_formula);

    % expected with [sts, diameter] = pspm_convert_area2diameter(area)
    [sts, diam] = pspm_convert_area2diameter(data);
    expected_from_pspm = 0.1 * (0.1 / 50) * diam * 1000;
    testCase.verifyEqual(out, expected_from_pspm);
end
function testVectorAreaUnitConversionTEST(testCase)
    data = [100 400 900];
    [sts,out]=pspm_convert_au2unit(data,'mm',100,'area',0.1,50,'mm'); 
    testCase.verifyEqual(sts,1); 
    % 
    % % expected with formula diameter = 2.*sqrt(area./pi);
    % expected_from_formula = 0.1 * (0.1 / 50) * 2 * sqrt(data ./ pi) * 1000 ;
    % testCase.verifyEqual(out, expected_from_formula);
    % 
    % % expected with [sts, diameter] = pspm_convert_area2diameter(area)
    % [sts, diam] = pspm_convert_area2diameter(data);
    % expected_from_pspm = 0.1 * (0.1 / 50) * diam * 1000;
    % testCase.verifyEqual(out, expected_from_pspm);

    data2 = unit2au(out,'mm',100,'area',0.1,50,'mm');
    testCase.verifyEqual(data   , data2, 'AbsTol', 1e-12);
end
function testFileChannelActionAddAndReplace(testCase)
    fn = fullfile('ImportTestData', 'eyelink', 'pspm_u_sc4b31.mat');
    fn_test = fullfile('ImportTestData', 'eyelink', 'pspm_u_sc4b31_au_addreplace.mat');

    S = load(fn);
    save(fn_test, '-struct', 'S');

    cleanupObj = onCleanup(@() delete(fn_test));

    unit = 'mm';
    distance = 600;
    record_method = 'diameter';
    multiplicator = 0.04;
    reference_distance = 500;
    reference_unit = 'mm';

    %% Load original pupil channel
    [sts, original_channel, ~, pos] = pspm_load_channel(fn_test, 'pupil', 'pupil');
    testCase.verifyEqual(sts, 1);

    original_data = original_channel.data;

    %% Convert original mm data to artificial au data
    au_data = unit2au(original_data, unit, distance, record_method, ...
        multiplicator, reference_distance, reference_unit);

    newdata = original_channel;
    newdata.data = au_data;
    newdata.header.units = 'au';

    [sts, ~] = pspm_write_channel(fn_test, newdata, 'replace', struct('channel', pos));
    testCase.verifyEqual(sts, 1);

    %% Count channels before add
    [sts, ~, ~, filestruct_before] = pspm_load_data(fn_test, 'none');
    testCase.verifyEqual(sts, 1);
    numofchanbefore = filestruct_before.numofchan;

    %% Test add
    options = struct();
    options.channel = pos;
    options.channel_action = 'add';

    [sts, out_add] = pspm_convert_au2unit(fn_test, unit, distance, record_method, ...
        multiplicator, reference_distance, reference_unit, options);

    testCase.verifyEqual(sts, 1);

    [sts, ~, data_after_add, filestruct_after_add] = pspm_load_data(fn_test, 'none');
    testCase.verifyEqual(sts, 1);

    testCase.verifyEqual(filestruct_after_add.numofchan, numofchanbefore + 1);
    testCase.verifyEqual(out_add, filestruct_after_add.numofchan);
    testCase.verifyEqual(data_after_add{out_add}.header.units, unit);
    testCase.verifyEqual(data_after_add{out_add}.header.chantype, original_channel.header.chantype);

    valid = isfinite(original_data);
    testCase.verifyEqual(data_after_add{out_add}.data(valid), ...
        original_data(valid), 'AbsTol', 1e-12);

    %% Test replace
    options.channel = pos;
    options.channel_action = 'replace';

    [sts, out_replace] = pspm_convert_au2unit(fn_test, unit, distance, record_method, ...
        multiplicator, reference_distance, reference_unit, options);

    testCase.verifyEqual(sts, 1);

    [sts, ~, data_after_replace, filestruct_after_replace] = pspm_load_data(fn_test, 'none');
    testCase.verifyEqual(sts, 1);

    testCase.verifyEqual(filestruct_after_replace.numofchan, filestruct_after_add.numofchan);
    testCase.verifyEqual(out_replace, pos);
    testCase.verifyEqual(data_after_replace{pos}.header.units, unit);
    testCase.verifyEqual(data_after_replace{pos}.header.chantype, original_channel.header.chantype);

    testCase.verifyEqual(data_after_replace{pos}.data(valid), ...
        original_data(valid), 'AbsTol', 1e-12);
end

%% Error handeling
function testErrorHandling(testCase)
    % invalid inputs
    [sts,out] = pspm_convert_au2unit();
    testCase.verifyEqual(sts,-1);
    testCase.verifyEmpty(out);
    
    [sts,out] = pspm_convert_au2unit(20);
    testCase.verifyEqual(sts,-1);
    testCase.verifyEmpty(out);
    
    [sts,out] = pspm_convert_au2unit(20,'mm');
    testCase.verifyEqual(sts,-1);
    testCase.verifyEmpty(out);
    
    [sts,out] = pspm_convert_au2unit(20,'mm',60);
    testCase.verifyEqual(sts,-1);
    testCase.verifyEmpty(out);
    % invalid unit inputs
    [sts,out] = pspm_convert_au2unit(20,'mm',60,'wrong',0.1,50,'mm');
    testCase.verifyEqual(sts,-1);
    testCase.verifyEmpty(out);
    
    [sts,out] = pspm_convert_au2unit(20,'mm','far','diameter',0.1,50,'mm');
    testCase.verifyEqual(sts,-1);
    testCase.verifyEmpty(out);
    
    [sts,out] = pspm_convert_au2unit(20,'mm',60,'diameter','bad',50,'mm');
    testCase.verifyEqual(sts,-1);
    testCase.verifyEmpty(out);
    
    [sts,out] = pspm_convert_au2unit(20,'mm',60,'diameter',0.1,'bad','mm');
    testCase.verifyEqual(sts,-1);
    testCase.verifyEmpty(out);
end

%% Pspm files
function testFileRoundTripConvertAu2Unit(testCase)
    fn = fullfile('ImportTestData', 'eyelink', 'pspm_u_sc4b31.mat');
    fn_roundtrip = fullfile('ImportTestData', 'eyelink', 'pspm_u_sc4b31_au.mat');

    % copy file
    S = load(fn);
    save(fn_roundtrip, '-struct', 'S');

    unit = 'mm';
    distance = 600;
    record_method = 'diameter';
    multiplicator = 0.04;
    reference_distance = 500;
    reference_unit = 'mm';

    options = struct();
    options.channel = 'pupil';
    options.channel_action = 'replace';

    %% 1) load original file
    [sts, infos, data] = pspm_load_data(fn);
    testCase.verifyEqual(sts, 1);

    %% 2) load pupil channel
    [sts, original_channel, ~, pos] = pspm_load_channel(fn, options.channel, 'pupil');
    testCase.verifyEqual(sts, 1);

    %% 3) change units to au
    au_data = unit2au(original_channel.data, unit, distance, record_method, ...
        multiplicator, reference_distance, reference_unit);

    newdata = original_channel;
    newdata.data = au_data;
    newdata.header.units = 'au';

    [sts, info_write] = pspm_write_channel(fn_roundtrip, newdata, 'replace', struct('channel', pos));
    testCase.verifyEqual(sts, 1);

    %% 4) convert back to units
    [sts, outchannel] = pspm_convert_au2unit( ...
        fn_roundtrip, unit, distance, record_method, ...
        multiplicator, reference_distance, reference_unit, ...
        struct('channel', pos, 'channel_action', 'replace'));
    testCase.verifyEqual(sts, 1);

    %% 5) load converted channel
    [sts, reconverted_channel] = pspm_load_channel(fn_roundtrip, outchannel, 'pupil');
    testCase.verifyEqual(sts, 1);

    %% 8) Test
    testCase.verifyEqual(reconverted_channel.data, original_channel.data, 'AbsTol', 1e-12);
    testCase.verifyEqual(reconverted_channel.header.units, unit);

    %% cleanup
    if exist(fn_roundtrip, 'file')
        delete(fn_roundtrip);
    end
end

end
end

function data = unit2au(outchannel, unit, distance, record_method, ...
    multiplicator, reference_distance, reference_unit)

    % [~, outchannel_ref] = pspm_convert_unit(outchannel, unit, reference_unit);
    % [~, distance_conv] = pspm_convert_unit(distance, unit, reference_unit);

    switch lower(record_method)
        case 'diameter'
            data = outchannel ./ ...
                (multiplicator * (distance / reference_distance ));
        case 'area'

            data = (outchannel ./ ...
                (multiplicator * ( distance/ reference_distance)));
            data = ((data./2).^2 ).*pi;
            
        otherwise
            error('Invalid record_method');
    end
end





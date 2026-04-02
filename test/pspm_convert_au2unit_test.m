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
    fn = '/home/bernd/git/PsPM/ImportTestData/eyelink/pspm_u_sc4b31.mat';
    fn_roundtrip = '/home/bernd/git/PsPM/ImportTestData/eyelink/pspm_u_sc4b31_au.mat';

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





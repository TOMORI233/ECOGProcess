function params = windowConfig_7_10Freq(params, ISI)
    narginchk(1, 2);

    if nargin < 2
        ISI = 500;
    end

    params.windowICA  = [-2000,  1000];
    params.windowBase = [-3500, -3000];

    switch ISI
        case 500
            params.windowPE  = [-2000, 2000];
            params.windowMMN = [0    , 500 ];
            params.windowDM  = [-1000, 1000];
            params.windowP   = [-2000, 7000];
            params.windowT0  = [0    , 500 ]; % sum cwt spect
        case 400
            params.windowPE  = [-400 , 800 ];
            params.windowMMN = [0    , 400 ];
            params.windowDM  = [-200 , 800 ];
            params.windowP   = [-2000, 6000];
            params.windowT0  = [0    , 400 ]; % sum cwt spect
        case 700
            params.windowPE  = [-700 , 800 ];
            params.windowMMN = [0    , 700 ];
            params.windowDM  = [-200 , 800 ];
            params.windowP   = [-2000, 9000];
            params.windowT0  = [0    , 700 ]; % sum cwt spect
    end

    return;
end
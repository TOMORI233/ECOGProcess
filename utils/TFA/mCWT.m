function [t, f, CData, coi] = mCWT(data, fs, cwtMethod, fsD, freqLimits)
    % Description: downsampling and apply cwt to data
    % Input:
    %     data: a 1*n vector
    %     fs: raw sample rate of data, in Hz
    %     cwtMethod: 'morse', 'morlet', 'bump' or 'STFT'
    %     fsD: downsample rate, in Hz
    %     freqLimits: frequency range for cwt mapping, specified as a two-element increasing vector (default: [0, 256])
    % Output:
    %     t: time vector, in sec
    %     f: frequency vector, in Hz
    %     CData: spectrogram mapped in t-f domain
    %     coi: cone of influence along t

    narginchk(2, 5);

    if nargin < 3
        cwtMethod = 'morlet';
    end

    if nargin < 4
        fsD = 500;
    end

    if nargin < 5
        freqLimits = [0, 256];
    end
    
    if ~isempty(fsD) && fsD ~= fs
        [P, Q] = rat(fsD / fs);
        dataResample = resample(data, P, Q);
    else
        fsD = fs;
        dataResample = data;
    end
    
    switch cwtMethod
        case 'morse'
            [wt, f, coi] =cwt(dataResample, 'morse', fsD, 'FequencyLimits', freqLimits);
        case 'morlet'
            [wt, f, coi] =cwt(dataResample, 'amor', fsD, 'FequencyLimits', freqLimits);
        case 'bump'
            [wt, f, coi] =cwt(dataResample, 'bump', fsD, 'FequencyLimits', freqLimits);   
        case 'STFT'
            spectrogram
        otherwise
            error('Invalid cwt method');
    end
    
    t = (1:length(dataResample)) / fsD;
    CData = abs(wt);

    return;
end
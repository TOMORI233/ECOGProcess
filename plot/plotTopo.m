function mAxe = plotTopo(varargin)
    % Description: remap Data according to [topoSize] and plot color map to axes
    % Input:
    %     mAxe: target axes
    %     Data: data to plot, make sure numel(data) == topoSize(1) * topoSize(2)
    %     topoSize: [x,y], Data will be remapped as a [x,y] matrix
    %     contourOpt: contour option "on" or "off" (default="on")
    %     resolution: apply 2-D interpolation to the remapped [Data], which is an
    %                 N-point insertion. Thus, resolution = N.
    % Output:
    %     mAxe: output axes

    if isgraphics(varargin{1}(1), "axes")
        mAxe = varargin{1}(1);
        varargin = varargin(2:end);
    else
        mAxe = gca;
    end

    mIp = inputParser;
    mIp.addRequired("mAxe", @(x) isgraphics(x, "axes"));
    mIp.addRequired("Data");
    mIp.addOptional("topoSize", [8, 8], @(x) validateattributes(x, 'numeric', {'numel', 2, 'positive', 'integer'}));
    mIp.addParameter("contourOpt", "on", @(x) any(validatestring(x, {'on', 'off'})));
    mIp.addParameter("resolution", 5, @(x) validateattributes(x, 'numeric', {'scalar', 'positive', 'integer'}));
    mIp.parse(mAxe, varargin{:})

    Data = mIp.Results.Data;
    topoSize = mIp.Results.topoSize;
    contourOpt = mIp.Results.contourOpt;
    N = mIp.Results.resolution;

    if numel(Data) ~= topoSize(1) * topoSize(2)
        error("Numel of input data should be topoSize(1)*topoSize(2)");
    end
    
    C = flipud(reshape(Data, topoSize)'); % starts from top-left
    C = padarray(C, [1, 1], "replicate");
    C = interp2(C, N);
    C = imgaussfilt(C, 8);
    X = linspace(0, topoSize(1) + 1, size(C, 1)); % extend 1 ch
    Y = linspace(0, topoSize(2) + 1, size(C, 2)); % extend 1 ch
    imagesc(mAxe, "XData", X, "YData", Y, "CData", C);

    if strcmpi(contourOpt, "on")
        % contour option may not work for linear array
        try
            hold on;
            contour(X, Y, C, "LineColor", "k");
        end

    end

    set(mAxe, "XLimitMethod", "tight");
    set(mAxe, "YLimitMethod", "tight");
    xticklabels(mAxe, '');
    yticklabels(mAxe, '');
    colormap(mAxe, 'jet');
end
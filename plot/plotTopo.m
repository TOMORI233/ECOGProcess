function varargout = plotTopo(varargin)
    % Description: remap Data according to [topoSize] and plot color map to axes
    % Input:
    %     mAxe: target axes
    %     Data: vector, make sure numel(data) == topoSize(1) * topoSize(2).
    %     topoSize: [x,y], Data will be remapped as a [x,y] matrix.
    %               [x,y] -> [nCol,nRow], indices start from left-top.
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
    mIp.addRequired("Data", @(x) isnumeric(x) && isvector(x));
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

    if any(isnan(Data))
        warning("NaN found in your data. NaN will be replaced by zero");
        Data(isnan(Data)) = 0;
    end
    
    C = flipud(reshape(Data, topoSize)');
    C = padarray(C, [1, 1], "replicate");
    C = interp2(C, N);
    C = imgaussfilt(C, 8);
    X = linspace(0, topoSize(1) + 1, size(C, 1));
    Y = linspace(0, topoSize(2) + 1, size(C, 2));
    imagesc(mAxe, "XData", X, "YData", Y, "CData", C);

    if strcmpi(contourOpt, "on")
        % contour option may not work for linear array
        try
            hold on;
            contour(mAxe, X, Y, C, "LineColor", "k");
        end

    end

    set(mAxe, "XLimitMethod", "tight");
    set(mAxe, "YLimitMethod", "tight");
    xticklabels('');
    yticklabels('');
    colormap(mAxe, 'jet');

    if nargout == 1
        varargout{1} = mAxe;
    elseif nargout > 1
        error("plotTopo(): output number should be <= 1");
    end

    return;
end
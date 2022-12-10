function plotLayout(varargin)
    % Description: plot layout image to figures or axes
    % Input:
    %     FigsOrAxes: target figures or axes array
    %     posIndex: 1 - AC of CC
    %               2 - PFC of CC
    %               3 - AC of XX
    %               4 - PFC of XX
    %     alphaValue: alpha from 0 to 1.
    %                 0 for completely transparent.
    %                 1 for completely opaque.
    
    if all(isgraphics(varargin{1}, "figure") | isgraphics(varargin{1}, "axes"))
        FigsOrAxes = varargin{1};
        posIndex = varargin{2};
        varargin = varargin(3:end);
    else
        FigsOrAxes = gcf;
        posIndex = varargin{1};
        varargin = varargin(2:end);
    end

    mIp = inputParser;
    mIp.addRequired("FigsOrAxes", @isgraphics);
    mIp.addRequired("posIndex", @(x) ismember(x, 1:4));
    mIp.addOptional("alphaValue", 0.5, @(x) isa(x, "double") && isscalar(x) && x >= 0 && x <= 1);
    mIp.parse(FigsOrAxes, posIndex, varargin{:});

    alphaValue = mIp.Results.alphaValue;

    load('layout.mat');

    for fIndex = 1:length(FigsOrAxes)
        
        switch class(FigsOrAxes(fIndex))
            case "matlab.ui.Figure"
                setAxes(FigsOrAxes(fIndex), 'color', 'none');
                layAx = mSubplot(FigsOrAxes(fIndex), 1, 1, 1, "shape", "fill");
            case "matlab.graphics.axis.Axes"
                currentPosition = FigsOrAxes(fIndex).Position;
                currentFig = FigsOrAxes(fIndex).Parent;
                layAx = axes(currentFig, "Position", currentPosition);
            otherwise
                error("Input targets should be figures or axes object array");
        end

        switch posIndex
            case 1 % chouchou AC square
                h = image(layAx, cc_AC_sulcus_square);
            case 2 % chouchou PFC square
                h = image(layAx, cc_PFC_sulcus_square);
            case 3 % xiaoxiao AC square 
                h = image(layAx, xx_AC_sulcus_square);
            case 4 % xiaoxiao PFC square
                h = image(layAx, xx_PFC_sulcus_square);
        end

        set(layAx, 'Visible', 'off');
        set(h, "alphadata", ~imbinarize(rgb2gray(h.CData)) * alphaValue);
    end
    
    return;
end

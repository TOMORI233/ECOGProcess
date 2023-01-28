function [PosIsGreater, varargout] = AreaAboveThr(data, time, chNP, thrFrac)
% positive
posData = data;
greater_Index = posData > max(posData)*thrFrac;
posData(~greater_Index) = 0;
posData(greater_Index) = posData(greater_Index)-max(posData)*thrFrac;
pos_AUC = trapz(time, posData);

% negative
negData = data;
less_Index = negData < min(negData)*thrFrac;
negData(~less_Index) = 0;
negData(less_Index) = abs(negData(less_Index) - min(negData)*thrFrac);
neg_AUC = trapz(time, negData);

PosIsGreater = pos_AUC >= neg_AUC;

if chNP > 0
    varargout{1} = pos_AUC;
    varargout{2} = posData;
else
    varargout{1} = neg_AUC;
    varargout{2} = negData;
end
end
        

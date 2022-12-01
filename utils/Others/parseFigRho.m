function [trialsMeanECOG, rhoMean, chSort, rhoSort] = parseFigRho(Fig)
    UserData = get(Fig, "UserData");
    trialsMeanECOG = UserData.trialsMeanECOG;
    rhoMean = UserData.rhoMean;
    chSort = UserData.chSort;
    rhoSort = UserData.rhoSort;
end
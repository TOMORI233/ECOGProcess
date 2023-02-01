AREAS = ["AC", "PFC"];
NAMES = ["CC", "XX"];
for aIndex = 1 : length(AREAS)
    for mIndex = 1 : length(NAMES)
        clearvars -except AREAS NAMES aIndex mIndex;
        areaSel = AREAS(aIndex);
        monkeyName = NAMES(mIndex);
        run("ME_MSTI_Batch.m");
    end
end
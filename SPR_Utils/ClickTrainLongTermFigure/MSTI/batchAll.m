AREAS = ["AC", "PFC"];
NAMES = ["CC", "XX"];
for aIndex = 1 : length(AREAS)
    for monIndex = 1 : length(NAMES)
        clearvars -except AREAS NAMES aIndex monIndex;
        areaSel = AREAS(aIndex);
        monkeyName = NAMES(monIndex);
        run("ME_MSTI_Batch.m");
    end
end
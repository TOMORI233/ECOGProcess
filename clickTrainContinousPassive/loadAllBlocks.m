RegIrreg4msBlk = {'E:\ECoG\chouchou\cc20220516\Block-1';...
    'E:\ECoG\chouchou\cc20220529\Block-5';...
    'E:\ECoG\chouchou\cc20220601\Block-4';...
    'E:\ECoG\chouchou\cc20220610\Block-3';...
    'E:\ECoG\chouchou\cc20220616\Block-5';...
    'E:\ECoG\chouchou\cc20220619\Block-3';...
    'E:\ECoG\xiaoxiao\xx20220623\Block-3';...
    };
RegIrreg8msBlk = {'E:\ECoG\chouchou\cc20220517\Block-4';...
    'E:\ECoG\chouchou\cc20220529\Block-6';...
    'E:\ECoG\chouchou\cc20220601\Block-5';...
    'E:\ECoG\chouchou\cc20220610\Block-4';...
    'E:\ECoG\chouchou\cc20220616\Block-6';...
    'E:\ECoG\chouchou\cc20220619\Block-4';...
    'E:\ECoG\xiaoxiao\xx20220623\Block-4';...
    };
RegIrreg20msBlk = {'E:\ECoG\chouchou\cc20220517\Block-5';...
    'E:\ECoG\chouchou\cc20220530\Block-6';...
    'E:\ECoG\chouchou\cc20220601\Block-6';...
    'E:\ECoG\chouchou\cc20220610\Block-5';...
    'E:\ECoG\chouchou\cc20220616\Block-7';...
    'E:\ECoG\chouchou\cc20220619\Block-5';...
    'E:\ECoG\xiaoxiao\xx20220623\Block-5';...
    };
RegIrreg40msBlk = {'E:\ECoG\chouchou\cc20220518\Block-4';...
    'E:\ECoG\chouchou\cc20220530\Block-7';...
    'E:\ECoG\chouchou\cc20220605\Block-5';...
    'E:\ECoG\chouchou\cc20220610\Block-6';...
    'E:\ECoG\chouchou\cc20220616\Block-8';...
    'E:\ECoG\chouchou\cc20220619\Block-6';...
    'E:\ECoG\xiaoxiao\xx20220623\Block-6';...
    };
RegIrreg80msBlk = {'E:\ECoG\chouchou\cc20220518\Block-5';...
    'E:\ECoG\chouchou\cc20220530\Block-8';...
    'E:\ECoG\chouchou\cc20220605\Block-6';...
    'E:\ECoG\chouchou\cc20220610\Block-7';...
    'E:\ECoG\chouchou\cc20220616\Block-9';...
    'E:\ECoG\chouchou\cc20220619\Block-7';...
    'E:\ECoG\xiaoxiao\xx20220623\Block-7';...
    };
RegIrreg4msInsertBlk = {'E:\ECoG\chouchou\cc20220516\Block-5';...
    'E:\ECoG\chouchou\cc20220528\Block-5';...
    'E:\ECoG\chouchou\cc20220529\Block-7';...
    [];...
    [];...
    [];...
    [];...
    };
offsetScreenBlk = {'E:\ECoG\chouchou\cc20220522\Block-1'};
irregVar1Blk = {'E:\ECoG\chouchou\cc20220519\Block-1'};
irregVar2Blk = {'E:\ECoG\chouchou\cc20220519\Block-5'};
irregVar3Blk = {'E:\ECoG\chouchou\cc20220519\Block-6'};
irregInsertReg1Blk = {'E:\ECoG\chouchou\cc20220521\Block-3'};
irregInsertReg2Blk = {'E:\ECoG\chouchou\cc20220521\Block-4'};
longICI40OrderBlk = {'E:\ECoG\chouchou\cc20220524\Block-6'};
% longICIInvertOrderBlk = {'E:\ECoG\chouchou\cc20220526\Block-2'};
regICIThr4msBlk = {'E:\ECoG\chouchou\cc20220518\Block-3'};

basicRegIrreg = struct('ICI4ms',RegIrreg4msBlk, 'ICI8ms',  RegIrreg8msBlk, 'ICI20ms', RegIrreg20msBlk, 'ICI40ms',  RegIrreg40msBlk, 'ICI80ms',  RegIrreg80msBlk, 'ICI4msInsert', RegIrreg4msInsertBlk);

allBlocks = [RegIrreg4msBlk; RegIrreg8msBlk; RegIrreg20msBlk; RegIrreg40msBlk; RegIrreg80msBlk; RegIrreg4msInsertBlk;...
    offsetScreenBlk;irregVar1Blk; irregVar2Blk; irregVar3Blk; irregInsertReg1Blk; irregInsertReg2Blk; longICI40OrderBlk; regICIThr4msBlk];

% allBlocks = {'E:\ECoG\xiaoxiao\xx20220623\Block-3'};

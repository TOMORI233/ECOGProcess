switch Paradigm
    case 'ClickTrainSSALongTerm4'
        stimStr = {'4-4.06ms Reg','4.06-4ms Reg','4-4.06ms Irreg','4.06-4ms Irreg'};
        S1Duration = [5005, 5080.1, 5000.2, 5075.2] + 4.06;

    case 'ClickTrainSSALongTerm8'
        stimStr = {'8-8.12ms Reg','8.12-8ms Reg','8-8.12ms Irreg','8.12-8ms Irreg'};
        S1Duration = [5005, 5080.1, 5000.2, 5075.2] + 8.12;
    case 'ClickTrainSSALongTerm20'
        stimStr = {'20-20.3ms Reg','20.3-20ms Reg','20-20.3ms Irreg','20.3-20ms Irreg'};
        S1Duration = [5005, 5080.1, 5000.2, 5075.2] + 20.3;
        
    case 'ClickTrainSSALongTerm40'
        stimStr = {'40-40.6ms Reg','40.6-40ms Reg','40-40.6ms Irreg','40.6-40ms Irreg'};
        S1Duration = [5005, 5080.1, 5000.2, 5075.2] + 40.6;
        
    case 'ClickTrainSSALongTerm80'
        stimStr = {'80-81.2ms Reg','81.2-80ms Reg','80-81.2ms Irreg','81.2-80ms Irreg'};
        S1Duration = [4965, 4958.2, 4935.7, 4969] + 81.2;
        
    case 'ClickTrainSSALongTermoffsetScreen'
        stimStr = {'4ms Reg', '4ms Irreg', '8ms Reg', '8ms Irreg', '20ms Reg', '20ms Irreg', '40ms Reg', '40ms Irreg', '80ms Reg', '80ms Irreg',};
        S1Duration = [5005, 5000.2, 5005, 5000.2, 5005, 5000.2, 5005, 5000.2, 4965, 4935.7] + 2;
        
    case 'ClickTrainSSALongTermInsert'
        stimStr = {'4-4.06ms Reg Insert','4.06-4ms Reg Insert' ,'4-4.06ms Irreg Insert','4.06-4ms Irreg Insert'};
        S1Duration = [5005, 5080.1, 5000.2, 5075.2];
        
    case 'ClickTrainSSALongTermVar1'
        stimStr = {'normalize SD = 0.067','normalize SD = 0.1248' ,'normalize SD = 0.2203','normalize SD = 0.4508'};
        S1Duration = [5000.2, 5000.2, 5000.2, 5000.2];
        
    case 'ClickTrainSSALongTermVar2'
        stimStr = {'normalize SD = 0.0178','normalize SD = 0.0372' ,'normalize SD = 0.0727','normalize SD = 0.1229'};
        S1Duration = [5000.2, 5000.2, 5000.2, 5000.2];
        
    case 'ClickTrainSSALongTermVar3'
        stimStr = {'normalize SD = 0.0025','normalize SD = 0.005' ,'normalize SD = 0.001','normalize SD = 0.002'};
        S1Duration = [5000.2, 5000.2, 5000.2, 5000.2];
        
    case 'ClickTrainSSALongTermRegInIrreg4o32'
        stimStr = {'4-4.06ms irregular n=4', '4-4.06ms irregular n=8', '4-4.06ms irregular n=16', '4-4.06ms irregular n=32'};
        S1Duration = [5000.2, 4997.6, 4999.4, 5001.7];
        
    case 'ClickTrainSSALongTermRegInIrreg64o160'
        stimStr = {'4-4.06ms irregular n=64', '4-4.06ms irregular n=96', '4-4.06ms irregular n=128', '4-4.06ms irregular n=160'};
        S1Duration = [5005, 5080.1, 5000.2, 5075.2];
        
    case 'ClickTrainSSALongTermOffConvertLowHigh43444546'
        stimStr = {'40ms - 43ms regular','40ms - 44ms regular' ,'40ms - 45ms regular','40ms - 46ms regular'};
        S1Duration = [5005+43, 5005+44, 5005+45, 5005+46];
        
%     case longICIInvertOrderBlk
%         stimStr = {'4ms Reg Insert','4.06ms Reg Insert' ,'4ms Irreg Insert','4.06ms Irreg Insert'};
%         S1Duration = [5005, 5080.1, 5000.2, 5075.2];
    case 'ClickTrainSSALongTermICIThr401234'
        stimStr = {'4ms -4.01ms Reg','4ms -4.02ms Reg' ,'4ms -4.03ms Reg','4ms -4.04ms Reg'};
        S1Duration = [5005+4.01, 5005+4.02, 5005+4.03, 5005+4.04];
        
end
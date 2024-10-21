%Apply NIfTI ROI to ff.mat run from desktop at home
function UseMANROI=OPTIMATSEG2FF2022
%select ROI file/s to process
[FileRIN,FolderRIN] = uigetfile('O:\MR_multi-echo_having_Dixon_data_All\AllDixonHaving_IdPr_Outputs\*.nii','Select NIfTI ROI file(s)','MultiSelect', 'on');%test
%select folder containg fat fractions
FolderFFIN = uigetdir('O:\MR_multi-echo_having_Dixon_data_All\','Select folder containg fat fractions');
% creat output folders  for CSV, ROI(nifti) and FF(nifti) 
FolderOUT =FolderRIN(1:end-1);
warning('off', 'MATLAB:MKDIR:DirectoryExists');
FolderOUTcsv = strcat(FolderOUT,'CSV');
FolderOUTff = strcat(FolderOUT,'FFnifti');
FolderOUTroi = strcat(FolderOUT,'ROInifti');
mkdir(FolderOUTcsv);
mkdir(FolderOUTff);
mkdir(FolderOUTroi);

if iscell(FileRIN) == 1
    NF =size(FileRIN,2) ;
else
    NF =1;
end

for i =1:NF
   %load ROI
    if NF ==1
        Fname =char(FileRIN)
    else
        Fname =char(FileRIN(i))
    end
    ROI = niftiread(fullfile(FolderRIN,Fname));
    ROI = rot90(ROI,3);
    ID = Fname(1:7);
    CheckREG = Fname(9); 
    
    %save Original ROI as NIfTI
    ROIout = ROI;
    niftiwrite(ROIout,fullfile(FolderOUTroi,strcat(extractBefore(Fname,'.'),'_DMM.nii')));  
    
    %clean slices 1-4 & 41-44 of all ROI
    ROI(:,:,1:4) = 0;
    ROI(:,:,(end-3):end) = 0;
    if CheckREG == 'D' %limit exdtent to 9 slices%
        [I1,I2,I3] = ind2sub(size(ROI),find(ROI));
        nslices = (max(I3)-min(I3))+1;
        if nslices>9
            Mid = min(I3 + ceil(nslices/2));
            ROI(:,:,1:(Mid-4)) = 0;
            ROI(:,:,(Mid+4):end) = 0;
        end
    end
    ROIr =ROI;
    
    %save reduced ROI
    save(fullfile(FolderOUTroi, strcat(extractBefore(Fname,'.'),'r.mat')),'ROIr');
    
    %save Reduced ROI as NIfTI
    ROIout1 = ROIr;
    %ROIout1 = rot90(ROIout1,3);
    niftiwrite(ROIout1,fullfile(FolderOUTroi,strcat(extractBefore(Fname,'.'),'r_DMM.nii')));    
    
    %Identify required FF
    if CheckREG == 'S'
        FFREG ='_Back';
    elseif CheckREG == 'H'|CheckREG == 'N'|CheckREG == 'E'
        FFREG ='_Hip';
    elseif CheckREG == 'D'
        FFREG ='_Leg';
    end
    
    %load fat fraction
    REG =dir(strcat(FolderFFIN,'\',ID,'_20201_2_0\',ID,FFREG,'*.mat'));
    FFIN = load(strcat(FolderFFIN,'\',ID,'_20201_2_0\',REG.name));
    FF = FFIN.ImageV;
    FF = rot90(FF,3);
    FF = flip(FF,3);

    % save FF as NIfTI
    FFout = FF;
    niftiwrite(FFout,fullfile(FolderOUTff,strcat(extractBefore(REG.name,'.'),'_DMM.nii')));        

    % extract ff values from region 
    PCENT=FF(find(ROIr));
    Out.Name = ID;
    Out.Location = CheckREG;
    Out.Region ='r';
    Out.Mean = mean(PCENT);
    Out.SD = std(PCENT);
    Out.Median = median(PCENT);
    Out.IQR = iqr(PCENT);
    Size = size(PCENT);
    Out.Size = Size(1);
    CSV = struct2table(Out);
    writetable(CSV,fullfile(FolderOUTcsv,strcat(ID,'_',extractBefore(REG.name,'.'),'_',extractBefore(Fname,'.'),'r.csv')),'WriteVariableNames',false);
    
    %errode ROI
    ER=3;
    se = strel('Square',ER);
    ROIre = imerode(ROI,se);
   
    %save eroded ROI
    save(fullfile(FolderOUTroi, strcat(extractBefore(Fname,'.'),'re.mat')),'ROIre');
    
    %save eroded ROI as NIfTI
    ROIout2 = ROIre;
    niftiwrite(ROIout2,fullfile(FolderOUTroi,strcat(extractBefore(Fname,'.'),'re_DMM.nii')));
    
    % extract ff values from region 
    PCENT2=FF(find(ROIre));
    Out2.Name = ID;
    Out2.Location = CheckREG;
    Out2.Region ='re';
    Out2.Mean = mean(PCENT2);
    Out2.SD = std(PCENT2);
    Out2.Median = median(PCENT2);
    Out2.IQR = iqr(PCENT2);
    Size = size(PCENT2);
    Out2.Size = Size(1);
    
    CSV2 = struct2table(Out2);
    writetable(CSV2,fullfile(FolderOUTcsv,strcat(ID,'_',extractBefore(REG.name,'.'),'_',extractBefore(Fname,'.'),'re.csv')),'WriteVariableNames',false);
   

end
'EndOPTIMATSEG2FF2022'

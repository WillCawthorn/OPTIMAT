% DicomSort take unsorted dicom folder 
% makes sorted copy inside specified folder of important series 7, 8,15, 16, 19, & 20
% Creates .MAT version
% Creats Fat Fractions in .MAT format 
% multiple patients as folders in slected folder  

function DataSOPTIMAT = OPTIMATSort2023(MainFolder)

 %if nargin == 0 
 %    MainFolder = uigetdir('X:\HandoverDMM2023OPTIMAT\Exampledata');
 %end

Folders = dir(MainFolder);
Folders(ismember( {Folders.name}, {'.', '..'})) = [];
MainFolder2 =strcat(MainFolder,'_SortedDM');
MainFolder3 =strcat(MainFolder,'_MatDM');
MainFolder4 =strcat(MainFolder,'_FFDM');
warning('off', 'MATLAB:MKDIR:DirectoryExists');

for i = 1:numel(Folders)
    %i%test
    ID = extractBefore(Folders(i).name,'_');
    mkdir(fullfile(MainFolder2, Folders(i).name));
    mkdir(fullfile(MainFolder3, Folders(i).name));
    mkdir(fullfile(MainFolder4, Folders(i).name));
    fullfile(MainFolder, Folders(i).name)% test
    Files=dir(fullfile(MainFolder, Folders(i).name));
    Files(ismember( {Files.name}, {'.', '..','manifest.csv','manifest.cvs'})) = [];
    for j = 1:numel(Files)
        %j%test
        FileName = fullfile(MainFolder, Folders(i).name, Files(j).name);
        Header = dicominfo(FileName);
        Sequence = Header.SeriesDescription;
        Series = Header.SeriesNumber;
        FolderName = fullfile(MainFolder2,Folders(i).name,strcat(num2str(Series), '_',Sequence,'_',ID ));
        if Series == 7 |Series == 8|Series == 15|Series == 16|Series == 19|Series == 20
            if exist(FolderName, 'dir')
                    copyfile(FileName,FolderName);
            else
                    mkdir(FolderName);
                    copyfile(FileName,FolderName);
            end % create folder if required and make copy 
        end % only extract useful Files
    end % files in Folder
    Sfolder =dir(fullfile(MainFolder2, Folders(i).name));
    Sfolder(ismember( {Sfolder.name}, {'.', '..'})) = [];
    for k = 1:numel(Sfolder)
        %k%test
        %fullfile(MainFolder2, Folders(i).name,Sfolder(k).name)%test
        SFiles = dir(fullfile(MainFolder2, Folders(i).name,Sfolder(k).name));
        SFiles(ismember( {SFiles.name}, {'.', '..'})) = [];
        Header = dicominfo(fullfile(MainFolder2, Folders(i).name, Sfolder(k).name,SFiles(1).name));
        x = Header.Rows;
        y = Header.Columns;
        z =size(SFiles);
        z = z(1);
        Series = Header.SeriesNumber;
        ImageV = zeros(x,y,z);
        for l = 1:z
            %l%test
            %fullfile(MainFolder2, Folders(i).name, Sfolder(k).name,SFiles(l).name)%test
            Header = dicominfo(fullfile(MainFolder2, Folders(i).name, Sfolder(k).name,SFiles(l).name));
            Image = dicomread(fullfile(MainFolder2, Folders(i).name, Sfolder(k).name,SFiles(l).name));
            ImageV(:,:,Header.InstanceNumber) = Image;
        end
        save(fullfile(MainFolder3,Folders(i).name,strcat(ID,'_',num2str(Series),'.mat')),'ImageV');
    end % genrate mat file of usefule files = all in _Mat folder    
    for m = 1:3
        %m%test
        data =0;
        if  m==1 && isfile(fullfile(MainFolder3, Folders(i).name,strcat(ID,'_7.mat'))) && isfile(fullfile(MainFolder3, Folders(i).name,strcat(ID,'_8.mat')))
            FM =fullfile(MainFolder3, Folders(i).name,strcat(ID,'_7.mat'));
            WM =fullfile(MainFolder3, Folders(i).name,strcat(ID,'_8.mat'));
            Name = 'Back';
            %if    
                data =1;
            %end
        end
        if  m==2 && isfile(fullfile(MainFolder3, Folders(i).name,strcat(ID,'_15.mat'))) && isfile(fullfile(MainFolder3, Folders(i).name,strcat(ID,'_16.mat')))
            FM =fullfile(MainFolder3, Folders(i).name,strcat(ID,'_15.mat'));
            WM =fullfile(MainFolder3, Folders(i).name,strcat(ID,'_16.mat')); 
            Name ='Hip';
                data =1;
        end
        if  m==3 && isfile(fullfile(MainFolder3, Folders(i).name,strcat(ID,'_19.mat'))) && isfile(fullfile(MainFolder3, Folders(i).name,strcat(ID,'_20.mat')))
            FM =fullfile(MainFolder3, Folders(i).name,strcat(ID,'_19.mat'));
            WM =fullfile(MainFolder3, Folders(i).name,strcat(ID,'_20.mat'));
            Name ='Leg';
                data = 1;
        end

        if data == 1
            Fimage =load(FM);
            Wimage =load(WM);
            FI = Fimage.ImageV;
            WI = Wimage.ImageV;
            S=2;
            FI = imgaussfilt(FI,S);
            WI = imgaussfilt(WI,S);
       
            if size(WI) == size(FI)
                ImageFF = (FI./(FI + WI))*100;
                ImageFF(ImageFF <0)=0;
                ImageFF(isnan(ImageFF))=0;
                ImageV = ImageFF;
                save(fullfile(MainFolder4, Folders(i).name,strcat(ID,'_',Name,'_FF',num2str(S),'.mat')),'ImageV');
            end %check FI and WI are smae size
        end % check all mat files exist 
    end % genrate fat fraction for three regions 
end % Patient Folders


 'EndOPTIMATSort2023'


   


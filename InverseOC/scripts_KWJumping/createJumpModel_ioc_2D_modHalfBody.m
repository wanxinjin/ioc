function model = createJumpModel_ioc_2D_modified(jaPath, targ, jump, rlModelPath)

model = rlCModel(rlModelPath);
load(jaPath);

%% Create model file and attach markers
%     addpath(cd(cd('..')));
% addpath(EKFCodePath);


%% Load model link lengths for participant
% mydir = pwd;
% idcs = strfind(mydir,'\');
% newdir = mydir(1:idcs(end)); 
% loadFilePath = [newdir 'results\Model_Info_JA_P' partNum '.mat'];
% load(loadFilePath);

modelLinks_ave = JA.modelLinks;

% [age,gender,height,weight,S2sc,calibPose] = getPartData(partNum);

gender = JA.partData.gender;
% height = JA.partData.height;
weight = JA.partData.weight;
% S2sc = JA.partData.S2sc;

% model = rlCModel('JumpModel_Eul_inertia_2D.xml');
transformNames = {model.transforms.name};
model.forwardPosition;

%     initPos = zeros(size(model.position));
initPos = zeros(numel(model.joints),1);

% because of 2D representation, just do L-pose for everyone
initPos(5) = pi/2; %shoulder elevation
initPos(6) = pi/2; %elbow flexion
initPos(7) = pi/2;
initPos(8) = pi/2; 


%World to pelvis center
trNum = find(ismember(transformNames,'world_to_base')==1);
model.transforms(trNum).t = squeeze(JA.world2base(12*(targ-1) + jump,:,:));
model.forwardPosition;

% vis.update();

frameList = {'back2Upperback','rAsis2Hip'};
for i = 1:numel(frameList)
    trNum = find(ismember(transformNames,frameList{i})==1);
    model = setInertialParam(model, trNum, gender, weight);
end

frameList = {'rShoulder2Elbow','rElbow2Wrist',...
    'rHip2Knee','rKnee2Ankle','rAnkle2Toe'};
for i = 1:numel(frameList)
    trNum = find(ismember(transformNames,frameList{i})==1);
    model = setInertialParam(model, trNum, gender, weight*2);
end

pause(0.01);

%% Neck and Shoulders
trNum = find(ismember(transformNames,'back2Upperback')==1);
T = model.transforms(trNum).t;
FT = model.transforms(trNum).frame_in.t;
% T(1:3,4) = FT(1:3,1:3)'*([0,0,norm(upperback - FT(1:3,4)')])';
T(1:3,4) = FT(1:3,1:3)'*([0,0,modelLinks_ave.spine])';
model.transforms(trNum).t = T;
model.forwardPosition;
model = setInertialParam(model, trNum, gender, weight);

trNum = find(ismember(transformNames,'upperBack2rshoulder')==1);
T = model.transforms(trNum).t;
FT = model.transforms(trNum).frame_in.t;
% T(1:3,4) = FT(1:3,1:3)'*(rshoulder - FT(1:3,4)')';
T(1:3,4) = FT(1:3,1:3)'*(modelLinks_ave.spine2shldr_R)';
model.transforms(trNum).t = T;
model.forwardPosition;

%% Pelvis
trNum = find(ismember(transformNames,'rAsis2Hip')==1);
T = model.transforms(trNum).t;
FT = model.transforms(trNum).frame_in.t; %mid_asis
% T(1:3,4) = mid2RHC;
T(1:3,4) = modelLinks_ave.base2hip_R;
model.transforms(trNum).t = T;
model.forwardPosition;
model = setInertialParam(model, trNum, gender, weight);

%% Right Arm
trNum = find(ismember(transformNames,'rShoulder2Elbow')==1);
T = model.transforms(trNum).t;
FT = model.transforms(trNum).frame_in.t;
% T(1:3,4) = FT(1:3,1:3)'*[0,0,-norm(rshoulder - relbow)]';
T(1:3,4) = FT(1:3,1:3)'*[0,0,modelLinks_ave.uparm_R]';
model.transforms(trNum).t = T;
model.forwardPosition;
model = setInertialParam(model, trNum, gender, weight);

trNum = find(ismember(transformNames,'rElbow2Wrist')==1);
T = model.transforms(trNum).t;
FT = model.transforms(trNum).frame_in.t;
% T(1:3,4) = FT(1:3,1:3)'*[0,0,-norm(relbow - rwrist)]';
T(1:3,4) = FT(1:3,1:3)'*[0,0,modelLinks_ave.forearm_R]';
model.transforms(trNum).t = T;
model.forwardPosition;
model = setInertialParam(model, trNum, gender, weight);

%% Right Leg
trNum = find(ismember(transformNames,'rHip2Knee')==1);
T = model.transforms(trNum).t;
FT = model.transforms(trNum).frame_in.t;
% T(1:3,4) = FT(1:3,1:3)'*(rknee - FT(1:3,4)')';
% % take norm of above, offset knee straight down, directly below hip
% T(1:3,4) = [0,0,norm(T(1:3,4))];
T(1:3,4) = FT(1:3,1:3)'*[0,0,modelLinks_ave.thigh_R]';
model.transforms(trNum).t = T;
model.forwardPosition;
model = setInertialParam(model, trNum, gender, weight);

trNum = find(ismember(transformNames,'rKnee2Ankle')==1);
T = model.transforms(trNum).t;
FT = model.transforms(trNum).frame_in.t;
% T(1:3,4) = FT(1:3,1:3)'*[0,0,-norm(rknee - rankle)]';
T(1:3,4) = FT(1:3,1:3)'*[0,0,modelLinks_ave.shin_R]';
model.transforms(trNum).t = T;
model.forwardPosition;
model = setInertialParam(model, trNum, gender, weight);

trNum = find(ismember(transformNames,'rAnkle2Toe')==1);
T = model.transforms(trNum).t;
FT = model.transforms(trNum).frame_in.t;
% T(1:3,4) = FT(1:3,1:3)'*(rtoe - FT(1:3,4)')';
T(1:3,4) = FT(1:3,1:3)'*(modelLinks_ave.foot_R)';
model.transforms(trNum).t = T;
model.forwardPosition;
model = setInertialParam(model, trNum, gender, weight);


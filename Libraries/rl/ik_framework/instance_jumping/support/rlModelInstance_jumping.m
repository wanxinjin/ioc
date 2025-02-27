classdef rlModelInstance_jumping < rlModelInstance % < rlModel
    % Citations used:
    % http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.872.5578&rep=rep1&type=pdf
    % https://www.tandfonline.com/doi/pdf/10.3109/17453678208992202
    
    properties
        % link length array (linkFrame, previousFrame, previousMarker, linkMarker)
        %   linkFrame: the jointId ('fixed id' or 'revolute id') that this length will modify
        %   previousFrame: the first frame ('a idref') in the joint,
        %     coinciding with the location of previousMarker
        %   previousMarker: the marker position of previousFrame
        %   linkMarker: the second marker that describes the length
        linkLengthArray = {...
            {'length_base_rhip',                'body_base',                    'HIP_BASE_JC',    	'HIP_R_JC'}; ...	% link offsets for right lower body
            {'length_rhip_rknee',               'body_rhip_rknee',              'HIP_R_JC',         'KNEE_R_JC'}; ...
            {'length_rknee_rankle',             'body_rknee_rankle',            'KNEE_R_JC',        'ANKLE_R_JC'}; ...
            {'length_rankle_rballfoot',         'body_rankle_rballfoot',        'ANKLE_R_JC',       'FOOT_R_JC'}; ...
            {'length_base_lhip',                'body_base',                    'HIP_BASE_JC',      'HIP_L_JC'}; ...    % link offsets for left lower body
            {'length_lhip_lknee',               'body_lhip_lknee',              'HIP_L_JC',         'KNEE_L_JC'}; ...
            {'length_lknee_lankle',             'body_lknee_lankle',            'KNEE_L_JC',        'ANKLE_L_JC'}; ...
            {'length_lankle_lballfoot',         'body_lankle_lballfoot',        'ANKLE_L_JC',       'FOOT_L_JC'}; ...
            {'length_base_l5s1',                'body_base',                    'HIP_BASE_JC',     	'L5S1_JC'}; ...     % link offsets for torso
            {'length_l5s1_t1c7',                'body_l5s1_t1c7',               'L5S1_JC',          'T1C7_JC'}; ...
            {'length_c7rshoulder_rshoulder',	'body_c7rshoulder_rshoulder',   'T1C7_JC',          'SHOULDER_R_JC'}; ...
            {'length_rshoulder_relbow',         'body_rshoulder_relbow',        'SHOULDER_R_JC',    'ELBOW_R_JC'}; ...
            {'length_relbow_rwrist',            'body_relbow_rwrist',           'ELBOW_R_JC',       'WRIST_R_JC'}; ...
            {'length_c7lshoulder_lshoulder',    'body_c7lshoulder_lshoulder',   'T1C7_JC',          'SHOULDER_L_JC'}; ...
            {'length_lshoulder_lelbow',         'body_lshoulder_lelbow',        'SHOULDER_L_JC',    'ELBOW_L_JC'}; ...
            {'length_lelbow_lwrist',            'body_lelbow_lwrist',           'ELBOW_L_JC',       'WRIST_L_JC'}; ...
            };
        
        % marker attachments (attachmentFrame, attachmentFrameMarker, [all sensorMarkers])        
        sensorAttachmentArray = {...
            {'frame_l5s1_0',        'HIP_BASE_JC',      'ASIS_R', 'PSIS_R', 'ASIS_L', 'PSIS_L'}; ...      % sensor placements for right lower body
            {'frame_rknee_0',       'KNEE_R_JC',        'KNEE_R_LAT', 'KNEE_R_MED'}; ...               
            {'frame_rankle_0',      'ANKLE_R_JC',       'ANKLE_R_LAT', 'ANKLE_R_MED'}; ...
            {'frame_rballfoot_end', 'FOOT_R_JC',        'FOOT_R_LAT', 'FOOT_R_MED', 'HEEL_R'}; ... % 
            {'frame_lknee_0',       'KNEE_L_JC',        'KNEE_L_LAT', 'KNEE_L_MED'}; ...                 % sensor placements for left lower body
            {'frame_lankle_0',      'ANKLE_L_JC',       'ANKLE_L_LAT', 'ANKLE_L_MED'}; ...
            {'frame_lballfoot_end', 'FOOT_L_JC',        'FOOT_L_LAT', 'FOOT_L_MED', 'HEEL_L'}; % 
            ...
            {'frame_l5s1_0',        'L5S1_JC',          'L5'};
            {'frame_t1c7_0',        'T1C7_JC',          'C7'}; ...                                % sensor placements for torso       
            {'frame_rshoulder_0',   'SHOULDER_R_JC',    'SHOULDER_R'}; ...                               % sensor placements for right upper body
            {'frame_relbow_0',      'ELBOW_R_JC',       'ELBOW_R_LAT', 'ELBOW_R_MED'}; ...
            {'frame_rwrist_0',      'WRIST_R_JC',       'WRIST_R_LAT', 'WRIST_R_MED'}; ...
            {'frame_lshoulder_0',   'SHOULDER_L_JC',    'SHOULDER_L'}; ...                               % sensor placements for left upper body
            {'frame_lelbow_0',      'ELBOW_L_JC',       'ELBOW_L_LAT', 'ELBOW_L_MED'}; ...
            {'frame_lwrist_0',      'WRIST_L_JC',       'WRIST_L_LAT','WRIST_L_MED'}; ...   
            };
        
        % trc/imu attachments (attachmentFrame, [name for the cluster assocation], [all sensorMarkers])
        sensorSecondaryAttachmentArray = {};
        
		% joint limits [deg]
%         jointRangeOfMotion = {};
        jointRangeOfMotion = {...
%             {'joint_rshoulder_0',	[-62,	166]}; ...
%             {'joint_rshoulder_1',	[-184,	0]}; ...
%             {'joint_rshoulder_2', 	[-68,	103]}; ...
            {'joint_relbow_0',		[0,		142]   }; ...
%             {'joint_relbow_1',		[-82+90,75+90]}; ...
            {'joint_rwrist_0',		[-75,  	76]   }; ...
%             {'joint_rwrist_1',		[-36,  	21]   }; ...
            ...
%             {'joint_rhip_0',		[-9, 	122]}; ...
%             {'joint_rhip_1',		[-45,  	26]}; ...
%             {'joint_rhip_2',		[-47,  	47]}; ...
            {'joint_rknee_0',		[-142,  1]}; ...
            {'joint_rankle_0',		[-56, 	12]}; ...
%             {'joint_rankle_2',      [-18, 	33]}; ...
            ...
%             {'joint_lshoulder_0',  	[-62, 	166]}; ...
%             {'joint_lshoulder_1',  	[0, 	184]}; ...
%             {'joint_lshoulder_2', 	[103+90,68+270]}; ...
            {'joint_lelbow_0',      [0, 	142]}; ...
%             {'joint_lelbow_1',     	[75+90, 82+270]}; ...
            {'joint_lwrist_0',    	[-75,  	76]   }; ...
%             {'joint_lwrist_1',    	[-21,  	36]   }; ...
            ...
%             {'joint_lhip_0',    	[-9, 	122]}; ...
%             {'joint_lhip_1',    	[-26,  	45]}; ...
%             {'joint_lhip_2',     	[-47,  	47]}; ...
            {'joint_lknee_0',    	[-142,  1]}; ...
            {'joint_lankle_0',      [-56, 	12]}; ...
%             {'joint_lankle_2',		[-33, 	18]}; ...
            };
        
        jointRangeOfMotionTolerance = 30;
        
        % subject demographics (id, height [m], weight [kg])
        subjectDemographicArray = {...
            {1, 1.70, 70, 'm'} ...
            };

        linkLengthSymmetry = {...
            {'length_base_rhip', 'length_base_lhip'}, ...
            {'length_rhip_rknee', 'length_lhip_lknee'}, ...
            {'length_rknee_rankle', 'length_lknee_lankle'}, ...
            {'length_rankle_rballfoot', 'length_lankle_lballfoot'}, ...
            {'length_c7rshoulder_rshoulder', 'length_c7lshoulder_lshoulder'}, ...
            {'length_rshoulder_relbow', 'length_lshoulder_lelbow'}, ...
            {'length_relbow_rwrist', 'length_lelbow_lwrist'}, ...
            {'length_rwrist_rhand', 'length_lwrist_lhand'}, ...
            };
        
        lengthUseInd = 250:400;
        
        harrington_crop1 = 250;
        harrington_crop2 = 400;
        
        trcSensorDecorator = {'position'};
%         trcSensorDecorator = {'position', 'velocity'};
        imuSensorYaw = 1;
             
        % joints to calculate rmse for
        mocapMarkers_rightArm = {'SHOULDER_R', 'ELBOW_R_LAT', 'ELBOW_R_MED', 'WRIST_R_LAT', 'WRIST_R_MED'};
        mocapMarkers_leftArm = {'SHOULDER_L', 'ELBOW_L_LAT', 'ELBOW_L_MED', 'WRIST_L_LAT', 'WRIST_L_MED'};
        mocapMarkers_rightLeg = {'KNEE_R_LAT', 'KNEE_R_MED', 'ANKLE_R_LAT', 'ANKLE_R_MED', 'FOOT_R_LAT', 'FOOT_R_MED', 'HEEL_R'};
        mocapMarkers_leftLeg = {'KNEE_L_LAT', 'KNEE_L_MED', 'ANKLE_L_LAT', 'ANKLE_L_MED', 'FOOT_L_LAT', 'FOOT_L_MED', 'HEEL_L'};
        mocapMarkers_torso = {'ASIS_R', 'PSIS_R', 'ASIS_L', 'PSIS_L', 'L5', 'C7'};
        
        joints_rightArm = {'joint_c7rshoulder_0', 'joint_rshoulder_0', 'joint_rshoulder_1', 'joint_rshoulder_2', 'joint_relbow_0', 'joint_relbow_1'};
        joints_leftArm = {'joint_c7lshoulder_0', 'joint_lshoulder_0', 'joint_lshoulder_1', 'joint_lshoulder_2', 'joint_lelbow_0', 'joint_lelbow_1'};
        joints_rightLeg = {'joint_rhip_0', 'joint_rhip_1', 'joint_rhip_2', 'joint_rknee_0', 'joint_rknee_1', 'joint_rankle_0', 'joint_rankle_1', 'joint_rankle_2'};
        joints_leftLeg = {'joint_lhip_0', 'joint_lhip_1', 'joint_lhip_2', 'joint_lknee_0', 'joint_lknee_1', 'joint_lankle_0', 'joint_lankle_1', 'joint_lankle_2'};
        joints_torso = {'frame_6dof_revz0_to_frame_6dof_revz1', 'frame_6dof_revy0_to_frame_6dof_revy1', 'frame_6dof_revx0_to_frame_6dof_revx1'};
        
%         jointsPlot = {'joint_rhip_0', 'joint_rhip_1', 'joint_rhip_2', 'joint_rknee_0', ...
%             'joint_lhip_0', 'joint_lhip_1', 'joint_lhip_2', 'joint_lknee_0', ...
%             'frame_6dof_revz0_to_frame_6dof_revz1', 'frame_6dof_revy0_to_frame_6dof_revy1', 'frame_6dof_revx0_to_frame_6dof_revx1'};
    end
    
    methods
        function obj = rlModelInstance_jumping(subjectId)
            obj.datasetName = 'Jumping';
            obj.subjectId = subjectId;
            obj.loadDemographics();
        end
        
        function  [dt, time, data] = loadData_trc(obj, pathToTrc, algorithmParam)
            trc = loadDataFromTrc_jumping(pathToTrc);
            
            if exist('algorithmParam', 'var') && isfield(algorithmParam, 'ekfRun') && ~isempty(algorithmParam.ekfRun)
                indsToKeep = algorithmParam.ekfRun;
            else
                indsToKeep = 1:1:length(trc.time); % downsample to match EKF
            end
            
            field_names = fieldnames(trc.data);
            
            trc.time = trc.time(indsToKeep);
            for i=1:numel(field_names)
                sensorName = field_names{i};
                
                if(size(trc.data.(sensorName),2) == 3) % keeps only entries that are nX3, ie marker data
                    trc.data.(sensorName) = trc.data.(sensorName)(indsToKeep, :);
                end
            end
            
            dt = mean(diff(trc.time));
            time = trc.time;
            data = trc.data;
        end
        
        function [kinematicTransform, dynamicTransform] = applyLinkTransform(obj, targetFrameStr, sourceFrameStr, linkVectorMean, lengthUseInd, dataInstance)
            % variable setup
            rotMirror = [-1 0 0; 0 1 0; 0 0 1];

            linkLength = norm(linkVectorMean);
            
            % set any link-specific information
            switch targetFrameStr
                case {'length_base_l5s1', 'length_base_lhip', ...
                        'length_c7rshoulder_rshoulder', 'length_c7lshoulder_lshoulder'} % either doesn't exist or already accounted for in other limbs
                    dumasFrameStr = '';
                    
                case {'length_base_rhip'}
                    dumasFrameStr = 'pelvis';
                    
                case {'length_rhip_rknee', 'length_lhip_lknee'}
                    dumasFrameStr = 'thigh';
                    
                case {'length_rknee_rankle', 'length_lknee_lankle'}
                    dumasFrameStr = 'leg';
                    
                case {'length_rankle_rballfoot', 'length_lankle_lballfoot'}
                    dumasFrameStr = 'foot';
                    
                case {'length_l5s1_t1c7'}
                    dumasFrameStr = 'torso';
                    
                case {'length_t1c7_c1head'}
                    dumasFrameStr = 'head&neck';
                    
                case {'length_rshoulder_relbow', 'length_lshoulder_lelbow'}
                    dumasFrameStr = 'arm';
                    
                case {'length_relbow_rwrist', 'length_lelbow_lwrist'}
                    dumasFrameStr = 'forearm';
                    
                case {'length_rwrist_rhand', 'length_lwrist_lhand'}
                    dumasFrameStr = 'hand';
            end
            
            if ~isempty(dumasFrameStr)
                anthLinkDistance =            lookupTableDumas('length',     dumasFrameStr, obj.gender, [], [])*obj.body_height;
            else
                anthLinkDistance = 0;
            end

            switch targetFrameStr 
                case {'length_base_rhip'}
                    if ~isempty(dataInstance)
                        [X00Length, ~] = harrington2007prediction(dataInstance.data, obj.harrington_crop1, obj.harrington_crop2);
                    else
                        X00Length = linkVectorMean;
                    end
                    
                    rotMtxDumas = rotz(pi/2)*rotx(pi/2);
                    anthLength = [anthLinkDistance 0 0]';
                    
                case {'length_base_lhip'}
                    if ~isempty(dataInstance)
                        [~, X00Length] = harrington2007prediction(dataInstance.data, obj.harrington_crop1, obj.harrington_crop2);
                    else
                        X00Length = linkVectorMean;
                    end
                    
                    rotMtxDumas = [];
                    anthLength = [-anthLinkDistance 0 0]';
                    
                case {'length_c7rshoulder_rshoulder'}
                    X00Length = [linkLength 0 0]';
                    rotMtxDumas = [];
%                     [X00Length2, ~] = amabile2006centre(dataInstance.data, obj.harrington_crop1, obj.harrington_crop2, obj.body_height);
           
                case {'length_c7lshoulder_lshoulder'}
                    X00Length = [-linkLength 0 0]';
                    rotMtxDumas = [];
                    
                case {'length_rankle_rballfoot'}
                    X00Length = [0 linkLength 0]';
                    rotMtxDumas = rotz(pi/2)*rotx(pi/2);
                    anthLength = [0 anthLinkDistance 0]';

                 case {'length_lankle_lballfoot'}
                    X00Length = [0 linkLength 0]';
                    rotMtxDumas = rotMirror*rotz(pi/2)*rotx(pi/2); 
                    anthLength = [0 anthLinkDistance 0]';

                case {'length_base_l5s1', 'length_l5s1_t1c7'} % first joint is sagittal
                    X00Length = [0 0 linkLength]';
                    rotMtxDumas = roty(pi)*rotz(pi/2)*rotx(pi/2);  % rotating from Dumas, but pointing up
                    anthLength = [0 0 anthLinkDistance]';

                case {'length_t1c7_c1head'}
                    X00Length = [0 0 linkLength]';
                    anthLength = [0 0 anthLinkDistance]';
                    rotMtxDumas = rotz(pi/2)*rotx(pi/2);
                    
                case {'length_rhip_rknee', 'length_rknee_rankle'} % first joint is sagittal
                    X00Length = [0 0 -linkLength]';
                    rotMtxDumas = rotz(pi/2)*rotx(pi/2); % dumas down
                    anthLength = [0 0 -anthLinkDistance]';

                case {'length_lhip_lknee', 'length_lknee_lankle'} % first joint is sagittal
                    X00Length = [0 0 -linkLength]';
                    rotMtxDumas = rotMirror*rotz(pi/2)*rotx(pi/2); % dumas down
                    anthLength = [0 0 -anthLinkDistance]';
                
                case {'length_rshoulder_relbow', 'length_relbow_rwrist', 'length_rwrist_rhand'}
                    X00Length = [0 0 -linkLength]';
                    rotMtxDumas = rotz(pi/2)*rotx(pi/2); % dumas down
                    anthLength = [0 0 -anthLinkDistance]';

                case {'length_lshoulder_lelbow', 'length_lelbow_lwrist', 'length_lwrist_lhand'}
                    X00Length = [0 0 -linkLength]';
                    rotMtxDumas = rotz(pi/2)*rotx(pi/2); % dumas down
                    anthLength = [0 0 -anthLinkDistance]';

            end
                  
            switch obj.linkDefinition
                case 'initialpose'
                    correctedLinkLength = linkVectorMean;
                 
                case 'X00'
                    correctedLinkLength = X00Length;
            end

            T = eye(4);
            T(1:3, 4) = correctedLinkLength;
          
            if ~isempty(dumasFrameStr)
                mass =            lookupTableDumas('mass',     dumasFrameStr, obj.gender, [], [])*obj.body_weight;
                comScale =        lookupTableDumas('com',      dumasFrameStr, obj.gender, linkLength, []);
                inertialScale =   lookupTableDumas('inertial', dumasFrameStr, obj.gender, linkLength, mass);
                
                % parallel axis, since Dumas inertia assumes it's on the edge of
                % the limb
                com = rotMtxDumas*comScale;
                inertial = rotMtxDumas*inertialScale*rotMtxDumas';
%                 inertial = zeros(3, 3);
                   
%                 targetFrameStr
%                 [maxVal, maxInd] = max(abs([linkLength X00Length com]));
%                 vec = [linkLength X00Length comScale com];
            else
                mass = [];
                com = [];
                inertial = [];
            end
 
            [kinematicTransform, dynamicTransform] = obj.assembleKinDynTransform(targetFrameStr, sourceFrameStr, T, mass, com, inertial);
        end
        
        function sensorTransform = applyMarkerSensor(obj, attachmentFrameStr, sensorMarkerStr, ...
                        markerOffset, sensorMarker, linkDistance, lengthUseInd, dataInstance)            
            switch sensorMarkerStr
                case {'ASIS_R', 'ASIS_L'} % front of the link
                    linkLengthArrangement_test = {attachmentFrameStr, 'HIP_BASE_JC', 'ASIS_R'};
                    [attachmentFrameStr_test, attachmentMarkerStr_test, sensorMarkerStr_test, markerOffset_R, sensorMarker_test, sensorMarkerMean_test, sensorMarkerStd_test] = ...
                        obj.sensorAttachmentArrayToMarkerData(linkLengthArrangement_test, lengthUseInd, dataInstance);
                    checkSensBool_R = checkSensorPlacement([], sensorMarker_test, sensorMarkerMean_test, sensorMarkerStd_test, ...
                        markerOffset_R, lengthUseInd, sensorMarkerStr_test, attachmentFrameStr_test);
                    
                    linkLengthArrangement_test = {attachmentFrameStr, 'HIP_BASE_JC', 'ASIS_L'};
                    [attachmentFrameStr_test, attachmentMarkerStr_test, sensorMarkerStr_test, markerOffset_L, sensorMarker_test, sensorMarkerMean_test, sensorMarkerStd_test] = ...
                        rlModelInstance.sensorAttachmentArrayToMarkerData(linkLengthArrangement_test, lengthUseInd, dataInstance);
                    checkSensBool_L = checkSensorPlacement([], sensorMarker_test, sensorMarkerMean_test, sensorMarkerStd_test, ...
                        markerOffset_R, lengthUseInd, sensorMarkerStr_test, attachmentFrameStr_test);
                    
                    markerOffsetSign = sign(markerOffset);
                    if checkSensBool_R == 1 && checkSensBool_L == 1
                        X00Length = markerOffsetSign .* mean(abs([markerOffset_R markerOffset_L]), 2); % ensure hip markers are symmetric
                    elseif checkSensBool_R == 1
                        X00Length = markerOffsetSign .* mean(abs([markerOffset_R]), 2); % unless one of the two markers is missing
                    else
                        X00Length = markerOffsetSign .* mean(abs([markerOffset_L]), 2);
                    end
                    
                case {'PSIS_L', 'PSIS_R'}  % back of the link
                    linkLengthArrangement_test = {attachmentFrameStr, 'HIP_BASE_JC', 'PSIS_R'};
                    [attachmentFrameStr_test, attachmentMarkerStr_test, sensorMarkerStr_test, markerOffset_R, sensorMarker_test, sensorMarkerMean_test, sensorMarkerStd_test] = ...
                        rlModelInstance.sensorAttachmentArrayToMarkerData(linkLengthArrangement_test, lengthUseInd, dataInstance);
                    checkSensBool_R = checkSensorPlacement([], sensorMarker_test, sensorMarkerMean_test, sensorMarkerStd_test, ...
                        markerOffset_R, lengthUseInd, sensorMarkerStr_test, attachmentFrameStr_test);
                    
                    linkLengthArrangement_test = {attachmentFrameStr, 'HIP_BASE_JC', 'PSIS_L'};
                    [attachmentFrameStr_test, attachmentMarkerStr_test, sensorMarkerStr_test, markerOffset_L, sensorMarker_test, sensorMarkerMean_test, sensorMarkerStd_test] = ...
                        rlModelInstance.sensorAttachmentArrayToMarkerData(linkLengthArrangement_test, lengthUseInd, dataInstance);
                    checkSensBool_L = checkSensorPlacement([], sensorMarker_test, sensorMarkerMean_test, sensorMarkerStd_test, ...
                        markerOffset_R, lengthUseInd, sensorMarkerStr_test, attachmentFrameStr_test);
                    
                    markerOffsetSign = sign(markerOffset);
                    if checkSensBool_R == 1 && checkSensBool_L == 1
                        X00Length = markerOffsetSign .* mean(abs([markerOffset_R markerOffset_L]), 2); % ensure hip markers are symmetric
                    elseif checkSensBool_R == 1
                        X00Length = markerOffsetSign .* mean(abs([markerOffset_R]), 2); % unless one of the two markers is missing
                    else
                        X00Length = markerOffsetSign .* mean(abs([markerOffset_L]), 2);
                    end
                    
                case 'L5'
                    X00Length = [0 -linkDistance 0]';
                    
                case 'C7'
                    X00Length = [0 -linkDistance 0]';
                    
                case {'SHOULDER_R', 'SHOULDER_L'} % no offset
                    X00Length = [0 0 0]';
                   
                case {'ELBOW_R_MED', 'WRIST_R_MED', ...
                        'ELBOW_L_LAT', 'WRIST_L_LAT'} % left of the link
                    X00Length = [-linkDistance 0 0]';
                    
                case {'ELBOW_R_LAT', 'WRIST_R_LAT', ...
                        'ELBOW_L_MED', 'WRIST_L_MED'} % right of the link
                    X00Length = [linkDistance 0 0]';                    
                    
                case {'KNEE_R_MED', 'ANKLE_R_MED', 'FOOT_R_MED', ...
                        'KNEE_L_LAT', 'ANKLE_L_LAT', 'FOOT_L_LAT'} % left of the link
                    X00Length = [-linkDistance 0 0]';
                    
                case {'KNEE_R_LAT', 'ANKLE_R_LAT', 'FOOT_R_LAT', ...
                        'KNEE_L_MED', 'ANKLE_L_MED', 'FOOT_L_MED'} % right of the link
                    X00Length = [linkDistance 0 0]';
                    
                case {'HEEL_R', 'HEEL_L'} % right of the link
                    X00Length = [0 -linkDistance 0]';
                    
                otherwise % IMU markers
                    X00Length = markerOffset;
            end
            
            switch obj.linkDefinition
                case 'initialpose'
                    correctedLinkLength = markerOffset;
                    
                case 'X00'
                    correctedLinkLength = X00Length;
                    
                case 'anthropometric'
                    correctedLinkLength = X00Length;
            end
            
            T = eye(4);
            T(1:3,4) = correctedLinkLength;
            
            sensorTransform = obj.assembleSenTransform(sensorMarkerStr, attachmentFrameStr, obj.trcSensorDecorator, T);
        end   
    end
end
classdef PLOTS
    methods(Static)
        % ======================================================================================================================================================
        function VisualizeTrackData_DEBUG(FUSED_TRACKS, TRACK_ESTIMATES, TRACK_ESTIMATES_RAD, TRACK_ESTIMATES_CAM, ...
                                    RADAR_MEAS_CLUSTER, RADAR_MEAS_CTS, CAMERA_MEAS_CTS, ...
                                    nNewTracks, nRadars, nCameras, gamma, motionModel)
                nMeasCam = CAMERA_MEAS_CTS.ValidCumulativeMeasCount(1,nCameras);
                nMeasRad = RADAR_MEAS_CTS.ValidCumulativeMeasCount(1,nRadars);
                nClstrsRad = RADAR_MEAS_CLUSTER.ValidCumulativeMeasCount(1,nRadars);
                pxRAD = single(zeros(1,TRACK_ESTIMATES_RAD.nValidTracks));
                pyRAD = single(zeros(1,TRACK_ESTIMATES_RAD.nValidTracks));
                pxCAM = single(zeros(1,TRACK_ESTIMATES_CAM.nValidTracks));
                pyCAM = single(zeros(1,TRACK_ESTIMATES_CAM.nValidTracks));
                nPts = 100;
                level = sqrt(50);
                %H = single([1,0,0,0; 0,0,1,0]);
                %R = [1,0;0,1];
                StateCovIndex = [1,2,4,5];
                
                
                figure(1);
                
                % RADAR Tracks
                for idx = 1:TRACK_ESTIMATES_RAD.nValidTracks
                    pxRAD(1,idx) = TRACK_ESTIMATES_RAD.TrackParam(1,idx).StateEstimate.px;
                    pyRAD(1,idx) = TRACK_ESTIMATES_RAD.TrackParam(1,idx).StateEstimate.py;
                    P = TRACK_ESTIMATES_RAD.TrackParam(1,idx).StateEstimate.ErrCOV(StateCovIndex,StateCovIndex);
                    S = P([1,4],[1,4]);
                    EllipseXY = PLOTS.sigmaEllipse2D( [pxRAD(1,idx); pyRAD(1,idx)], S, level, nPts );
                    plot(EllipseXY(1,:), EllipseXY(2,:), '-', 'color', 'r', 'markersize', 5);hold on;axis equal; grid on;
                end
                plot(pxRAD,  pyRAD, '*', 'color', 'r', 'markersize', 4); axis equal;  grid on; hold on;
                plot(RADAR_MEAS_CLUSTER.MeasArray(1, 1:nClstrsRad), RADAR_MEAS_CLUSTER.MeasArray(2, 1:nClstrsRad), '.', 'color', 'r', 'markersize', 5);
                axis equal;  grid on; hold on;
                
                
                
                % CAMERA Tracks
                for idx = 1:TRACK_ESTIMATES_CAM.nValidTracks
                    pxCAM(1,idx) = TRACK_ESTIMATES_CAM.TrackParam(1,idx).StateEstimate.px;
                    pyCAM(1,idx) = TRACK_ESTIMATES_CAM.TrackParam(1,idx).StateEstimate.py;
                    P = TRACK_ESTIMATES_CAM.TrackParam(1,idx).StateEstimate.ErrCOV(StateCovIndex,StateCovIndex);
                    %S = H*P*H' + R;
                    S = P([1,4],[1,4]);
                    EllipseXY = PLOTS.sigmaEllipse2D( [pxCAM(1,idx); pyCAM(1,idx)], S, level, nPts );
                    plot(EllipseXY(1,:), EllipseXY(2,:), '-', 'color', 'b', 'markersize', 5);hold on;axis equal; grid on;
                end
                plot(pxCAM,  pyCAM, '*', 'color', 'b', 'markersize', 4); axis equal;  grid on; hold on;
                plot(CAMERA_MEAS_CTS.MeasArray(1, 1:nMeasCam), CAMERA_MEAS_CTS.MeasArray(2, 1:nMeasCam), '.', 'color', 'b', 'markersize', 5);
               
                
                % FUSED Tracks
                newTrack_PXPY = single(zeros(2, 100));
                for idx = 1:nNewTracks
                    newTrack_PXPY(1,idx) = FUSED_TRACKS(idx).x(1,1);
                    newTrack_PXPY(2,idx) = FUSED_TRACKS(idx).x(3,1);
                end
                plot(newTrack_PXPY(1, 1:nNewTracks), newTrack_PXPY(2, 1:nNewTracks), '*', 'color', 'm', 'markersize', 4);hold on;axis equal; grid on;
                for idx = 1:nNewTracks
                    P = FUSED_TRACKS(idx).P;
                    S = P([1,4],[1,4]);
                    EllipseXY = PLOTS.sigmaEllipse2D( [newTrack_PXPY(1,idx); newTrack_PXPY(2,idx)], S, level, nPts );
                    plot(EllipseXY(1,:), EllipseXY(2,:), '-', 'color', 'm', 'markersize', 5);hold on;axis equal; grid on;
                end
                
                
%                 Predicted FUSED track
%                 for idx = 1:nNewTracks
%                     X = FUSED_TRACKS(idx).x;
%                     P = FUSED_TRACKS(idx).P;
%                     Xpred = motionModel.f(X);
%                     Ppred = motionModel.F(X) * P * motionModel.F(X)' + motionModel.Q;
%                     disp(Xpred); disp(Ppred);
%                     plot(Xpred(1,1),  Xpred(3,1), '*', 'color', 'k', 'markersize', 4); axis equal;  grid on; hold on;
%                     S = Ppred([1,4],[1,4]);
%                     EllipseXY = PLOTS.sigmaEllipse2D( [Xpred(1,1); Xpred(3,1)], S, level, nPts );
%                     plot(EllipseXY(1,:), EllipseXY(2,:), '-', 'color', 'k', 'markersize', 5);hold on;axis equal; grid on;
%                 end
                
                
                axis equal;  grid on; hold on;
                hold off;
                set(gca,'XLim',[-150 220])
                set(gca,'YLim',[-80 80])
                %set(gca,'XLim',[-0 50])
                %set(gca,'YLim',[-10 10])
                drawnow
        end
        % ======================================================================================================================================================
        function VisualizeTrackData(FUSED_TRACKS, TRACK_ESTIMATES, TRACK_ESTIMATES_RAD, TRACK_ESTIMATES_CAM, ...
                                    RADAR_MEAS_CLUSTER, RADAR_MEAS_CTS, CAMERA_MEAS_CTS, ...
                                    nNewTracks, nRadars, nCameras, gamma, TRAJECTORY_HISTORY)
                nMeasCam = CAMERA_MEAS_CTS.ValidCumulativeMeasCount(1,nCameras);
                nMeasRad = RADAR_MEAS_CTS.ValidCumulativeMeasCount(1,nRadars);
                nClstrsRad = RADAR_MEAS_CLUSTER.ValidCumulativeMeasCount(1,nRadars);
                pxRAD = single(zeros(1,TRACK_ESTIMATES_RAD.nValidTracks));
                pyRAD = single(zeros(1,TRACK_ESTIMATES_RAD.nValidTracks));
                pxCAM = single(zeros(1,TRACK_ESTIMATES_CAM.nValidTracks));
                pyCAM = single(zeros(1,TRACK_ESTIMATES_CAM.nValidTracks));
                pxFUS = single(zeros(1,TRACK_ESTIMATES.nValidTracks));
                pyFUS = single(zeros(1,TRACK_ESTIMATES.nValidTracks));
                nPts = 100;
                level = sqrt(50);
                %H = single([1,0,0,0; 0,0,1,0]);
                %R = [1,0;0,1];
                StateCovIndex = [1,2,4,5];
                
               
                figure(1);
                % Fused New Tracks
                newTrack_PXPY = single(zeros(2, 100));
                for idx = 1:nNewTracks
                    newTrack_PXPY(1,idx) = FUSED_TRACKS(idx).Xfus(1,1);
                    newTrack_PXPY(2,idx) = FUSED_TRACKS(idx).Xfus(3,1);
                end
                
                
                
                % RADAR Tracks
                for idx = 1:TRACK_ESTIMATES_RAD.nValidTracks
                    pxRAD(1,idx) = TRACK_ESTIMATES_RAD.TrackParam(1,idx).StateEstimate.px;
                    pyRAD(1,idx) = TRACK_ESTIMATES_RAD.TrackParam(1,idx).StateEstimate.py;
                    P = TRACK_ESTIMATES_RAD.TrackParam(1,idx).StateEstimate.ErrCOV(StateCovIndex,StateCovIndex);
                    %S = H*P*H' + R;
                    S = P([1,4],[1,4]);
                    EllipseXY = PLOTS.sigmaEllipse2D( [pxRAD(1,idx); pyRAD(1,idx)], S, level, nPts );
                    plot(EllipseXY(1,:), EllipseXY(2,:), '-', 'color', 'k', 'markersize', 5);hold on;axis equal; grid on;
                end
                plot(pxRAD,  pyRAD, '*', 'color', 'r', 'markersize', 4); axis equal;  grid on; hold on;
                %plot(RADAR_MEAS_CLUSTER.MeasArray(1, 1:nClstrsRad), RADAR_MEAS_CLUSTER.MeasArray(2, 1:nClstrsRad), '.', 'color', 'r', 'markersize', 5);
                plot(RADAR_MEAS_CTS.MeasArray(1, 1:nMeasRad), RADAR_MEAS_CTS.MeasArray(2, 1:nMeasRad), '.', 'color', 'r', 'markersize', 5);
                axis equal;  grid on; hold on;
                
                
                
                % CAMERA Tracks
                for idx = 1:TRACK_ESTIMATES_CAM.nValidTracks
                    pxCAM(1,idx) = TRACK_ESTIMATES_CAM.TrackParam(1,idx).StateEstimate.px;
                    pyCAM(1,idx) = TRACK_ESTIMATES_CAM.TrackParam(1,idx).StateEstimate.py;
                    P = TRACK_ESTIMATES_CAM.TrackParam(1,idx).StateEstimate.ErrCOV(StateCovIndex,StateCovIndex);
                    %S = H*P*H' + R;
                    S = P([1,4],[1,4]);
                    EllipseXY = PLOTS.sigmaEllipse2D( [pxCAM(1,idx); pyCAM(1,idx)], S, level, nPts );
                    plot(EllipseXY(1,:), EllipseXY(2,:), '-', 'color', 'k', 'markersize', 5);hold on;axis equal; grid on;
                end
                plot(pxCAM,  pyCAM, '*', 'color', 'b', 'markersize', 4); axis equal;  grid on; hold on;
                plot(CAMERA_MEAS_CTS.MeasArray(1, 1:nMeasCam), CAMERA_MEAS_CTS.MeasArray(2, 1:nMeasCam), '.', 'color', 'b', 'markersize', 5);
                
                
                
                % FUSED New Tracks
%                 for idx = 1:nNewTracks
%                     P = FUSED_TRACKS(idx).Pfus;
%                     S = P([1,4],[1,4]);
%                     EllipseXY = PLOTS.sigmaEllipse2D( [newTrack_PXPY(1,idx); newTrack_PXPY(2,idx)], S, level, nPts );
%                     plot(EllipseXY(1,:), EllipseXY(2,:), '-', 'color', 'm', 'markersize', 5);hold on;axis equal; grid on;
%                 end
%                 plot(newTrack_PXPY(1, 1:nNewTracks), newTrack_PXPY(2, 1:nNewTracks), '*', 'color', 'm', 'markersize', 4);hold on;axis equal; grid on;
                
                
                % FUSED Tracks
                for idx = 1:TRACK_ESTIMATES.nValidTracks
                    pxFUS(1,idx) = TRACK_ESTIMATES.TrackParam(1,idx).StateEstimate.px;
                    pyFUS(1,idx) = TRACK_ESTIMATES.TrackParam(1,idx).StateEstimate.py;
                    P = TRACK_ESTIMATES.TrackParam(1,idx).StateEstimate.ErrCOV(StateCovIndex,StateCovIndex);
                    S = P([1,4],[1,4]);
                    EllipseXY = PLOTS.sigmaEllipse2D( [pxFUS(1,idx); pyFUS(1,idx)], S, level, nPts );
                    plot(EllipseXY(1,:), EllipseXY(2,:), '-', 'color', 'm', 'markersize', 5);hold on;axis equal; grid on;
                end
                plot(pxFUS,  pyFUS, '*', 'color', 'm', 'markersize', 4); axis equal;  grid on; hold on;
                axis equal;  grid on; hold on;
                
                
                nPtsTV1 = TRAJECTORY_HISTORY.TRACK_HISTORY(1).BufferStartIndex;
                nPtsTV2 = TRAJECTORY_HISTORY.TRACK_HISTORY(2).BufferStartIndex;
                PX_TV1 = TRAJECTORY_HISTORY.TRACK_HISTORY(1).HistoryBufferPx(1,1:nPtsTV1);
                PY_TV1 = TRAJECTORY_HISTORY.TRACK_HISTORY(1).HistoryBufferPy(1,1:nPtsTV1);
                PX_TV2 = TRAJECTORY_HISTORY.TRACK_HISTORY(2).HistoryBufferPx(1,1:nPtsTV2);
                PY_TV2 = TRAJECTORY_HISTORY.TRACK_HISTORY(2).HistoryBufferPy(1,1:nPtsTV2);
                plot(PX_TV1, PY_TV1,'.', 'color', 'b', 'markersize', 5); axis equal;hold on;
                plot(PX_TV2, PY_TV2,'-*', 'color', 'r', 'markersize', 5); axis equal;
                
                
                axis equal;  grid on; hold on;
                hold off;
                set(gca,'XLim',[-150 220])
                set(gca,'YLim',[-80 80])
                %set(gca,'XLim',[-0 50])
                %set(gca,'YLim',[-10 10])
                drawnow
        end
        % ======================================================================================================================================================
        function VisualizeTrackDataMagnified(TRACK_ESTIMATES_RAD, TRACK_ESTIMATES_CAM, ...
                                    RADAR_MEAS_CLUSTER, RADAR_MEAS_CTS, CAMERA_MEAS_CTS, ...
                                    nRadars, nCameras, gamma)
                nMeasCam = CAMERA_MEAS_CTS.ValidCumulativeMeasCount(1,nCameras);
                nMeasRad = RADAR_MEAS_CTS.ValidCumulativeMeasCount(1,nRadars);
                nClstrsRad = RADAR_MEAS_CLUSTER.ValidCumulativeMeasCount(1,nRadars);
                pxRAD = single(zeros(1,TRACK_ESTIMATES_RAD.nValidTracks));
                pyRAD = single(zeros(1,TRACK_ESTIMATES_RAD.nValidTracks));
                pxCAM = single(zeros(1,TRACK_ESTIMATES_CAM.nValidTracks));
                pyCAM = single(zeros(1,TRACK_ESTIMATES_CAM.nValidTracks));
                nPts = 200;
                level = sqrt(3);
                %H = single([1,0,0,0; 0,0,1,0]);
                %R = [1,0;0,1];
                StateCovIndex = [1,2,4,5];
                
                
                figure(1); 
                subplot(1,2,1);
                % Track 1
                for idx = 1:TRACK_ESTIMATES_RAD.nValidTracks
                    pxRAD(1,idx) = TRACK_ESTIMATES_RAD.TrackParam(1,idx).StateEstimate.px;
                    pyRAD(1,idx) = TRACK_ESTIMATES_RAD.TrackParam(1,idx).StateEstimate.py;
                    P = TRACK_ESTIMATES_RAD.TrackParam(1,idx).StateEstimate.ErrCOV(StateCovIndex,StateCovIndex);
                    %S = H*P*H' + R;
                    S = P([1,4],[1,4]);
                    EllipseXY = PLOTS.sigmaEllipse2D( [pxRAD(1,idx); pyRAD(1,idx)], S, level, nPts );
                    plot(EllipseXY(1,:), EllipseXY(2,:), '-', 'color', 'r', 'markersize', 8);hold on;axis equal; grid on;
                end
                plot(pxRAD,  pyRAD, '*', 'color', 'r', 'markersize', 4); axis equal;  grid on; hold on;
                plot(RADAR_MEAS_CLUSTER.MeasArray(1, 1:nClstrsRad), RADAR_MEAS_CLUSTER.MeasArray(2, 1:nClstrsRad), '.', 'color', 'r', 'markersize', 5);
                axis equal;  grid on; hold on;
                % CAMERA Tracks
                for idx = 1:TRACK_ESTIMATES_CAM.nValidTracks
                    pxCAM(1,idx) = TRACK_ESTIMATES_CAM.TrackParam(1,idx).StateEstimate.px;
                    pyCAM(1,idx) = TRACK_ESTIMATES_CAM.TrackParam(1,idx).StateEstimate.py;
                    P = TRACK_ESTIMATES_CAM.TrackParam(1,idx).StateEstimate.ErrCOV(StateCovIndex,StateCovIndex);
                    %S = H*P*H' + R;
                    S = P([1,4],[1,4]);
                    EllipseXY = PLOTS.sigmaEllipse2D( [pxCAM(1,idx); pyCAM(1,idx)], S, level, nPts );
                    plot(EllipseXY(1,:), EllipseXY(2,:), '-', 'color', 'b', 'markersize', 8);hold on;axis equal; grid on;
                end
                plot(pxCAM,  pyCAM, '*', 'color', 'b', 'markersize', 4); axis equal;  grid on; hold on;
                plot(CAMERA_MEAS_CTS.MeasArray(1, 1:nMeasCam), CAMERA_MEAS_CTS.MeasArray(2, 1:nMeasCam), '.', 'color', 'b', 'markersize', 5);
                axis equal;  grid on; hold on;
                hold off;
                xCenter = pxRAD(1,1); yCenter = pyRAD(1,1);
                XUpperLimit =  xCenter + 10; XLowerLimit =  xCenter - 10; XLimit = [XLowerLimit  XUpperLimit];
                YUpperLimit =  yCenter + 10; YLowerLimit =  yCenter - 10; YLimit = [YLowerLimit  YUpperLimit];
                set(gca,'XLim', XLimit)
                set(gca,'YLim', YLimit)
                drawnow
                
                
                subplot(1,2,2);
                % Track 2
                for idx = 1:TRACK_ESTIMATES_RAD.nValidTracks
                    pxRAD(1,idx) = TRACK_ESTIMATES_RAD.TrackParam(1,idx).StateEstimate.px;
                    pyRAD(1,idx) = TRACK_ESTIMATES_RAD.TrackParam(1,idx).StateEstimate.py;
                    P = TRACK_ESTIMATES_RAD.TrackParam(1,idx).StateEstimate.ErrCOV(StateCovIndex,StateCovIndex);
                    %S = H*P*H' + R;
                    S = P([1,4],[1,4]);
                    EllipseXY = PLOTS.sigmaEllipse2D( [pxRAD(1,idx); pyRAD(1,idx)], S, level, nPts );
                    plot(EllipseXY(1,:), EllipseXY(2,:), '-', 'color', 'r', 'markersize', 8);hold on;axis equal; grid on;
                end
                plot(pxRAD,  pyRAD, '*', 'color', 'r', 'markersize', 4); axis equal;  grid on; hold on;
                plot(RADAR_MEAS_CLUSTER.MeasArray(1, 1:nClstrsRad), RADAR_MEAS_CLUSTER.MeasArray(2, 1:nClstrsRad), '.', 'color', 'r', 'markersize', 5);
                axis equal;  grid on; hold on;
                % CAMERA Tracks
                for idx = 1:TRACK_ESTIMATES_CAM.nValidTracks
                    pxCAM(1,idx) = TRACK_ESTIMATES_CAM.TrackParam(1,idx).StateEstimate.px;
                    pyCAM(1,idx) = TRACK_ESTIMATES_CAM.TrackParam(1,idx).StateEstimate.py;
                    P = TRACK_ESTIMATES_CAM.TrackParam(1,idx).StateEstimate.ErrCOV(StateCovIndex,StateCovIndex);
                    %S = H*P*H' + R;
                    S = P([1,4],[1,4]);
                    EllipseXY = PLOTS.sigmaEllipse2D( [pxCAM(1,idx); pyCAM(1,idx)], S, level, nPts );
                    plot(EllipseXY(1,:), EllipseXY(2,:), '-', 'color', 'b', 'markersize', 8);hold on;axis equal; grid on;
                end
                plot(pxCAM,  pyCAM, '*', 'color', 'b', 'markersize', 4); axis equal;  grid on; hold on;
                plot(CAMERA_MEAS_CTS.MeasArray(1, 1:nMeasCam), CAMERA_MEAS_CTS.MeasArray(2, 1:nMeasCam), '.', 'color', 'b', 'markersize', 5);
                axis equal;  grid on; hold on;
                hold off;
                xCenter = pxRAD(1,2); yCenter = pyRAD(1,2);
                XUpperLimit =  xCenter + 10; XLowerLimit =  xCenter - 10; XLimit = [XLowerLimit  XUpperLimit];
                YUpperLimit =  yCenter + 10; YLowerLimit =  yCenter - 10; YLimit = [YLowerLimit  YUpperLimit];
                set(gca,'XLim', XLimit)
                set(gca,'YLim', YLimit)
                drawnow
                
        end
        % ======================================================================================================================================================
        function [ xy ] = sigmaEllipse2D( mu, Sigma, level, npoints )
                Theta = zeros(1,npoints+1);
                theta1 = 0;theta2 = 2*pi;
                dTheta = theta2/npoints;
                a = theta1;
                for i = 1:npoints
                    Theta(i) = a;
                    a = a + dTheta;
                end
                Theta(1,end) = Theta(1,1); 
                Cos_Sin = [cos(Theta) ; sin(Theta)];
                Sigma_sqrt = sqrtm(Sigma);              %here sigma -> covarience
                val = level.*(Sigma_sqrt*Cos_Sin);
                xy = mu + val;
        end
        % ======================================================================================================================================================
        function VisualizeTrackData_Radar(TRACK_ESTIMATES_RAD, RADAR_MEAS_CTS, nRadars, GammaSq)
                nMeasRad = RADAR_MEAS_CTS.ValidCumulativeMeasCount(1,nRadars);
                pxRAD = single(zeros(1,TRACK_ESTIMATES_RAD.nValidTracks));
                pyRAD = single(zeros(1,TRACK_ESTIMATES_RAD.nValidTracks));
                nPts = 100;
                level = sqrt(50);
                StateCovIndex = [1,2,4,5];
                
                
                figure(1);
                
                % RADAR Tracks
                for idx = 1:TRACK_ESTIMATES_RAD.nValidTracks
                    pxRAD(1,idx) = TRACK_ESTIMATES_RAD.TrackParam(1,idx).StateEstimate.px;
                    pyRAD(1,idx) = TRACK_ESTIMATES_RAD.TrackParam(1,idx).StateEstimate.py;
                    P = TRACK_ESTIMATES_RAD.TrackParam(1,idx).StateEstimate.ErrCOV(StateCovIndex,StateCovIndex);
                    S = P([1,4],[1,4]);
                    EllipseXY = PLOTS.sigmaEllipse2D( [pxRAD(1,idx); pyRAD(1,idx)], S, level, nPts );
                    plot(EllipseXY(1,:), EllipseXY(2,:), '-', 'color', 'r', 'markersize', 5);hold on;axis equal; grid on;
                end
                plot(pxRAD,  pyRAD, '*', 'color', 'r', 'markersize', 4); axis equal;  grid on; hold on;
                plot(RADAR_MEAS_CTS.MeasArray(1, 1:nMeasRad), RADAR_MEAS_CTS.MeasArray(2, 1:nMeasRad), '.', 'color', 'r', 'markersize', 5);
                axis equal;  grid on; hold on;
                
                axis equal;  grid on; hold on;
                hold off;
                set(gca,'XLim',[-150 220])
                set(gca,'YLim',[-80 80])
                drawnow
        end
        % ======================================================================================================================================================
        function VisualizeTrackData_Camera(TRACK_ESTIMATES_CAM, CAMERA_MEAS_CTS, nCameras, GammaSq)
                nMeasCam = CAMERA_MEAS_CTS.ValidCumulativeMeasCount(1,nCameras);
                pxCAM = single(zeros(1,TRACK_ESTIMATES_CAM.nValidTracks));
                pyCAM = single(zeros(1,TRACK_ESTIMATES_CAM.nValidTracks));
                nPts = 100;
                level = sqrt(50);
                StateCovIndex = [1,2,4,5];
                
                
                figure(1);
                
                % RADAR Tracks
                for idx = 1:TRACK_ESTIMATES_CAM.nValidTracks
                    pxCAM(1,idx) = TRACK_ESTIMATES_CAM.TrackParam(1,idx).StateEstimate.px;
                    pyCAM(1,idx) = TRACK_ESTIMATES_CAM.TrackParam(1,idx).StateEstimate.py;
                    P = TRACK_ESTIMATES_CAM.TrackParam(1,idx).StateEstimate.ErrCOV(StateCovIndex,StateCovIndex);
                    S = P([1,4],[1,4]);
                    EllipseXY = PLOTS.sigmaEllipse2D( [pxCAM(1,idx); pyCAM(1,idx)], S, level, nPts );
                    plot(EllipseXY(1,:), EllipseXY(2,:), '-', 'color', 'r', 'markersize', 5);hold on;axis equal; grid on;
                end
                plot(pxCAM,  pyCAM, '*', 'color', 'r', 'markersize', 4); axis equal;  grid on; hold on;
                plot(CAMERA_MEAS_CTS.MeasArray(1, 1:nMeasCam), CAMERA_MEAS_CTS.MeasArray(2, 1:nMeasCam), '.', 'color', 'r', 'markersize', 5);
                axis equal;  grid on; hold on;
                
                axis equal;  grid on; hold on;
                hold off;
                set(gca,'XLim',[-150 220])
                set(gca,'YLim',[-80 80])
                drawnow
        end
        % ======================================================================================================================================================
    end
end
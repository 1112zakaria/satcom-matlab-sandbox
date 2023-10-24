% Tutorials that I've looked at:
% - Satellite Scenario Basics
% - 
% Questions:
% - How can I dynamically point the gimbals onto the ground
% receivers that it is connected to?
%   - This might be called gimbal steering...
% - How do I do satellite-to-satellite multi-hop? Is that even possible?
%   - A: it is possible to point satellite gimbal to a satellite
% - How do I add event handler logic for current simulation state?


% Satellite scenario init
sc = satelliteScenario;

% Initialize two satellite objects
semiMajorAxis = [10000000];
eccentricity = [0.05];
inclination = [0];
rightAscensionOfAscendingNode = [-50];
argumentOfPeriapsis = [0];
trueAnomaly = [0];
sat = satellite(sc,semiMajorAxis,eccentricity,inclination, ...
    rightAscensionOfAscendingNode,argumentOfPeriapsis,trueAnomaly);

% Initialize ground station object
startTime = datetime(2020,5,1,11,36,0);
stopTime = startTime + days(2);
sampleTime = 60;
lat = 45;
lon = -79;
gs1 = groundStation(sc,lat,lon);

startTime = datetime(2020,5,1,11,36,0);
stopTime = startTime + days(2);
sampleTime = 60;
lat = -13;
lon = -45;
gs2 = groundStation(sc,lat,lon);

% Link stuff
gimbalrxSat = gimbal(sat);
gimbaltxSat = gimbal(sat);
gainToNoiseTemperatureRatio = 5;                                                        % dB/K
systemLoss = 3;                                                                         % dB
rxSat = receiver(gimbalrxSat,Name="Satellite Receiver",GainToNoiseTemperatureRatio= ...
    gainToNoiseTemperatureRatio,SystemLoss=systemLoss);
frequency = 27e9;                                                                     % Hz
power = 20;                                                                           % dBW
bitRate = 20;                                                                         % Mbps
systemLoss = 3;                                                                       % dB
txSat = transmitter(gimbaltxSat,Name="Satellite Transmitter",Frequency=frequency, ...
    power=power,BitRate=bitRate,SystemLoss=systemLoss);

dishDiameter = 0.5;                                                                    % meters
apertureEfficiency = 0.5;
gaussianAntenna(txSat,DishDiameter=dishDiameter,ApertureEfficiency=apertureEfficiency);
gaussianAntenna(rxSat,DishDiameter=dishDiameter,ApertureEfficiency=apertureEfficiency);

% Pointing the gimbals
pointAt(gimbaltxSat,gs2);
pointAt(gimbalrxSat,gs1);
gimbalgs1 = gimbal(gs1);
gimbalgs2 = gimbal(gs2);

% Add transmitters to gs1 and gs2
frequency = 30e9;                                                                          % Hz
power = 40;                                                                                % dBW
bitRate = 20;                                                                              % Mbps
txGs1 = transmitter(gimbalgs1,Name="Ground Station 1 Transmitter",Frequency=frequency, ...
        Power=power,BitRate=bitRate);
requiredEbNo = 14;                                                                     % dB
rxGs2 = receiver(gimbalgs2,Name="Ground Station 2 Receiver",RequiredEbNo=requiredEbNo);
dishDiameter = 5;                                % meters
gaussianAntenna(txGs1,DishDiameter=dishDiameter);
gaussianAntenna(rxGs2,DishDiameter=dishDiameter);

% Point the ground station gimbals
pointAt(gimbalgs1,sat);
pointAt(gimbalgs2,sat);

% Link Analysis
lnk = link(txGs1,rxSat,txSat,rxGs2);
linkIntervals(lnk)

% Access analysis
ac = access(sat,gs1);
intvls1 = accessIntervals(ac);
ac = access(sat,gs2);
intvls2 = accessIntervals(ac);

% Play simulation
play(sc);
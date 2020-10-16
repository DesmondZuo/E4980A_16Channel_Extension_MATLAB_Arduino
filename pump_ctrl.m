function pump_ctrl(pump_stage)
global ardu_mega

switch pump_stage
    case 1 % IN
        writeDigitalPin(ardu_mega, 'D22', 1);
        writeDigitalPin(ardu_mega, 'D26', 0);
        disp('Inflating......')
    case 2 % HOLD
        writeDigitalPin(ardu_mega, 'D22', 0);
        writeDigitalPin(ardu_mega, 'D26', 0);
        writePWMVoltage(ardu_mega, 12 , 0);
        disp('Holding......')
    case 3 % OUT
        writeDigitalPin(ardu_mega, 'D22', 0);
        writeDigitalPin(ardu_mega, 'D26', 1);
        writePWMVoltage(ardu_mega, 12 , 0);
        disp('Deflating......')
end

end
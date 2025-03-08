function LSD = generate_LSD(SRC,DST, Type, META, LSF)
%GENERATE_ Summary of this function goes here
%   Detailed explanation goes here
    Type_ = int2bit(Type, 16, true);
    SRC_ = int2bit(encode_call_sign(SRC), 64, true);
    DST_ = int2bit(encode_call_sign(DST), 64, true);
    META_ = int2bit(encode_call_sign(META), 112, true);
    LSD = [ SRC_ DST_ Type_ META_  ];
    
    if LSF == "on"
        gp = "z^16+z^14+z^12+z^11+z^8+z^5+z^4+z^2+1";
        crcCFG = crcConfig(Polynomial=gp,InitialConditions=hex2dec("FFFF"));
        LSD = crcGenerate(LSD, crcCFG);
    end

end


%Receiver

receivedsignal=reshape(repeatingproperorder',[],1);

changetobits=reshape(receivedsignal,8,[]);

changetodescaledints=(bit2int(changetobits,8)')/255;

%soundsc(changetodescaledints,FS);






    


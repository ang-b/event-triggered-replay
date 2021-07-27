classdef AttackPhase < Simulink.IntEnumType
    enumeration
        IDLE (0)
        RECORD (1)
        PLAYBACK (2)
    end
    
    % Simulink stuff
    methods (Static = true)
        
       function retVal = getDefaultValue()
           retVal = AttackPhase.RECORD;
       end
       
       function retVal = addClassNameToEnumNames()
           retVal = true;
       end
        
    end
end

classdef TriggerSystem < matlab.System ...
       & matlab.system.mixin.CustomIcon
    % ReplayAttacker Add summary here

    properties(DiscreteState)
        heldInput;
    end

    methods
        % Constructor (for MATLAB usage)
        function this = TriggerSystem(varargin)
            if nargin > 0 && ~isempty(varargin{1}) && isnumeric(varargin{1})
                this.heldInput = 0;
            end
        end
    end 
    
    methods(Access = protected)
        % Common functions
        function setupImpl(this,u)
            this.heldInput = zeros(numel(u), 1);
        end
        
        function [uTrig, trig] = stepImpl(this, u, err, delta, aux)
             if err >= delta
                 uTrig = u;
                 this.heldInput = uTrig;
                 trig = true;
             else
                 % case 1: standard evt triggered
                 uTrig = this.heldInput*0.95;
                 % case 2: control to 0
%                  uTrig = zeros(size(this.heldInput));
                 trig = false;
             end
        end

        function resetImpl(this)
            this.heldInput = zeros(size(this.heldInput));
        end

        % Simulink functions
        function [sz,dt,cp] = getDiscreteStateSpecificationImpl(this,name)
          if strcmp(name,'heldInput')
            sz = propagatedInputSize(this, 1);
            dt = "double";
            cp = false;
          end
        end
        
        function flag = isInputSizeMutableImpl(~,~)
            flag = false;
        end

        function flag = isInputDataTypeMutableImpl(~,~)
            flag = false;
        end

        function num = getNumInputsImpl(~)
            num = 4;
        end

        function num = getNumOutputsImpl(~)
            num = 2;
        end

        function [uTrigSize, tildeySize] = getOutputSizeImpl(this)
            uTrigSize = propagatedInputSize(this, 1);
            tildeySize = [1 1];
        end
        
        function [ut, t] = getOutputDataTypeImpl(~)
            ut = "double";
            t = "logical";
        end

        function varargout = isOutputFixedSizeImpl(~)
            varargout = repmat({true}, 1,2);
        end

        function varargout = isOutputComplexImpl(~)
           varargout = repmat({false}, 1,2);
        end
        
        function icon = getIconImpl(~)
            % Define icon for System block
            icon = mfilename("class"); % Use class name
            % icon = "My System"; % Example: text icon
            % icon = ["My","System"]; % Example: multi-line text icon
            % icon = matlab.system.display.Icon("myicon.jpg"); % Example: image file icon
        end
    end

    methods(Static, Access = protected)
        %% Simulink customization functions
        function header = getHeaderImpl
            % Define header panel for System block dialog
            header = matlab.system.display.Header(mfilename("class"));
        end

        function group = getPropertyGroupsImpl
            % Define property section(s) for System block dialog
            group = matlab.system.display.Section(mfilename("class"));
        end
    end
    
end

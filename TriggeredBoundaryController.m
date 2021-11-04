classdef TriggeredBoundaryController < matlab.System ...
       & matlab.system.mixin.CustomIcon
    % TriggeredBoundaryController Add summary here

    properties(DiscreteState)
        heldInput;
        isOut;
        xlast;
    end

    properties(Nontunable)
        A(2,2); % state transition matrix A
        B(2,1); % input matrix B
        gamma(2,2); % open-loop discrete-time static gain
        mu(2,1); % closed-loop discrete-time static ffw compensation
        K(1,2); % feedback gain K
    end
    
    properties
        sat_bounds(1,2); % saturation bounds
    end

    properties(Access = private)
        G;
        AIN;
        T;
        iT;
        beta;
    end

    methods
        % Constructor (for MATLAB usage)
        % TODO or not allowed?
    end 
    
    methods(Access = protected)
        % Common functions
        function setupImpl(this,~)
            this.heldInput = zeros(size(this.B,2), 1);
            this.isOut = false;
            this.xlast = zeros(2, 1);
            this.AIN = (eye(2) - this.A);
            
            [Qf,Lf] = qr(this.AIN.');
            Qf = Qf.';
            Lf = Lf.';

            % assume the system is in form [0; b2]
            Q1 = Qf(1,:);
            Q2 = Qf(2,:);

            % L1 not needed
            L2 = Lf(2,1);
            L3 = Lf(2,2);

            this.G = Q2.'/L3*L2*Q1 + Q2.'*Q2;
            this.T = [orth(this.G) null(this.G)];
            this.iT = pinv(this.G);
            this.beta = 1/norm(this.iT);
        end
        
        function [uTrig, trig] = stepImpl(this, xref, x, delta, theta)
            err = norm(x - xref);
            if err < delta && this.isOut
                this.xlast = x;
                M = [cos(theta)  -sin(theta); 
                     sin(theta)   cos(theta)];
                e = M * 2 * x;
                e = - this.iT*this.G* e / norm(this.iT*this.G);
%                 uTrig = this.G * ((1+eps)*delta*e + this.AIN*this.xlast);
                uTrig = this.B.' * this.AIN * ...
                        ((2 + eps) * delta * e + this.iT*this.xlast) / ...
                        ( norm(this.B*this.B.'));
                uTrig = min(this.sat_bounds(2), max(this.sat_bounds(1), uTrig));
                this.heldInput = uTrig;
                trig = true;
                this.isOut = false;
            elseif err >= delta
                uTrig = - this.K * ( x - xref./this.mu );
                uTrig = min(this.sat_bounds(2), max(this.sat_bounds(1), uTrig));
                trig = true;
                this.isOut = true;
            else
                % case 1: standard evt triggered
                uTrig = this.heldInput;
                % case 2: control to 0
%                 uTrig = zeros(size(this.heldInput));
                trig = false;
            end
%             uTrig = min(this.sat_bounds(2), max(this.sat_bounds(2), uTrig));
        end

        function resetImpl(this)
            this.heldInput = zeros(size(this.heldInput));
        end

        % Simulink functions
        function [sz,dt,cp] = getDiscreteStateSpecificationImpl(this,name)
          if strcmp(name,'xlast')
              sz = propagatedInputSize(this, 2);
              dt = "double";
              cp = false;
          elseif strcmp(name, 'isOut')
              sz = [1 1];
              dt = "logical";
              cp = false;
          elseif strcmp(name, 'heldInput')
              sz = [size(this.B,2) 1];
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
            uTrigSize = [size(this.B,2) 1];
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
    
    methods(Access = private)
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

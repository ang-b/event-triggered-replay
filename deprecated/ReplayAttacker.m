classdef ReplayAttacker < matlab.System ...
       & matlab.system.mixin.CustomIcon
    % ReplayAttacker Add summary here

    properties(Nontunable)
        bufferSize = 1024;
    end

    properties(Access = private)
        prevPhase;
        period;
        buffer_u;
        buffer_y
        rec_index;
        play_index;
    end

    methods
        % Constructor (for MATLAB usage)
        function this = ReplayAttacker(varargin)
            if nargin > 0 && ~isempty(varargin{1}) && isnumeric(varargin{1})
                this.bufferSize = varargin{1}; 
            end
        end
    end
    
    methods(Access = private)
        % wrapping functions for reuse in Simulink and MATLAB scripts
        
        function updateRecordBuffer(this,u,y,phase)
            this.buffer_u(:,this.rec_index) = u; 
            this.buffer_y(:,this.rec_index) = y;
            
            % Keep recording and playing in a circular buffer fashion:
            if phase ~= this.prevPhase
                % if we just entered this phase, store the record index as
                % the first playback index
                this.play_index = mod(this.rec_index,this.bufferSize);
                % TODO? zero the buffer
                this.period = 1;
            end  
            this.rec_index = mod(this.rec_index, this.bufferSize) + 1;
            this.period = this.rec_index - this.play_index;
        end
        
        function [tildeu, tildey] = recPhaseOutput(~,u,y)
              tildeu = u;
              tildey = y;
        end
        
        function updatePlaybackBuffer(this,phase)
            % Keep recording and playing in a circular buffer fashion:
            this.play_index = mod(this.play_index, ...
                                  min(this.bufferSize, this.period)) + 1;
            if phase ~= this.prevPhase 
                % if we just entered the playback phase, the next record
                % cycle will begin from start
                this.rec_index = 1;
            end
        end
        
        function [tildeu, tildey] = playPhaseOutput(this)
            tildeu = this.buffer_u(:, this.play_index);
            tildey = this.buffer_y(:, this.play_index);
        end
        
        function init(this,szu,szy)
            this.buffer_u = zeros(szu, this.bufferSize);
            this.buffer_y = zeros(szy, this.bufferSize);
            this.rec_index = 1;
            this.play_index = 1;
            this.prevPhase = AttackPhase.IDLE;
            this.period = 1;
        end
    end

    methods(Access = protected)
        %% Common functions
        function setupImpl(this, u, y)
            this.init(size(u,1), size(y,1));
        end
        
        function [tildeu, tildey] = stepImpl(this, u, y, phase)
             switch (phase)
                case AttackPhase.RECORD
                    this.updateRecordBuffer(u,y,phase);
                    [tildeu, tildey] = this.recPhaseOutput(u,y);
                case AttackPhase.PLAYBACK               
                    [tildeu, tildey] = this.playPhaseOutput();
                    this.updatePlaybackBuffer(phase);
                 case AttackPhase.IDLE
                    [tildeu, tildey] = this.recPhaseOutput(u,y); 
                 otherwise
                    error('Invalid phase value.');
             end
            this.prevPhase = phase;
        end

        function resetImpl(this)
            this.init(size(this.buffer_u,1), size(this.buffer_y,1));
        end

        %% Simulink functions
        function flag = isInputSizeMutableImpl(~,~)
            flag = false;
        end

        function flag = isInputDataTypeMutableImpl(~,~)
            flag = false;
        end

        function num = getNumInputsImpl(~)
            num = 3;
        end

        function num = getNumOutputsImpl(~)
            num = 2;
        end

        function [tildeuSize, tildeySize] = getOutputSizeImpl(this)
            tildeuSize = propagatedInputSize(this, 1);
            tildeySize = propagatedInputSize(this, 2);
        end
        
        function varargout = getOutputDataTypeImpl(~)
            varargout = repmat({'double'}, 1,2);
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

classdef DateWrapper < double 
    methods
        function this = DateWrapper(varargin)
            this = this@double(varargin{:});
        end%


        function disp(this)
            sizeThis = size(this);
            sizeString = sprintf('%gx', sizeThis);
            sizeString(end) = '';
            isEmpty = any(sizeThis==0);
            if isEmpty
                frequencyDisplayName = 'Empty';
            else
                freq = DateWrapper.getFrequency(this);
                firstFreq = freq(1);
                if all(firstFreq==freq(:))
                    frequencyDisplayName = char(firstFreq);
                else
                    frequencyDisplayName = 'Mixed Frequency';
                end
            end
            fprintf('  %s %s Date(s)\n', sizeString, frequencyDisplayName);
            if ~isEmpty
                textual.looseLine( );
                print = DateWrapper.toDefaultString(this);
                if isscalar(this)
                    disp(["    """ + print + """"]);
                else
                    disp(print);
                end
            end
            textual.looseLine( );
        end%
        
        
        function inx = ismember(this, that)
            inx = ismember(round(100*this), round(100*that));
        end%


        function dt = not(this)
            dt = DateWrapper.toDatetime(this);
        end%


        function this = uplus(this)
        end%


        function this = uminus(this)
            inxInf = isinf(double(this));
            if ~all(inxInf)
                throw( exception.Base('DateWrapper:InvalidInputsIntoUminus', 'error') );
            end
            this = DateWrapper(-double(this));
        end%


        function this = plus(a, b)
            if isa(a, 'DateWrapper') && isa(b, 'DateWrapper')
                throw( exception.Base('DateWrapper:InvalidInputsIntoPlus', 'error') );
            end
            if ~all(double(a)==round(a)) && ~all(double(b)==round(b))
                throw( exception.Base('DateWrapper:InvalidInputsIntoPlus', 'error') );
            end
            x = double(a) + double(b);
            x = round(x*100)/100;
            try
                freq = DateWrapper.getFrequencyAsNumeric(x);
            catch
                throw( exception.Base('DateWrapper:InvalidInputsIntoPlus', 'error') );
            end
            if isempty(x)
                this = DateWrapper.empty(size(x));
            else
                serial = floor(x);
                this = DateWrapper.fromSerial(freq(1), serial); 
            end
        end%
        
        
        function this = minus(a, b)
            if isa(a, 'DateWrapper') && isa(b, 'DateWrapper')
                if ~all(DateWrapper.getFrequencyAsNumeric(a(:))==DateWrapper.getFrequencyAsNumeric(b(:)))
                    throw( exception.Base('DateWrapper:InvalidInputsIntoMinus', 'error') );
                end
                this = floor(a) - floor(b);
                return
            end
            if ~all(double(a)==round(a)) && ~all(double(b)==round(b))
                throw( exception.Base('DateWrapper:InvalidInputsIntoMinus', 'error') );
            end
            x = double(a) - double(b);
            x = round(x*100)/100;
            try
                frequency = DateWrapper.getFrequency(x);
            catch
                throw( exception.Base('DateWrapper:InvalidInputsIntoMinus', 'error') );
            end
            if isempty(x)
                this = DateWrapper.empty(size(x));
            else
                serial = DateWrapper.getSerial(x);
                this = DateWrapper.fromSerial(frequency(1), serial); 
            end
        end%
        
        
        function this = colon(varargin)
            if nargin==2
                [from, to] = varargin{:};
                if isequal(from, -Inf) || isequal(to, Inf)
                    if ~isa(from, 'DateWrapper')
                        from = DateWrapper(from);
                    end
                    if ~isa(to, 'DateWrapper')
                        to = DateWrapper(to);
                    end
                    this = [from, to];
                    return
                end
                step = 1;
            elseif nargin==3
                [from, step, to] = varargin{:};
            end
            if isnan(from) || isnan(step) || isnan(to)
                this = DateWrapper.NaD( );
                return
            end
            if ~isnumeric(from) || ~isnumeric(to) ...
                || not(numel(from)==1) || not(numel(to)==1) ...
                || not(DateWrapper.getFrequencyAsNumeric(from)==DateWrapper.getFrequencyAsNumeric(to))
                throw(exception.Base('DateWrapper:InvalidStartEndInColon', 'error'));
            end
            if ~isnumeric(step) || numel(step)~=1 || step~=round(step)
                throw(exception.Base('DateWrapper:InvalidStepInColon', 'error'));
            end
            freq = DateWrapper.getFrequencyAsNumeric(from);
            fromSerial = floor(from);
            toSerial = floor(to);
            serial = fromSerial : step : toSerial;
            serial = floor(serial);
            this = DateWrapper.fromSerial(freq, serial);
        end%


        function this = real(this)
            this = DateWrapper(real(double(this)));
        end%


        function this = min(varargin)
            minDouble = min@double(varargin{:});
            this = DateWrapper(minDouble);
        end%


        function this = max(varargin)
            maxDouble = max@double(varargin{:});
            this = DateWrapper(maxDouble);
        end%


        function this = getFirst(this)
            this = this(1);
        end%


        function this = getLast(this)
            this = this(end);
        end%


        function this = getIth(this, pos)
            this = this(pos);
        end%


        function flag = isnad(this)
            flag = isequaln(double(this), NaN);
        end%


        function n = rnglen(varargin)
            if nargin==1
                firstDate = getFirst(varargin{1});
                lastDate = getLast(varargin{1});
            else
                firstDate = varargin{1};
                lastDate = varargin{2};
            end
            if ~isa(firstDate, 'DateWrapper') || ~isa(lastDate, 'DateWrapper')
                throw( exception.Base('DateWrapper:InvalidInputsIntoRnglen', 'error') );
            end
            firstFrequency = DateWrapper.getFrequencyAsNumeric(firstDate(:));
            lastFrequency = DateWrapper.getFrequencyAsNumeric(lastDate(:));
            if ~all(firstFrequency==lastFrequency)
                throw( exception.Base('DateWrapper:InvalidInputsIntoRnglen', 'error') );
            end
            n = floor(lastDate) - floor(firstDate) + 1;
        end%


        function this = addTo(this, c)
            if ~isa(this, 'DateWrapper') || ~isnumeric(c) || ~all(c==round(c))
                throw( exception.Base('DateWrapper:InvalidInputsIntoAddTo', 'error') );
            end
            this = DateWrapper(double(this) + c);
        end%
            

        function datetimeObj = datetime(this, varargin)
            datetimeObj = DateWrapper.toDatetime(this, varargin{:});
        end%


        function [durationObj, halfDurationObj] = duration(this)
            frequency = DateWrapper.getFrequency(this);
            [durationObj, halfDurationObj] = duration(frequency);
        end%
    end

        


    methods % == < > <= >=
        %(
        function flag = eq(d1, d2)
            flag = round(d1*100)==round(d2*100);
        end%


        function flag = lt(d1, d2)
            flag = round(d1*100)<round(d2*100);
        end%


        function flag = gt(d1, d2)
            flag = round(d1*100)>round(d2*100);
        end%


        function flag = le(d1, d2)
            flag = round(d1*100)<=round(d2*100);
        end%


        function flag = ge(d1, d2)
            flag = round(d1*100)>=round(d2*100);
        end%
        %)
    end
    


    
    methods (Hidden)
        function pos = positionOf(dates, start)
            dates = double(dates);
            if nargin<2
                refDate = min(dates(:));
            else
                refDate = start;
            end
            refDate = double(refDate);
            pos = round(dates - refDate + 1);
        end%




        function varargout = datestr(this, varargin)
            [varargout{1:nargout}] = datestr(double(this), varargin{:});
        end%




        function varargout = xline(this, varargin)
            [varargout{1:nargout}] = xline(DateWrapper.toDatetime(this), varargin{:});
        end%
    end


    methods (Static)
        varargout = reportConsecutive(varargin)
        varargout = reportMissingPeriodsAndPages(varargin)




        function this = Inf( )
            this = DateWrapper(Inf);
        end%


        function this = NaD( )
            this = DateWrapper(NaN);
        end%


        function c = toCellstr(dateCode, varargin)
            c = dat2str(double(dateCode), varargin{:});
        end%


        function frequency = getFrequencyAsNumeric(dateCode)
            frequency = round(100*(double(dateCode) - floor(dateCode)));
            inxZero = frequency==0;
            if any(inxZero)
                inxDaily = frequency==0 & floor(dateCode)>=Frequency.MIN_DAILY_SERIAL;
                frequency(inxDaily) = 365;
            end
        end%


        function frequency = getFrequency(dateCode)
            numericFrequency = DateWrapper.getFrequencyAsNumeric(dateCode);
            frequency = Frequency(numericFrequency);
        end%


        function serial = getSerial(input)
            serial = floor(double(input));
        end%


        function varargout = fromDouble(varargin)
            [varargout{1:nargout}] = DateWrapper.fromDateCode(varargin{:});            
        end%


        function [this, frequency, serial] = fromDateCode(x)
            frequency = DateWrapper.getFrequencyAsNumeric(x);
            serial = DateWrapper.getSerial(x);
            this = DateWrapper.fromSerial(frequency, serial);
        end%


        function this = fromSerial(varargin)
            dateCode = DateWrapper.getDateCodeFromSerial(varargin{:});
            this = DateWrapper(dateCode);
        end%


        function dateCode = fromIsoStringAsNumeric(freq, isoDate)
            freq = double(freq);
            if isequal(freq, 0)
                dateCode = double(isoDate);
                return
            end
            reshapeOutput = size(isoDate);
            isoDate = reshape(extractBefore(string(isoDate), 11), 1, [ ]);
            isoDate = join(replace(isoDate, "-", " "), " ");
            ymd = sscanf(isoDate, "%g");
            serial = Frequency.ymd2serial(freq, ymd(1:3:end), ymd(2:3:end), ymd(3:3:end)); 
            dateCode = DateWrapper.getDateCodeFromSerial(freq, serial);
            dateCode = reshape(dateCode, reshapeOutput);
        end%


        function this = fromIsoString(varargin)
            dateCode = DateWrapper.fromIsoStringAsNumeric(varargin{:});
            this = DateWrapper(dateCode);
        end%


        function isoDate = toIsoString(this, varargin)
            if isempty(this)
                isoDate = string.empty(size(this));
                return
            end
            reshapeOutput = size(this);
            isoDate = repmat("", reshapeOutput);
            freq = DateWrapper.getFrequencyAsNumeric(this);
            inxNaN = isnan(freq);
            if all(inxNaN)
                return
            end
            freq(inxNaN) = [ ];
            if ~Frequency.sameFrequency(freq)
                thisError = [
                    "DateWrapper:ToIsoString"
                    "Cannot convert dates of multiple date frequencies "
                    "in one run of the function DateWrapper.toIsoString( )."
                ];
                throw(exception.Base(thisError, 'error'));
            end
            freq = freq(1);
            if freq==0
                isoDate = string(double(this));
                return
            end
            [year, month, day] = Frequency.serial2ymd(freq, floor(this), varargin{:});
            isoDate(~inxNaN) = compose("%04g-%02g-%02g", [year(:), month(:), day(:)]);
            isoDate = reshape(isoDate, reshapeOutput);
        end%


        function dateCode = getDateCodeFromSerial(freq, serial)
            freq = double(freq);
            inxFreqCodes = freq~=0 & freq~=365;
            freqCode = zeros(size(freq));
            freqCode(inxFreqCodes) = double(freq(inxFreqCodes)) / 100;
            dateCode = round(serial) + freqCode;
        end%


        function this = fromDatetime(frequency, dt)
            serial = Frequency.ymd2serial(frequency, year(dt), month(dt), day(dt));
            this = DateWrapper.fromSerial(frequency, serial);
        end%


        function dateCode = fromDatetimeAsNumeric(freq, dt)
            serial = Frequency.ymd2serial(freq, year(dt), month(dt), day(dt));
            dateCode = DateWrapper.getDateCodeFromSerial(freq, serial);
        end%


        function datetimeObj = toDatetime(input, varargin)
            frequency = DateWrapper.getFrequency(input);
            if ~all(frequency(1)==frequency(:))
                throw( exception.Base('DateWrapper:InvalidInputsIntoDatetime', 'error') )
            end
            datetimeObj = datetime(frequency(1), DateWrapper.getSerial(input), varargin{:});
        end%


        function checkMixedFrequency(varargin)
            if Frequency.sameFrequency(varargin{:})
                return
            end
            freq = reshape(varargin{1}, 1, [ ]);
            if nargin>=2
                freq = [freq, reshape(varargin{2}, 1, [ ])];
            end
            if nargin>=3
                context = varargin{3};
            else
                context = 'in this context';
            end
            cellstrFreq = Frequency.toCellstr(unique(freq, 'stable'));
            throw( exception.Base('Dates:MixedFrequency', 'error'), ...
                   context, cellstrFreq{:} ); %#ok<GTARG>
        end%
        
        
        function formats = chooseFormat(formats, freq, k)
            if nargin<3
                k = 1;
            elseif k>numel(formats)
                k = numel(formats);
            end

            if ischar(formats)
                return
            end

            if iscellstr(formats)
                formats = formats{k};
                return
            end

            if isa(formats, 'string')
                formats = formats(k);
                return
            end

            if ~isstruct(formats)
                throw( exception.Base('DateWrapper:InvalidDateFormat', 'error') );
            end

            switch freq
                case 0
                    formats = formats(k).ii;
                case 1
                    formats = formats(k).yy;
                case 2
                    formats = formats(k).hh;
                case 4
                    formats = formats(k).qq;
                case 6
                    formats = formats(k).bb;
                case 12
                    formats = formats(k).mm;
                case 52
                    formats = formats(k).ww;
                case 365
                    formats = formats(k).dd;
                otherwise
                    formats = '';
            end
        end%


        function flag = validateDateInput(input)
            freqLetter = iris.get('FreqLetters');
            if isa(input, 'DateWrapper')
                flag = true;
                return
            end
            if isa(input, 'double')
                try
                    DateWrapper.getFrequency(input);
                    flag = true;
                catch
                    flag = false;
                end
                return
            end
            if isequal(input, @all)
                flag = true;
                return
            end
            if ~(ischar(input) || isa(input, 'string')) || isempty(input)
                flag = false;
                return
            end
            input = strtrim(cellstr(input));
            match = regexpi(input, ['\d+[', freqLetter, ']\d*'], 'Once');
            flag = all(~cellfun('isempty', match));
        end%


        function flag = validateProperDateInput(input)
            if ~DateWrapper.validateDateInput(input)
                flag = false;
                return
            end
            if any(~isfinite(double(input)))
                flag = false;
                return
            end
            flag = true;
        end%
        

        function flag = validateRangeInput(input)
            if isequal(input, Inf) || isequal(input, @all)
                flag = true;
                return
            end
            if ischar(input) || isa(input, 'string')
                try
                    input = textinp2dat(input);
                catch
                    flag = false;
                    return
                end
            end
            if ~DateWrapper.validateDateInput(input)
                flag = false;
                return
            end
            if numel(input)==1
                flag = true;
                return
            end
            if numel(input)==2
                if (isinf(input(1)) || isinf(input(2)))
                    flag = true;
                    return
                elseif all(freqcmp(input))
                    flag = true;
                    return
                else
                    flag = false;
                    return
                end
            end
            if ~all(freqcmp(input))
                flag = false;
                return
            end
            if ~all(round(diff(input))==1)
                flag = false;
                return
            end
            flag = true;
        end


        function flag = validateProperRangeInput(input)
            if ischar(input) || isa(input, 'string')
                input = textinp2dat(input);
            end
            if ~DateWrapper.validateRangeInput(input)
                flag = false;
                return
            end
            if isequal(input, @all) || isempty(input) || any(isinf(input))
                flag = false;
                return
            end
            flag = true;
        end%


        function pos = getRelativePosition(ref, dates, bounds, context)
            ref = double(ref);
            dates =  double(dates);
            refFreq = DateWrapper.getFrequencyAsNumeric(ref);
            datesFreq = DateWrapper.getFrequencyAsNumeric(dates);
            if ~all(datesFreq==refFreq)
                THIS_ERROR= { 'DateWrapper:CannotRelativePositionForMixedFrequencies', ...
                              'Relative positions can be only calculated for dates of identical frequencies' };
                throw( exception.Base(THIS_ERROR, 'error') );
            end
            refSerial = DateWrapper.getSerial(ref);
            datesSerial = DateWrapper.getSerial(dates);
            pos = round(datesSerial - refSerial + 1);
            % Check lower and upper bounds on the positions
            if nargin>=3 && ~isempty(bounds)
                inxOutRange = pos<bounds(1) | pos>bounds(2);
                if any(inxOutRange)
                    if nargin<4
                        context = 'range';
                    end
                    THIS_ERROR = { 'DateWrapper:DateOutOfRange'
                                   'This date is out of %1: %s ' };
                    temp = dat2str(dates(inxOutRange));
                    throw( exception.Base(THIS_ERROR, 'error'), ...
                           context, temp{:} );
                end
            end
        end%




        function date = ii(input)
            date = DateWrapper(round(input));
        end%




        function dates = removeWeekends(dates)
            inxWeekend = DateWrapper.isWeekend(double(dates));
            dates(inxWeekend) = [ ];
        end%




        function inxWeekend = isWeekend(dates)
            weekday = weekdayiso(double(dates));
            inxWeekend = weekday==6 | weekday==7;
        end%




        function s = toDefaultString(dates)
            dates = double(dates);
            s = repmat("", size(dates));

            [year, per, freq] = dat2ypf(dates);
            freqLetter = Frequency.toLetter(freq);
            
            inx = isnan(dates);
            if nnz(inx)>0
                s(inx) = "NaD";
            end

            inx = freq==0;
            if nnz(inx)>0
                s(inx) = compose("%g", dates(inx));
            end

            inx = freq==365;
            if nnz(inx)>0
                s(inx) = datestr(dates(inx), "yyyy-mmm-dd");
            end

            inx = freq==1;
            if nnz(inx)>0
                s(inx) = compose( ...
                    "%g%s", [reshape(year(inx), [ ], 1), reshape(freqLetter(inx), [ ], 1)] ...
                );
            end

            inx = freq==12 | freq==52;
            if nnz(inx)>0
                s(inx) = compose( ...
                    "%g%s%02g", [reshape(year(inx), [ ], 1), reshape(freqLetter(inx), [ ], 1), reshape(per(inx), [ ], 1)] ...
                );
            end

            inx = freq==2 | freq==4;
            if nnz(inx)>0
                s(inx) = compose( ...
                    "%g%s%g", [reshape(year(inx), [ ], 1), reshape(freqLetter(inx), [ ], 1), reshape(per(inx), [ ], 1)] ...
                );
            end
        end%




        function output = roundEqual(this, that)
            output = round(100*this)==round(100*that);
        end%




        function output = roundColon(from, varargin)
            from = double(from);
            convertToDateWrapper = isa(from, 'DateWrapper');
            if nargin==2
                to = double(varargin{1});
                step = 1;
            elseif nargin==3
                step = double(varargin{1});
                to = double(varargin{2});
            end
            output = (round(100*from) : round(100*step) : round(100*to))/100;
            if convertToDateWrapper
                output = DateWrapper(output);
            end
        end%




        function output = roundPlus(this, that)
            convertToDateWrapper = isa(this, 'DateWrapper') || isa(that, 'DateWrapper');
            this = double(this);
            that = double(that);
            output = (round(100*this) + round(100*that))/100;
            if convertToDateWrapper
                output = DateWrapper(output);
            end
        end%
    end
end

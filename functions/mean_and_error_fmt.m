function [ str_val ] = mean_and_error_fmt( vec, varargin  )
% calculate mean and error for the vector of direct measurements
% and format it into string  like 10.7±0.7
% расчет погрешностей прямых измерений
% параметры
%    vec - вектор измерений
% второй необязательный параметр
%    signigicance_level-уровень значимости(0.68 по умолчанию, 0.95, 0.997 и т.п.) 
% третий необязательный параметр
%    precision - разряд для округления (0.1 по умолчанию, может быть 0.01, 10, 100)
narginchk(1, 3);
if ~isvector(vec)
    error('vec must be a vector');
end;
if (nargin<2)
    significance_level=0.68;
else
    significance_level=varargin{1};
end
if (nargin<3)
    significant_digits=0.1;
else
    if (varargin{2}>0)
        significant_digits=varargin{2};
    else
        error('wrong significant_digits parameter');
    end;
end

[m,e]=mean_and_error(vec,significance_level);
sd1=round(log10(significant_digits));
if (sd1>0)
   formatt=sprintf('%%df ± %%df',sd1,sd1);
else
   d1=abs(sd1); 
   formatt=sprintf('%%0.%df ± %%0.%df',d1,d1);
end;

str_val=sprintf(formatt,m,e);
end


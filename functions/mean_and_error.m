function [ mean_val, err_val] = mean_and_error( vec, varargin )
% calculate mean and error of direct measurements
% расчет погрешностей прямых измерений
% параметры
%    vec - вектор измерений
% второй необязательный параметр
%    signigicance_level-уровень значимости(0.68 по умолчанию, 0.95, 0.997 и т.п.) 
narginchk(1, 2);
if ~isvector(vec)
    error('vec must be a vector');
end;
if (nargin==1)
    significance_level=0.68;
else
    significance_level=varargin{1};
end
mean_val=mean(vec);
err_val=tinv(1-(1-significance_level)/2,length(vec)-1)*std(vec)/sqrt(length(vec));

end


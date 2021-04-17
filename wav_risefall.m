function [y w] = wav_risefall(x,rf,Fs,method)

% [y w] = wav_risefall(x,rf,Fs,method)
%
% Obligatory inputs:
%	x - sound vector, mono
%
% Optional inputs (defaults):
%	rf     = [0.01 0.01];   % rise and fall time in s
%	Fs     = 44100;         % sampling frequency of x
%	method = 'tukey',       % 'tukey', 'lin'
%
% Output:
%	y - sound vector including rise and fall times
%	w - vector of the window applied
%
% Description: The program applies rise and fall times to a sound vector.
%
% ---------
%
%    Copyright (C) 2012, B. Herrmann
%    This program is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
% -------------------------------------------------------------------------
% B. Herrmann, Email: herrmann.b@gmail.com, 2012-01-08

% check inputs
y = [];
if nargin < 1 || isempty(x), fprintf('Error: x needs to be defined!\n'),return; end
if ~isvector(x), fprintf('Error: x needs to be a vector!\n'), return; end
if nargin < 2 || isempty(rf), rf = [0.01 0.01]; end
if nargin < 3 || isempty(Fs), Fs = 44100; end
if nargin < 4 || isempty(method), method = 'tukey'; end
if max(size(rf)) == 1, rf(2) = rf(1); end
if ~ismember(method,{'tukey' 'lin'})
	fprintf('Info: Unrecognized method! method = ''tukey'' is used instead\n');
	method = 'tukey';
end

% have x as colum vector
x = x(:);
w = ones(length(x),1);

% get samples for rise and fall times
nsamp_rise = round(rf(1)*Fs);
nsamp_fall = round(rf(2)*Fs);

% get rise and fall vectors
if strcmp(method, 'lin')
	rise = linspace(0,1,nsamp_rise)';
	fall = linspace(1,0,nsamp_fall)';
elseif strcmp(method, 'tukey')
	rf_window = tukeywin(nsamp_rise*2, Fs);
	rise = rf_window(1:nsamp_rise);
	rf_window = tukeywin(nsamp_fall*2, Fs);
	fall = rf_window(end-nsamp_fall+1:end);
end

% applied rise and fall vectors to x
x(1:nsamp_rise) = x(1:nsamp_rise).*rise;
x(end-nsamp_fall+1:end) = x(end-nsamp_fall+1:end).*fall;
y = x;

% get the applied window
w(1:nsamp_rise) = w(1:nsamp_rise).*rise;
w(end-nsamp_fall+1:end) = w(end-nsamp_fall+1:end).*fall;

return;

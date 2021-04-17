function stim = mmn_random_control(num_stim, num_trains, trgs)

% stim = mmn_random_control(num_stim, num_trains, trgs)
% 
% Obligatory inputs:
%	num_stim   - number of stimuli in a train
%	num_trains - number of trains
%
% Optional inputs (defaults):
%	trgs = 1:num_stim;
%
% Output:
%	stim - vector of randomized triggers
%
% Description:
%	This program provides a MMN randomized control block according to
%	Jacobsen and Schr?ger (2001, Psychophysiology). No trg code occurs
%	twice in succession
% -----------------------------------------------------------------------


% Load some defaults if appropriate
% ---------------------------------
nInputs = nargin;
if nInputs < 1, fprintf('Error: num_stim and num_trains need to be defined!\n'); return; end
if nInputs < 2, fprintf('Error: num_trains need to be defined!\n'); return; end
if nInputs < 3, trgs = 1:num_stim; end
if size(trgs,2) > size(trgs,1), trgs = trgs'; end
if length(trgs) ~= num_stim, fprintf('Error: num_stim and number of triggers do not match!\n'); return; end

stim = [];
for j = 1 : num_trains
	no_doubles = 0;
	while no_doubles == 0
		ix = randperm(num_stim)';
		tmpTrgs = trgs(ix);
		if isempty(stim) || stim(end) ~= tmpTrgs(1);
			no_doubles = 1;
			stim = [stim; tmpTrgs];
		end
	end
end

return;

function [G_list, attackNames, meta] = makeWaferTLPNBenchmark_9_8()
% makeWaferTLPNBenchmark_9_8
% Small wafer processing TLPN benchmark with |P|=9 and |T|=8.
%
% This is exactly the n=2 case of makeParamWaferTLPNBenchmark.
%
% Observable labels:
%   t1 -> a
%   t4 -> b
%   t7 -> c
%   t8 -> d

[G_list, attackNames, meta] = makeParamWaferTLPNBenchmark(2);

end
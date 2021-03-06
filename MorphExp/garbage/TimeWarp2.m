function y=TimeWarp2(s1,s2,path1,path2,lambda)
% Given two signals (s1 and s2), and two warping paths 
% (path1 and path2) as comes out of the dtw program.
% Find the signal that is a fractional lambda between s1 and s2.

[d1 l1] = size(s1);
[d2 l2] = size(s2);

if d1 ~= d2
	fprintf('TimeWarp Error: Depth of two data arrays is not equal.\n')
	return
end

if l1 ~= length(path1)
	fprintf('TimeWarp Error: Path 1 and signal 1 are not the same length.\n');
	return;
end

if l2 ~= length(path2)
	fprintf('TimeWarp Error: Path 2 and signal 2 are not the same length.\n');
	return;
end

l = round((l2-l1)*lambda+l1);
y = zeros(1,l);

t = lambda*(path1-(1:l1)) + (1:l1);
for index=1:l
	[m lineno] = min((t-index).^2);
	y(index) = s1(lineno)*(1-lambda);
end

t = (1-lambda)*(path2-(1:l1)) + (1:l1);
for index=1:l
	[m lineno] = min((t-index).^2);
	y(index) = y(index) + s2(lineno)*lambda;
end


% Now (optionally) plot the result.  
if 0
	m = max(l1, l2);
	
	subplot(3,1,1);
	if (d1 ~= 1)
		imagesc(s1);
		axis([1 m 1 d1]);
	else
		plot(s1)
		axis([1 m min(s1) max(s1)]);
	end
	title('Signal 1');

	subplot(3,1,2);
	if (d1 ~= 1)
		imagesc(y);
		axis([1 m 1 d1]);
	else
		plot(y);
		axis([1 m min(y) max(y)]);
	end
	title('Lambda between s1 and s2');
	
	subplot(3,1,3);
	if (d1 ~= 1)
		imagesc(s2);
		axis([1 m 1 d1]);
	else
		plot(s2);
		axis([1 m min(s2) max(s2)]);
	end
	title('Signal 2');
	drawnow;
end


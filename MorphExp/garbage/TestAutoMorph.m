lambdaList=[0:0.25:1];

if exist('morning') ~= 1
	mc = ReadSound('MorningCorner.aiff');
	morning = mc(1:16000);
	corner = mc(16001:length(mc));
	clear mc;
	sr=22050;
end


if exist('morningpitch') ~= 1
	cornerpitch=pitchsnake(corner,sr,sr/64,100,300);
	cornerwidth = length(cornerpitch);
	morningpitch=pitchsnake(morning,sr,sr/64,100,300);
	morningwidth = length(morningpitch);
end

if exist('morningmfcc') ~= 1
	morningmfcc = mfcc2(morning, sr, sr/64);
	morningmfcc = morningmfcc(:,1:morningwidth);
	cornermfcc = mfcc2(corner, sr, sr/64);
	cornermfcc = cornermfcc(:,1:cornerwidth);
end

if exist('morningspect') ~= 1
	morningspect = ppspect(morning,256);
	morningspect = morningspect(:,1:morningwidth);
	cornerspect = ppspect(corner,256);
	cornerspect = cornerspect(:,1:cornerwidth);
end

if exist('path1') ~= 1
	[error,path1,path2] = dtw(morningmfcc, cornermfcc);
end


% Now (optionally) plot the result.  
if 0
	m = max(size(morningspect,2), size(cornerspect,2));
	d1 = 257;
	
	subplot(3,1,1);
		imagesc(morningspect);
		axis([1 m 1 d1]);
	title('Signal 1');

	s15 = zeros(size(morningspect));
	for i=1:size(morningspect,2)
		s15(:,i) = cornerspect(:,path1(i));
	end
	subplot(3,1,2);
		imagesc(s15);
		axis([1 m 1 d1]);
	title('Signal 2 warped to be like Signal 1');
	
	subplot(3,1,3);
		imagesc(cornerspect);
		axis([1 m 1 d1]);
	title('Signal 2');
end

% OK, now we have the two spectrograms: morningspect and cornerspect
% We have warping paths: path1 and path2
% We have pitch values: morningpitch and cornerpitch
specLength = size(cornerspect,1);
f=(1:specLength)'-1;
f0 = flipud(morningspect);
f1 = flipud(cornerspect);
final=[];
for lambda=lambdaList
	[index1,index2]=TimeWarpPaths(path1,path2,lambda);
	specLength = length(index1);
	image = zeros(size(cornerspect,1),specLength);
	alpha = cornerpitch(index2)./morningpitch(index1);
	
	for i=1:specLength
		i0=round(f/(1 + lambda*(alpha(i) - 1))) + 1;
		i0=max(1,min(specLength,i0));
		i1=alpha(i)*(i0-1) + 1;
		i1=max(1,min(specLength,i1));
		image(:,i) = lambda*f1(i1,index2(i)) + (1-lambda)*f0(i0,index1(i));
	end
	image=flipud(image);
	final=[final image];
end		


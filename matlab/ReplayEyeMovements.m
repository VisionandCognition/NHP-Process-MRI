%% replay eye movement
fid=uigetdir(pwd,'Select model folder');
x=dlmread([fid '/EyeX.txt']);
y=dlmread([fid '/EyeY.txt']);
d=dlmread([fid '/EyeD.txt']);
t=x(:,1);
xyd=[x(:,3) y(:,3) d(:,3)];

figure;
subplot(3,1,1); plot(t,xyd(:,1),'k');title('X');
subplot(3,1,2); plot(t,xyd(:,2),'k');title('Y');
subplot(3,1,3); plot(t,xyd(:,3),'k');title('D');

%% animate
f=figure;
i=1;j=0;
ns=10;np=5;
% every 50 samples
while i<size(xyd,1)-(ns-1) && ishandle(f)
    viscircles([0,0],75,'EdgeColor','r');
    hold on;
    j=j+1;
    p(j)=plot(xyd(i:i+(ns-1),1),xyd(i:i+(ns-1),2),'ko','MarkerSize',3);
    axis([-1600 1600 -1200 1200])
    i=i+ns;
    pause(0.001)
    if j==np
        delete(p(1));
        p(1:np-1)=p(2:np);
        j=j-1;
    end
end
clear all;
close all;
tt=load('./test/rec/t.mat');
t=tt.data;
tt=load('./test/rec/rec_1.mat');
R1=tt.data;
tt=load('./test/rec/rec_2.mat');
R2=tt.data;
figure;
for i=1:size(R1,2)
    subplot(1,size(R1,2),i)
    plot(R1(:,i),t);
    set(gca,'ydir','reverse');
    xlabel('v1 [m/s]');
    ylabel('t [m/s]');
end
figure;
for i=1:size(R2,2)
    subplot(1,size(R2,2),i)
    plot(R2(:,i),t);
    set(gca,'ydir','reverse');
    xlabel('v2 [m/s]');
    ylabel('t [m/s]');
end
function [x1, x2, z] = double_well3(d, b)

close all;

ytop = b*1.2;
xright = d + sqrt(d^2 - d + ytop);
xleft = -xright;

meshpts = 200;
[x1, x2] = meshgrid(linspace(xleft, xright, meshpts));

f = @(x,y) b/(d^4) * (x.^2 + y.^2 - d^2).^2;

z =  f(x1, x2);
contourf(x1,x2, z, linspace(0, ytop, 20));
xlim([xleft xright]);
ylim([xleft xright]);
zlim([0 ytop]);
pbaspect([1 1 1]);

end
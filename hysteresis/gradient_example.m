clearvars
clc

lims = [-2 2];
r = 1;
circ = @(x,y) x.^2 + y.^2 - r;

fimplicit(circ, lims);
pbaspect([1 1 1]);

gradc_x = @(x,y) 2*x;

[X,Y] = meshgrid(linspace(lims(1), lims(2), 100));
hold on

quiver(X, Y, gradc_x(X), gradc_x(Y));
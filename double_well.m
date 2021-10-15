function double_well(d, b)

close all;

ytop = b*2;
xright = d + sqrt(d^2 - d + ytop);
xleft = -xright;


x = linspace(xleft, xright, 200);

y = b*( (x-d).^2 .* (x+d).^2 ) ./ d^4;

plot(x,y);
xlim([xleft xright]);
ylim([0 ytop]);
end
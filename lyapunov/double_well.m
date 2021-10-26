function double_well(d, b)

close all;

ytop = b*2;
xright = d + sqrt(d^2 - d + ytop);
xleft = -xright;


x = linspace(xleft, xright, 200);

y = b*( (x-d).^2 .* (x+d).^2 ) ./ d^4;
f = @(x) b * (x.^4 - 2*x.^2*d^2 + d^4) ./ d^4;

plot(x,y);
hold on 
plot(x, f(x));
xlim([xleft xright]);
ylim([0 ytop]);
end
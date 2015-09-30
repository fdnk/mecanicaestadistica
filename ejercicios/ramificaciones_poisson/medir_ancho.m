close all;
clear all;

p=1:-0.05:0.2;
intentos = 1000;

anchos = zeros(numel(p),intentos);
parfor i=1:numel(p)
  anchos(i,:) = zeros(intentos,1);
  for k=1:intentos
    stats = realizar_experimento(p(i), 0);
    if stats.ok
      anchos(i,k) = stats.ancho;
    else
      anchos(i,k) = Inf;
    endif
  endfor
  fprintf('Terminado p=%.3g, i=%d\n',p(i), i);
endparfor
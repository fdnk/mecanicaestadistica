function plot_fallas()
% Ploteo las fallas como puntos

% Obtengo todas las fallas
  fallas = getNextFail();

  % La semirrecta negativa (sin cero)
  semirrecta=fallas{1};
  for k=1:numel(semirrecta)
    puntos = semirrecta{k};
    plot(-k*ones(size(puntos)), -puntos, 'k.', 'markersize', 5);
  endfor
  semirrecta=fallas{2};
  for k=1:numel(semirrecta)
    puntos = semirrecta{k};
    plot((k-1)*ones(size(puntos)), -puntos, 'k.', 'markersize', 5);
  endfor
endfunction
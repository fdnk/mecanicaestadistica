function anotar_ramificar(pos, init)
% anotar_ramificar(pos, init) dibuja un tramito que termina en circulo
  %fprintf('Ramifica: k=%d, t=%.3g\n', pos(2), pos(1));
  
  if numel(pos) ~=2 || numel(init)~=2
    disp('Todo mal');
    disp(pos);
    disp(init);
  endif
    
  
  plot(pos(2), -pos(1), 'bo', 'markersize', 10, 'linewidth', 3); % Un circulito
  
  trayecto = [pos; init];
  plot(trayecto(:,2), -trayecto(:,1));
end
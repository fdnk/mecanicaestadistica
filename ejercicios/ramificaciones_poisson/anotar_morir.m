function anotar_morir(pos, init)
% anotar_morir(pos, init) dibuja un tramito que termina en cruz
  %fprintf('Muere: k=%d, t=%.3g\n', pos(2), pos(1));
  
  if numel(pos) ~=2 || numel(init)~=2
    disp('Todo mal');
    disp(pos);
    disp(init);
  endif
    
  
  plot(pos(2), -pos(1), 'rx', 'markersize', 15, 'linewidth', 3); % La crucecita
  
  trayecto = [pos; init];
  plot(trayecto(:,2), -trayecto(:,1));
  
end
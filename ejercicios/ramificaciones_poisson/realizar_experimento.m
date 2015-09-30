function [stats, h] = realizar_experimento(p, file, seed)
  if nargin==3
    rand("state", v);
  endif
  
  assert(~getNextFail(0,0,'clear')); % Limpio la matriz de fallas
  
  TASK_MAX = 1000;
  
  HACER_PLOTS=true;
  GUARDAR_PLOTS=false;
  if nargin >= 2
    if isequal(file, 0)
      HACER_PLOTS=false;
    else
      GUARDAR_PLOTS=true;
      graphics_toolkit("gnuplot"); % Con fltk no puedo guardar plots invisibles
    endif
  endif
  
  %% Programa propiamente dicho
  h=[];
  work = {[0,0,0]}; %[to, z, z_padre]
  global task;
  task = 0;
  
  if HACER_PLOTS
    h=figure;
    if GUARDAR_PLOTS
      set(h, 'visible', 'off');
    endif
    
    hold on;
    title(sprintf('p=%.3g',p));
  endif
  
  hojas = {};
  visitados_pos ={};
  visitados_neg ={};
  stats.ok = true;
  while (task < numel(work))
    if task >= TASK_MAX
      % No hay final
      stats.ok = false;
      break;
    endif
    task = task + 1;
    data = work{task};
    pos_inicial = data(1:2);
    z_actual = data(2);
    pos_padre = data([1 3]);
    ti = pos_inicial(1);
    
    %% ¿Ya estuve acá?
    if z_actual >= 0
      z = z_actual+1;
      if numel(visitados_pos) < z
        visitados_pos{z} = [];
      endif
      %if ~isempty(visitados_pos{z})
        if ~all(visitados_pos{z}-ti)
          % Si, ya estuve
          continue
        endif
      %endif
      % No estuve, anoto que pasé por acá
      visitados_pos{z} = [visitados_pos{z}, ti];
    else
      z = -z_actual;
      if numel(visitados_neg) < z
        visitados_neg{z} = [];
      endif
      %if ~isempty(visitados_neg{z})
        if ~all(visitados_neg{z}-ti)
          % Si, ya estuve
          continue
        endif
      %endif
      % No estuve, anoto que pasé por acá
      visitados_neg{z} = [visitados_neg{z}, ti];
    endif
    
    
    
    % Avanzo hasta encontrar una falla
    tx = getNextFail( pos_inicial(1), pos_inicial(2) );
    
    pos_falla = [tx, z_actual];
    if rand < p
      % muero aca
      if HACER_PLOTS
        anotar_morir(pos_falla, pos_padre);
      endif
      hojas{numel(hojas)+1} = [pos_falla, pos_padre(2)];
     else
      % me ramifico
      if HACER_PLOTS
        anotar_ramificar(pos_falla, pos_padre);
      endif
      
      % Agrego las ramas a la cola
      % A la derecha
      work{numel(work)+1} = [tx, z_actual+1, z_actual];
      % A la izquierda
      work{numel(work)+1} = [tx, z_actual-1, z_actual];
     endif
  endwhile

  if HACER_PLOTS
    %% Ploteo el inicio
    plot(0,0,'b^', 'markersize', 10, 'linewidth', 3);

    %% Ploteo las fallas
    plot_fallas();
  endif
  

  %% Estadísticas
  nodos_medios = reshape(cell2mat(work), 3, numel(work))'; % [to, z, z_padre]
  hojas = reshape(cell2mat(hojas), 3, numel(hojas))'; % [to, z, z_padre]
  nodos = [nodos_medios; hojas];
  tmax = max(nodos(:,1));
  nmax = max(nodos(:,2));
  nmin = min(nodos(:,2));
  ancho = nmax - nmin;

  stats.tmax = tmax;
  stats.ancho = ancho;
  stats.nlim = [nmin, nmax];
  stats.tasks = task;
  
  if HACER_PLOTS
    if nmin~=nmax
      axis([nmin nmax -tmax 0]);
    endif
    if GUARDAR_PLOTS
      print(h, file, '-depsc2');
    endif
  endif


endfunction

clear all;
close all;

function anotar_morir(pos, init)
% anotar_morir(pos, init) dibuja un tramito que termina en cruz
  fprintf('Muere: k=%d, t=%.3g\n', pos(2), pos(1));
  plot(pos(2), -pos(1), 'rx'); % El circulito
  
  trayecto = [pos; init];
  plot(trayecto(:,2), -trayecto(:,1));
  
end
function anotar_ramificar(pos, init)
% anotar_ramificar(pos, init) dibuja un tramito que termina en circulo
  fprintf('Ramifica: k=%d, t=%.3g\n', pos(2), pos(1));
  plot(pos(2), -pos(1), 'bo');
  
  trayecto = [pos; init];
  plot(trayecto(:,2), -trayecto(:,1));
end


function hilo = crearHilo(To)
% hilo = crearHilo(To) crea un vector lleno de fallas con tasa lambda
  Ti=0;
  lambda = 30;
  C = poissrnd(lambda); % Cantidades de fallas
  
  hilo = sort(rand(C,1)*(To-Ti)+Ti);
end

function tx = getNextFail(to, z)
% tx = getNextFail(to, z)  La papa: Busca en el hilo de enteros z, la próxima
%falla posterior a to. La primera vez que es llamada crea los hilos con fallas.
  
  %% Las variables que uso para almacenar los hilos con fallas
  persistent Mpos;
  persistent Mneg;
  persistent Tmax;
  if isempty(Tmax)
    % Defino todo la primera vez
    disp('Creando realización nueva de fallas');
    Mpos={};
    Mneg={};
    Tmax=100;    
  endif
  
  if to>Tmax
    error("No implementado, agrandar todo.")
  endif
  
  if z >= 0
    z=z+1; % Porque mis indices empiezan en 1
    if numel(Mpos) < z
      Mpos{z} = [];
    endif
    if isempty(Mpos{z})
      % No tengo hilo, lo creo
      Mpos{z} = crearHilo(Tmax);
    endif
    
    % Busco el proximo
    lista = Mpos{z}-to;
    tx = min(lista(lista>0))+to;
  else % z<0
    z=-z;
    if numel(Mneg) < z
      Mneg{z} = [];
    endif
    if isempty(Mneg{z})
      % No tengo hilo, lo creo
      Mneg{z} = crearHilo(Tmax);
    endif
    
    % Busco el proximo
    lista = Mneg{z}-to;
    tx = min(lista(lista>0))+to;
  end
  %Mpos
  %Mneg
end



%% Programa propiamente dicho
work = {[0,0]}; %[to, z]
task = 0;

p = 0.6;
figure;
hold on;

while (task < numel(work))
  task = task + 1;
  pos_inicial = work{task};
  
  % Avanzo hasta encontrar una falla
  tx = getNextFail( pos_inicial(1), pos_inicial(2) );
  pos_falla = pos_inicial + [tx, 0];
  
  if rand < p
    % muero aca
    anotar_morir(pos_falla, pos_inicial);
   else
    % me ramifico
    
    % A la derecha
    pos_actual = pos_falla+[0,1];
    anotar_ramificar(pos_actual, pos_inicial);
    work{numel(work)+1} = pos_actual;
    
    % A la izquierda
    pos_actual = pos_falla+[0,-1];
    anotar_ramificar(pos_actual, pos_inicial);
    work{numel(work)+1} = pos_actual;
   endif
endwhile

axis(axis+[-1 1 1 1]); %lindo


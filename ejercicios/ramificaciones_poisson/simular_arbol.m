clear all;
close all;

function anotar_morir(pos, init)
% anotar_morir(pos, init) dibuja un tramito que termina en cruz
  fprintf('Muere: k=%d, t=%.3g\n', pos(2), pos(1));
  plot(pos(2), -pos(1), 'rx', 'markersize', 10); % La crucecita
  
  trayecto = [pos; init];
  plot(trayecto(:,2), -trayecto(:,1));
  
end
function anotar_ramificar(pos, init)
% anotar_ramificar(pos, init) dibuja un tramito que termina en circulo
  fprintf('Ramifica: k=%d, t=%.3g\n', pos(2), pos(1));
  plot(pos(2), -pos(1), 'bo', 'markersize', 7); % Un circulito
  
  trayecto = [pos; init];
  plot(trayecto(:,2), -trayecto(:,1));
end


function hilo = crearHilo(ti, tf)
% hilo = crearHilo(ti, tf) crea un vector lleno de fallas con tasa lambda
  lambda = 30;  % La media
  T=tf-ti;
  assert(T>0);
  C = poissrnd(lambda*T); % Cantidades de fallas en T segundos
  
  hilo = sort(ti+rand(C,1)*T); % Reparto esas fallas uniformemente
end

function tx = getNextFail(to, z)
% tx = getNextFail(to, z)  La papa: Busca en el hilo de enteros z, la próxima
%falla posterior a to. La primera vez que es llamada crea los hilos con fallas.
  %% Las variables que uso para almacenar los hilos con fallas
  persistent Mpos;
  persistent Mneg;
  persistent Tmax;
  
  if nargin == 0
    % Si me invocan sin parámetros, devuelvo todas las fallas
    tx={Mneg, Mpos};
    return;
  endif
  
  if isempty(Tmax)
    % Defino todo la primera vez
    disp('Creando realización nueva de fallas');
    Mpos={};
    Mneg={};
    Tmax=1;
  endif
  
  if (to>Tmax)
    % Agrego otros cachos
    N=ceil(to/Tmax)-1; % Necesito esta cantidad de frames
    newTmax = Tmax + N*1;
    fprintf('Agrego un frame: ti=%.3g  tf=%.3g\n', Tmax, newTmax);
    
    for k=1:numel(Mpos)
      Mpos{k} = [Mpos{k}; crearHilo(Tmax, newTmax)];
    endfor
    for k=1:numel(Mneg)
      Mneg{k} = [Mneg{k}; crearHilo(Tmax, newTmax)];
    endfor
    
    Tmax = newTmax;
  endif
  
  if z >= 0
    z=z+1; % Porque mis indices empiezan en 1
    if numel(Mpos) < z
      Mpos{z} = [];
    endif
    if isempty(Mpos{z})
      % No tengo hilo, lo creo
      Mpos{z} = crearHilo(0, Tmax);
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
      Mneg{z} = crearHilo(0, Tmax);
    endif
    
    % Busco el proximo
    lista = Mneg{z}-to;
    tx = min(lista(lista>0))+to;
  end
  %Mpos
  %Mneg
end



%% Programa propiamente dicho
work = {[0,0,0]}; %[to, z, z_padre]
task = 0;

p = 0.6;
figure;
hold on;

hojas = {};

while (task < numel(work))
  task = task + 1;
  data = work{task};
  
  pos_inicial = data(1:2);
  z_actual = data(2);
  pos_padre = data([1 3]);
  % Avanzo hasta encontrar una falla
  tx = getNextFail( pos_inicial(1), pos_inicial(2) );
  
  pos_falla = [tx, z_actual];
  if rand < p
    % muero aca
    anotar_morir(pos_falla, pos_padre);
    hojas{numel(hojas)+1} = [pos_falla, pos_padre(2)];
   else
    % me ramifico
    anotar_ramificar(pos_falla, pos_padre);
    
    % Agrego las ramas a la cola
    % A la derecha
    work{numel(work)+1} = [tx, z_actual+1, z_actual];
    % A la izquierda
    work{numel(work)+1} = [tx, z_actual-1, z_actual];
   endif
endwhile

%% Ploteo el inicio
plot(0,0,'b^', 'markersize', 10);

%% Ploteo las fallas
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

%% Estadísticas
nodos_medios = reshape(cell2mat(work), 3, numel(work))'; % [to, z, z_padre]
hojas = reshape(cell2mat(hojas), 3, numel(hojas))'; % [to, z, z_padre]
nodos = [nodos_medios; hojas];
tmax = max(nodos(:,1));
ancho = max(nodos(:,2)) - min(nodos(:,2));

fprintf('Profundidad: %.3g seg. Ancho: %d\n',tmax, ancho);


function tx = getNextFail(to, z, param)
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
  elseif nargin == 3
    if strcmp(param, 'clear')
      %disp('limpiando...');
      Tmax=[]; % Así la proxima se crea todo de nuevo.
      tx = 0;
      return;
    endif
  endif
  
  if isempty(Tmax)
    % Defino todo la primera vez
    %disp('Creando realización nueva de fallas');
    Mpos={};
    Mneg={};
    Tmax=1;
  endif
  
  if (to>=Tmax)
    % Agrego otros cachos
    N=ceil(to/Tmax + eps)-1; % Necesito esta cantidad de frames
    newTmax = Tmax + N*1;
    %fprintf('Agrego un frame: ti=%.3g  tf=%.3g\n', Tmax, newTmax);
    
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
  
  if isempty(tx)
    % Me caí del frame y no econtre nada. Debo agregar
    tx = getNextFail(Tmax,z);
  endif
end
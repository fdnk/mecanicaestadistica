function hilo = crearHilo(ti, tf)
% hilo = crearHilo(ti, tf) crea un vector lleno de fallas con tasa lambda
  lambda = 1;  % La media: 30 fallas por frame
  T=tf-ti;
  assert(T>0);
  C = poissrnd(lambda*T); % Cantidades de fallas en T segundos
  
  hilo = sort(ti+rand(C,1)*T); % Reparto esas fallas uniformemente
end
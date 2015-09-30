close all;
clear all;

p=0.1:0.01:1;
intentos = 1000;

anchos = zeros(numel(p),intentos);
largos = zeros(numel(p),intentos);
parfor i=1:numel(p)
  anchos(i,:) = zeros(intentos,1);
  for k=1:intentos
    stats = realizar_experimento(p(i), 0);
    if stats.ok
      anchos(i,k) = stats.ancho;
      largos(i,k) = stats.tmax;
    else
      anchos(i,k) = Inf;
      largos(i,k) = Inf;
    endif
  endfor
endparfor

% Guardo mi valiosa informacion
t=time;
save('medias_ancho_largo.dat', 'anchos', 'largos', 't');

%% Calculos
% Ancho y largo medio
ancho_media = mean(anchos,2);
largo_media = mean(largos,2);

h1=figure;
bar(p,ancho_media);
ylabel('media anchos');
xlabel('p');

h2=figure;
bar(p,largo_media);
ylabel('media largos');
xlabel('p');

print(h1, 'ancho', '-depsc2');
print(h2, 'largo', '-depsc2');

% Probabilidad de no terminar nunca
h3=figure;
p_error = sum(anchos==Inf, 2)/numel(anchos(1,:));
xlabel('p');
ylabel('Prob. no convergencia');
print(h3, 'noconvergencia', '-depsc2');


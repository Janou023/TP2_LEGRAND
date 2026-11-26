s = SIGNAL;
col18 = s(:,18);
debut = find(col18 == 1);
fin = debut + 5120;
fenetrefermee = [debut fin];

col19 = s(:,19);
debut2 = find(col19 == 1);
fin2 = debut2 + 5120;
fenetreouvert = [debut2 fin2];

Fs = 512;
nb_blocs = min(size(fenetrefermee, 1), size(fenetreouvert, 1));
figure('Position', [100 100 1200 700]);

for i = 1:nb_blocs
    % --- Extraction et FFT : Fenêtre FERMÉE ---
    bloc1 = fenetrefermee(i,:);
    lignes1 = bloc1(1):1:bloc1(2);
    valeursbloc1 = s(lignes1,:);
    E1 = valeursbloc1(:,[1 2]);

    N = length(E1(:,2));
    fftE1 = abs(fft(E1(:,2) - mean(E1(:,2))) / N);
    fftE1 = fftE1(1:floor(N/2)+1);
    fftE1(2:end-1) = 2 * fftE1(2:end-1);
    f = Fs * (0:floor(N/2)) / N;

    % --- Extraction et FFT : Fenêtre OUVERTE ---
    bloc2 = fenetreouvert(i,:);
    lignes2 = bloc2(1):1:bloc2(2);
    valeursbloc2 = s(lignes2,:);
    E2 = valeursbloc2(:,[1 2]);

    N2 = length(E2(:,2));
    fftE2 = abs(fft(E2(:,2) - mean(E2(:,2))) / N2);
    fftE2 = fftE2(1:floor(N2/2)+1);
    fftE2(2:end-1) = 2 * fftE2(2:end-1);
    f2 = Fs * (0:floor(N2/2)) / N2;

    % --- Colonne de gauche : Signaux temporels superposés ---
    subplot(nb_blocs, 2, 2*i - 1);
    plot(E1(:,1), E1(:,2));
    hold on;
    plot(E2(:,1), E2(:,2));
    hold off;
    title(['Signal temporel - Bloc ' num2str(i)]);
    legend('Fermée', 'Ouverte');
    grid on;

    % --- Colonne de droite : FFT superposées ---
    subplot(nb_blocs, 2, 2*i);
    plot(f, fftE1);
    hold on;
    plot(f2, fftE2);
    hold off;
    xlim([8 12]);
    title(['FFT - Bloc ' num2str(i)]);
    legend('Fermée', 'Ouverte');
    grid on;
end

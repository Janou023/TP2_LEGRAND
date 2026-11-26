nb_sujets = 20;
colonnes = 2:17;
nb_col = length(colonnes);

% Tableaux pour stocker la moyenne de chaque sujet (20 lignes) par colonne (16 colonnes)
resultats_ouvert_toutes_col = zeros(nb_sujets, nb_col);
resultats_ferme_toutes_col = zeros(nb_sujets, nb_col);

for sujet = 1:nb_sujets
    nom_fichier = sprintf('subject_%02d.mat', sujet);
    load(nom_fichier);

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

    for idx_col = 1:nb_col
        col = colonnes(idx_col);

        % Remise à zéro des tableaux pour chaque colonne
        tableau_alpha_ferme = [];
        tableau_alpha_ouvert = [];

        for i = 1:nb_blocs
            % --- Extraction et FFT : Fenêtre FERMÉE ---
            bloc1 = fenetrefermee(i,:);
            lignes1 = bloc1(1):1:bloc1(2);
            valeursbloc1 = s(lignes1,:);
            E1 = valeursbloc1(:,[1 col]);

            N = length(E1(:,2));
            fftE1 = abs(fft(E1(:,2) - mean(E1(:,2))) / N);
            fftE1 = fftE1(1:floor(N/2)+1);
            fftE1(2:end-1) = 2 * fftE1(2:end-1);
            f = Fs * (0:floor(N/2)) / N;
            fftE1_extrait = fftE1((8<=f) & (f<=12));
            Somme_valeurs_E1 = sum(fftE1_extrait);
            tableau_alpha_ferme = [tableau_alpha_ferme Somme_valeurs_E1];

            % --- Extraction et FFT : Fenêtre OUVERTE ---
            bloc2 = fenetreouvert(i,:);
            lignes2 = bloc2(1):1:bloc2(2);
            valeursbloc2 = s(lignes2,:);
            E2 = valeursbloc2(:,[1 col]);

            N2 = length(E2(:,2));
            fftE2 = abs(fft(E2(:,2) - mean(E2(:,2))) / N2);
            fftE2 = fftE2(1:floor(N2/2)+1);
            fftE2(2:end-1) = 2 * fftE2(2:end-1);
            f2 = Fs * (0:floor(N2/2)) / N2;
            fftE2_extrait = fftE2((8<=f2) & (f2<=12));
            Somme_valeurs_E2 = sum(fftE2_extrait);
            tableau_alpha_ouvert = [tableau_alpha_ouvert Somme_valeurs_E2];
        end

        moyenne_alpha_ouvert = mean(tableau_alpha_ouvert);
        moyenne_alpha_ferme = mean(tableau_alpha_ferme);

        % Stockage pour ce sujet et cette colonne
        resultats_ouvert_toutes_col(sujet, idx_col) = moyenne_alpha_ouvert;
        resultats_ferme_toutes_col(sujet, idx_col) = moyenne_alpha_ferme;
    end
end

% Moyenne sur les 20 sujets pour chaque colonne (16 lignes x 2 colonnes)
moyennes_par_colonne = [mean(resultats_ferme_toutes_col, 1)' mean(resultats_ouvert_toutes_col, 1)'];

% Affichage tableau dans la console
tableau_final_colonnes = array2table([colonnes' moyennes_par_colonne], ...
    'VariableNames', {'Colonne', 'Yeux_Ouverts', 'Yeux_Fermes'})

% Affichage graphique comparatif pour les colonnes 2 à 17
figure;
graph  = bar(colonnes, moyennes_par_colonne);
xlabel('Numéro de colonne (électrode)');
ylabel('Moyenne bande alpha (8-12 Hz)');
title('Comparaison Yeux Ouverts vs Yeux Fermés (Colonnes 2 à 17)');
legend('Fermé', 'Ouvert');
xticks(colonnes);
grid on;
:- module(bot,
      [  get_moves/3
      ]).
	
:- dynamic score/1.

:- dynamic actionMaxScore/1.
	
:- dynamic strategie/1.	
	
% A few comments but all is explained in README of github

% get_moves signature
% get_moves(Moves, gamestate, board).

% Exemple of variable
% gamestate: [side, [captured pieces] ] (e.g. [silver, [ [0,1,rabbit,silver],[0,2,horse,silver] ]) 
% board: [[0,0,rabbit,silver],[0,1,rabbit,silver],[0,2,horse,silver],[0,3,rabbit,silver],[0,4,elephant,silver],[0,5,rabbit,silver],[0,6,rabbit,silver],[0,7,rabbit,silver],[1,0,camel,silver],[1,1,cat,silver],[1,2,rabbit,silver],[1,3,dog,silver],[1,4,rabbit,silver],[1,5,horse,silver],[1,6,dog,silver],[1,7,cat,silver],[2,7,rabbit,gold],[6,0,cat,gold],[6,1,horse,gold],[6,2,camel,gold],[6,3,elephant,gold],[6,4,rabbit,gold],[6,5,dog,gold],[6,6,rabbit,gold],[7,0,rabbit,gold],[7,1,rabbit,gold],[7,2,rabbit,gold],[7,3,cat,gold],[7,4,dog,gold],[7,5,rabbit,gold],[7,6,horse,gold],[7,7,rabbit,gold]]

% Call exemple:
% get_moves(Moves, [silver, []], [[0,0,rabbit,silver],[0,1,rabbit,silver],[0,2,horse,silver],[0,3,rabbit,silver],[0,4,elephant,silver],[0,5,rabbit,silver],[0,6,rabbit,silver],[0,7,rabbit,silver],[1,0,camel,silver],[1,1,cat,silver],[1,2,rabbit,silver],[1,3,dog,silver],[1,4,rabbit,silver],[1,5,horse,silver],[1,6,dog,silver],[1,7,cat,silver],[2,7,rabbit,gold],[6,0,cat,gold],[6,1,horse,gold],[6,2,camel,gold],[6,3,elephant,gold],[6,4,rabbit,gold],[6,5,dog,gold],[6,6,rabbit,gold],[7,0,rabbit,gold],[7,1,rabbit,gold],[7,2,rabbit,gold],[7,3,cat,gold],[7,4,dog,gold],[7,5,rabbit,gold],[7,6,horse,gold],[7,7,rabbit,gold]]).

% default call
%get_moves([[[1,0],[2,0]],[[0,0],[1,0]],[[0,1],[0,0]],[[0,0],[0,1]]], Gamestate, Board).

%get_moves(Moves, Gamestate, Board):- 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%					REMARQUE (POUR DEBUG):													%
% 			Pour afficher toute la solution d unification									%
%			(pas une juste une partie avec des ... ) 										%
%			(surtout pour le predicat "deplacer" ou "tout_deplacement_possible_silver")		%
%			On peut utiliser cette commande (à executer dans la console prolog) :			%
% set_prolog_flag(answer_write_options,[ quoted(true),portray(true),spacing(next_argument)]). %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% REPRESENTATIONS UTILISEES (exemples):
% 
%		MOUVEMENT :
%				[[Xdepart,Ydepart],[Xarrive,Yarrive]] --> [[0,0], [1,0]] 
%		MOUVEMENTS :
%				[[[0,0], [1,0]], [[0,0], [0,1]], [[5,5], [6,5]]]
%		COORDONNEE :
%				(0,0)
%		PION :	
%				[X,Y,typePion,joueur] --> [0,0,rabbit,silver] 
%		PLATEAU:
%				[[0,0,rabbit,silver],[0,1,rabbit,silver],[0,2,horse,silver],[0,3,rabbit,silver],[0,4,elephant,silver],[0,5,rabbit,silver],[0,6,rabbit,silver],[0,7,rabbit,silver],[1,0,camel,silver],[1,1,cat,silver],[1,2,rabbit,silver],[1,3,dog,silver],[1,4,rabbit,silver],[1,5,horse,silver],[1,6,dog,silver],[1,7,cat,silver],[2,7,rabbit,gold],[6,0,cat,gold],[6,1,horse,gold],[6,2,camel,gold],[6,3,elephant,gold],[6,4,rabbit,gold],[6,5,dog,gold],[6,6,rabbit,gold],[7,0,rabbit,gold],[7,1,rabbit,gold],[7,2,rabbit,gold],[7,3,cat,gold],[7,4,dog,gold],[7,5,rabbit,gold],[7,6,horse,gold],[7,7,rabbit,gold]]
%		ZONE VIDE (pas de pion) DU PLATEAU:
%				[X,Y,-1,-1] --> [5,5,-1,-1] 
%		POUSSER :
%				[[[XennemiDepart,YennemiDepart],[XennemiArrive,YennemiArrive]],[[XallieDepart,YallieDepart],[XallieArrive,YallieArrive]]]
%		TIRER :
%				[[[XallieDepart,YallieDepart],[XallieArrive,YallieArrive]],[[[XennemiDepart,YennemiDepart],[XennemiArrive,YennemiArrive]]]]		
%
%		LISTE ACTION AVEC SCORE :
%				[[SCORE1, ACTION1], [SCORE2, ACTION2]]			
%				EXEMPLE AVEC DEPLACEMENT :
%					[[20, [[1, 0], [2, 0]]], [15, [[1, 1], [2, 1]]], [-95, [[1, 2], [2, 2]]], [15, [[1, 3], [2, 3]]], [20, [[1, 4], [2, 4]]], [-95, [[1, 5], [2, 5]]], [20, [[1, 6], [2, 6]]]]
%				ACTION PASSER SON TOUR:
%					[SCORE]
%						par exemple : [0]
%				EXEMPLE AVEC ACTIONS POUSSER :
%					[[100, [[[2, 7], [2, 6]], [[1, 7], [2, 7]]]], [5, [[[2, 7], [3, 7]], [[1, 7], [2, 7]]]]].
%				EXEMPLE AVEC ACTIONS TIRER :
%					[[5, [[[3, 7], [3, 6]], [[2, 7], [3, 7]]]], [0, [[[3, 7], [4, 7]], [[2, 7], [3, 7]]]]]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	LISTE DES TESTS POUR UNE ACTION POUR CHAQUE STRATEGIE
%
%	
%		- score de depart deplacement: 0 			
%		- score de depart pousser: 0 
%		- score de depart tirer: 0 
%
%
%		STRATEGIE PAR DEFAUT :
%			DEPLACEMENT :
%				- Si un lapin va sur la ligne 7 : +1000 points
%				- Si un pion se déplace vers le bas : +5 points
% 				- Si un pion se freeze tout seul : -10 points
%				- Si un pion freeze un ennemi : +10 points
%				- Si un pion defreeze un ennemi : -10 points
%				- Si un pion se suicide : -100 points
% 				Actions suivantes : + ? points
%			POUSSER :
%				- Si un pion se suicide : -100 points
%				- Si un pion tue un ennemi : +100 points
%			TIRER :
%				- Si un pion se suicide : -100 points
%				- Si un pion tue un ennemi : +100 points
%
%
%		STRATEGIE DEFENSE :
%			(Se met en place si au minimum il y a un lapin adverse sur la ligne 2 (donc se déclenche quand il y a un lapin sur la ligne 1 ou 0) ou qu'il y a au minimum deux lapin sur la ligne 3).
%			DEPLACEMENT :
%				- Si un lapin va sur la ligne 7 : +1000 points
%				- Si un pion se déplace vers le haut : +5 points
% 				- Si un pion se freeze tout seul : -10 points
%				- Si un pion freeze un lapin ennemi : +20 points
%				- Si un pion freeze un ennemi (autre que lapin) : +10 points
%				- Si un pion defreeze un lapin ennemi : -20 points
%				- Si un pion defreeze un ennemi (autre que lapin) : -10 points
%				- Si un pion se suicide : -100 points
%				- Si un pion bloque un lapin ennemi (se met à coté de lui) : au dessus +15 points, sur les cotés +8 points
% 				- Si un pion debloque un lapin ennemi : si le pion allié etait au dessus -15 points, si le pion allié était sur les cotés -8 points
%				Actions suivantes : + ? points
%			POUSSER :
%				- Si un pion se suicide : -100 points
%				- Si un pion tue un lapin : +200 points
%				- Si un pion tue un ennemi (autre que lapin) : +100 points
%			TIRER :
%				- Si un pion se suicide : -100 points
%				- Si un pion tue un lapin : +200 points
%				- Si un pion tue un ennemi (autre que lapin) : +100 points
%
%
%	REMARQUE : les tests pour les actions en profondeur peuvent êtres différents mais en général ce sont des copies
%
%		Test spécifique profondeur :
%			- Si un déplacement est redondant : -10 points



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%			 Prédicats de bases						%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%									


%Concat du poly
concat([],L,L).
concat([T|Q],L,[T|R]):- concat(Q,L,R).

%element du poly
element(X, [X|_]).
element(X, [_|Q]):- element(X,Q).
%element([4,4,rabbit,silver], [[4,4,rabbit,silver],[5,4,dog,gold]]).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%			Prédicat d'appel principal 				%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%get_moves(Moves, Gamestate, Board) -> Moves doit s'unifier avec la liste des mouvements à effectuer.

get_moves(Moves, Gamestate, Board):- create_strategie(Board, Gamestate), recup_meilleurs_coups(Board, Gamestate, 4, 0, Moves).

%Exemple d'éxecutions :
%get_moves(Moves, [silver, []],[[0,0,rabbit,silver],[0,1,rabbit,silver],[0,2,horse,silver],[0,3,rabbit,silver],[0,4,elephant,silver],[0,5,rabbit,silver],[0,6,rabbit,silver],[0,7,rabbit,silver],[1,0,camel,silver],[1,1,cat,silver],[1,2,rabbit,silver],[1,3,dog,silver],[1,4,rabbit,silver],[1,5,horse,silver],[1,6,dog,silver],[1,7,cat,silver],[2,7,rabbit,gold],[6,0,cat,gold],[6,1,horse,gold],[6,2,camel,gold],[6,3,elephant,gold],[6,4,rabbit,gold],[6,5,dog,gold],[6,6,rabbit,gold],[7,0,rabbit,gold],[7,1,rabbit,gold],[7,2,rabbit,gold],[7,3,cat,gold],[7,4,dog,gold],[7,5,rabbit,gold],[7,6,horse,gold],[7,7,rabbit,gold]]).
%get_moves(Moves, [silver, []],[[0,0,rabbit,silver]]).
%get_moves(Moves,[silver, []], [[4,6,rabbit,silver]] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%			Stratégies								%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%create_strategie(Board,Gamestate) --> Crée un prédicat dynamique strategie(A). en fonction de l'état du Board (et possiblement du gamestate).

create_strategie(Board, _):- strategie_defense(Board, Board, Val), Val > 4,  retractall(strategie(_)), asserta(strategie(1)), !.
create_strategie(Board, Gamestate):- retractall(strategie(_)), asserta(strategie(0)).

%strategie_defense(Board, TempBoard, Val) --> parcours tous le board pour tester si il y a des lapins ennemi dangereux
% Val est une valeur seuil qui est déterminée par le prédicat

strategie_defense(_, [], 0).
strategie_defense(Board, [T|Q], Val):- lapin_dangereux(Board, T, R), strategie_defense(Board, Q, Rtemp), Val is R + Rtemp. 

%lapin_dangereux(Board,Pion, Valeur) --> Si un lapin est sur la ligne 0,1,2 ou 3 on unifie Valeur avec 7-Ligne.

lapin_dangereux(Board, [X,Y,rabbit,gold], R):- \+pion_freeze(Board, [X,Y,rabbit,gold]), X < 4, R is 7 - X.
lapin_dangereux(_,_, 0).

 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%			Boucle principale						%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 

%recup_meilleurs_coups(Board, Gamestate, I, K, Res) --> Boucle principale qui est conrtolée par I et K, I est la valeur initiale et se décrémente jusqu'à K.
%Res s'unifie avec la liste des meilleurs coups pour un tour.
 
recup_meilleurs_coups(Board, Gamestate, I, K, Res) :- 
	I > K, 
	action_tour_silver(Board, Gamestate, I, Consom, TmpRes),
	% write('ACTION RESTANTE :'),
	% write(I),
	% write('BOARD:'),
	% write(Board),
	update_board(Board, NvBoard, Gamestate, NvGamestate, TmpRes), 
	% write('NVBOARD:'),
	% write(NvBoard),
	NvI is I - Consom, 
	recup_meilleurs_coups(NvBoard, NvGamestate, NvI, K, TRes), 
	concat(TmpRes, TRes, Res), !.

	
recup_meilleurs_coups(_,_,I,K, []):- I =< K. 

%Exemple d'execution (appeler create_stratégie avant) :
%create_strategie([], []).
%recup_meilleurs_coups([[0,0,rabbit,silver],[0,1,rabbit,silver],[0,2,horse,silver],[0,3,rabbit,silver],[0,4,elephant,silver],[0,5,rabbit,silver],[0,6,rabbit,silver],[0,7,rabbit,silver],[1,0,camel,silver],[1,1,cat,silver],[1,2,rabbit,silver],[1,3,dog,silver],[1,4,rabbit,silver],[1,5,horse,silver],[1,6,dog,silver],[1,7,cat,silver],[2,7,rabbit,gold],[6,0,cat,gold],[6,1,horse,gold],[6,2,camel,gold],[6,3,elephant,gold],[6,4,rabbit,gold],[6,5,dog,gold],[6,6,rabbit,gold],[7,0,rabbit,gold],[7,1,rabbit,gold],[7,2,rabbit,gold],[7,3,cat,gold],[7,4,dog,gold],[7,5,rabbit,gold],[7,6,horse,gold],[7,7,rabbit,gold]],[silver, []],4,0,Res).
%recup_meilleurs_coups([[0,0,rabbit,silver]], [silver, []], 4, 0, Res).


%action_tour_silver(Board, Gamestate, Act, Consom, Res) --> Act est le nombre de ressources encore disponibles (0 <= Act <=4 ), Consom est le nombre de ressource que l'action consomme : 1 deplacement ou 2 pousser/tirer ou 4 si on passe son tour) .
%Res s'unifie avec la meilleur action pour une étape.

action_tour_silver(Board, Gamestate, Act, Consom, Res):-
	Act > 1,
	tout_deplacement_possible_silver(Board, Board, ResDep),
	% write('BOARD:'),
	% write(Board),
	% write('DEPLACEMENT:'),
	% write(ResDep),
	ActDep is Act-1,
	ActPou is Act-2,
	score_tout_deplacement_silver(Board, Gamestate, ResDep, ResDepScore, ActDep),	
	% write('DepScore'),
	% write(ResDepScore),
	tout_pousser_possible_silver(Board, Board, ResPou), 
	% write('Pousser:'),
	% write(ResPou),	
	score_tout_pousser_silver(Board, Gamestate, ResPou, ResPouScore, ActPou), 
	% write('PouScore:'),
	% write(ResPouScore),	
	tout_tirer_possible_silver(Board, Board, ResTir), 
	% write('Tirer:'),
	% write(ResTir),	
	score_tout_tirer_silver(Board, Gamestate, ResTir, ResTirScore, ActPou), 
	% write('TirScore:'),
	% write(ResTirScore),
	score_passer_son_tour(Act, ResDepScore, ResDepPassScore),
	meilleur_action(ResDepPassScore, Res1),
	% write(Res1),
	meilleur_action(ResPouScore, Res2),
	% write(Res2),
	meilleur_action(ResTirScore, Res3),
	% write(Res3),
	meilleur_action(Res1, Res2, Res3, Consom, Res), !.
	% write('4').
	
action_tour_silver(Board, Gamestate, 1, 1, Res):-
	tout_deplacement_possible_silver(Board, Board, ResDep), 
	% write('BOARD:'),
	% write(Board),
	% write('DEPLACEMENT:'),
	% write(ResDep),
	score_tout_deplacement_silver(Board, Gamestate, ResDep, ResDepScore, 0), 
	score_passer_son_tour(1, ResDepScore, ResDepPassScore),
	% write('DepScore'),
	% write(ResDepScore),
	meilleur_action(ResDepPassScore, [_|Res]).

%exemple d'execution ( create_strategie([], []). ) : 

%action_tour_silver([[0,0,rabbit,silver],[0,1,rabbit,silver],[0,2,horse,silver],[0,3,rabbit,silver],[0,4,elephant,silver],[0,5,rabbit,silver],[0,6,rabbit,silver],[0,7,rabbit,silver],[1,0,camel,silver],[1,1,cat,silver],[1,2,rabbit,silver],[1,3,dog,silver],[1,4,rabbit,silver],[1,5,horse,silver],[1,6,dog,silver],[1,7,cat,silver],[2,7,rabbit,gold],[6,0,cat,gold],[6,1,horse,gold],[6,2,camel,gold],[6,3,elephant,gold],[6,4,rabbit,gold],[6,5,dog,gold],[6,6,rabbit,gold],[7,0,rabbit,gold],[7,1,rabbit,gold],[7,2,rabbit,gold],[7,3,cat,gold],[7,4,dog,gold],[7,5,rabbit,gold],[7,6,horse,gold],[7,7,rabbit,gold]],[silver,[]], 4, Consom, Res). 
%action_tour_silver([[0,0,rabbit,silver]], [silver, []], 4, Consom, Res).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%			Predicats controle Score			%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%score_tout_deplacement_silver(Board,Gamestate, ResDep, ResDepScore, ActDep) --> ActDep correspond au nombre de ressources disponibles après avoir fait un déplacement
%ResDep est la liste de tous les déplacements immédiats pour un état du board.
%ResDepScore liste de tous les déplacements immédiats pour un état du board et pour chaque déplacement on associe un score.

score_tout_deplacement_silver(_, _, [], [], _):- !.
score_tout_deplacement_silver(Board, Gamestate, [T|Q], ResDepScore, Act):- score_deplacement_silver(Board, Gamestate, T, ResScore, Act), score_tout_deplacement_silver(Board, Gamestate, Q, TmpRes, Act), concat([[ResScore|[T]]], TmpRes, ResDepScore).

%EXEMPLE EXECUTION:
%score_tout_deplacement_silver([[0,0,rabbit,silver],[0,1,rabbit,silver],[0,2,horse,silver],[0,3,rabbit,silver],[0,4,elephant,silver],[0,5,rabbit,silver],[0,6,rabbit,silver],[0,7,rabbit,silver],[1,0,camel,silver],[1,1,cat,silver],[1,2,rabbit,silver],[1,3,dog,silver],[1,4,rabbit,silver],[1,5,horse,silver],[1,6,dog,silver],[1,7,cat,silver],[2,7,rabbit,gold],[6,0,cat,gold],[6,1,horse,gold],[6,2,camel,gold],[6,3,elephant,gold],[6,4,rabbit,gold],[6,5,dog,gold],[6,6,rabbit,gold],[7,0,rabbit,gold],[7,1,rabbit,gold],[7,2,rabbit,gold],[7,3,cat,gold],[7,4,dog,gold],[7,5,rabbit,gold],[7,6,horse,gold],[7,7,rabbit,gold]], [silver, []], [[[1, 0], [2, 0]], [[1, 1], [2, 1]], [[1, 2], [2, 2]], [[1, 3], [2, 3]], [[1, 4], [2, 4]], [[1, 5], [2, 5]], [[1, 6], [2, 6]]], ResDepScore, 3).


%score_tout_pousser_silver(Board, Gamestate, ResPou, ResPouScore, ActPou) --> ActPou correspond au nombre de ressources disponibles après avoir fait une action pousser
%ResPou est la liste de toutes les actions pousser immédiates pour un état du board.
%ResPouScore liste de toutes les actions pousser immédiates pour un état du board et pour chaque action on associe un score.

score_tout_pousser_silver(_, _, [], [], _):- !.
score_tout_pousser_silver(Board, Gamestate, [T|Q], ResDepScore, Act):- score_pousser_silver(Board, Gamestate, T, ResScore, Act), score_tout_pousser_silver(Board, Gamestate, Q, TmpRes, Act), concat([[ResScore|[T]]], TmpRes, ResDepScore).

%EXEMPLE EXECUTION: 
%score_tout_pousser_silver([[0,0,rabbit,silver],[0,1,rabbit,silver],[0,2,horse,silver],[0,3,rabbit,silver],[0,4,elephant,silver],[0,5,rabbit,silver],[0,6,rabbit,silver],[0,7,rabbit,silver],[1,0,camel,silver],[1,1,cat,silver],[1,2,rabbit,silver],[1,3,dog,silver],[1,4,rabbit,silver],[1,5,horse,silver],[1,6,dog,silver],[1,7,cat,silver],[2,7,rabbit,gold],[6,0,cat,gold],[6,1,horse,gold],[6,2,camel,gold],[6,3,elephant,gold],[6,4,rabbit,gold],[6,5,dog,gold],[6,6,rabbit,gold],[7,0,rabbit,gold],[7,1,rabbit,gold],[7,2,rabbit,gold],[7,3,cat,gold],[7,4,dog,gold],[7,5,rabbit,gold],[7,6,horse,gold],[7,7,rabbit,gold]], [silver, []],  [[[[2, 7], [2, 6]], [[1, 7], [2, 7]]], [[[2, 7], [3, 7]], [[1, 7], [2, 7]]]], ResPouScore, 2).


%score_tout_tirer_silver(Board, Gamestate, ResTir, ResTirScore, ActTir) --> ActTir correspond au nombre de ressources disponibles après avoir fait une action tirer
%ResTir est la liste de toutes les actions tirer immédiates pour un état du board.
%ResTirScore liste de toutes les actions tirer immédiates pour un état du board et pour chaque action on associe un score.

score_tout_tirer_silver(_, _, [], [], _):- !.
score_tout_tirer_silver(Board, Gamestate, [T|Q], ResDepScore, Act):- score_tirer_silver(Board, Gamestate, T, ResScore, Act), score_tout_tirer_silver(Board, Gamestate, Q, TmpRes, Act), concat([[ResScore|[T]]], TmpRes, ResDepScore).

%EXEMPLE EXECUTION:
%score_tout_tirer_silver([[0,0,rabbit,silver],[0,1,rabbit,silver],[0,2,horse,silver],[0,3,rabbit,silver],[0,4,elephant,silver],[0,5,rabbit,silver],[0,6,rabbit,silver],[0,7,rabbit,silver],[1,0,camel,silver],[1,1,cat,silver],[1,2,rabbit,silver],[1,3,dog,silver],[1,4,rabbit,silver],[1,5,horse,silver],[1,6,dog,silver],[3,7,cat,silver],[2,7,rabbit,gold],[6,0,cat,gold],[6,1,horse,gold],[6,2,camel,gold],[6,3,elephant,gold],[6,4,rabbit,gold],[6,5,dog,gold],[6,6,rabbit,gold],[7,0,rabbit,gold],[7,1,rabbit,gold],[7,2,rabbit,gold],[7,3,cat,gold],[7,4,dog,gold],[7,5,rabbit,gold],[7,6,horse,gold],[7,7,rabbit,gold]], [silver, []],  [[[[3, 7], [3, 6]], [[2, 7], [3, 7]]], [[[3, 7], [4, 7]], [[2, 7], [3, 7]]]], ResTirScore, 2).


%score_passer_son_tour(Act, ResDepScore, ResDepPassScore)--> Prédicat qui si il est possible (nombre de ressources restantes Act < 4) ajoute l'action Passer son tour à la liste des actions (avec score) des déplacements.

score_passer_son_tour(4, ResDepScore, ResDepScore).
score_passer_son_tour(Act, ResDepScore, [[0] | ResDepScore]):- Act < 4.


%score_deplacement_silver(Board, Gamestate, Deplacement, ScoreDep, Act) --> Act nombre de ressources restantes
%initialise le prédicat score(0) et lance le cycle de test pour une action déplacement

score_deplacement_silver(Board, Gamestate, Deplacement, ScoreDep, Act):- creation_score(0), cycle_test_deplacement_silver(Board,Gamestate, Deplacement, Act), score(ScoreDep).

%EXEMPLE EXECUTION :
%score_deplacement_silver([[0,0,rabbit,silver],[0,1,rabbit,silver],[0,2,horse,silver],[0,3,rabbit,silver],[0,4,elephant,silver],[0,5,rabbit,silver],[0,6,rabbit,silver],[0,7,rabbit,silver],[1,0,camel,silver],[1,1,cat,silver],[1,2,rabbit,silver],[1,3,dog,silver],[1,4,rabbit,silver],[1,5,horse,silver],[1,6,dog,silver],[1,7,cat,silver],[2,7,rabbit,gold],[6,0,cat,gold],[6,1,horse,gold],[6,2,camel,gold],[6,3,elephant,gold],[6,4,rabbit,gold],[6,5,dog,gold],[6,6,rabbit,gold],[7,0,rabbit,gold],[7,1,rabbit,gold],[7,2,rabbit,gold],[7,3,cat,gold],[7,4,dog,gold],[7,5,rabbit,gold],[7,6,horse,gold],[7,7,rabbit,gold]], [silver, []],[[1, 0], [2, 0]], Score, 3).


%score_pousser_silver(Board,Gamestate, Pousser, ScoreDep, Act)
%initialise le prédicat score(0) et lance le cycle de test pour une action pousser

score_pousser_silver(Board,Gamestate, Pousser, ScoreDep, Act):- creation_score(0), cycle_test_pousser_silver(Board, Gamestate, Pousser, Act), score(ScoreDep).


%score_tirer_silver(Board,Gamestate, Tirer, ScoreDep, Act)
%initialise le prédicat score(0) et lance le cycle de test pour une action tirer

score_tirer_silver(Board,Gamestate, Tirer, ScoreDep, Act):- creation_score(0), cycle_test_tirer_silver(Board, Gamestate, Tirer, Act), score(ScoreDep).

%meilleur_action(ListeActionAvecScore, Resultat) --> Choisie la meilleur action parmi une liste à partir du score de chaque action
%Ce prédicat initialise le test et utilise choix_meilleur_action.
meilleur_action([], []).
meilleur_action([T|Q], Res):- retractall(actionMaxScore(_)), asserta(actionMaxScore(T)), choix_meilleur_action(Q), actionMaxScore(Res), !.
%choix_meilleur_action(ListeActions)
choix_meilleur_action([]).
choix_meilleur_action([[Score|Action]|Q]):- actionMaxScore([A|_]), Score > A, retractall(actionMaxScore(_)), asserta(actionMaxScore([Score|Action])), choix_meilleur_action(Q).
choix_meilleur_action([[Score|_]|Q]):- actionMaxScore([A|_]), Score =< A, choix_meilleur_action(Q).

%EXEMPLE EXECUTION :
%meilleur_action([[0,[[3,2],[4,2]]],[-9,[[6,2],[6,3]]],[59,[[6,2],[7,2]]],[23,[[5,2],[6,2]]]], Res).
%meilleur_action([[0,[[1,2],[0,2]]],[0,[[1,2],[1,1]]],[0,[[0,3],[0,2]]],[5,[[2,2],[3,2]]],[-95,[[1,5],[2,5]]],[5,[[1,6],[2,6]]],[5,[[1,7],[2,7]]],[0,[[3,1],[3,2]]],[5,[[3,1],[4,1]]]],Res).

%meilleur_action(ActionDeplacementScore, ActionPousserScore, ActionTirerScore, Consom, MeilleurAction)
%prédicat non optimal mais qui permet de choisir la meilleur actions parmi la meilleur action deplacement, pousser et tirer
%Consom s'unifie avec la consommation de ressources lié à l'action choisie.
meilleur_action([_|[]], [], [], 4, []):- !.
meilleur_action([_|A1], [], [], 1, A1):- !.
meilleur_action([], [_|[A2]], [], 2, A2):- !.
meilleur_action([], [], [_|[A3]], 2, A3):- !.
meilleur_action([Sc1|[]], [], [Sc3|[_]], 4, []):- Sc1 >= Sc3, !.
meilleur_action([Sc1|A1], [], [Sc3|[_]], 1, A1):- Sc1 >= Sc3, !.
meilleur_action([Sc1|_], [Sc2|[A2]], [], 2, A2):- Sc2 >= Sc1, !.
meilleur_action([Sc1|[]], [Sc2|[_]], [], 4, []):- Sc1 >= Sc2, !.
meilleur_action([Sc1|A1], [Sc2|[_]], [], 1, A1):- Sc1 >= Sc2, !.
meilleur_action([], [Sc2|_], [Sc3|[A3]], 2, A3):- Sc3 >= Sc2, !.
meilleur_action([Sc1|_], [], [Sc3|[A3]], 2, A3):- Sc3 >= Sc1, !.
meilleur_action([], [Sc2|[A2]], [Sc3|_], 2, A2):- Sc2 >= Sc3, !.
meilleur_action([Sc1|[]], [Sc2|[_]], [Sc3|[_]], 4, []):- Sc1 >= Sc2, Sc1 >= Sc3, !.
meilleur_action([Sc1|A1], [Sc2|[_]], [Sc3|[_]], 1, A1):- Sc1 >= Sc2, Sc1 >= Sc3, !.
meilleur_action([Sc1|_], [Sc2|[A2]], [Sc3|[_]], 2, A2):- Sc2 >= Sc1, Sc2 >= Sc3, !.
meilleur_action([Sc1|_], [Sc2|[_]], [Sc3|[A3]], 2, A3):- Sc3 >= Sc2, Sc3 >= Sc1.

%EXEMPLE EXECUTION :
%meilleur_action([-9,[[6,2],[6,3]]],[6, [[[2, 7], [3, 7]], [[1, 7], [2, 7]]]],[5, [[[3, 7], [4, 7]], [[2, 7], [3, 7]]]], Consom, Res ).
%meilleur_action([5,[[1,0],[2,0]]],[0,[[[2,7],[2,6]],[[1,7],[2,7]]]],[], Consom, A).


%Prédicats liés à la création et la modification du score
creation_score(Score):- retractall(score(_)), asserta(score(Score)).
addition_score(Valeur):- score(TmpScore), retractall(score(_)), Score is TmpScore + Valeur, asserta(score(Score)). 
soustraction_score(Valeur):- score(TmpScore), retractall(score(_)), Score is TmpScore - Valeur, asserta(score(Score)). 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 	Prédicats Cycles de tests qui modifient le score	%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Les predicats de cycle et de tests sont à modifier afin de rajouter de nouveau test, de modifier les scores, etc
% Si on ajoute une nouvelle strategie, il faut aussi définir le nouveau cycle de test.

%cycle_test_deplacement_silver(Board, Gamestate, ActionDeplacement, Act)
%Cycle de tests qui vont s'appliquer sur l'action de déplacement afin de modifier le score de base.

cycle_test_deplacement_silver(Board, Gamestate, [[Xdepart,Ydepart], [Xarrive,Yarrive]], Act):- 
	strategie(Strat),
	get_case(Board, (Xdepart,Ydepart), Pion),
	update_board(Board, NvBoard, Gamestate, NvGamestate, [[[Xdepart,Ydepart], [Xarrive,Yarrive]]]),
	get_case(NvBoard, (Xarrive, Yarrive), NvPion),
	test_deplacement_victoire((Xarrive,Yarrive), Pion),
	test_suicide(Gamestate, NvGamestate, Strat),
	test_deplacement_direction([[Xdepart,Ydepart], [Xarrive,Yarrive]], Strat ),
	test_freeze(NvBoard, NvPion, Strat),
	test_freeze_ennemi(Board,NvBoard,NvPion, Strat),
	test_defreeze_ennemi(Board,NvBoard,Pion, Strat),
	test_blocage_lapin(NvBoard,NvPion, Strat),
	test_deblocage_lapin(Board, Pion, Strat),
	test_actions_suivantes(NvBoard,NvGamestate,NvPion,[[Xdepart,Ydepart]],Act).

%EXEMPLE EXECUTION (necessite une définition du score) :
%cycle_test_deplacement_silver([[0,0,rabbit,silver],[0,1,rabbit,silver],[0,2,horse,silver],[0,3,rabbit,silver],[0,4,elephant,silver],[0,5,rabbit,silver],[0,6,rabbit,silver],[0,7,rabbit,silver],[1,0,camel,silver],[1,1,cat,silver],[1,2,rabbit,silver],[1,3,dog,silver],[1,4,rabbit,silver],[1,5,horse,silver],[1,6,dog,silver],[1,7,cat,silver],[2,7,rabbit,gold],[6,0,cat,gold],[6,1,horse,gold],[6,2,camel,gold],[6,3,elephant,gold],[6,4,rabbit,gold],[6,5,dog,gold],[6,6,rabbit,gold],[7,0,rabbit,gold],[7,1,rabbit,gold],[7,2,rabbit,gold],[7,3,cat,gold],[7,4,dog,gold],[7,5,rabbit,gold],[7,6,horse,gold],[7,7,rabbit,gold]], [silver, []],[[1, 0], [2, 0]],3).	
%cycle_test_deplacement_silver([[0,2,rabbit,silver],[0,4,cat,silver],[0,5,elephant,silver],[0,6,rabbit,silver],[0,7,rabbit,silver],[1,1,rabbit,silver],[1,2,dog,silver],[1,4,rabbit,silver],[1,5,rabbit,silver],[1,7,dog,silver],[2,0,rabbit,silver],[2,1,horse,silver],[2,3,rabbit,silver],[2,7,elephant,gold],[3,6,cat,gold],[4,3,horse,silver],[4,4,rabbit,gold],[4,5,camel,gold],[4,6,cat,silver],[5,0,camel,silver],[5,1,rabbit,gold],[5,3,horse,gold],[5,6,rabbit,gold],[6,0,rabbit,gold],[6,2,dog,gold],[6,5,cat,gold],[7,0,rabbit,gold],[7,1,dog,gold],[7,2,rabbit,gold],[7,3,horse,gold],[7,5,rabbit,gold],[7,6,rabbit,gold]],[silver,[]],[[1,2],[2,2]], 3).
%cycle_test_deplacement_silver([[0,2,rabbit,silver],[0,4,cat,silver],[0,5,elephant,silver],[0,6,rabbit,silver],[0,7,rabbit,silver],[1,1,rabbit,silver],[2,2,dog,silver],[1,4,rabbit,silver],[1,5,rabbit,silver],[1,7,dog,silver],[2,0,rabbit,silver],[2,1,horse,silver],[2,3,rabbit,silver],[2,7,elephant,gold],[3,6,cat,gold],[4,3,horse,silver],[4,4,rabbit,gold],[4,5,camel,gold],[4,6,cat,silver],[5,0,camel,silver],[5,1,rabbit,gold],[5,3,horse,gold],[5,6,rabbit,gold],[6,0,rabbit,gold],[6,2,dog,gold],[6,5,cat,gold],[7,0,rabbit,gold],[7,1,dog,gold],[7,2,rabbit,gold],[7,3,horse,gold],[7,5,rabbit,gold],[7,6,rabbit,gold]],[silver,[]],[[2,2],[1,2]], 2).


%cycle_test_pousser_silver(Board, Gamestate, ActionPousser, Act)
%Cycle de tests qui vont s'appliquer sur l'action pousser afin de modifier le score de base.
	
cycle_test_pousser_silver(Board, Gamestate, [[[XDennemi, YDennemi], [XAennemi, YAennemi]], [[XDallie, YDallie], [XDennemi, YDennemi]]], Act):-
	strategie(Strat),
	get_case(Board, (XDennemi,YDennemi), PionEnnemi),
	get_case(Board, (XDallie,YDallie), PionAllie),
	update_board(Board, NvBoard, Gamestate, NvGamestate, [[[XDennemi, YDennemi], [XAennemi, YAennemi]], [[XDallie, YDallie], [XDennemi, YDennemi]]]),
	get_case(NvBoard, (XDennemi,YDennemi), NvPionAllie),
	test_tuer_ennemi(Gamestate, NvGamestate, Strat),
	test_suicide(Gamestate, NvGamestate, Strat),
	test_actions_suivantes(NvBoard,NvGamestate,NvPionAllie,[[]],Act).

%EXEMPLE EXECUTION
%cycle_test_pousser_silver([[2,3,rabbit, gold], [1,3,dog,silver]], [silver, []], [[[2,3],[2,2]],[[1,3],[2,3]]], 2).
	
	
%cycle_test_tirer_silver(Board,Gamestate,ActionTirer, Act)
%Cycle de tests qui vont s'appliquer sur l'action tirer afin de modifier le score de base.

cycle_test_tirer_silver(Board,Gamestate,[[[XDallie, YDallie], [XAallie, YAallie]], [[XDennemi, YDennemi], [XDallie, YDallie]]], Act):-
	strategie(Strat),
	get_case(Board, (XDallie,YDallie), PionAllie),
	get_case(Board, (XDennemi,YDennemi), PionEnnemi),
	update_board(Board, NvBoard, Gamestate, NvGamestate,[[[XDallie, YDallie], [XAallie, YAallie]], [[XDennemi, YDennemi], [XDallie, YDallie]]] ),
	get_case(NvBoard, (XAallie, YAallie), NvPionAllie),
	test_tuer_ennemi(Gamestate, NvGamestate, Strat),
	test_suicide(Gamestate, NvGamestate, Strat),
	test_actions_suivantes(NvBoard,NvGamestate,NvPionAllie,[[]],Act).
	
	
%%%%%%%%%%%%%%%%%%%%% DEFINITION DES PREDICATS DE TESTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%test_deplacement_victoire(Coordonées, Pion)
%Si un lapin va sur la ligne 7 on modifie le score
test_deplacement_victoire((7,_), [_,_,rabbit,silver]):- addition_score(1000), !.
test_deplacement_victoire(_,_).


%test_deplacement_direction(ActionDeplacement, Stratégie)
%Si un pion se déplace dans une direction particulière selon la strategie on modifie le score.
test_deplacement_direction([[Xdepart,_], [Xarrive,_]], 0):- Xdepart is Xarrive-1, addition_score(5), !.
test_deplacement_direction([[Xdepart,_], [Xarrive,_]], 1):- Xdepart is Xarrive+1, addition_score(5), !.
test_deplacement_direction(_, _).


%test_tuer_ennemi(Gamestate, NvGamestate, Stratégie)
% Si on pion adverse est tué, selon la strategie on modifie le score

test_tuer_ennemi([silver| [Q]], [silver| [[[_,_,_,gold]|Q]]], 0):- addition_score(100), !.
test_tuer_ennemi([silver| [Q]], [silver| [[[_,_,rabbit,gold]|Q]]], 1):- addition_score(200), !.
test_tuer_ennemi([silver| [Q]], [silver| [[[_,_,_,gold]|Q]]], 1):- addition_score(100), !.
test_tuer_ennemi(_,_,_).

%EXEMPLE EXECUTION :
%test_tuer_ennemi([silver, []], [silver,[[2,2,rabbit,gold]]], 0).
%test_tuer_ennemi([silver, [[5,5,rabbit,silver]]], [silver,[[2,2,rabbit,gold],[5,5,rabbit,silver]]], 1).


%test_suicide(Gamestate, NvGamestate, Stratégie)
% Si le pion se suicide, selon la startégie, on modifie le score.

test_suicide([silver| [Q]], [silver| [[[_,_,_,silver]|Q]]], 0):- soustraction_score(100), !.
test_suicide([silver| [Q]], [silver| [[[_,_,_,silver]|Q]]], 1):- soustraction_score(100), !.
test_suicide(_,_,_).


%test_freeze(NvBoard, NvPion, Stratégie)
%Si le pion se freeze lui meme, selon la stratégie, on modifie le score

test_freeze(NvBoard, NvPion, 0):- pion_freeze(NvBoard, NvPion), soustraction_score(10), !.
test_freeze(NvBoard, NvPion, 1):- pion_freeze(NvBoard, NvPion), soustraction_score(10), !.
test_freeze(_,_,_).


%test_freeze_ennemi(Board,NvBoard,NvPion, Stratégie)
%Si le pion freeze un adversaire, selon la stratégie, on modifie le score

test_freeze_ennemi(Board,NvBoard,[X,Y,_,_],0):- Xtemp is X + 1, get_case(Board, (Xtemp,Y), [Xpion1,Ypion1,Type,gold]), \+pion_freeze(Board,[Xpion1,Ypion1,Type,gold]), pion_freeze(NvBoard,[Xpion1,Ypion1,Type,gold]), addition_score(10).
test_freeze_ennemi(Board,NvBoard,[X,Y,_,_],0):- Xtemp is X - 1, get_case(Board, (Xtemp,Y), [Xpion1,Ypion1,Type,gold]), \+pion_freeze(Board,[Xpion1,Ypion1,Type,gold]), pion_freeze(NvBoard,[Xpion1,Ypion1,Type,gold]), addition_score(10).
test_freeze_ennemi(Board,NvBoard,[X,Y,_,_],0):- Ytemp is Y + 1, get_case(Board, (X,Ytemp), [Xpion1,Ypion1,Type,gold]), \+pion_freeze(Board,[Xpion1,Ypion1,Type,gold]), pion_freeze(NvBoard,[Xpion1,Ypion1,Type,gold]), addition_score(10).
test_freeze_ennemi(Board,NvBoard,[X,Y,_,_],0):- Ytemp is Y - 1, get_case(Board, (X,Ytemp), [Xpion1,Ypion1,Type,gold]), \+pion_freeze(Board,[Xpion1,Ypion1,Type,gold]), pion_freeze(NvBoard,[Xpion1,Ypion1,Type,gold]), addition_score(10).

test_freeze_ennemi(Board,NvBoard,[X,Y,_,_],1):- Xtemp is X + 1, get_case(Board, (Xtemp,Y), [Xpion1,Ypion1,rabbit,gold]), \+pion_freeze(Board,[Xpion1,Ypion1,rabbit,gold]), pion_freeze(NvBoard,[Xpion1,Ypion1,rabbit,gold]), addition_score(20).
test_freeze_ennemi(Board,NvBoard,[X,Y,_,_],1):- Xtemp is X - 1, get_case(Board, (Xtemp,Y), [Xpion1,Ypion1,rabbit,gold]), \+pion_freeze(Board,[Xpion1,Ypion1,rabbit,gold]), pion_freeze(NvBoard,[Xpion1,Ypion1,rabbit,gold]), addition_score(20).
test_freeze_ennemi(Board,NvBoard,[X,Y,_,_],1):- Ytemp is Y + 1, get_case(Board, (X,Ytemp), [Xpion1,Ypion1,rabbit,gold]), \+pion_freeze(Board,[Xpion1,Ypion1,rabbit,gold]), pion_freeze(NvBoard,[Xpion1,Ypion1,rabbit,gold]), addition_score(20).
test_freeze_ennemi(Board,NvBoard,[X,Y,_,_],1):- Ytemp is Y - 1, get_case(Board, (X,Ytemp), [Xpion1,Ypion1,rabbit,gold]), \+pion_freeze(Board,[Xpion1,Ypion1,rabbit,gold]), pion_freeze(NvBoard,[Xpion1,Ypion1,rabbit,gold]), addition_score(20).
test_freeze_ennemi(Board,NvBoard,[X,Y,_,_],1):- Xtemp is X + 1, get_case(Board, (Xtemp,Y), [Xpion1,Ypion1,Type,gold]), \+pion_freeze(Board,[Xpion1,Ypion1,Type,gold]), pion_freeze(NvBoard,[Xpion1,Ypion1,Type,gold]), addition_score(10).
test_freeze_ennemi(Board,NvBoard,[X,Y,_,_],1):- Xtemp is X - 1, get_case(Board, (Xtemp,Y), [Xpion1,Ypion1,Type,gold]), \+pion_freeze(Board,[Xpion1,Ypion1,Type,gold]), pion_freeze(NvBoard,[Xpion1,Ypion1,Type,gold]), addition_score(10).
test_freeze_ennemi(Board,NvBoard,[X,Y,_,_],1):- Ytemp is Y + 1, get_case(Board, (X,Ytemp), [Xpion1,Ypion1,Type,gold]), \+pion_freeze(Board,[Xpion1,Ypion1,Type,gold]), pion_freeze(NvBoard,[Xpion1,Ypion1,Type,gold]), addition_score(10).
test_freeze_ennemi(Board,NvBoard,[X,Y,_,_],1):- Ytemp is Y - 1, get_case(Board, (X,Ytemp), [Xpion1,Ypion1,Type,gold]), \+pion_freeze(Board,[Xpion1,Ypion1,Type,gold]), pion_freeze(NvBoard,[Xpion1,Ypion1,Type,gold]), addition_score(10).

test_freeze_ennemi(_,_,_,_).

% EXEMPLE EXECUTION:
%test_freeze_ennemi([[2,4,rabbit,gold], [1,3,horse,silver]], [[2,4,rabbit,gold], [2,3,horse,silver]], [2,3,horse,silver] , 0).


%test_defreeze_ennemi(Board,NvBoard,Pion, Stratégie)
%Si le pion enleve le freeze d'in ennemi, selon la startégie, on modifie le score.

test_defreeze_ennemi(Board,NvBoard,[X,Y,_,_],0):- Xtemp is X + 1, get_case(Board, (Xtemp,Y), [Xpion1,Ypion1,Type,gold]), pion_freeze(Board,[Xpion1,Ypion1,Type,gold]), \+pion_freeze(NvBoard,[Xpion1,Ypion1,Type,gold]), soustraction_score(10).
test_defreeze_ennemi(Board,NvBoard,[X,Y,_,_],0):- Xtemp is X - 1, get_case(Board, (Xtemp,Y), [Xpion1,Ypion1,Type,gold]), pion_freeze(Board,[Xpion1,Ypion1,Type,gold]), \+pion_freeze(NvBoard,[Xpion1,Ypion1,Type,gold]), soustraction_score(10).
test_defreeze_ennemi(Board,NvBoard,[X,Y,_,_],0):- Ytemp is Y + 1, get_case(Board, (X,Ytemp), [Xpion1,Ypion1,Type,gold]), pion_freeze(Board,[Xpion1,Ypion1,Type,gold]), \+pion_freeze(NvBoard,[Xpion1,Ypion1,Type,gold]), soustraction_score(10).
test_defreeze_ennemi(Board,NvBoard,[X,Y,_,_],0):- Ytemp is Y - 1, get_case(Board, (X,Ytemp), [Xpion1,Ypion1,Type,gold]), pion_freeze(Board,[Xpion1,Ypion1,Type,gold]), \+pion_freeze(NvBoard,[Xpion1,Ypion1,Type,gold]), soustraction_score(10).

test_defreeze_ennemi(Board,NvBoard,[X,Y,_,_],1):- Xtemp is X + 1, get_case(Board, (Xtemp,Y), [Xpion1,Ypion1,rabbit,gold]), pion_freeze(Board,[Xpion1,Ypion1,rabbit,gold]), \+pion_freeze(NvBoard,[Xpion1,Ypion1,rabbit,gold]), soustraction_score(20).
test_defreeze_ennemi(Board,NvBoard,[X,Y,_,_],1):- Xtemp is X - 1, get_case(Board, (Xtemp,Y), [Xpion1,Ypion1,rabbit,gold]), pion_freeze(Board,[Xpion1,Ypion1,rabbit,gold]), \+pion_freeze(NvBoard,[Xpion1,Ypion1,rabbit,gold]), soustraction_score(20).
test_defreeze_ennemi(Board,NvBoard,[X,Y,_,_],1):- Ytemp is Y + 1, get_case(Board, (X,Ytemp), [Xpion1,Ypion1,rabbit,gold]), pion_freeze(Board,[Xpion1,Ypion1,rabbit,gold]), \+pion_freeze(NvBoard,[Xpion1,Ypion1,rabbit,gold]), soustraction_score(20).
test_defreeze_ennemi(Board,NvBoard,[X,Y,_,_],1):- Ytemp is Y - 1, get_case(Board, (X,Ytemp), [Xpion1,Ypion1,rabbit,gold]), pion_freeze(Board,[Xpion1,Ypion1,rabbit,gold]), \+pion_freeze(NvBoard,[Xpion1,Ypion1,rabbit,gold]), soustraction_score(20).
test_defreeze_ennemi(Board,NvBoard,[X,Y,_,_],1):- Xtemp is X + 1, get_case(Board, (Xtemp,Y), [Xpion1,Ypion1,Type,gold]), pion_freeze(Board,[Xpion1,Ypion1,Type,gold]), \+pion_freeze(NvBoard,[Xpion1,Ypion1,Type,gold]), soustraction_score(10).
test_defreeze_ennemi(Board,NvBoard,[X,Y,_,_],1):- Xtemp is X - 1, get_case(Board, (Xtemp,Y), [Xpion1,Ypion1,Type,gold]), pion_freeze(Board,[Xpion1,Ypion1,Type,gold]), \+pion_freeze(NvBoard,[Xpion1,Ypion1,Type,gold]), soustraction_score(10).
test_defreeze_ennemi(Board,NvBoard,[X,Y,_,_],1):- Ytemp is Y + 1, get_case(Board, (X,Ytemp), [Xpion1,Ypion1,Type,gold]), pion_freeze(Board,[Xpion1,Ypion1,Type,gold]), \+pion_freeze(NvBoard,[Xpion1,Ypion1,Type,gold]), soustraction_score(10).
test_defreeze_ennemi(Board,NvBoard,[X,Y,_,_],1):- Ytemp is Y - 1, get_case(Board, (X,Ytemp), [Xpion1,Ypion1,Type,gold]), pion_freeze(Board,[Xpion1,Ypion1,Type,gold]), \+pion_freeze(NvBoard,[Xpion1,Ypion1,Type,gold]), soustraction_score(10).

test_defreeze_ennemi(_,_,_,_).


%test_blocage_lapin(NvBoard,NvPion, Stratégie)
%Test spécifique à une startégie de défense. Si le déplacement permet de bloquer un lapin adverse alors on modifie le score.

test_blocage_lapin(Board, [X,Y,_,_], 1):- voisinB(Board, (X,Y), [Xennemi,_,rabbit,gold]), Xennemi < 4, addition_score(15).
test_blocage_lapin(Board, [X,Y,_,_], 1):- voisinG(Board, (X,Y), [Xennemi,_,rabbit,gold]), Xennemi < 4, addition_score(8).
test_blocage_lapin(Board, [X,Y,_,_], 1):- voisinD(Board, (X,Y), [Xennemi,_,rabbit,gold]), Xennemi < 4, addition_score(8).
test_blocage_lapin(_, _, _).


%test_deblocage_lapin(NvBoard,NvPion, Stratégie)
%Test spécifique à une startégie de défense. Si le déplacement débloque un lapin adverse alors on modifie le score.

test_deblocage_lapin(Board, [X,Y,_,_], 1):- voisinB(Board, (X,Y), [Xennemi,_,rabbit,gold]), Xennemi < 4, soustraction_score(15).
test_deblocage_lapin(Board, [X,Y,_,_], 1):- voisinG(Board, (X,Y), [Xennemi,_,rabbit,gold]), Xennemi < 4, soustraction_score(8).
test_deblocage_lapin(Board, [X,Y,_,_], 1):- voisinD(Board, (X,Y), [Xennemi,_,rabbit,gold]), Xennemi < 4, soustraction_score(8).
test_deblocage_lapin(_, _, _).


	
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%											%
%	Predicats pour test_action_suivante		%
%		Permet d'ajouter une profondeur		%
%											%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	

%test_actions_suivantes(NvBoard,NvGamestate,NvPion,AnciennesPos,Act)
% Prédicat qui permet d'initialiser les tests des actions suivantes en profondeur.
% Si le score est négatif, on ne modifie pas le score de l'action immédiate.
% AnciennesPos permet de garder en memoire les déplacements déjà effectues

test_actions_suivantes(NvBoard,NvGamestate,NvPion,AnciennesPos,Act):- test_action_suivante(NvBoard,NvGamestate,NvPion,AnciennesPos,Act,Res), Res >= 0, addition_score(Res), !.
test_actions_suivantes(_,_,_,_,_). %ce test ne peut pas diminuer le score car dans tous les cas, on peut passer son tour.


%test_action_suivante(NvBoard,NvGamestate,NvPion,AnciennesPos,Act, Res)
%prédicat qui sera appelé récursivement pour faire des tests sur les actions en profondeur
% Res est le score à ajouter, Act correspond aux ressources disponibles

test_action_suivante(_,_,[_,_,-1,-1],_,_, 0):- !.

test_action_suivante(NvBoard,NvGamestate,NvPion,AnciennesPos,Act, Res) :-
	action_pion_silver(NvBoard, NvGamestate, Act, AnciennesPos, NvPion, Res).
	
%%%
%A partir de maintenant, les prédicats définies seront des "copies" des prédicats définies au dessus mais qui seront légèrement modifiés pour s'adapter à la récursion et pour avoir un système de score séparé.
%	
%
	
%action_pion_silver(Board, Gamestate, Act, AnciennesPos, Pion, Res)
%Equivalent de action_tour_silver.

action_pion_silver(_,_,Act,_,_,0):- Act < 1, !.
	
action_pion_silver(Board, Gamestate, Act, AnciennesPos, Pion, Res):-
	Act > 1,
	ActDep is Act-1,
	ActPou is Act-2,
	liste_pion_deplacement_possible_silver(Board, Pion, ResDep),	
	% tout_deplacement_possible_silver(Board,Board,ResDep),
	score_pion_deplacement_silver(Board, Gamestate, AnciennesPos, ResDep, ResDepScore, ActDep), 
	liste_pion_pousser_possible_silver(Board, Pion, ResPou), 
	% tout_pousser_possible_silver(Board,Board,ResPou),
	score_pion_pousser_silver(Board, Gamestate, AnciennesPos, ResPou, ResPouScore, ActPou), 	
	liste_pion_tirer_possible_silver(Board, Pion, ResTir), 	
	% tout_tirer_possible_silver(Board,Board,ResTir),
	score_pion_tirer_silver(Board, Gamestate, AnciennesPos, ResTir, ResTirScore, ActPou), 
	meilleur_action(ResDepScore, Res1),
	meilleur_action(ResPouScore, Res2),
	meilleur_action(ResTirScore, Res3),
	meilleur_score(Res1, Res2, Res3, Consom, Res), !. 
	
action_pion_silver(Board, Gamestate, 1, AnciennesPos, Pion, Res):-
	% tout_deplacement_possible_silver(Board,Board,ResDep),
	liste_pion_deplacement_possible_silver(Board, Pion, ResDep),	
	score_pion_deplacement_silver(Board, Gamestate, AnciennesPos, ResDep, ResDepScore, 0),
	meilleur_score(ResDepScore, Res).
	
	
%liste_pion_deplacement_possible_silver(Board, Pion, ResDep)
%si pion_deplacement_possible_silver est faux, il faut renvoyer une liste vide.
	
liste_pion_deplacement_possible_silver(Board, Pion, ResDep):- pion_deplacement_possible_silver(Board, Pion, ResDep), !.
liste_pion_deplacement_possible_silver(_, _, []).


%liste_pion_pousser_possible_silver(Board, Pion, ResPou)
%si pion_pousser_possible_silver est faux, il faut renvoyer une liste vide.

liste_pion_pousser_possible_silver(Board, Pion, ResPou):- pion_pousser_possible_silver(Board, Pion, ResPou), !.
liste_pion_pousser_possible_silver(_, _, []).


%liste_pion_tirer_possible_silver(Board, Pion, ResTir)
%si pion_tirer_possible_silver est faux, il faut renvoyer une liste vide.

liste_pion_tirer_possible_silver(Board, Pion, ResTir):- pion_tirer_possible_silver(Board, Pion, ResTir), !.
liste_pion_tirer_possible_silver(_, _, []).


%score_pion_deplacement_silver(Board, Gamestate, AnciennesPos, ResDep, ResDepScore, ActDep)
%Copie de score_tout_deplacement_silver
	
score_pion_deplacement_silver(_, _, _, [], [], _):- !.
score_pion_deplacement_silver(Board, Gamestate, AnciennesPos, [T|Q], ResDepScore, Act):- test_score_deplacement_silver(Board, Gamestate, AnciennesPos, T, ResScore, Act), score_pion_deplacement_silver(Board, Gamestate, AnciennesPos, Q, TmpRes, Act), concat([[ResScore|[T]]], TmpRes, ResDepScore).


%score_pion_pousser_silver(Board, Gamestate, AnciennesPos, ResPou, ResPouScore, ActPou)
%Copie de score_tout_pousser_silver

score_pion_pousser_silver(_, _, _, [], [], _):- !.
score_pion_pousser_silver(Board, Gamestate, AnciennesPos, [T|Q], ResDepScore, Act):- test_score_pousser_silver(Board, Gamestate, AnciennesPos, T, ResScore, Act), score_pion_pousser_silver(Board, Gamestate, AnciennesPos, Q, TmpRes, Act), concat([[ResScore|[T]]], TmpRes, ResDepScore).


%score_pion_tirer_silver(Board, Gamestate, AnciennesPos, ResTir, ResTirScore, ActPou)
%Copie de score_tout_tirer_silver

score_pion_tirer_silver(_, _, _, [], [], _):- !.
score_pion_tirer_silver(Board, Gamestate, AnciennesPos, [T|Q], ResDepScore, Act):- test_score_tirer_silver(Board, Gamestate, AnciennesPos, T, ResScore, Act), score_pion_tirer_silver(Board, Gamestate, AnciennesPos, Q, TmpRes, Act), concat([[ResScore|[T]]], TmpRes, ResDepScore).

%test_score_deplacement_silver(Board, Gamestate, AnciennesPos, Deplacement, ScoreDep, Act)
%Copie de score_deplacement_silver (intéret limité ici)

test_score_deplacement_silver(Board, Gamestate, AnciennesPos, Deplacement, ScoreDep, Act):-  profond_cycle_test_deplacement_silver(Board,Gamestate, AnciennesPos, Deplacement, Act, ScoreDep).


%test_score_pousser_silver(Board,Gamestate, AnciennesPos, Pousser, ScoreDep, Act)
%Copie de score_pousser_silver (intérêt limité ici)

test_score_pousser_silver(Board,Gamestate, AnciennesPos, Pousser, ScoreDep, Act):- profond_cycle_test_pousser_silver(Board, Gamestate, AnciennesPos, Pousser, Act, ScoreDep).


%test_score_tirer_silver(Board,Gamestate, AnciennesPos, Tirer, ScoreDep, Act)
%Copie de score_tirer_silver (interet limité ici)

test_score_tirer_silver(Board,Gamestate, AnciennesPos, Tirer, ScoreDep, Act):- profond_cycle_test_tirer_silver(Board, Gamestate, AnciennesPos, Tirer, Act, ScoreDep).


%profond_cycle_test_deplacement_silver(Board, Gamestate, AnciennesPos, ActionDeplacement, Act, Score)
%Copie de cycle_test_deplacement_silver
%Ce cycle a ses porpres copies de tests

profond_cycle_test_deplacement_silver(Board, Gamestate, AnciennesPos, [[Xdepart,Ydepart], [Xarrive,Yarrive]], Act, Score):- 
	strategie(Strat),
	get_case(Board, (Xdepart,Ydepart), Pion),
	update_board(Board, NvBoard, Gamestate, NvGamestate, [[[Xdepart,Ydepart], [Xarrive,Yarrive]]]),
	get_case(NvBoard, (Xarrive, Yarrive), NvPion),
	test_deplacement_victoire((Xarrive,Yarrive), Pion, Res1),
	test_suicide(Gamestate, NvGamestate, Strat, Res2),
	test_deplacement_direction([[Xdepart,Ydepart], [Xarrive,Yarrive]], Strat, Res3),
	test_freeze(NvBoard, NvPion, Strat, Res4),
	test_freeze_ennemi(Board,NvBoard,NvPion, Strat, Res5),
	test_defreeze_ennemi(Board,NvBoard, Pion, Strat, Res6),
	test_blocage_lapin(NvBoard, NvPion, Strat, Res9),
	test_deblocage_lapin(Board, Pion, Strat, Res10),
	test_deplacement_redondant(AnciennesPos, [Xarrive,Yarrive], Res8),
	test_action_suivante(NvBoard,NvGamestate,NvPion, [[Xdepart,Ydepart]|AnciennesPos], Act, Res7),
	Score is Res1 + Res2 + Res3 + Res4 + Res5 + Res6 + Res7 + Res8 + Res9 + Res10.

	
%profond_cycle_test_pousser_silver(Board, Gamestate, AnciennesPos, ActionPousser, Act, Score)
%Copie de cycle_test_pousser_silver
	
profond_cycle_test_pousser_silver(Board, Gamestate, AnciennesPos, [[[XDennemi, YDennemi], [XAennemi, YAennemi]], [[XDallie, YDallie], [XDennemi, YDennemi]]], Act, Score):-
	strategie(Strat),
	get_case(Board, (XDennemi,YDennemi), PionEnnemi),
	get_case(Board, (XDallie,YDallie), PionAllie),
	update_board(Board, NvBoard, Gamestate, NvGamestate, [[[XDennemi, YDennemi], [XAennemi, YAennemi]], [[XDallie, YDallie], [XDennemi, YDennemi]]]),
	test_tuer_ennemi(Gamestate, NvGamestate, Strat, Res1),
	test_suicide(Gamestate, NvGamestate, Strat, Res2),
	test_action_suivante(NvBoard,NvGamestate,NvPion, AnciennesPos, Act, Res3),
	Score is Res1 + Res2 + Res3.
	

%profond_cycle_test_tirer_silver(Board,Gamestate, AnciennesPos, ActionTirer, Act, Score)
%copie de cycle_test_tirer_silver
	
profond_cycle_test_tirer_silver(Board,Gamestate, AnciennesPos, [[[XDallie, YDallie], [XAallie, YAallie]], [[XDennemi, YDennemi], [XDallie, YDallie]]], Act, Score):-
	strategie(Strat),
	get_case(Board, (XDallie,YDallie), PionAllie),
	get_case(Board, (XDennemi,YDennemi), PionEnnemi),
	update_board(Board, NvBoard, Gamestate, NvGamestate,[[[XDallie, YDallie], [XAallie, YAallie]], [[XDennemi, YDennemi], [XDallie, YDallie]]] ),
	test_tuer_ennemi(Gamestate, NvGamestate, Strat, Res1),
	test_suicide(Gamestate, NvGamestate, Strat, Res2),
	test_action_suivante(NvBoard,NvGamestate,NvPion, AnciennesPos, Act, Res3),
	Score is Res1 + Res2 + Res3.
	

%COPIE DES TESTS 
	
test_deplacement_victoire((7,_), [_,_,rabbit,silver], 1000):- !.
test_deplacement_victoire(_,_,0).



test_deplacement_direction([[Xdepart,_], [Xarrive,_]], 0, 5):- Xdepart is Xarrive-1, !.
test_deplacement_direction([[Xdepart,_], [Xarrive,_]], 1, 5):- Xdepart is Xarrive+1, !.
test_deplacement_direction(_,_,0).


%Test spécifique à la profondeur
%test_deplacement_redondant(AnciennesPos, Position, Score)
%Si le pion effectue un déplacement redondante, on modifie le score

test_deplacement_redondant(AnciennesPos, Position, -10):- element(Position, AnciennesPos).
test_deplacement_redondant(_,_,0).


	
test_tuer_ennemi([silver| [Q]], [silver| [[[_,_,_,gold]|Q]]], 0, 100):- !.
test_tuer_ennemi([silver| [Q]], [silver| [[[_,_,rabbit,gold]|Q]]], 1, 200):- !.
test_tuer_ennemi([silver| [Q]], [silver| [[[_,_,_,gold]|Q]]], 1, 100):- !.
test_tuer_ennemi(_,_,_,0).



test_suicide([silver| [Q]], [silver| [[[_,_,_,silver]|Q]]], 0, -100):- !.
test_suicide([silver| [Q]], [silver| [[[_,_,_,silver]|Q]]], 1, -100):- !.
test_suicide(_,_,_,0).



test_freeze(NvBoard, NvPion, 0, -10):- pion_freeze(NvBoard, NvPion), !.
test_freeze(NvBoard, NvPion, 1, -10):- pion_freeze(NvBoard, NvPion), !.
test_freeze(_,_,_,0).



test_freeze_ennemi(Board,NvBoard,[X,Y,_,_], 0, 10):- Xtemp is X + 1, get_case(Board, (Xtemp,Y), [Xpion1,Ypion1,Type,gold]), \+pion_freeze(Board,[Xpion1,Ypion1,Type,gold]), pion_freeze(NvBoard,[Xpion1,Ypion1,Type,gold]).
test_freeze_ennemi(Board,NvBoard,[X,Y,_,_], 0, 10):- Xtemp is X - 1, get_case(Board, (Xtemp,Y), [Xpion1,Ypion1,Type,gold]), \+pion_freeze(Board,[Xpion1,Ypion1,Type,gold]), pion_freeze(NvBoard,[Xpion1,Ypion1,Type,gold]).
test_freeze_ennemi(Board,NvBoard,[X,Y,_,_], 0, 10):- Ytemp is Y + 1, get_case(Board, (X,Ytemp), [Xpion1,Ypion1,Type,gold]), \+pion_freeze(Board,[Xpion1,Ypion1,Type,gold]), pion_freeze(NvBoard,[Xpion1,Ypion1,Type,gold]).
test_freeze_ennemi(Board,NvBoard,[X,Y,_,_], 0, 10):- Ytemp is Y - 1, get_case(Board, (X,Ytemp), [Xpion1,Ypion1,Type,gold]), \+pion_freeze(Board,[Xpion1,Ypion1,Type,gold]), pion_freeze(NvBoard,[Xpion1,Ypion1,Type,gold]).

test_freeze_ennemi(Board,NvBoard,[X,Y,_,_], 1, 20):- Xtemp is X + 1, get_case(Board, (Xtemp,Y), [Xpion1,Ypion1,rabbit,gold]), \+pion_freeze(Board,[Xpion1,Ypion1,rabbit,gold]), pion_freeze(NvBoard,[Xpion1,Ypion1,rabbit,gold]).
test_freeze_ennemi(Board,NvBoard,[X,Y,_,_], 1, 20):- Xtemp is X - 1, get_case(Board, (Xtemp,Y), [Xpion1,Ypion1,rabbit,gold]), \+pion_freeze(Board,[Xpion1,Ypion1,rabbit,gold]), pion_freeze(NvBoard,[Xpion1,Ypion1,rabbit,gold]).
test_freeze_ennemi(Board,NvBoard,[X,Y,_,_], 1, 20):- Ytemp is Y + 1, get_case(Board, (X,Ytemp), [Xpion1,Ypion1,rabbit,gold]), \+pion_freeze(Board,[Xpion1,Ypion1,rabbit,gold]), pion_freeze(NvBoard,[Xpion1,Ypion1,rabbit,gold]).
test_freeze_ennemi(Board,NvBoard,[X,Y,_,_], 1, 20):- Ytemp is Y - 1, get_case(Board, (X,Ytemp), [Xpion1,Ypion1,rabbit,gold]), \+pion_freeze(Board,[Xpion1,Ypion1,rabbit,gold]), pion_freeze(NvBoard,[Xpion1,Ypion1,rabbit,gold]).
test_freeze_ennemi(Board,NvBoard,[X,Y,_,_], 1, 10):- Xtemp is X + 1, get_case(Board, (Xtemp,Y), [Xpion1,Ypion1,Type,gold]), \+pion_freeze(Board,[Xpion1,Ypion1,Type,gold]), pion_freeze(NvBoard,[Xpion1,Ypion1,Type,gold]).
test_freeze_ennemi(Board,NvBoard,[X,Y,_,_], 1, 10):- Xtemp is X - 1, get_case(Board, (Xtemp,Y), [Xpion1,Ypion1,Type,gold]), \+pion_freeze(Board,[Xpion1,Ypion1,Type,gold]), pion_freeze(NvBoard,[Xpion1,Ypion1,Type,gold]).
test_freeze_ennemi(Board,NvBoard,[X,Y,_,_], 1, 10):- Ytemp is Y + 1, get_case(Board, (X,Ytemp), [Xpion1,Ypion1,Type,gold]), \+pion_freeze(Board,[Xpion1,Ypion1,Type,gold]), pion_freeze(NvBoard,[Xpion1,Ypion1,Type,gold]).
test_freeze_ennemi(Board,NvBoard,[X,Y,_,_], 1, 10):- Ytemp is Y - 1, get_case(Board, (X,Ytemp), [Xpion1,Ypion1,Type,gold]), \+pion_freeze(Board,[Xpion1,Ypion1,Type,gold]), pion_freeze(NvBoard,[Xpion1,Ypion1,Type,gold]).

test_freeze_ennemi(_,_,_,_,0).



test_defreeze_ennemi(Board,NvBoard,[X,Y,_,_], 0, -10):- Xtemp is X + 1, get_case(Board, (Xtemp,Y), [Xpion1,Ypion1,Type,gold]), pion_freeze(Board,[Xpion1,Ypion1,Type,gold]), \+pion_freeze(NvBoard,[Xpion1,Ypion1,Type,gold]).
test_defreeze_ennemi(Board,NvBoard,[X,Y,_,_], 0, -10):- Xtemp is X - 1, get_case(Board, (Xtemp,Y), [Xpion1,Ypion1,Type,gold]), pion_freeze(Board,[Xpion1,Ypion1,Type,gold]), \+pion_freeze(NvBoard,[Xpion1,Ypion1,Type,gold]).
test_defreeze_ennemi(Board,NvBoard,[X,Y,_,_], 0, -10):- Ytemp is Y + 1, get_case(Board, (X,Ytemp), [Xpion1,Ypion1,Type,gold]), pion_freeze(Board,[Xpion1,Ypion1,Type,gold]), \+pion_freeze(NvBoard,[Xpion1,Ypion1,Type,gold]).
test_defreeze_ennemi(Board,NvBoard,[X,Y,_,_], 0, -10):- Ytemp is Y - 1, get_case(Board, (X,Ytemp), [Xpion1,Ypion1,Type,gold]), pion_freeze(Board,[Xpion1,Ypion1,Type,gold]), \+pion_freeze(NvBoard,[Xpion1,Ypion1,Type,gold]).

test_defreeze_ennemi(Board,NvBoard,[X,Y,_,_], 1, -20):- Xtemp is X + 1, get_case(Board, (Xtemp,Y), [Xpion1,Ypion1,rabbit,gold]), pion_freeze(Board,[Xpion1,Ypion1,rabbit,gold]), \+pion_freeze(NvBoard,[Xpion1,Ypion1,rabbit,gold]).
test_defreeze_ennemi(Board,NvBoard,[X,Y,_,_], 1, -20):- Xtemp is X - 1, get_case(Board, (Xtemp,Y), [Xpion1,Ypion1,rabbit,gold]), pion_freeze(Board,[Xpion1,Ypion1,rabbit,gold]), \+pion_freeze(NvBoard,[Xpion1,Ypion1,rabbit,gold]).
test_defreeze_ennemi(Board,NvBoard,[X,Y,_,_], 1, -20):- Ytemp is Y + 1, get_case(Board, (X,Ytemp), [Xpion1,Ypion1,rabbit,gold]), pion_freeze(Board,[Xpion1,Ypion1,rabbit,gold]), \+pion_freeze(NvBoard,[Xpion1,Ypion1,rabbit,gold]).
test_defreeze_ennemi(Board,NvBoard,[X,Y,_,_], 1, -20):- Ytemp is Y - 1, get_case(Board, (X,Ytemp), [Xpion1,Ypion1,rabbit,gold]), pion_freeze(Board,[Xpion1,Ypion1,rabbit,gold]), \+pion_freeze(NvBoard,[Xpion1,Ypion1,rabbit,gold]).
test_defreeze_ennemi(Board,NvBoard,[X,Y,_,_], 1, -10):- Xtemp is X + 1, get_case(Board, (Xtemp,Y), [Xpion1,Ypion1,Type,gold]), pion_freeze(Board,[Xpion1,Ypion1,Type,gold]), \+pion_freeze(NvBoard,[Xpion1,Ypion1,Type,gold]).
test_defreeze_ennemi(Board,NvBoard,[X,Y,_,_], 1, -10):- Xtemp is X - 1, get_case(Board, (Xtemp,Y), [Xpion1,Ypion1,Type,gold]), pion_freeze(Board,[Xpion1,Ypion1,Type,gold]), \+pion_freeze(NvBoard,[Xpion1,Ypion1,Type,gold]).
test_defreeze_ennemi(Board,NvBoard,[X,Y,_,_], 1, -10):- Ytemp is Y + 1, get_case(Board, (X,Ytemp), [Xpion1,Ypion1,Type,gold]), pion_freeze(Board,[Xpion1,Ypion1,Type,gold]), \+pion_freeze(NvBoard,[Xpion1,Ypion1,Type,gold]).
test_defreeze_ennemi(Board,NvBoard,[X,Y,_,_], 1, -10):- Ytemp is Y - 1, get_case(Board, (X,Ytemp), [Xpion1,Ypion1,Type,gold]), pion_freeze(Board,[Xpion1,Ypion1,Type,gold]), \+pion_freeze(NvBoard,[Xpion1,Ypion1,Type,gold]).

test_defreeze_ennemi(_,_,_,_,0).



test_blocage_lapin(Board, [X,Y,_,_], 1, 15):- voisinB(Board, (X,Y), [Xennemi,_,rabbit,gold]), Xennemi < 4 .
test_blocage_lapin(Board, [X,Y,_,_], 1, 8):- voisinG(Board, (X,Y), [Xennemi,_,rabbit,gold]),  Xennemi < 4 .
test_blocage_lapin(Board, [X,Y,_,_], 1, 8):- voisinD(Board, (X,Y), [Xennemi,_,rabbit,gold]),  Xennemi < 4 .
test_blocage_lapin(_, _, _, 0).



test_deblocage_lapin(Board, [X,Y,_,_], 1, -15):- voisinB(Board, (X,Y), [Xennemi,_,rabbit,gold]), Xennemi < 4 .
test_deblocage_lapin(Board, [X,Y,_,_], 1, -8):- voisinG(Board, (X,Y), [Xennemi,_,rabbit,gold]),  Xennemi < 4 .
test_deblocage_lapin(Board, [X,Y,_,_], 1, -8):- voisinD(Board, (X,Y), [Xennemi,_,rabbit,gold]),  Xennemi < 4 .
test_deblocage_lapin(_, _, _, 0).
	

%predicat qui choisis la meilleur action parmi une liste
%contrairement à meilleur_action ce prédicat unifie Res avec un score.
meilleur_score([], 0).
meilleur_score([T|Q], Res):- retractall(actionMaxScore(_)), asserta(actionMaxScore(T)), choix_meilleur_action(Q), actionMaxScore([Res|_]), !.
	
	
%Prédicat similaire à meilleur_action mais qui permet d'obtenir le score.
	
meilleur_score([],[],[],0,0):- !.
meilleur_score([Sc1|_], [], [], 1, Sc1):- !.
meilleur_score([], [Sc2|[_]], [], 2, Sc2):- !.
meilleur_score([], [], [Sc3|[_]], 2, Sc3):- !.
meilleur_score([Sc1|_], [], [Sc3|[_]], 1, Sc1):- Sc1 >= Sc3, !.
meilleur_score([Sc1|_], [Sc2|[_]], [], 2, Sc2):- Sc2 >= Sc1, !.
meilleur_score([Sc1|_], [Sc2|[_]], [], 1, Sc1):- Sc1 >= Sc2, !.
meilleur_score([], [Sc2|_], [Sc3|[_]], 2, Sc3):- Sc3 >= Sc2, !.
meilleur_score([Sc1|_], [], [Sc3|[_]], 2, Sc3):- Sc3 >= Sc1, !.
meilleur_score([], [Sc2|[_]], [Sc3|_], 2, Sc2):- Sc2 >= Sc3, !.
meilleur_score([Sc1|_], [Sc2|[_]], [Sc3|[_]], 1, Sc1):- Sc1 >= Sc2, Sc1 >= Sc3, !.
meilleur_score([Sc1|_], [Sc2|[_]], [Sc3|[_]], 2, Sc2):- Sc2 >= Sc1, Sc2 >= Sc3, !.
meilleur_score([Sc1|_], [Sc2|[_]], [Sc3|[_]], 2, Sc3):- Sc3 >= Sc2, Sc3 >= Sc1.
	
	

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	Prédicats Mise à jour du plateau		%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%update_board(Board, NvBoard, Gamestate, NvGamestate, Action(s))
%1- deplacement
%2- test mort (maj board si mort)
%3- boucle autant de fois qu'il y a d'actions

update_board(Board, Board, Gamestate, Gamestate, []):- !.
update_board(Board, NvBoard, Gamestate, NvGamestate, [[[Xdepart, Ydepart], [Xarrive, Yarrive]]|Q]):- deplacement(Board, TmpNvBoard, (Xdepart,Ydepart), (Xarrive,Yarrive)), maj_mort(TmpNvBoard,TmpNvBoard2,Gamestate,TmpNvGamestate,(XTemp,YTemp)), update_board(TmpNvBoard2, NvBoard, TmpNvGamestate, NvGamestate, Q).

% EXEMPLE EXECUTION :
%update_board([[1,2,rabbit, silver],[5,7, rabbit, gold]], NvBoard, [silver, []], NvGamestate, [[[1,2],[2,2]]] ).
%update_board([[1,2,rabbit, silver],[5,7, rabbit, gold], [2,3,rabbit,silver]], NvBoard, [silver, []], NvGamestate, [[[1,2],[2,2]]] ).
%update_board([[0,0,cat, silver],[1,0, rabbit, gold]], NvBoard, [silver, []], NvGamestate, [[[1, 0], [2, 0]], [[0, 0], [1, 0]]] ).
%update_board([[3,5,cat, silver],[4,5, rabbit, gold]], NvBoard, [silver, []], NvGamestate, [[[4, 5], [5, 5]], [[3, 5], [4, 5]]] ).
%update_board([[3,5,cat, silver],[4,5, rabbit, gold], [6,5, rabbit, gold]], NvBoard, [silver, []], NvGamestate, [[[4, 5], [5, 5]], [[3, 5], [4, 5]]] ).
%update_board([[1,2,elephant,silver],[0,3,horse,silver],[0,4,rabbit,silver],[0,5,dog,silver],[0,6,camel,silver],[0,7,rabbit,silver],[2,2,dog,silver],[1,3,rabbit,silver],[1,4,cat,silver],[1,5,cat,silver],[1,6,horse,silver],[1,7,rabbit,silver],[2,0,rabbit,silver],[2,1,rabbit,silver],[2,3,camel,gold],[2,4,elephant,gold],[3,0,rabbit,silver],[3,1,rabbit,silver],[4,0,rabbit,gold],[4,6,rabbit,gold],[6,1,cat,gold],[6,2,dog,gold],[6,5,rabbit,gold],[6,7,cat,gold],[7,0,rabbit,gold],[7,1,rabbit,gold],[7,2,rabbit,gold],[7,3,rabbit,gold],[7,4,rabbit,gold],[7,5,horse,gold],[7,6,horse,gold],[7,7,dog,gold]], NvBoard, [silver, []], NvGamestate,  [[[2, 2], [3, 2]]]).
%update_board([[2,3,rabbit, gold], [1,3,dog,silver]], NvBoard, [silver, []], NvGamestate, [[[2,3],[2,2]],[[1,3],[2,3]]]).

%maj_mort(Board,NvBoard,Gamestate,NvGamestate, Coordonées)
%Verifie si un pion Joueur sur une trappe est mort, si oui, on modifie le Board et le Gamestate.
%Remarque : Avec une seule action il est impossible d'avoir deux morts.

maj_mort(Board,NvBoard,Gamestate,NvGamestate,(X,Y)):- mort(Board, (X,Y)), get_case(Board, (X,Y), Pion), delete_pion(Pion, Board, NvBoard), maj_gamestate(Pion, Gamestate, NvGamestate), !.
maj_mort(Board, Board, Gamestate, Gamestate, _).

%EXEMPLE EXECUTION :
%maj_mort([[2,2,rabbit, silver]], NvBoard, [silver, []], NvGamestate, (X,Y)).
%maj_mort([[1,2,elephant,silver],[0,3,horse,silver],[0,4,rabbit,silver],[0,5,dog,silver],[0,6,camel,silver],[0,7,rabbit,silver],[3,2,dog,silver],[1,3,rabbit,silver],[1,4,cat,silver],[1,5,cat,silver],[1,6,horse,silver],[1,7,rabbit,silver],[2,0,rabbit,silver],[2,1,rabbit,silver],[2,3,camel,gold],[2,4,elephant,gold],[3,0,rabbit,silver],[3,1,rabbit,silver],[4,0,rabbit,gold],[4,6,rabbit,gold],[6,1,cat,gold],[6,2,dog,gold],[6,5,rabbit,gold],[6,7,cat,gold],[7,0,rabbit,gold],[7,1,rabbit,gold],[7,2,rabbit,gold],[7,3,rabbit,gold],[7,4,rabbit,gold],[7,5,horse,gold],[7,6,horse,gold],[7,7,dog,gold]],NvBoard,[silver, []], NvGamestate, (X,Y)).

%mort(Board, CoordonéesTrappes)
%Verifie si un pion est mort, si oui est vrai.

mort(Board, (2,2)):- voisins(Board, (2,2), Res), get_case(Board, (2,2), [2,2,_,Joueur]), Joueur \= -1, \+element([_,_,_,Joueur], Res), !.
mort(Board, (2,5)):- voisins(Board, (2,5), Res), get_case(Board, (2,5), [2,5,_,Joueur]), Joueur \= -1, \+element([_,_,_,Joueur], Res), !.
mort(Board, (5,2)):- voisins(Board, (5,2), Res), get_case(Board, (5,2), [5,2,_,Joueur]), Joueur \= -1, \+element([_,_,_,Joueur], Res), !.
mort(Board, (5,5)):- voisins(Board, (5,5), Res), get_case(Board, (5,5), [5,5,_,Joueur]), Joueur \= -1, \+element([_,_,_,Joueur], Res), !.
mort(_,_):- fail. 

%EXEMPLE EXECUTION :
%mort([[2,2,rabbit,silver]], (2,2)).
%mort([[5,5,rabbit,silver], [6,5,rabbit,gold]], (5,5)).
%mort([[2,2,rabbit,silver], [3,2,rabbit,silver]], (2,2)).
%mort([[1,2,elephant,silver],[0,3,horse,silver],[0,4,rabbit,silver],[0,5,dog,silver],[0,6,camel,silver],[0,7,rabbit,silver],[3,2,dog,silver],[1,3,rabbit,silver],[1,4,cat,silver],[1,5,cat,silver],[1,6,horse,silver],[1,7,rabbit,silver],[2,0,rabbit,silver],[2,1,rabbit,silver],[2,3,camel,gold],[2,4,elephant,gold],[3,0,rabbit,silver],[3,1,rabbit,silver],[4,0,rabbit,gold],[4,6,rabbit,gold],[6,1,cat,gold],[6,2,dog,gold],[6,5,rabbit,gold],[6,7,cat,gold],[7,0,rabbit,gold],[7,1,rabbit,gold],[7,2,rabbit,gold],[7,3,rabbit,gold],[7,4,rabbit,gold],[7,5,horse,gold],[7,6,horse,gold],[7,7,dog,gold]],(X,Y)).


%maj_gamestate(Pion, Gamestate, NvGamestate)
%Modifie le gamestate en ajoutant un pion

maj_gamestate(Pion, [Joueur | [Liste]], [Joueur | [R]]):- concat([Pion], Liste, R).

%EXEMPLE EXECUTION :
%maj_gamestate([2,2,rabbit,silver], [silver, []], Res).
%maj_gamestate([2,2,rabbit,silver], [silver, [ [0,1,rabbit,silver],[0,2,horse,silver] ]], Res).


%deplacement(Board,NvBoard,Depart,Arrive) :- NvBoard s unifie avec Board modifié, on modifie seulement les coordonnées d une pièce sans verification.

deplacement([[A,B,C,D]|E], [[LigneA,ColonneA,C,D]|E], (A,B), (LigneA, ColonneA)):- !.
deplacement([A|E], [A|R], (LigneD,ColonneD), (LigneA, ColonneA) ):- deplacement(E,R,(LigneD,ColonneD), (LigneA, ColonneA) ).

%EXEMPLE EXECUTION :
%deplacement([[0,0,rabbit,silver],[0,1,rabbit,silver],[0,2,horse,silver],[0,3,rabbit,silver],[0,4,elephant,silver],[0,5,rabbit,silver],[0,6,rabbit,silver],[0,7,rabbit,silver],[1,0,camel,silver],[1,1,cat,silver],[1,2,rabbit,silver],[1,3,dog,silver],[1,4,rabbit,silver],[1,5,horse,silver],[1,6,dog,silver],[1,7,cat,silver],[2,7,rabbit,gold],[6,0,cat,gold],[6,1,horse,gold],[6,2,camel,gold],[6,3,elephant,gold],[6,4,rabbit,gold],[6,5,dog,gold],[6,6,rabbit,gold],[7,0,rabbit,gold],[7,1,rabbit,gold],[7,2,rabbit,gold],[7,3,cat,gold],[7,4,dog,gold],[7,5,rabbit,gold],[7,6,horse,gold],[7,7,rabbit,gold]], Res, (1,1), (2,1)).


%suppression d un pion du plateau.
%PROTOTYPE : delete_pion(pion,board,R).
%EXECUTION : delete_pion([0,0,rabbit,silver],[[0,0,rabbit,silver],[0,1,rabbit,silver],[0,2,horse,silver],[0,3,rabbit,silver],[0,4,elephant,silver],[0,5,rabbit,silver],[0,6,rabbit,silver],[0,7,rabbit,silver],[1,0,camel,silver],[1,1,cat,silver],[1,2,rabbit,silver],[1,3,dog,silver],[1,4,rabbit,silver],[1,5,horse,silver],[1,6,dog,silver],[1,7,cat,silver],[2,7,rabbit,gold],[6,0,cat,gold],[6,1,horse,gold],[6,2,camel,gold],[6,3,elephant,gold],[6,4,rabbit,gold],[6,5,dog,gold],[6,6,rabbit,gold],[7,0,rabbit,gold],[7,1,rabbit,gold],[7,2,rabbit,gold],[7,3,cat,gold],[7,4,dog,gold],[7,5,rabbit,gold],[7,6,horse,gold],[7,7,rabbit,gold]],R).

% delete_pion(_,[],_).
% delete_pion(X,[X|Q],R):- concat(_,Q,R),!.
% delete_pion(X,[T|Q],[T|R]):-delete_pion(X,Q,R).

delete_pion(_,[],_).
delete_pion(X,[X|Q],Q):- !.
delete_pion(X,[T|Q],[T|R]):-delete_pion(X,Q,R).



	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	Prédicats règles du jeu Arimaa				%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	
%pion_freeze(Board,Pion) --> indique si un pion est freeze (ne peut rien faire).

pion_freeze(Board, [X,Y,TypeAllie,silver]):- voisins(Board, (X,Y), Res), element([_,_,TypeEnnemi,gold], Res), plus_fort(TypeEnnemi, TypeAllie), \+element([_,_,_,silver], Res).
pion_freeze(Board, [X,Y,TypeAllie,gold]):- voisins(Board, (X,Y), Res), element([_,_,TypeEnnemi,silver], Res), plus_fort(TypeEnnemi, TypeAllie), \+element([_,_,_,gold], Res).

%EXEMPLE EXECUTION: 
%pion_freeze([[4,4,rabbit,silver],[5,4,dog,gold]], [4,4,rabbit,silver] ).
%pion_freeze([[4,4,camel,silver],[5,4,dog,gold]], [4,4,camel,silver] ).
%pion_freeze([[4,4,camel,silver],[5,4,dog,gold],[3,4,elephant,gold]], [4,4,camel,silver] ).
%pion_freeze([[4,4,rabbit,silver],[3,4,rabbit,silver],[5,4,dog,gold]], [4,4,rabbit,silver]).
%pion_freeze([[2,4,rabbit,gold],[2,3,horse,silver]], [2,4,rabbit,gold]).
%pion_freeze([[1,2,rabbit,silver],[1,7,cat,silver],[2,2,rabbit,silver],[2,3,rabbit,silver],[2,6,rabbit,silver],[2,7,dog,silver],[3,0,horse,silver],[5,0,rabbit,silver],[3,2,horse,silver],[3,3,dog,silver],[3,4,elephant,silver],[3,5,rabbit,silver],[3,6,rabbit,silver],[4,4,rabbit,silver],[4,6,cat,silver],[5,1,camel,silver],[6,0,rabbit,gold],[6,1,camel,gold],[6,4,rabbit,gold],[6,5,rabbit,gold],[7,0,horse,gold],[7,1,rabbit,gold],[7,2,horse,gold],[7,4,elephant,gold],[7,5,cat,gold],[7,6,dog,gold],[7,7,dog,gold]],[5,0,rabbit,silver]).
%pion_freeze([[0,1,dog,silver],[0,2,horse,silver],[0,4,horse,silver],[0,5,rabbit,silver],[0,7,camel,silver],[1,3,rabbit,silver],[1,5,rabbit,silver],[1,7,rabbit,silver],[2,0,rabbit,silver],[2,1,rabbit,silver],[2,4,rabbit,silver],[3,0,rabbit,silver],[3,2,camel,gold],[4,2,cat,silver],[4,6,elephant,silver],[5,1,rabbit,gold],[5,6,dog,gold],[6,0,rabbit,gold],[6,2,rabbit,gold],[6,4,cat,gold],[6,5,horse,gold],[7,0,rabbit,gold],[7,1,dog,gold],[7,2,rabbit,gold],[7,5,elephant,gold]], [4,2,cat,silver] ).


%tout_deplacement_possible_silver(Board, TempBoard, Res) --> Res s unifie avec une liste de tous les deplacements possibles du joueur silver avec une profondeur de 1.
%Pour cela on utilise le prédicat deplacement_possible qui test si un deplacement est possible, et ce prédicat est combiné avec un setof.

%Board corresponds au plateau et ne sera pas modifié, TempBoard est une copie de Board qui permet un parcours un à un de chaque pion du plateau.

tout_deplacement_possible_silver(_, [], []).
tout_deplacement_possible_silver(Board, [[X,Y,Type,silver]|B], Res):- pion_deplacement_possible_silver(Board, [X,Y,Type,silver], TmpRes), tout_deplacement_possible_silver(Board,B,TRes), concat(TmpRes,TRes,Res), !.
tout_deplacement_possible_silver(Board, [[_,_,_,_]|B], Res):- tout_deplacement_possible_silver(Board, B, Res). 

%EXEMPLE EXECUTION :
%tout_deplacement_possible_silver([[0,0,rabbit,silver],[0,1,rabbit,silver],[0,2,horse,silver],[0,3,rabbit,silver],[0,4,elephant,silver],[0,5,rabbit,silver],[0,6,rabbit,silver],[0,7,rabbit,silver],[1,0,camel,silver],[1,1,cat,silver],[1,2,rabbit,silver],[1,3,dog,silver],[1,4,rabbit,silver],[1,5,horse,silver],[1,6,dog,silver],[1,7,cat,silver],[2,7,rabbit,gold],[6,0,cat,gold],[6,1,horse,gold],[6,2,camel,gold],[6,3,elephant,gold],[6,4,rabbit,gold],[6,5,dog,gold],[6,6,rabbit,gold],[7,0,rabbit,gold],[7,1,rabbit,gold],[7,2,rabbit,gold],[7,3,cat,gold],[7,4,dog,gold],[7,5,rabbit,gold],[7,6,horse,gold],[7,7,rabbit,gold]], [[0,0,rabbit,silver],[0,1,rabbit,silver],[0,2,horse,silver],[0,3,rabbit,silver],[0,4,elephant,silver],[0,5,rabbit,silver],[0,6,rabbit,silver],[0,7,rabbit,silver],[1,0,camel,silver],[1,1,cat,silver],[1,2,rabbit,silver],[1,3,dog,silver],[1,4,rabbit,silver],[1,5,horse,silver],[1,6,dog,silver],[1,7,cat,silver],[2,7,rabbit,gold],[6,0,cat,gold],[6,1,horse,gold],[6,2,camel,gold],[6,3,elephant,gold],[6,4,rabbit,gold],[6,5,dog,gold],[6,6,rabbit,gold],[7,0,rabbit,gold],[7,1,rabbit,gold],[7,2,rabbit,gold],[7,3,cat,gold],[7,4,dog,gold],[7,5,rabbit,gold],[7,6,horse,gold],[7,7,rabbit,gold]],Res).
%tout_deplacement_possible_silver([[0,1,dog,silver],[0,2,horse,silver],[0,4,horse,silver],[0,5,rabbit,silver],[0,7,camel,silver],[1,3,rabbit,silver],[1,5,rabbit,silver],[1,7,rabbit,silver],[2,0,rabbit,silver],[2,1,rabbit,silver],[2,4,rabbit,silver],[3,0,rabbit,silver],[3,2,camel,gold],[4,2,cat,silver],[4,6,elephant,silver],[5,1,rabbit,gold],[5,6,dog,gold],[6,0,rabbit,gold],[6,2,rabbit,gold],[6,4,cat,gold],[6,5,horse,gold],[7,0,rabbit,gold],[7,1,dog,gold],[7,2,rabbit,gold],[7,5,elephant,gold]], [[0,1,dog,silver],[0,2,horse,silver],[0,4,horse,silver],[0,5,rabbit,silver],[0,7,camel,silver],[1,3,rabbit,silver],[1,5,rabbit,silver],[1,7,rabbit,silver],[2,0,rabbit,silver],[2,1,rabbit,silver],[2,4,rabbit,silver],[3,0,rabbit,silver],[3,2,camel,gold],[4,2,cat,silver],[4,6,elephant,silver],[5,1,rabbit,gold],[5,6,dog,gold],[6,0,rabbit,gold],[6,2,rabbit,gold],[6,4,cat,gold],[6,5,horse,gold],[7,0,rabbit,gold],[7,1,dog,gold],[7,2,rabbit,gold],[7,5,elephant,gold]], Res).


%pion_deplacement_possible_silver(_silverBoard, Pion, Resultat)--> pour un pion donné unifie Resultat avec tous ses deplacements possibles.

pion_deplacement_possible_silver(Board, [Xdepart,Ydepart,TypeAllie,silver], Res):- \+ pion_freeze(Board, [Xdepart,Ydepart,TypeAllie,silver]), setof([[Xdepart,Ydepart],[Xarrive,Yarrive]], deplacement_possible_silver(Board,[[Xdepart,Ydepart],[Xarrive,Yarrive]]), Res).

%EXEMPLE EXECUTION :
%pion_deplacement_possible_silver([[4,7,cat,silver],[5,7,rabbit,silver]],[4,7,cat,silver], Res ).
%pion_deplacement_possible_silver([[4,7,rabbit,silver],[5,7,rabbit,silver]],[4,7,rabbit,silver], Res ).
%pion_deplacement_possible_silver([[4,7,rabbit,silver],[5,7,cat,gold]],[4,7,rabbit,silver], Res ).
%pion_deplacement_possible_silver([[4,7,cat,silver],[5,7,cat,gold]],[4,7,cat,silver], Res ).
%pion_deplacement_possible_silver([[1,2,rabbit,silver],[1,7,cat,silver],[2,2,rabbit,silver],[2,3,rabbit,silver],[2,6,rabbit,silver],[2,7,dog,silver],[3,0,horse,silver],[5,0,rabbit,silver],[3,2,horse,silver],[3,3,dog,silver],[3,4,elephant,silver],[3,5,rabbit,silver],[3,6,rabbit,silver],[4,4,rabbit,silver],[4,6,cat,silver],[5,1,camel,silver],[6,0,rabbit,gold],[6,1,camel,gold],[6,4,rabbit,gold],[6,5,rabbit,gold],[7,0,horse,gold],[7,1,rabbit,gold],[7,2,horse,gold],[7,4,elephant,gold],[7,5,cat,gold],[7,6,dog,gold],[7,7,dog,gold]],[5,0,rabbit,silver], Res).


%deplacement_possible_silver(Board, Deplacement ) --> renvoie vrai si le deplacement du pion d une case à une autre case voisine (précisée) est possible sinon renvoie faux (la profondeur du deplacement est de 1 case).

deplacement_possible_silver(Board, [[X,Y],[Z,Y]]):- get_case(Board, (X,Y), [X,Y,C,D]), C \= -1, D \= -1, Z is X+1, voisinB(Board,(X,Y),[Z,Y,A,B]), A = -1, B = -1.
deplacement_possible_silver(Board, [[X,Y],[Z,Y]]):- get_case(Board, (X,Y), [X,Y,C,D]), C \= -1, C \= rabbit, D \= -1, Z is X-1, voisinH(Board,(X,Y),[Z,Y,A,B]), A = -1, B = -1.
deplacement_possible_silver(Board, [[X,Y],[X,Z]]):- get_case(Board, (X,Y), [X,Y,C,D]), C \= -1, D \= -1, Z is Y+1, voisinD(Board,(X,Y),[X,Z,A,B]), A = -1, B = -1.
deplacement_possible_silver(Board, [[X,Y],[X,Z]]):- get_case(Board, (X,Y), [X,Y,C,D]), C \= -1, D \= -1, Z is Y-1, voisinG(Board,(X,Y),[X,Z,A,B]), A = -1, B = -1.

%EXEMPLES EXECUTION :
%deplacement_possible_silver([[0,0,rabbit,silver],[0,1,rabbit,silver],[0,2,horse,silver],[0,3,rabbit,silver],[0,4,elephant,silver],[0,5,rabbit,silver],[0,6,rabbit,silver],[0,7,rabbit,silver],[1,0,camel,silver],[1,1,cat,silver],[1,2,rabbit,silver],[1,3,dog,silver],[1,4,rabbit,silver],[1,5,horse,silver],[1,6,dog,silver],[1,7,cat,silver],[2,7,rabbit,gold],[6,0,cat,gold],[6,1,horse,gold],[6,2,camel,gold],[6,3,elephant,gold],[6,4,rabbit,gold],[6,5,dog,gold],[6,6,rabbit,gold],[7,0,rabbit,gold],[7,1,rabbit,gold],[7,2,rabbit,gold],[7,3,cat,gold],[7,4,dog,gold],[7,5,rabbit,gold],[7,6,horse,gold],[7,7,rabbit,gold]],[[1,0],[2,0]]).
%deplacement_possible_silver([[0,0,rabbit,silver],[0,1,rabbit,silver],[0,2,horse,silver],[0,3,rabbit,silver],[0,4,elephant,silver],[0,5,rabbit,silver],[0,6,rabbit,silver],[0,7,rabbit,silver],[1,0,camel,silver],[1,1,cat,silver],[1,2,rabbit,silver],[1,3,dog,silver],[1,4,rabbit,silver],[1,5,horse,silver],[1,6,dog,silver],[1,7,cat,silver],[2,7,rabbit,gold],[6,0,cat,gold],[6,1,horse,gold],[6,2,camel,gold],[6,3,elephant,gold],[6,4,rabbit,gold],[6,5,dog,gold],[6,6,rabbit,gold],[7,0,rabbit,gold],[7,1,rabbit,gold],[7,2,rabbit,gold],[7,3,cat,gold],[7,4,dog,gold],[7,5,rabbit,gold],[7,6,horse,gold],[7,7,rabbit,gold]],[[6,6],[X,Y]]).
%setof([[6,6],[X,Y]],deplacement_possible([[0,0,rabbit,silver],[0,1,rabbit,silver],[0,2,horse,silver],[0,3,rabbit,silver],[0,4,elephant,silver],[0,5,rabbit,silver],[0,6,rabbit,silver],[0,7,rabbit,silver],[1,0,camel,silver],[1,1,cat,silver],[1,2,rabbit,silver],[1,3,dog,silver],[1,4,rabbit,silver],[1,5,horse,silver],[1,6,dog,silver],[1,7,cat,silver],[2,7,rabbit,gold],[6,0,cat,gold],[6,1,horse,gold],[6,2,camel,gold],[6,3,elephant,gold],[6,4,rabbit,gold],[6,5,dog,gold],[6,6,rabbit,gold],[7,0,rabbit,gold],[7,1,rabbit,gold],[7,2,rabbit,gold],[7,3,cat,gold],[7,4,dog,gold],[7,5,rabbit,gold],[7,6,horse,gold],[7,7,rabbit,gold]],[[6,6],[X,Y]]),Res).


%tout_pousser_possible_silver(Board, TempBoard, Resultat): Resultat s'unifie avec toutes les actions pousser dispo.

tout_pousser_possible_silver(_, [], []).
tout_pousser_possible_silver(Board, [[X,Y,Type,silver]|B], Res):- pion_pousser_possible_silver(Board,[X,Y,Type,silver], TmpRes), tout_pousser_possible_silver(Board,B,TRes), concat(TmpRes,TRes,Res), !.
tout_pousser_possible_silver(Board, [[_,_,_,_]|B], Res):- tout_pousser_possible_silver(Board, B, Res). 

%EXEMPLE EXECUTION:
%tout_pousser_possible_silver([[0,0,rabbit,silver],[0,1,rabbit,silver],[0,2,horse,silver],[0,3,rabbit,silver],[0,4,elephant,silver],[0,5,rabbit,silver],[0,6,rabbit,silver],[0,7,rabbit,silver],[1,0,camel,silver],[1,1,cat,silver],[1,2,rabbit,silver],[1,3,dog,silver],[1,4,rabbit,silver],[1,5,horse,silver],[1,6,dog,silver],[1,7,cat,silver],[2,7,rabbit,gold],[6,0,cat,gold],[6,1,horse,gold],[6,2,camel,gold],[6,3,elephant,gold],[6,4,rabbit,gold],[6,5,dog,gold],[6,6,rabbit,gold],[7,0,rabbit,gold],[7,1,rabbit,gold],[7,2,rabbit,gold],[7,3,cat,gold],[7,4,dog,gold],[7,5,rabbit,gold],[7,6,horse,gold],[7,7,rabbit,gold]], [[0,0,rabbit,silver],[0,1,rabbit,silver],[0,2,horse,silver],[0,3,rabbit,silver],[0,4,elephant,silver],[0,5,rabbit,silver],[0,6,rabbit,silver],[0,7,rabbit,silver],[1,0,camel,silver],[1,1,cat,silver],[1,2,rabbit,silver],[1,3,dog,silver],[1,4,rabbit,silver],[1,5,horse,silver],[1,6,dog,silver],[1,7,cat,silver],[2,7,rabbit,gold],[6,0,cat,gold],[6,1,horse,gold],[6,2,camel,gold],[6,3,elephant,gold],[6,4,rabbit,gold],[6,5,dog,gold],[6,6,rabbit,gold],[7,0,rabbit,gold],[7,1,rabbit,gold],[7,2,rabbit,gold],[7,3,cat,gold],[7,4,dog,gold],[7,5,rabbit,gold],[7,6,horse,gold],[7,7,rabbit,gold]], Res).


%pion_pousser_possible_silver(Board, Pion, Resultat) --> Pour un pion donné, Resultat s'unifie avec une liste d'actions pousser possible. Pour cela on liste les actions pousser possible pour chaque case voisine: Haut, Bas, Gauche, droite.

pion_pousser_possible_silver(Board, [Xallie, Yallie, TypeAllie, silver], Res):- \+ pion_freeze(Board, [Xallie,Yallie,TypeAllie,silver]), pion_pousser_possibleB_silver(Board, [Xallie, Yallie, _, silver], Res1), pion_pousser_possibleH_silver(Board, [Xallie, Yallie, _, silver], Res2), pion_pousser_possibleD_silver(Board, [Xallie, Yallie, _, silver], Res3), pion_pousser_possibleG_silver(Board, [Xallie, Yallie, _, silver], Res4), concat(Res1,Res2,TmpRes1), concat(Res3, Res4, TmpRes2), concat(TmpRes1, TmpRes2, Res).

pion_pousser_possibleB_silver(Board, [Xallie, Yallie, _, silver], Res):- Xennemi is Xallie + 1, Yennemi is Yallie, setof([[[Xennemi,Yennemi],[Vennemi,Wennemi]],[[Xallie,Yallie],[Xennemi,Yennemi]]], pousser_possible_silver(Board,[[[Xennemi,Yennemi],[Vennemi,Wennemi]],[[Xallie,Yallie],[Xennemi,Yennemi]]]), Res), !.
pion_pousser_possibleB_silver(_,_,[]).
pion_pousser_possibleH_silver(Board, [Xallie, Yallie, _, silver], Res):- Xennemi is Xallie - 1, Yennemi is Yallie, setof([[[Xennemi,Yennemi],[Vennemi,Wennemi]],[[Xallie,Yallie],[Xennemi,Yennemi]]], pousser_possible_silver(Board,[[[Xennemi,Yennemi],[Vennemi,Wennemi]],[[Xallie,Yallie],[Xennemi,Yennemi]]]), Res), !.
pion_pousser_possibleH_silver(_,_,[]).
pion_pousser_possibleD_silver(Board, [Xallie, Yallie, _, silver], Res):- Xennemi is Xallie, Yennemi is Yallie + 1, setof([[[Xennemi,Yennemi],[Vennemi,Wennemi]],[[Xallie,Yallie],[Xennemi,Yennemi]]], pousser_possible_silver(Board,[[[Xennemi,Yennemi],[Vennemi,Wennemi]],[[Xallie,Yallie],[Xennemi,Yennemi]]]), Res), !.
pion_pousser_possibleD_silver(_,_,[]).
pion_pousser_possibleG_silver(Board, [Xallie, Yallie, _, silver], Res):- Xennemi is Xallie, Yennemi is Yallie - 1, setof([[[Xennemi,Yennemi],[Vennemi,Wennemi]],[[Xallie,Yallie],[Xennemi,Yennemi]]], pousser_possible_silver(Board,[[[Xennemi,Yennemi],[Vennemi,Wennemi]],[[Xallie,Yallie],[Xennemi,Yennemi]]]), Res), !.
pion_pousser_possibleG_silver(_,_,[]).

%EXEMPLE EXECUTION :
%pion_pousser_possible_silver([[4,4,cat,silver],[3,4,rabbit,gold],[5,4,rabbit,gold],[4,3,rabbit,gold],[4,5,rabbit,gold]],[4,4,cat,silver],X).
%pion_pousser_possible_silver([[4,4,cat,silver],[3,4,rabbit,silver],[5,4,rabbit,silver]],[4,4,cat,silver],X).
%pion_pousser_possible_silver([[4,4,cat,silver],[3,4,dog,gold],[5,4,rabbit,gold],[4,3,rabbit,gold],[4,5,rabbit,gold]],[4,4,cat,silver],X).
%pion_pousser_possible_silver([[4,4,cat,silver]],[4,4,cat,silver],X).
%pion_pousser_possible_silver([[2,2,rabbit,silver],[2,6,rabbit,silver],[3,2,rabbit,silver],[3,4,elephant,silver],[3,6,rabbit,silver],[3,7,cat,silver],[4,1,rabbit,silver],[4,3,rabbit,silver],[4,4,rabbit,silver],[4,5,rabbit,silver],[4,6,cat,silver],[4,7,dog,silver],[5,0,horse,silver],[5,1,camel,silver],[6,2,horse,silver],[5,3,dog,silver],[6,0,rabbit,gold],[6,1,camel,gold],[6,3,rabbit,gold],[6,5,rabbit,gold],[7,0,horse,gold],[7,1,rabbit,gold],[7,2,horse,gold],[7,3,elephant,gold],[7,5,cat,gold],[7,6,dog,gold],[7,7,dog,gold]],[6,2,horse,silver], Res).


%pousser_possible_silver(Board, PousserEnnemi) -> PousserEnnemi de la forme : [[[[XennemiDepart,YennemiDepart],[XennemiArrive,YennemiArrive]]],[[XallieDepart,YallieDepart],[XallieArrive,YallieArrive]]]
%Comme pour deplacement_possible, permet de tester si un pion allie peut pousser un pion ennemi (déterminé).

pousser_possible_silver(Board, [[[Xennemi,Yennemi],[Zennemi,Yennemi]],[[Xallie,Yallie],[Xennemi,Yennemi]]]):- Zennemi is Xennemi+1, get_case(Board,(Xallie,Yallie), [Xallie,Yallie,TypeAllie,silver]), TypeAllie \= -1, get_case(Board, (Xennemi,Yennemi), [Xennemi,Yennemi,TypeEnnemi,gold]), TypeEnnemi \= -1, plus_fort(TypeAllie,TypeEnnemi), voisinB(Board,(Xennemi,Yennemi),[Zennemi,Yennemi,A,B]), A = -1, B = -1. 
pousser_possible_silver(Board, [[[Xennemi,Yennemi],[Zennemi,Yennemi]],[[Xallie,Yallie],[Xennemi,Yennemi]]]):- Zennemi is Xennemi-1, get_case(Board,(Xallie,Yallie), [Xallie,Yallie,TypeAllie,silver]), TypeAllie \= -1, get_case(Board, (Xennemi,Yennemi), [Xennemi,Yennemi,TypeEnnemi,gold]), TypeEnnemi \= -1, plus_fort(TypeAllie,TypeEnnemi), voisinH(Board,(Xennemi,Yennemi),[Zennemi,Yennemi,A,B]), A = -1, B = -1. 
pousser_possible_silver(Board, [[[Xennemi,Yennemi],[Xennemi,Zennemi]],[[Xallie,Yallie],[Xennemi,Yennemi]]]):- Zennemi is Yennemi+1, get_case(Board,(Xallie,Yallie), [Xallie,Yallie,TypeAllie,silver]), TypeAllie \= -1, get_case(Board, (Xennemi,Yennemi), [Xennemi,Yennemi,TypeEnnemi,gold]), TypeEnnemi \= -1, plus_fort(TypeAllie,TypeEnnemi), voisinD(Board,(Xennemi,Yennemi),[Xennemi,Zennemi,A,B]), A = -1, B = -1. 
pousser_possible_silver(Board, [[[Xennemi,Yennemi],[Xennemi,Zennemi]],[[Xallie,Yallie],[Xennemi,Yennemi]]]):- Zennemi is Yennemi-1, get_case(Board,(Xallie,Yallie), [Xallie,Yallie,TypeAllie,silver]), TypeAllie \= -1, get_case(Board, (Xennemi,Yennemi), [Xennemi,Yennemi,TypeEnnemi,gold]), TypeEnnemi \= -1, plus_fort(TypeAllie,TypeEnnemi), voisinG(Board,(Xennemi,Yennemi),[Xennemi,Zennemi,A,B]), A = -1, B = -1. 

%EXEMPLE EXECUTION:
%pousser_possible_silver([[4,5,rabbit,silver],[0,1,rabbit,silver],[4,6,horse,silver],[0,3,rabbit,silver],[0,4,elephant,silver],[0,5,rabbit,silver],[0,6,rabbit,silver],[0,7,rabbit,silver],[1,0,camel,silver],[1,1,cat,silver],[1,2,rabbit,silver],[1,3,dog,silver],[1,4,rabbit,silver],[1,5,horse,silver],[1,6,dog,silver],[1,7,cat,silver],[2,7,rabbit,gold],[6,0,cat,gold],[6,1,horse,gold],[6,2,camel,gold],[6,3,elephant,gold],[6,4,rabbit,gold],[6,5,dog,gold],[6,6,rabbit,gold],[7,0,rabbit,gold],[7,1,rabbit,gold],[5,5,rabbit,gold],[5,6,cat,gold],[7,4,dog,gold],[7,5,rabbit,gold],[7,6,horse,gold],[7,7,rabbit,gold]],[[[5,5],[6,5]],[[4,5],[5,5]]]).
%pousser_possible_silver([[4,5,rabbit,silver],[0,1,rabbit,silver],[4,6,horse,silver],[0,3,rabbit,silver],[0,4,elephant,silver],[0,5,rabbit,silver],[0,6,rabbit,silver],[0,7,rabbit,silver],[1,0,camel,silver],[1,1,cat,silver],[1,2,rabbit,silver],[1,3,dog,silver],[1,4,rabbit,silver],[1,5,horse,silver],[1,6,dog,silver],[1,7,cat,silver],[2,7,rabbit,gold],[6,0,cat,gold],[6,1,horse,gold],[6,2,camel,gold],[6,3,elephant,gold],[6,4,rabbit,gold],[6,5,dog,gold],[7,0,rabbit,gold],[7,1,rabbit,gold],[5,5,rabbit,gold],[5,6,cat,gold],[7,4,dog,gold],[7,5,rabbit,gold],[7,6,horse,gold],[7,7,rabbit,gold]],[[[5,6],[6,6]],[[4,6],[5,6]]]).
%pousser_possible_silver([[4,5,rabbit,silver],[0,1,rabbit,silver],[4,6,horse,silver],[0,3,rabbit,silver],[0,4,elephant,silver],[0,5,rabbit,silver],[0,6,rabbit,silver],[0,7,rabbit,silver],[1,0,camel,silver],[1,1,cat,silver],[1,2,rabbit,silver],[1,3,dog,silver],[1,4,rabbit,silver],[1,5,horse,silver],[1,6,dog,silver],[1,7,cat,silver],[2,7,rabbit,gold],[6,0,cat,gold],[6,1,horse,gold],[6,2,camel,gold],[6,3,elephant,gold],[6,4,rabbit,gold],[6,5,dog,gold],[7,0,rabbit,gold],[7,1,rabbit,gold],[5,5,rabbit,gold],[5,6,cat,gold],[7,4,dog,gold],[7,5,rabbit,gold],[7,6,horse,gold],[7,7,rabbit,gold]],[[[5,6],[X,Y]],[[4,6],[5,6]]]).
%setof([[[5,6],[X,Y]],[[4,6],[5,6]]],pousser_possible_silver([[4,5,rabbit,silver],[0,1,rabbit,silver],[4,6,horse,silver],[0,3,rabbit,silver],[0,4,elephant,silver],[0,5,rabbit,silver],[0,6,rabbit,silver],[0,7,rabbit,silver],[1,0,camel,silver],[1,1,cat,silver],[1,2,rabbit,silver],[1,3,dog,silver],[1,4,rabbit,silver],[1,5,horse,silver],[1,6,dog,silver],[1,7,cat,silver],[2,7,rabbit,gold],[6,0,cat,gold],[6,1,horse,gold],[6,2,camel,gold],[6,3,elephant,gold],[6,4,rabbit,gold],[6,5,dog,gold],[7,0,rabbit,gold],[7,1,rabbit,gold],[5,5,rabbit,gold],[5,6,cat,gold],[7,4,dog,gold],[7,5,rabbit,gold],[7,6,horse,gold],[7,7,rabbit,gold]],[[[5,6],[X,Y]],[[4,6],[5,6]]]), Res).


%tout_tirer_possible_silver(Board, TempBoard, Resultat): Resultat s'unifie avec toutes les actions tirer dispo.

tout_tirer_possible_silver(_, [], []).
tout_tirer_possible_silver(Board, [[X,Y,Type,silver]|B], Res):- pion_tirer_possible_silver(Board,[X,Y,Type,silver], TmpRes), tout_tirer_possible_silver(Board,B,TRes), concat(TmpRes,TRes,Res), !.
tout_tirer_possible_silver(Board, [[_,_,_,_]|B], Res):- tout_tirer_possible_silver(Board, B, Res). 

%EXEMPLE EXECUTION:
%tout_tirer_possible_silver([[0,0,rabbit,silver],[0,1,rabbit,silver],[0,2,horse,silver],[0,3,rabbit,silver],[0,4,elephant,silver],[0,5,rabbit,silver],[0,6,rabbit,silver],[0,7,rabbit,silver],[1,0,camel,silver],[1,1,cat,silver],[1,2,rabbit,silver],[1,3,dog,silver],[1,4,rabbit,silver],[1,5,horse,silver],[1,6,dog,silver],[3,7,cat,silver],[2,7,rabbit,gold],[6,0,cat,gold],[6,1,horse,gold],[6,2,camel,gold],[6,3,elephant,gold],[6,4,rabbit,gold],[6,5,dog,gold],[6,6,rabbit,gold],[7,0,rabbit,gold],[7,1,rabbit,gold],[7,2,rabbit,gold],[7,3,cat,gold],[7,4,dog,gold],[7,5,rabbit,gold],[7,6,horse,gold],[7,7,rabbit,gold]], [[0,0,rabbit,silver],[0,1,rabbit,silver],[0,2,horse,silver],[0,3,rabbit,silver],[0,4,elephant,silver],[0,5,rabbit,silver],[0,6,rabbit,silver],[0,7,rabbit,silver],[1,0,camel,silver],[1,1,cat,silver],[1,2,rabbit,silver],[1,3,dog,silver],[1,4,rabbit,silver],[1,5,horse,silver],[1,6,dog,silver],[3,7,cat,silver],[2,7,rabbit,gold],[6,0,cat,gold],[6,1,horse,gold],[6,2,camel,gold],[6,3,elephant,gold],[6,4,rabbit,gold],[6,5,dog,gold],[6,6,rabbit,gold],[7,0,rabbit,gold],[7,1,rabbit,gold],[7,2,rabbit,gold],[7,3,cat,gold],[7,4,dog,gold],[7,5,rabbit,gold],[7,6,horse,gold],[7,7,rabbit,gold]], Res).


%pion_tirer_possible_silver(Board, Pion, Resultat) --> Pour un pion donné, Resultat s'unifie avec une liste d'actions tirer possible. Pour cela on liste les actions tirer possible pour chaque case voisine: Haut, Bas, Gauche, droite.

pion_tirer_possible_silver(Board, [Xallie, Yallie, TypeAllie, silver], Res):- \+ pion_freeze(Board, [Xallie,Yallie,TypeAllie,silver]), pion_tirer_possibleB_silver(Board, [Xallie, Yallie, _, silver], Res1), pion_tirer_possibleH_silver(Board, [Xallie, Yallie, _, silver], Res2), pion_tirer_possibleD_silver(Board, [Xallie, Yallie, _, silver], Res3), pion_tirer_possibleG_silver(Board, [Xallie, Yallie, _, silver], Res4), concat(Res1,Res2,TmpRes1), concat(Res3, Res4, TmpRes2), concat(TmpRes1, TmpRes2, Res).

pion_tirer_possibleB_silver(Board, [Xallie, Yallie, _, silver], Res):- Xennemi is Xallie + 1, Yennemi is Yallie, setof([[[Xallie,Yallie],[Vallie,Wallie]],[[Xennemi,Yennemi],[Xallie,Yallie]]], tirer_possible_silver(Board,[[[Xallie,Yallie],[Vallie,Wallie]],[[Xennemi,Yennemi],[Xallie,Yallie]]]), Res), !.
pion_tirer_possibleB_silver(_,_,[]).
pion_tirer_possibleH_silver(Board, [Xallie, Yallie, _, silver], Res):- Xennemi is Xallie - 1, Yennemi is Yallie, setof([[[Xallie,Yallie],[Vallie,Wallie]],[[Xennemi,Yennemi],[Xallie,Yallie]]], tirer_possible_silver(Board,[[[Xallie,Yallie],[Vallie,Wallie]],[[Xennemi,Yennemi],[Xallie,Yallie]]]), Res), !.
pion_tirer_possibleH_silver(_,_,[]).
pion_tirer_possibleD_silver(Board, [Xallie, Yallie, _, silver], Res):- Xennemi is Xallie, Yennemi is Yallie + 1, setof([[[Xallie,Yallie],[Vallie,Wallie]],[[Xennemi,Yennemi],[Xallie,Yallie]]], tirer_possible_silver(Board,[[[Xallie,Yallie],[Vallie,Wallie]],[[Xennemi,Yennemi],[Xallie,Yallie]]]), Res), !.
pion_tirer_possibleD_silver(_,_,[]).
pion_tirer_possibleG_silver(Board, [Xallie, Yallie, _, silver], Res):- Xennemi is Xallie, Yennemi is Yallie - 1, setof([[[Xallie,Yallie],[Vallie,Wallie]],[[Xennemi,Yennemi],[Xallie,Yallie]]], tirer_possible_silver(Board,[[[Xallie,Yallie],[Vallie,Wallie]],[[Xennemi,Yennemi],[Xallie,Yallie]]]), Res), !.
pion_tirer_possibleG_silver(_,_,[]).

%EXEMPLE EXECUTION :
%pion_tirer_possible_silver([[4,4,cat,silver],[3,4,rabbit,gold],[4,5,rabbit,gold]],[4,4,cat,silver],X).
%pion_tirer_possible_silver([[4,4,cat,silver],[3,4,rabbit,silver],[4,5,rabbit,silver]],[4,4,cat,silver],X).
%pion_tirer_possible_silver([[4,4,cat,silver],[3,4,rabbit,gold],[4,5,camel,gold]],[4,4,cat,silver],X).
%pion_tirer_possible_silver([[0,0,rabbit,silver],[0,1,rabbit,silver],[0,2,horse,silver],[0,3,rabbit,silver],[0,4,elephant,silver],[0,5,rabbit,silver],[0,6,rabbit,silver],[0,7,rabbit,silver],[1,0,camel,silver],[1,1,cat,silver],[1,2,rabbit,silver],[1,3,dog,silver],[1,4,rabbit,silver],[1,5,horse,silver],[1,6,dog,silver],[3,7,cat,silver],[2,7,rabbit,gold],[6,0,cat,gold],[6,1,horse,gold],[6,2,camel,gold],[6,3,elephant,gold],[6,4,rabbit,gold],[6,5,dog,gold],[6,6,rabbit,gold],[7,0,rabbit,gold],[7,1,rabbit,gold],[7,2,rabbit,gold],[7,3,cat,gold],[7,4,dog,gold],[7,5,rabbit,gold],[7,6,horse,gold],[7,7,rabbit,gold]],[3,7,cat,silver],X).


%tirer_possible_silver(Board, TirerEnnemi) -> TirerEnnemi de la forme : [[[XallieDepart,YallieDepart],[XallieArrive,YallieArrive]],[[[XennemiDepart,YennemiDepart],[XennemiArrive,YennemiArrive]]]]

tirer_possible_silver(Board, [[[Xallie,Yallie],[Zallie,Yallie]],[[Xennemi,Yennemi],[Xallie,Yallie]]]):- Zallie is Xallie+1, get_case(Board,(Xallie,Yallie), [Xallie,Yallie,TypeAllie,silver]), TypeAllie \= -1, get_case(Board, (Xennemi,Yennemi), [Xennemi,Yennemi,TypeEnnemi,gold]), TypeEnnemi \= -1, plus_fort(TypeAllie,TypeEnnemi), voisinB(Board,(Xallie,Yallie),[Zallie,Yallie,A,B]), A = -1, B = -1. 
tirer_possible_silver(Board, [[[Xallie,Yallie],[Zallie,Yallie]],[[Xennemi,Yennemi],[Xallie,Yallie]]]):- Zallie is Xallie-1, get_case(Board,(Xallie,Yallie), [Xallie,Yallie,TypeAllie,silver]), TypeAllie \= -1, get_case(Board, (Xennemi,Yennemi), [Xennemi,Yennemi,TypeEnnemi,gold]), TypeEnnemi \= -1, plus_fort(TypeAllie,TypeEnnemi), voisinH(Board,(Xallie,Yallie),[Zallie,Yallie,A,B]), A = -1, B = -1. 
tirer_possible_silver(Board, [[[Xallie,Yallie],[Xallie,Zallie]],[[Xennemi,Yennemi],[Xallie,Yallie]]]):- Zallie is Yallie+1, get_case(Board,(Xallie,Yallie), [Xallie,Yallie,TypeAllie,silver]), TypeAllie \= -1, get_case(Board, (Xennemi,Yennemi), [Xennemi,Yennemi,TypeEnnemi,gold]), TypeEnnemi \= -1, plus_fort(TypeAllie,TypeEnnemi), voisinD(Board,(Xallie,Yallie),[Xallie,Zallie,A,B]), A = -1, B = -1. 
tirer_possible_silver(Board, [[[Xallie,Yallie],[Xallie,Zallie]],[[Xennemi,Yennemi],[Xallie,Yallie]]]):- Zallie is Yallie-1, get_case(Board,(Xallie,Yallie), [Xallie,Yallie,TypeAllie,silver]), TypeAllie \= -1, get_case(Board, (Xennemi,Yennemi), [Xennemi,Yennemi,TypeEnnemi,gold]), TypeEnnemi \= -1, plus_fort(TypeAllie,TypeEnnemi), voisinG(Board,(Xallie,Yallie),[Xallie,Zallie,A,B]), A = -1, B = -1. 

%EXEMPLE EXECUTION:
%tirer_possible_silver([[0,0,rabbit,silver],[0,1,rabbit,silver],[5,5,horse,silver],[0,3,rabbit,silver],[0,4,elephant,silver],[0,5,rabbit,silver],[0,6,rabbit,silver],[0,7,rabbit,silver],[1,0,camel,silver],[1,1,cat,silver],[1,2,rabbit,silver],[1,3,dog,silver],[1,4,rabbit,silver],[1,5,horse,silver],[1,6,dog,silver],[1,7,cat,silver],[2,7,rabbit,gold],[6,0,cat,gold],[6,1,horse,gold],[6,2,camel,gold],[6,3,elephant,gold],[6,4,rabbit,gold],[6,5,dog,gold],[6,6,rabbit,gold],[7,0,rabbit,gold],[7,1,rabbit,gold],[7,2,rabbit,gold],[7,3,cat,gold],[7,4,dog,gold],[7,5,rabbit,gold],[7,6,horse,gold],[7,7,rabbit,gold]],[[[5,5],[4,5]],[[6,5],[5,5]]]).
%setof([[[5,5],[X,Y]],[[6,5],[5,5]]],tirer_possible_silver([[0,0,rabbit,silver],[0,1,rabbit,silver],[5,5,horse,silver],[0,3,rabbit,silver],[0,4,elephant,silver],[0,5,rabbit,silver],[0,6,rabbit,silver],[0,7,rabbit,silver],[1,0,camel,silver],[1,1,cat,silver],[1,2,rabbit,silver],[1,3,dog,silver],[1,4,rabbit,silver],[1,5,horse,silver],[1,6,dog,silver],[1,7,cat,silver],[2,7,rabbit,gold],[6,0,cat,gold],[6,1,horse,gold],[6,2,camel,gold],[6,3,elephant,gold],[6,4,rabbit,gold],[6,5,dog,gold],[6,6,rabbit,gold],[7,0,rabbit,gold],[7,1,rabbit,gold],[7,2,rabbit,gold],[7,3,cat,gold],[7,4,dog,gold],[7,5,rabbit,gold],[7,6,horse,gold],[7,7,rabbit,gold]],[[[5,5],[X,Y]],[[6,5],[5,5]]]),Res).


%voisins(Board, Coord, Res) --> Res s unifie avec une liste des voisins [VoisinH, VoisinB, VoisinG, VoisinD] Avec VoisinH pouvant être : [X,Y,piece,joueur], [X,Y,-1,-1] ou [] (quand hors du plateau). 

%voisins(Board, Coord, [Voisin1, voisin2, etc]) (4Max)
voisins(Board, (Ligne,Colonne), Res):-  voisinH(Board, (Ligne, Colonne), Tmp), voisinB(Board, (Ligne, Colonne), Tmp1), voisinG(Board, (Ligne, Colonne), Tmp2),voisinD(Board, (Ligne, Colonne), Tmp3), Res = [Tmp,Tmp1,Tmp2,Tmp3].

%voisin de la case au dessus
voisinH(Board, (Ligne, Colonne), Res):- LH is Ligne-1 , get_case(Board, (LH,Colonne), Res), !.
voisinH(_, (_,_), []).
%voisin de la case en dessous
voisinB(Board, (Ligne,Colonne), Res):- LB is Ligne+1, get_case(Board, (LB,Colonne), Res), !.
voisinB(_, (_,_), []).
%voisin de la case à gauche
voisinG(Board, (Ligne,Colonne), Res):- CD is Colonne-1, get_case(Board, (Ligne,CD), Res), !.
voisinG(_, (_,_), []).
%voisin de la case à droite
voisinD(Board, (Ligne,Colonne), Res):- CG is Colonne+1, get_case(Board, (Ligne,CG), Res), !.
voisinD(_, (_,_), []).

%EXEMPLE EXECUTION :
%voisins([[0,0,rabbit,silver],[0,1,rabbit,silver],[0,2,horse,silver],[0,3,rabbit,silver],[0,4,elephant,silver],[0,5,rabbit,silver],[0,6,rabbit,silver],[0,7,rabbit,silver],[1,0,camel,silver],[1,1,cat,silver],[1,2,rabbit,silver],[1,3,dog,silver],[1,4,rabbit,silver],[1,5,horse,silver],[1,6,dog,silver],[1,7,cat,silver],[2,7,rabbit,gold],[6,0,cat,gold],[6,1,horse,gold],[6,2,camel,gold],[6,3,elephant,gold],[6,4,rabbit,gold],[6,5,dog,gold],[6,6,rabbit,gold],[7,0,rabbit,gold],[7,1,rabbit,gold],[7,2,rabbit,gold],[7,3,cat,gold],[7,4,dog,gold],[7,5,rabbit,gold],[7,6,horse,gold],[7,7,rabbit,gold]],(5,5),Res).


%get_case(Board, Coord, Res): Res s unifie avec le contenu d une case en fonction d une coordonnée. Contenu possible:
% - [X,Y,Piece,Joueur] --> Cas d une pièce.
% - [X,Y,-1,-1] --> cas d une case vide. (attention, dans tous les cas Res peut s unifier avec [X,Y,-1,-1] si X et Y sont des coords dans le plateau, donc toujours appeler get_case avec un Res : [X,Y,A,B] puis tester A, B)
% - False --> Hors plateau

get_case([[A,B,C,D]|_], (A,B), [A,B,C,D]):- !.
get_case([_|E], (Ligne,Colonne), Res):- get_case(E, (Ligne,Colonne), Res).
get_case([], (Ligne,_), _):- Ligne < 0, !, fail.
get_case([], (Ligne,_), _):- Ligne > 7, !, fail.
get_case([], (_,Colonne), _):- Colonne < 0, !, fail.
get_case([], (_,Colonne), _):- Colonne > 7, !, fail.
get_case([], (Ligne,Colonne), [Ligne,Colonne,-1, -1]).

%EXEMPLE EXECUTION :
%get_case([[0,0,rabbit,silver],[0,1,rabbit,silver],[0,2,horse,silver],[0,3,rabbit,silver],[0,4,elephant,silver],[0,5,rabbit,silver],[0,6,rabbit,silver],[0,7,rabbit,silver],[1,0,camel,silver],[1,1,cat,silver],[1,2,rabbit,silver],[1,3,dog,silver],[1,4,rabbit,silver],[1,5,horse,silver],[1,6,dog,silver],[1,7,cat,silver],[2,7,rabbit,gold],[6,0,cat,gold],[6,1,horse,gold],[6,2,camel,gold],[6,3,elephant,gold],[6,4,rabbit,gold],[6,5,dog,gold],[6,6,rabbit,gold],[7,0,rabbit,gold],[7,1,rabbit,gold],[7,2,rabbit,gold],[7,3,cat,gold],[7,4,dog,gold],[7,5,rabbit,gold],[7,6,horse,gold],[7,7,rabbit,gold]],(0,0),Res).


%plus_fort(type1,type2) --> est-ce que le pion de type 1 est plus fort que le pion de type 2.
plus_fort(cat,rabbit).
plus_fort(dog,rabbit).
plus_fort(horse,rabbit).
plus_fort(camel,rabbit).
plus_fort(elephant,rabbit).
plus_fort(dog,cat).
plus_fort(horse,cat).
plus_fort(camel,cat).
plus_fort(elephant,cat).
plus_fort(horse,dog).
plus_fort(camel,dog).
plus_fort(elephant,dog).
plus_fort(camel,horse).
plus_fort(elephant,horse).
plus_fort(elephant,camel).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	Divers : Prédicats Autres et Tests	%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Test : Un test pour voir si get_moves marche (envoie juste à l'application les 4 premiers mouvements déterminés, risque de conflits et bug) 
%get_moves(Moves, Gamestate, Board):- tout_deplacement_possible_silver(Board, Board, Res), concat([[[A,B],[C,D]],[[E,F],[G,H]],[[I,J],[K,L]],[[M,N],[O,P]]],Q,Res), Moves = [[[A,B],[C,D]],[[E,F],[G,H]],[[I,J],[K,L]],[[M,N],[O,P]]].


%liste des pions jouables ainsi que chaque coup possible. RETOURNE UNE LISTE À 2 ÉLÉMENTS : 1- la tête est un pion, 2- la queue est une liste de coups possibles pour ce pion.
%RESULTAT exemple : R = [[[1, 0, camel, silver], [[2, 0]]], [[1, 1, cat, silver], [[2, 1]]], [[1, 2, rabbit, silver], [[2, 2]]], [[1, 3, dog, silver], [[2, 3]]], [[1, 4, rabbit|...], [[2|...]]], [[1, 5|...], [[...|...]]], [[1|...], [...]], [[...|...]|...], [...|...]|...].
%PROTOTYPE : liste_coup(Board,BoardTemp,R).
%EXECUTION :liste_coup([[0,0,rabbit,silver],[0,1,rabbit,silver],[0,2,horse,silver],[0,3,rabbit,silver],[0,4,elephant,silver],[0,5,rabbit,silver],[0,6,rabbit,silver],[0,7,rabbit,silver],[1,0,camel,silver],[1,1,cat,silver],[1,2,rabbit,silver],[1,3,dog,silver],[1,4,rabbit,silver],[1,5,horse,silver],[1,6,dog,silver],[1,7,cat,silver],[2,7,rabbit,gold],[6,0,cat,gold],[6,1,horse,gold],[6,2,camel,gold],[6,3,elephant,gold],[6,4,rabbit,gold],[6,5,dog,gold],[6,6,rabbit,gold],[7,0,rabbit,gold],[7,1,rabbit,gold],[7,2,rabbit,gold],[7,3,cat,gold],[7,4,dog,gold],[7,5,rabbit,gold],[7,6,horse,gold],[7,7,rabbit,gold]],[[0,0,rabbit,silver],[0,1,rabbit,silver],[0,2,horse,silver],[0,3,rabbit,silver],[0,4,elephant,silver],[0,5,rabbit,silver],[0,6,rabbit,silver],[0,7,rabbit,silver],[1,0,camel,silver],[1,1,cat,silver],[1,2,rabbit,silver],[1,3,dog,silver],[1,4,rabbit,silver],[1,5,horse,silver],[1,6,dog,silver],[1,7,cat,silver],[2,7,rabbit,gold],[6,0,cat,gold],[6,1,horse,gold],[6,2,camel,gold],[6,3,elephant,gold],[6,4,rabbit,gold],[6,5,dog,gold],[6,6,rabbit,gold],[7,0,rabbit,gold],[7,1,rabbit,gold],[7,2,rabbit,gold],[7,3,cat,gold],[7,4,dog,gold],[7,5,rabbit,gold],[7,6,horse,gold],[7,7,rabbit,gold]],R).

%liste_coup(_,[],[]).
%liste_coup(Board,[[X,Y,_,_]|Q],R):- \+setof([X1,Y1],deplacement_possible(Board,[[X,Y],[X1,Y1]]),_),liste_coup(Board,Q,R),!.
%liste_coup(Board,[[X,Y,T,J]|Q],R):- setof([X1,Y1],deplacement_possible(Board,[[X,Y],[X1,Y1]]),Res),concat([[[X,Y,T,J],Res]],R1,R),liste_coup(Board,Q,R1).


%à modifier car ne marche pas dans le cas où un pion qui empecher un autre de tomber bouge et donc le pion sur la trappe meurt --> il faut faire une comparaison entre les deux gamestates (si un silver est en plus alors --> suicide)
%test_deplacement_suicide(Board, (X, Y)):- get_case(Board, (X,Y), [X,Y,A,B]), A = -1 ,B = -1, soustraction_score(100), !.
%test_deplacement_suicide(_,_).

%test_deplacement_suicide([[2,2,rabbit,silver]],(2, 2)).


%mise à jour du board après avoir déplacé un pion. 
%PROTOTYPE : maj_board(Board,P,X,Y,R). p est un pion avant de délplacement, X et Y sont les nouvelles coordonnées de ce pion et R est la nouvelle board mise à jour.
%EXECUTION : maj_board([[0,0,rabbit,silver],[0,1,rabbit,silver],[0,2,horse,silver],[7,5,rabbit,gold],[7,6,horse,gold],[7,7,rabbit,gold]],[0,0,rabbit,silver],1,1,R).

%maj_board(Board,[X1,Y1,T,J],X,Y,R):- delete_pion([X1,Y1,T,J],Board,R1),concat([[X,Y,T,J]],R1,R).
%:- module(bot,
%      [  get_moves/3
%      ]).
	
% A few comments but all is explained in README of github

% get_moves signature
% get_moves(Moves, gamestate, board).

% Exemple of variable
% gamestate: [side, [captured pieces] ] (e.g. [silver, [ [0,1,rabbit,silver],[0,2,horse,silver] ]) 
% board: [[0,0,rabbit,silver],[0,1,rabbit,silver],[0,2,horse,silver],[0,3,rabbit,silver],[0,4,elephant,silver],[0,5,rabbit,silver],[0,6,rabbit,silver],[0,7,rabbit,silver],[1,0,camel,silver],[1,1,cat,silver],[1,2,rabbit,silver],[1,3,dog,silver],[1,4,rabbit,silver],[1,5,horse,silver],[1,6,dog,silver],[1,7,cat,silver],[2,7,rabbit,gold],[6,0,cat,gold],[6,1,horse,gold],[6,2,camel,gold],[6,3,elephant,gold],[6,4,rabbit,gold],[6,5,dog,gold],[6,6,rabbit,gold],[7,0,rabbit,gold],[7,1,rabbit,gold],[7,2,rabbit,gold],[7,3,cat,gold],[7,4,dog,gold],[7,5,rabbit,gold],[7,6,horse,gold],[7,7,rabbit,gold]]

% Call exemple:
% get_moves(Moves, [silver, []], [[0,0,rabbit,silver],[0,1,rabbit,silver],[0,2,horse,silver],[0,3,rabbit,silver],[0,4,elephant,silver],[0,5,rabbit,silver],[0,6,rabbit,silver],[0,7,rabbit,silver],[1,0,camel,silver],[1,1,cat,silver],[1,2,rabbit,silver],[1,3,dog,silver],[1,4,rabbit,silver],[1,5,horse,silver],[1,6,dog,silver],[1,7,cat,silver],[2,7,rabbit,gold],[6,0,cat,gold],[6,1,horse,gold],[6,2,camel,gold],[6,3,elephant,gold],[6,4,rabbit,gold],[6,5,dog,gold],[6,6,rabbit,gold],[7,0,rabbit,gold],[7,1,rabbit,gold],[7,2,rabbit,gold],[7,3,cat,gold],[7,4,dog,gold],[7,5,rabbit,gold],[7,6,horse,gold],[7,7,rabbit,gold]]).

% default call
get_moves([[[1,0],[2,0]],[[0,0],[1,0]],[[0,1],[0,0]],[[0,0],[0,1]]], Gamestate, Board).

%get_moves(Moves, Gamestate, Board):- 







%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%					REMARQUE (POUR DEBUG):													%
% 			Pour afficher toute la solution d'unification									%
%			(pas une juste une partie avec des ... ) 										%
%			(surtout pour le predicat "deplacer" ou "tout_deplacement_possible_silver")		%
%			On peut utiliser cette commande (à executer dans la console prolog) :			%
set_prolog_flag(answer_write_options,[ quoted(true),portray(true),spacing(next_argument)]). %
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
%
%
%







%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%			Debut Des Prédicats de bases			%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%									









%Concat du poly
concat([],L,L).
concat([T|Q],L,[T|R]):- concat(Q,L,R).




%tout_deplacement_possible_silver(Board, TempBoard, Res) --> Res s'unifie avec une liste de tous les deplacements possibles du joueur silver avec une profondeur de 1.
%Pour cela on utilise le prédicat deplacement_possible qui test si un deplacement est possible, et ce prédicat est combiné avec un setof.

%Board corresponds au plateau et ne sera pas modifié, TempBoard est une copie de Board qui permet un parcours un à un de chaque pion du plateau.

tout_deplacement_possible_silver(Board, [], []).
tout_deplacement_possible_silver(Board, [[X,Y,_,silver]|B], Res):- setof([[X,Y],[V,W]],deplacement_possible(Board, [[X,Y],[V,W]]), TmpRes), tout_deplacement_possible_silver(Board,B,TRes), concat(TmpRes,TRes,Res), !.
tout_deplacement_possible_silver(Board, [[X,Y,_,_]|B], Res):- tout_deplacement_possible_silver(Board, B, Res). 

%EXEMPLE EXECUTION :
%tout_deplacement_possible_silver([[0,0,rabbit,silver],[0,1,rabbit,silver],[0,2,horse,silver],[0,3,rabbit,silver],[0,4,elephant,silver],[0,5,rabbit,silver],[0,6,rabbit,silver],[0,7,rabbit,silver],[1,0,camel,silver],[1,1,cat,silver],[1,2,rabbit,silver],[1,3,dog,silver],[1,4,rabbit,silver],[1,5,horse,silver],[1,6,dog,silver],[1,7,cat,silver],[2,7,rabbit,gold],[6,0,cat,gold],[6,1,horse,gold],[6,2,camel,gold],[6,3,elephant,gold],[6,4,rabbit,gold],[6,5,dog,gold],[6,6,rabbit,gold],[7,0,rabbit,gold],[7,1,rabbit,gold],[7,2,rabbit,gold],[7,3,cat,gold],[7,4,dog,gold],[7,5,rabbit,gold],[7,6,horse,gold],[7,7,rabbit,gold]], [[0,0,rabbit,silver],[0,1,rabbit,silver],[0,2,horse,silver],[0,3,rabbit,silver],[0,4,elephant,silver],[0,5,rabbit,silver],[0,6,rabbit,silver],[0,7,rabbit,silver],[1,0,camel,silver],[1,1,cat,silver],[1,2,rabbit,silver],[1,3,dog,silver],[1,4,rabbit,silver],[1,5,horse,silver],[1,6,dog,silver],[1,7,cat,silver],[2,7,rabbit,gold],[6,0,cat,gold],[6,1,horse,gold],[6,2,camel,gold],[6,3,elephant,gold],[6,4,rabbit,gold],[6,5,dog,gold],[6,6,rabbit,gold],[7,0,rabbit,gold],[7,1,rabbit,gold],[7,2,rabbit,gold],[7,3,cat,gold],[7,4,dog,gold],[7,5,rabbit,gold],[7,6,horse,gold],[7,7,rabbit,gold]],Res).



%deplacement_possible(Board, Deplacement ) --> renvoie vrai si le deplacement du pion d'une case à une autre case voisine (précisée) est possible sinon renvoie faux (la profondeur du deplacement est de 1 case).

%Pour l'instant pas de cut (!), Peut renvoyer tout les déplacements par exemple on appel sur deplacement(Board, [[5,5], [X,Y]]. A voir après avec l'utilisation de Setof (+ retract et asserta).

%deplacement_possible(board, [[Xdepart,YDepart], [Xarrive,Yarrive]) :- On test si la case depart est bien un pion, puis On test si la case arrivée est -1 -1.
deplacement_possible(Board, [[X,Y],[Z,Y]] ):- get_case(Board, (X,Y), [X,Y,C,D]), C \= -1, D \= -1, Z is X+1, voisinB(Board,(X,Y),[Z,Y,A,B]), A = -1, B = -1.
deplacement_possible(Board, [[X,Y],[Z,Y]] ):- get_case(Board, (X,Y), [X,Y,C,D]), C \= -1, D \= -1, Z is X-1, voisinH(Board,(X,Y),[Z,Y,A,B]), A = -1, B = -1.
deplacement_possible(Board, [[X,Y],[X,Z]] ):- get_case(Board, (X,Y), [X,Y,C,D]), C \= -1, D \= -1, Z is Y+1, voisinD(Board,(X,Y),[X,Z,A,B]), A = -1, B = -1.
deplacement_possible(Board, [[X,Y],[X,Z]] ):- get_case(Board, (X,Y), [X,Y,C,D]), C \= -1, D \= -1, Z is Y-1, voisinG(Board,(X,Y),[X,Z,A,B]), A = -1, B = -1.

%EXEMPLES EXECUTION :
%deplacement_possible([[0,0,rabbit,silver],[0,1,rabbit,silver],[0,2,horse,silver],[0,3,rabbit,silver],[0,4,elephant,silver],[0,5,rabbit,silver],[0,6,rabbit,silver],[0,7,rabbit,silver],[1,0,camel,silver],[1,1,cat,silver],[1,2,rabbit,silver],[1,3,dog,silver],[1,4,rabbit,silver],[1,5,horse,silver],[1,6,dog,silver],[1,7,cat,silver],[2,7,rabbit,gold],[6,0,cat,gold],[6,1,horse,gold],[6,2,camel,gold],[6,3,elephant,gold],[6,4,rabbit,gold],[6,5,dog,gold],[6,6,rabbit,gold],[7,0,rabbit,gold],[7,1,rabbit,gold],[7,2,rabbit,gold],[7,3,cat,gold],[7,4,dog,gold],[7,5,rabbit,gold],[7,6,horse,gold],[7,7,rabbit,gold]],[[1,0],[2,0]]).
%deplacement_possible([[0,0,rabbit,silver],[0,1,rabbit,silver],[0,2,horse,silver],[0,3,rabbit,silver],[0,4,elephant,silver],[0,5,rabbit,silver],[0,6,rabbit,silver],[0,7,rabbit,silver],[1,0,camel,silver],[1,1,cat,silver],[1,2,rabbit,silver],[1,3,dog,silver],[1,4,rabbit,silver],[1,5,horse,silver],[1,6,dog,silver],[1,7,cat,silver],[2,7,rabbit,gold],[6,0,cat,gold],[6,1,horse,gold],[6,2,camel,gold],[6,3,elephant,gold],[6,4,rabbit,gold],[6,5,dog,gold],[6,6,rabbit,gold],[7,0,rabbit,gold],[7,1,rabbit,gold],[7,2,rabbit,gold],[7,3,cat,gold],[7,4,dog,gold],[7,5,rabbit,gold],[7,6,horse,gold],[7,7,rabbit,gold]],[[6,6],[X,Y]]).
%setof([X,Y],deplacement_possible([[0,0,rabbit,silver],[0,1,rabbit,silver],[0,2,horse,silver],[0,3,rabbit,silver],[0,4,elephant,silver],[0,5,rabbit,silver],[0,6,rabbit,silver],[0,7,rabbit,silver],[1,0,camel,silver],[1,1,cat,silver],[1,2,rabbit,silver],[1,3,dog,silver],[1,4,rabbit,silver],[1,5,horse,silver],[1,6,dog,silver],[1,7,cat,silver],[2,7,rabbit,gold],[6,0,cat,gold],[6,1,horse,gold],[6,2,camel,gold],[6,3,elephant,gold],[6,4,rabbit,gold],[6,5,dog,gold],[6,6,rabbit,gold],[7,0,rabbit,gold],[7,1,rabbit,gold],[7,2,rabbit,gold],[7,3,cat,gold],[7,4,dog,gold],[7,5,rabbit,gold],[7,6,horse,gold],[7,7,rabbit,gold]],[[6,6],[X,Y]]),Res).


%voisins(Board, Coord, Res) --> Res s'unifie avec une liste des voisins [VoisinH, VoisinB, VoisinG, VoisinD] Avec VoisinH pouvant être : [X,Y,piece,joueur], [X,Y,-1,-1] ou [] (quand hors du plateau). 

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



%get_case(Board, Coord, Res): Res s'unifie avec le contenu d'une case en fonction d'une coordonnée. Contenu possible:
% - [X,Y,Piece,Joueur] --> Cas d'une pièce.
% - [X,Y,-1,-1] --> cas d'une case vide. (attention, dans tous les cas Res peut s'unifier avec [X,Y,-1,-1] si X et Y sont des coords dans le plateau, donc toujours appeler get_case avec un Res : [X,Y,A,B] puis tester A, B)
% - False --> Hors plateau

%penser à rajouter le cas des trappes.
get_case([[A,B,C,D]|_], (A,B), [A,B,C,D]):- !.
get_case([_|E], (Ligne,Colonne), Res):- get_case(E, (Ligne,Colonne), Res).
get_case([], (Ligne,_), _):- Ligne < 0, !, fail.
get_case([], (Ligne,_), _):- Ligne > 7, !, fail.
get_case([], (_,Colonne), _):- Colonne < 0, !, fail.
get_case([], (_,Colonne), _):- Colonne > 7, !, fail.
get_case([], (Ligne,Colonne), [Ligne,Colonne,-1, -1]).

%EXEMPLE EXECUTION :
%get_case([[0,0,rabbit,silver],[0,1,rabbit,silver],[0,2,horse,silver],[0,3,rabbit,silver],[0,4,elephant,silver],[0,5,rabbit,silver],[0,6,rabbit,silver],[0,7,rabbit,silver],[1,0,camel,silver],[1,1,cat,silver],[1,2,rabbit,silver],[1,3,dog,silver],[1,4,rabbit,silver],[1,5,horse,silver],[1,6,dog,silver],[1,7,cat,silver],[2,7,rabbit,gold],[6,0,cat,gold],[6,1,horse,gold],[6,2,camel,gold],[6,3,elephant,gold],[6,4,rabbit,gold],[6,5,dog,gold],[6,6,rabbit,gold],[7,0,rabbit,gold],[7,1,rabbit,gold],[7,2,rabbit,gold],[7,3,cat,gold],[7,4,dog,gold],[7,5,rabbit,gold],[7,6,horse,gold],[7,7,rabbit,gold]],(0,0),Res).


%deplacement(Board,NvBoard,Depart,Arrive) :- NvBoard s'unifie avec Board modifié, on modifie seulement les coordonnées d'une pièce sans verification.

deplacement([[A,B,C,D]|E], [[LigneA,ColonneA,C,D]|E], (A,B), (LigneA, ColonneA)):- !.
deplacement([A|E], [A|R], (LigneD,ColonneD), (LigneA, ColonneA) ):- deplacement(E,R,(LigneD,ColonneD), (LigneA, ColonneA) ).

%EXEMPLE EXECUTION :
%deplacement([[0,0,rabbit,silver],[0,1,rabbit,silver],[0,2,horse,silver],[0,3,rabbit,silver],[0,4,elephant,silver],[0,5,rabbit,silver],[0,6,rabbit,silver],[0,7,rabbit,silver],[1,0,camel,silver],[1,1,cat,silver],[1,2,rabbit,silver],[1,3,dog,silver],[1,4,rabbit,silver],[1,5,horse,silver],[1,6,dog,silver],[1,7,cat,silver],[2,7,rabbit,gold],[6,0,cat,gold],[6,1,horse,gold],[6,2,camel,gold],[6,3,elephant,gold],[6,4,rabbit,gold],[6,5,dog,gold],[6,6,rabbit,gold],[7,0,rabbit,gold],[7,1,rabbit,gold],[7,2,rabbit,gold],[7,3,cat,gold],[7,4,dog,gold],[7,5,rabbit,gold],[7,6,horse,gold],[7,7,rabbit,gold]], Res, (1,1), (2,1)).
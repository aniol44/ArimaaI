:- module(bot,
      [  get_moves/3
      ]).
	
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
%				[[[[XennemiDepart,YennemiDepart],[XennemiArrive,YennemiArrive]]],[[XallieDepart,YallieDepart],[XallieArrive,YallieArrive]]]
%		TIRER :
%				[[[XallieDepart,YallieDepart],[XallieArrive,YallieArrive]],[[[XennemiDepart,YennemiDepart],[XennemiArrive,YennemiArrive]]]]			
%



%Test : Un test pour voir si get_moves marche (envoie juste à l application les 4 premiers mouvements déterminés, risque de conflits et bug) 
%get_moves(Moves, Gamestate, Board):- tout_deplacement_possible_silver(Board, Board, Res), concat([[[A,B],[C,D]],[[E,F],[G,H]],[[I,J],[K,L]],[[M,N],[O,P]]],Q,Res), Moves = [[[A,B],[C,D]],[[E,F],[G,H]],[[I,J],[K,L]],[[M,N],[O,P]]].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%			Debut Des Prédicats de bases			%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%									


%Concat du poly
concat([],L,L).
concat([T|Q],L,[T|R]):- concat(Q,L,R).

%element du poly
element(X, [X|_]).
element(X, [T|Q]):- element(X,Q).
%element([4,4,rabbit,silver], [[4,4,rabbit,silver],[5,4,dog,gold]]).


%pion_freeze(Board,Pion) --> indique si un pion est freeze (ne peut rien faire).

pion_freeze(Board, [X,Y,TypeAllie,silver]):- voisins(Board, (X,Y), Res), element([_,_,TypeEnnemi,gold], Res), plus_fort(TypeEnnemi, TypeAllie), \+element([_,_,Type,silver], Res).
pion_freeze(Board, [X,Y,TypeAllie,gold]):- voisins(Board, (X,Y), Res), element([_,_,TypeEnnemi,silver], Res), plus_fort(TypeEnnemi, TypeAllie), \+element([_,_,Type,silver], Res).

%EXEMPLE EXECUTION: 
%pion_freeze([[4,4,rabbit,silver],[5,4,dog,gold]], [4,4,rabbit,silver] ).
%pion_freeze([[4,4,camel,silver],[5,4,dog,gold]], [4,4,camel,silver] ).
%pion_freeze([[4,4,camel,silver],[5,4,dog,gold],[3,4,elephant,gold]], [4,4,camel,silver] ).
%pion_freeze([[4,4,rabbit,silver],[3,4,rabbit,silver],[5,4,dog,gold]], [4,4,rabbit,silver]).

%tout_deplacement_possible_silver(Board, TempBoard, Res) --> Res s unifie avec une liste de tous les deplacements possibles du joueur silver avec une profondeur de 1.
%Pour cela on utilise le prédicat deplacement_possible qui test si un deplacement est possible, et ce prédicat est combiné avec un setof.

%Board corresponds au plateau et ne sera pas modifié, TempBoard est une copie de Board qui permet un parcours un à un de chaque pion du plateau.

tout_deplacement_possible_silver(_, [], []).
tout_deplacement_possible_silver(Board, [[X,Y,_,silver]|B], Res):- setof([[X,Y],[V,W]],deplacement_possible(Board, [[X,Y],[V,W]]), TmpRes), tout_deplacement_possible_silver(Board,B,TRes), concat(TmpRes,TRes,Res), !.
tout_deplacement_possible_silver(Board, [[_,_,_,_]|B], Res):- tout_deplacement_possible_silver(Board, B, Res). 

%EXEMPLE EXECUTION :
%tout_deplacement_possible_silver([[0,0,rabbit,silver],[0,1,rabbit,silver],[0,2,horse,silver],[0,3,rabbit,silver],[0,4,elephant,silver],[0,5,rabbit,silver],[0,6,rabbit,silver],[0,7,rabbit,silver],[1,0,camel,silver],[1,1,cat,silver],[1,2,rabbit,silver],[1,3,dog,silver],[1,4,rabbit,silver],[1,5,horse,silver],[1,6,dog,silver],[1,7,cat,silver],[2,7,rabbit,gold],[6,0,cat,gold],[6,1,horse,gold],[6,2,camel,gold],[6,3,elephant,gold],[6,4,rabbit,gold],[6,5,dog,gold],[6,6,rabbit,gold],[7,0,rabbit,gold],[7,1,rabbit,gold],[7,2,rabbit,gold],[7,3,cat,gold],[7,4,dog,gold],[7,5,rabbit,gold],[7,6,horse,gold],[7,7,rabbit,gold]], [[0,0,rabbit,silver],[0,1,rabbit,silver],[0,2,horse,silver],[0,3,rabbit,silver],[0,4,elephant,silver],[0,5,rabbit,silver],[0,6,rabbit,silver],[0,7,rabbit,silver],[1,0,camel,silver],[1,1,cat,silver],[1,2,rabbit,silver],[1,3,dog,silver],[1,4,rabbit,silver],[1,5,horse,silver],[1,6,dog,silver],[1,7,cat,silver],[2,7,rabbit,gold],[6,0,cat,gold],[6,1,horse,gold],[6,2,camel,gold],[6,3,elephant,gold],[6,4,rabbit,gold],[6,5,dog,gold],[6,6,rabbit,gold],[7,0,rabbit,gold],[7,1,rabbit,gold],[7,2,rabbit,gold],[7,3,cat,gold],[7,4,dog,gold],[7,5,rabbit,gold],[7,6,horse,gold],[7,7,rabbit,gold]],Res).

%deplacement_possible(Board, Deplacement ) --> renvoie vrai si le deplacement du pion d une case à une autre case voisine (précisée) est possible sinon renvoie faux (la profondeur du deplacement est de 1 case).
%Pour l instant pas de cut (!), Peut renvoyer tout les déplacements par exemple on appel sur deplacement(Board, [[5,5], [X,Y]]. A voir après avec l utilisation de Setof (+ retract et asserta).
%deplacement_possible(board, [[Xdepart,YDepart], [Xarrive,Yarrive]) :- On test si la case depart est bien un pion, puis On test si la case arrivée est -1 -1.

deplacement_possible(Board, [[X,Y],[Z,Y]] ):- get_case(Board, (X,Y), [X,Y,C,D]), C \= -1, D \= -1, Z is X+1, voisinB(Board,(X,Y),[Z,Y,A,B]), A = -1, B = -1.
deplacement_possible(Board, [[X,Y],[Z,Y]] ):- get_case(Board, (X,Y), [X,Y,C,D]), C \= -1, D \= -1, Z is X-1, voisinH(Board,(X,Y),[Z,Y,A,B]), A = -1, B = -1.
deplacement_possible(Board, [[X,Y],[X,Z]] ):- get_case(Board, (X,Y), [X,Y,C,D]), C \= -1, D \= -1, Z is Y+1, voisinD(Board,(X,Y),[X,Z,A,B]), A = -1, B = -1.
deplacement_possible(Board, [[X,Y],[X,Z]] ):- get_case(Board, (X,Y), [X,Y,C,D]), C \= -1, D \= -1, Z is Y-1, voisinG(Board,(X,Y),[X,Z,A,B]), A = -1, B = -1.

%EXEMPLES EXECUTION :
%deplacement_possible([[0,0,rabbit,silver],[0,1,rabbit,silver],[0,2,horse,silver],[0,3,rabbit,silver],[0,4,elephant,silver],[0,5,rabbit,silver],[0,6,rabbit,silver],[0,7,rabbit,silver],[1,0,camel,silver],[1,1,cat,silver],[1,2,rabbit,silver],[1,3,dog,silver],[1,4,rabbit,silver],[1,5,horse,silver],[1,6,dog,silver],[1,7,cat,silver],[2,7,rabbit,gold],[6,0,cat,gold],[6,1,horse,gold],[6,2,camel,gold],[6,3,elephant,gold],[6,4,rabbit,gold],[6,5,dog,gold],[6,6,rabbit,gold],[7,0,rabbit,gold],[7,1,rabbit,gold],[7,2,rabbit,gold],[7,3,cat,gold],[7,4,dog,gold],[7,5,rabbit,gold],[7,6,horse,gold],[7,7,rabbit,gold]],[[1,0],[2,0]]).
%deplacement_possible([[0,0,rabbit,silver],[0,1,rabbit,silver],[0,2,horse,silver],[0,3,rabbit,silver],[0,4,elephant,silver],[0,5,rabbit,silver],[0,6,rabbit,silver],[0,7,rabbit,silver],[1,0,camel,silver],[1,1,cat,silver],[1,2,rabbit,silver],[1,3,dog,silver],[1,4,rabbit,silver],[1,5,horse,silver],[1,6,dog,silver],[1,7,cat,silver],[2,7,rabbit,gold],[6,0,cat,gold],[6,1,horse,gold],[6,2,camel,gold],[6,3,elephant,gold],[6,4,rabbit,gold],[6,5,dog,gold],[6,6,rabbit,gold],[7,0,rabbit,gold],[7,1,rabbit,gold],[7,2,rabbit,gold],[7,3,cat,gold],[7,4,dog,gold],[7,5,rabbit,gold],[7,6,horse,gold],[7,7,rabbit,gold]],[[6,6],[X,Y]]).
%setof([[6,6],[X,Y]],deplacement_possible([[0,0,rabbit,silver],[0,1,rabbit,silver],[0,2,horse,silver],[0,3,rabbit,silver],[0,4,elephant,silver],[0,5,rabbit,silver],[0,6,rabbit,silver],[0,7,rabbit,silver],[1,0,camel,silver],[1,1,cat,silver],[1,2,rabbit,silver],[1,3,dog,silver],[1,4,rabbit,silver],[1,5,horse,silver],[1,6,dog,silver],[1,7,cat,silver],[2,7,rabbit,gold],[6,0,cat,gold],[6,1,horse,gold],[6,2,camel,gold],[6,3,elephant,gold],[6,4,rabbit,gold],[6,5,dog,gold],[6,6,rabbit,gold],[7,0,rabbit,gold],[7,1,rabbit,gold],[7,2,rabbit,gold],[7,3,cat,gold],[7,4,dog,gold],[7,5,rabbit,gold],[7,6,horse,gold],[7,7,rabbit,gold]],[[6,6],[X,Y]]),Res).


%pousser_possible(Board, PousserEnnemi) -> PousserEnnemi de la forme : [[[[XennemiDepart,YennemiDepart],[XennemiArrive,YennemiArrive]]],[[XallieDepart,YallieDepart],[XallieArrive,YallieArrive]]]
%Comme pour deplacement_possible, permet de tester si un pion allie peut pousser un pion ennemi.
% pas de cut pour pouvoir determiner les possibilités de l action pousser par un pion avec un setof

pousser_possible(Board, [[[Xennemi,Yennemi],[Zennemi,Yennemi]],[[Xallie,Yallie],[Xennemi,Yennemi]]]):- Zennemi is Xennemi+1, get_case(Board,(Xallie,Yallie), [Xallie,Yallie,TypeAllie,JoueurAllie]), TypeAllie \= -1, JoueurAllie \= -1, get_case(Board, (Xennemi,Yennemi), [Xennemi,Yennemi,TypeEnnemi,JoueurEnnemi]), TypeEnnemi \= -1, JoueurEnnemi \= -1, plus_fort(TypeAllie,TypeEnnemi), voisinB(Board,(Xennemi,Yennemi),[Zennemi,Yennemi,A,B]), A = -1, B = -1. 
pousser_possible(Board, [[[Xennemi,Yennemi],[Zennemi,Yennemi]],[[Xallie,Yallie],[Xennemi,Yennemi]]]):- Zennemi is Xennemi-1, get_case(Board,(Xallie,Yallie), [Xallie,Yallie,TypeAllie,JoueurAllie]), TypeAllie \= -1, JoueurAllie \= -1, get_case(Board, (Xennemi,Yennemi), [Xennemi,Yennemi,TypeEnnemi,JoueurEnnemi]), TypeEnnemi \= -1, JoueurEnnemi \= -1, plus_fort(TypeAllie,TypeEnnemi), voisinH(Board,(Xennemi,Yennemi),[Zennemi,Yennemi,A,B]), A = -1, B = -1. 
pousser_possible(Board, [[[Xennemi,Yennemi],[Xennemi,Zennemi]],[[Xallie,Yallie],[Xennemi,Yennemi]]]):- Zennemi is Yennemi+1, get_case(Board,(Xallie,Yallie), [Xallie,Yallie,TypeAllie,JoueurAllie]), TypeAllie \= -1, JoueurAllie \= -1, get_case(Board, (Xennemi,Yennemi), [Xennemi,Yennemi,TypeEnnemi,JoueurEnnemi]), TypeEnnemi \= -1, JoueurEnnemi \= -1, plus_fort(TypeAllie,TypeEnnemi), voisinD(Board,(Xennemi,Yennemi),[Xennemi,Zennemi,A,B]), A = -1, B = -1. 
pousser_possible(Board, [[[Xennemi,Yennemi],[Xennemi,Zennemi]],[[Xallie,Yallie],[Xennemi,Yennemi]]]):- Zennemi is Yennemi-1, get_case(Board,(Xallie,Yallie), [Xallie,Yallie,TypeAllie,JoueurAllie]), TypeAllie \= -1, JoueurAllie \= -1, get_case(Board, (Xennemi,Yennemi), [Xennemi,Yennemi,TypeEnnemi,JoueurEnnemi]), TypeEnnemi \= -1, JoueurEnnemi \= -1, plus_fort(TypeAllie,TypeEnnemi), voisinG(Board,(Xennemi,Yennemi),[Xennemi,Zennemi,A,B]), A = -1, B = -1. 

%EXEMPLE EXECUTION:
%pousser_possible([[4,5,rabbit,silver],[0,1,rabbit,silver],[4,6,horse,silver],[0,3,rabbit,silver],[0,4,elephant,silver],[0,5,rabbit,silver],[0,6,rabbit,silver],[0,7,rabbit,silver],[1,0,camel,silver],[1,1,cat,silver],[1,2,rabbit,silver],[1,3,dog,silver],[1,4,rabbit,silver],[1,5,horse,silver],[1,6,dog,silver],[1,7,cat,silver],[2,7,rabbit,gold],[6,0,cat,gold],[6,1,horse,gold],[6,2,camel,gold],[6,3,elephant,gold],[6,4,rabbit,gold],[6,5,dog,gold],[6,6,rabbit,gold],[7,0,rabbit,gold],[7,1,rabbit,gold],[5,5,rabbit,gold],[5,6,cat,gold],[7,4,dog,gold],[7,5,rabbit,gold],[7,6,horse,gold],[7,7,rabbit,gold]],[[[5,5],[6,5]],[[4,5],[5,5]]]).
%pousser_possible([[4,5,rabbit,silver],[0,1,rabbit,silver],[4,6,horse,silver],[0,3,rabbit,silver],[0,4,elephant,silver],[0,5,rabbit,silver],[0,6,rabbit,silver],[0,7,rabbit,silver],[1,0,camel,silver],[1,1,cat,silver],[1,2,rabbit,silver],[1,3,dog,silver],[1,4,rabbit,silver],[1,5,horse,silver],[1,6,dog,silver],[1,7,cat,silver],[2,7,rabbit,gold],[6,0,cat,gold],[6,1,horse,gold],[6,2,camel,gold],[6,3,elephant,gold],[6,4,rabbit,gold],[6,5,dog,gold],[7,0,rabbit,gold],[7,1,rabbit,gold],[5,5,rabbit,gold],[5,6,cat,gold],[7,4,dog,gold],[7,5,rabbit,gold],[7,6,horse,gold],[7,7,rabbit,gold]],[[[5,6],[6,6]],[[4,6],[5,6]]]).
%pousser_possible([[4,5,rabbit,silver],[0,1,rabbit,silver],[4,6,horse,silver],[0,3,rabbit,silver],[0,4,elephant,silver],[0,5,rabbit,silver],[0,6,rabbit,silver],[0,7,rabbit,silver],[1,0,camel,silver],[1,1,cat,silver],[1,2,rabbit,silver],[1,3,dog,silver],[1,4,rabbit,silver],[1,5,horse,silver],[1,6,dog,silver],[1,7,cat,silver],[2,7,rabbit,gold],[6,0,cat,gold],[6,1,horse,gold],[6,2,camel,gold],[6,3,elephant,gold],[6,4,rabbit,gold],[6,5,dog,gold],[7,0,rabbit,gold],[7,1,rabbit,gold],[5,5,rabbit,gold],[5,6,cat,gold],[7,4,dog,gold],[7,5,rabbit,gold],[7,6,horse,gold],[7,7,rabbit,gold]],[[[5,6],[X,Y]],[[4,6],[5,6]]]).
%setof([[[5,6],[X,Y]],[[4,6],[5,6]]],pousser_possible([[4,5,rabbit,silver],[0,1,rabbit,silver],[4,6,horse,silver],[0,3,rabbit,silver],[0,4,elephant,silver],[0,5,rabbit,silver],[0,6,rabbit,silver],[0,7,rabbit,silver],[1,0,camel,silver],[1,1,cat,silver],[1,2,rabbit,silver],[1,3,dog,silver],[1,4,rabbit,silver],[1,5,horse,silver],[1,6,dog,silver],[1,7,cat,silver],[2,7,rabbit,gold],[6,0,cat,gold],[6,1,horse,gold],[6,2,camel,gold],[6,3,elephant,gold],[6,4,rabbit,gold],[6,5,dog,gold],[7,0,rabbit,gold],[7,1,rabbit,gold],[5,5,rabbit,gold],[5,6,cat,gold],[7,4,dog,gold],[7,5,rabbit,gold],[7,6,horse,gold],[7,7,rabbit,gold]],[[[5,6],[X,Y]],[[4,6],[5,6]]]), Res).


%tirer_possible(Board, TirerEnnemi) -> TirerEnnemi de la forme : [[[XallieDepart,YallieDepart],[XallieArrive,YallieArrive]],[[[XennemiDepart,YennemiDepart],[XennemiArrive,YennemiArrive]]]]
tirer_possible(Board, [[[Xallie,Yallie],[Zallie,Yallie]],[[Xennemi,Yennemi],[Xallie,Yallie]]]):- Zallie is Xallie+1, get_case(Board,(Xallie,Yallie), [Xallie,Yallie,TypeAllie,JoueurAllie]), TypeAllie \= -1, JoueurAllie \= -1, get_case(Board, (Xennemi,Yennemi), [Xennemi,Yennemi,TypeEnnemi,JoueurEnnemi]), TypeEnnemi \= -1, JoueurEnnemi \= -1, plus_fort(TypeAllie,TypeEnnemi), voisinB(Board,(Xallie,Yallie),[Zallie,Yallie,A,B]), A = -1, B = -1. 
tirer_possible(Board, [[[Xallie,Yallie],[Zallie,Yallie]],[[Xennemi,Yennemi],[Xallie,Yallie]]]):- Zallie is Xallie-1, get_case(Board,(Xallie,Yallie), [Xallie,Yallie,TypeAllie,JoueurAllie]), TypeAllie \= -1, JoueurAllie \= -1, get_case(Board, (Xennemi,Yennemi), [Xennemi,Yennemi,TypeEnnemi,JoueurEnnemi]), TypeEnnemi \= -1, JoueurEnnemi \= -1, plus_fort(TypeAllie,TypeEnnemi), voisinH(Board,(Xallie,Yallie),[Zallie,Yallie,A,B]), A = -1, B = -1. 
tirer_possible(Board, [[[Xallie,Yallie],[Xallie,Zallie]],[[Xennemi,Yennemi],[Xallie,Yallie]]]):- Zallie is Yallie+1, get_case(Board,(Xallie,Yallie), [Xallie,Yallie,TypeAllie,JoueurAllie]), TypeAllie \= -1, JoueurAllie \= -1, get_case(Board, (Xennemi,Yennemi), [Xennemi,Yennemi,TypeEnnemi,JoueurEnnemi]), TypeEnnemi \= -1, JoueurEnnemi \= -1, plus_fort(TypeAllie,TypeEnnemi), voisinD(Board,(Xallie,Yallie),[Xallie,Zallie,A,B]), A = -1, B = -1. 
tirer_possible(Board, [[[Xallie,Yallie],[Xallie,Zallie]],[[Xennemi,Yennemi],[Xallie,Yallie]]]):- Zallie is Yallie-1, get_case(Board,(Xallie,Yallie), [Xallie,Yallie,TypeAllie,JoueurAllie]), TypeAllie \= -1, JoueurAllie \= -1, get_case(Board, (Xennemi,Yennemi), [Xennemi,Yennemi,TypeEnnemi,JoueurEnnemi]), TypeEnnemi \= -1, JoueurEnnemi \= -1, plus_fort(TypeAllie,TypeEnnemi), voisinG(Board,(Xallie,Yallie),[Xallie,Zallie,A,B]), A = -1, B = -1. 

%EXEMPLE EXECUTION:
%tirer_possible([[0,0,rabbit,silver],[0,1,rabbit,silver],[5,5,horse,silver],[0,3,rabbit,silver],[0,4,elephant,silver],[0,5,rabbit,silver],[0,6,rabbit,silver],[0,7,rabbit,silver],[1,0,camel,silver],[1,1,cat,silver],[1,2,rabbit,silver],[1,3,dog,silver],[1,4,rabbit,silver],[1,5,horse,silver],[1,6,dog,silver],[1,7,cat,silver],[2,7,rabbit,gold],[6,0,cat,gold],[6,1,horse,gold],[6,2,camel,gold],[6,3,elephant,gold],[6,4,rabbit,gold],[6,5,dog,gold],[6,6,rabbit,gold],[7,0,rabbit,gold],[7,1,rabbit,gold],[7,2,rabbit,gold],[7,3,cat,gold],[7,4,dog,gold],[7,5,rabbit,gold],[7,6,horse,gold],[7,7,rabbit,gold]],[[[5,5],[4,5]],[[6,5],[5,5]]]).
%setof([[[5,5],[X,Y]],[[6,5],[5,5]]],tirer_possible([[0,0,rabbit,silver],[0,1,rabbit,silver],[5,5,horse,silver],[0,3,rabbit,silver],[0,4,elephant,silver],[0,5,rabbit,silver],[0,6,rabbit,silver],[0,7,rabbit,silver],[1,0,camel,silver],[1,1,cat,silver],[1,2,rabbit,silver],[1,3,dog,silver],[1,4,rabbit,silver],[1,5,horse,silver],[1,6,dog,silver],[1,7,cat,silver],[2,7,rabbit,gold],[6,0,cat,gold],[6,1,horse,gold],[6,2,camel,gold],[6,3,elephant,gold],[6,4,rabbit,gold],[6,5,dog,gold],[6,6,rabbit,gold],[7,0,rabbit,gold],[7,1,rabbit,gold],[7,2,rabbit,gold],[7,3,cat,gold],[7,4,dog,gold],[7,5,rabbit,gold],[7,6,horse,gold],[7,7,rabbit,gold]],[[[5,5],[X,Y]],[[6,5],[5,5]]]),Res).


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


%deplacement(Board,NvBoard,Depart,Arrive) :- NvBoard s unifie avec Board modifié, on modifie seulement les coordonnées d une pièce sans verification.

deplacement([[A,B,C,D]|E], [[LigneA,ColonneA,C,D]|E], (A,B), (LigneA, ColonneA)):- !.
deplacement([A|E], [A|R], (LigneD,ColonneD), (LigneA, ColonneA) ):- deplacement(E,R,(LigneD,ColonneD), (LigneA, ColonneA) ).

%EXEMPLE EXECUTION :
%deplacement([[0,0,rabbit,silver],[0,1,rabbit,silver],[0,2,horse,silver],[0,3,rabbit,silver],[0,4,elephant,silver],[0,5,rabbit,silver],[0,6,rabbit,silver],[0,7,rabbit,silver],[1,0,camel,silver],[1,1,cat,silver],[1,2,rabbit,silver],[1,3,dog,silver],[1,4,rabbit,silver],[1,5,horse,silver],[1,6,dog,silver],[1,7,cat,silver],[2,7,rabbit,gold],[6,0,cat,gold],[6,1,horse,gold],[6,2,camel,gold],[6,3,elephant,gold],[6,4,rabbit,gold],[6,5,dog,gold],[6,6,rabbit,gold],[7,0,rabbit,gold],[7,1,rabbit,gold],[7,2,rabbit,gold],[7,3,cat,gold],[7,4,dog,gold],[7,5,rabbit,gold],[7,6,horse,gold],[7,7,rabbit,gold]], Res, (1,1), (2,1)).


%suppression d un pion du plateau lorsqu il est mangé.
%PROTOTYPE : delete_pion(pion,board,R).
%EXECUTION : delete_pion([0,0,rabbit,silver],[[0,0,rabbit,silver],[0,1,rabbit,silver],[0,2,horse,silver],[0,3,rabbit,silver],[0,4,elephant,silver],[0,5,rabbit,silver],[0,6,rabbit,silver],[0,7,rabbit,silver],[1,0,camel,silver],[1,1,cat,silver],[1,2,rabbit,silver],[1,3,dog,silver],[1,4,rabbit,silver],[1,5,horse,silver],[1,6,dog,silver],[1,7,cat,silver],[2,7,rabbit,gold],[6,0,cat,gold],[6,1,horse,gold],[6,2,camel,gold],[6,3,elephant,gold],[6,4,rabbit,gold],[6,5,dog,gold],[6,6,rabbit,gold],[7,0,rabbit,gold],[7,1,rabbit,gold],[7,2,rabbit,gold],[7,3,cat,gold],[7,4,dog,gold],[7,5,rabbit,gold],[7,6,horse,gold],[7,7,rabbit,gold]],R).

delete_pion(_,[],_).
delete_pion(X,[X|Q],R):- concat(_,Q,R),!.
delete_pion(X,[T|Q],[T|R]):-delete_pion(X,Q,R).

%liste des pions jouables ainsi que chaque coup possible. RETOURNE UNE LISTE À 2 ÉLÉMENTS : 1- la tête est un pion, 2- la queue est une liste de coups possibles pour ce pion.
%RESULTAT exemple : R = [[[1, 0, camel, silver], [[2, 0]]], [[1, 1, cat, silver], [[2, 1]]], [[1, 2, rabbit, silver], [[2, 2]]], [[1, 3, dog, silver], [[2, 3]]], [[1, 4, rabbit|...], [[2|...]]], [[1, 5|...], [[...|...]]], [[1|...], [...]], [[...|...]|...], [...|...]|...].
%PROTOTYPE : liste_coup(Board,BoardTemp,R).
%EXECUTION :liste_coup([[0,0,rabbit,silver],[0,1,rabbit,silver],[0,2,horse,silver],[0,3,rabbit,silver],[0,4,elephant,silver],[0,5,rabbit,silver],[0,6,rabbit,silver],[0,7,rabbit,silver],[1,0,camel,silver],[1,1,cat,silver],[1,2,rabbit,silver],[1,3,dog,silver],[1,4,rabbit,silver],[1,5,horse,silver],[1,6,dog,silver],[1,7,cat,silver],[2,7,rabbit,gold],[6,0,cat,gold],[6,1,horse,gold],[6,2,camel,gold],[6,3,elephant,gold],[6,4,rabbit,gold],[6,5,dog,gold],[6,6,rabbit,gold],[7,0,rabbit,gold],[7,1,rabbit,gold],[7,2,rabbit,gold],[7,3,cat,gold],[7,4,dog,gold],[7,5,rabbit,gold],[7,6,horse,gold],[7,7,rabbit,gold]],[[0,0,rabbit,silver],[0,1,rabbit,silver],[0,2,horse,silver],[0,3,rabbit,silver],[0,4,elephant,silver],[0,5,rabbit,silver],[0,6,rabbit,silver],[0,7,rabbit,silver],[1,0,camel,silver],[1,1,cat,silver],[1,2,rabbit,silver],[1,3,dog,silver],[1,4,rabbit,silver],[1,5,horse,silver],[1,6,dog,silver],[1,7,cat,silver],[2,7,rabbit,gold],[6,0,cat,gold],[6,1,horse,gold],[6,2,camel,gold],[6,3,elephant,gold],[6,4,rabbit,gold],[6,5,dog,gold],[6,6,rabbit,gold],[7,0,rabbit,gold],[7,1,rabbit,gold],[7,2,rabbit,gold],[7,3,cat,gold],[7,4,dog,gold],[7,5,rabbit,gold],[7,6,horse,gold],[7,7,rabbit,gold]],R).

liste_coup(_,[],[]).
liste_coup(Board,[[X,Y,_,_]|Q],R):- \+setof([X1,Y1],deplacement_possible(Board,[[X,Y],[X1,Y1]]),_),liste_coup(Board,Q,R),!.
liste_coup(Board,[[X,Y,T,J]|Q],R):- setof([X1,Y1],deplacement_possible(Board,[[X,Y],[X1,Y1]]),Res),concat([[[X,Y,T,J],Res]],R1,R),liste_coup(Board,Q,R1).

%mise à jour du board après avoir déplacé un pion. 
%PROTOTYPE : maj_board(Board,P,X,Y,R). p est un pion avant de délplacement, X et Y sont les nouvelles coordonnées de ce pion et R est la nouvelle board mise à jour.
%EXECUTION : maj_board([[0,0,rabbit,silver],[0,1,rabbit,silver],[0,2,horse,silver],[7,5,rabbit,gold],[7,6,horse,gold],[7,7,rabbit,gold]],[0,0,rabbit,silver],1,1,R).

maj_board(Board,[X1,Y1,T,J],X,Y,R):- delete_pion([X1,Y1,T,J],Board,R1),concat([[X,Y,T,J]],R1,R).



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

%boucle principal de jeux

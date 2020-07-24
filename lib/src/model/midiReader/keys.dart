

import 'note.dart';

/// EXPLICATION SUR FIGMA

class Keys {

	static final int NB_TOUCHES_VERTICALE_MAX = 120;
	static String TAG = "class : KEYS --> ";

	List<ListeVerticale> keys;

	Keys() {
		//System.out.println(TAG + "Keys constructor");
		keys = List();
		for(int i=0;i<NB_TOUCHES_VERTICALE_MAX;i++){
			keys.add(new ListeVerticale());
		}
	}

	noteOn(Note n){
		if (n.getKey()>NB_TOUCHES_VERTICALE_MAX || n.getKey()<0){
			print("!!!$n note in range!!!");
		}else{
			keys[n.getKey()].noteOn(n);
		}
	}

	noteOff(Note n){
		if (n.getKey()>NB_TOUCHES_VERTICALE_MAX || n.getKey()<0){
			print("!!!$n note in range!!!");
		}else{
			keys[n.getKey()].noteOff(n);
		}
	}

	Map<int,List<Note>> getListeNote(){ //Je returne une Map qui dit à chaque tick quels temps sont à jouer
		List<Note> l = [];
		Map<int,List<Note>> map = new Map();

		//je récupère toutes les notes
		for(ListeVerticale list in keys){
			l.addAll(list.listNotes);
		}

		//Je trouve le temps d'espaçage entre les affichages
		int tick_espacage = _trouveLeTempsEspacage(l);

		//je trie la liste
		for(Note n in l){
			//print(n);
		}

	}

  int _trouveLeTempsEspacage(List<Note> l) {
		int temps_espacage = 0;



		return temps_espacage;
	}

}

class ListeVerticale{

	List<Note> listNotes;

	ListeVerticale(){
		listNotes = [];
	}

	void noteOn(Note n){
		if (listNotes.length!=0 && !listNotes[listNotes.length-1].aDejaUneNoteOff()){
			//Si la note d'avant n'a pas été terminée, je la retire et j'insère la mienne
			listNotes.removeLast();
			print("J'ajoute $n");
			listNotes.add(n);
		}else{
			listNotes.add(n);
		}
	}

	void noteOff(Note n){
		if (listNotes.length == 0 || listNotes[listNotes.length-1].aDejaUneNoteOff()){
			//Il n'y a pas de note avant ou la note d'avant est déjà terminée
			print("Il n'y a pas de note avant ou la note d'avant est déjà terminée");
		}
		else{
			listNotes[listNotes.length-1].setTimeOff(n.getTimeOff());
			Note note = listNotes.removeLast();
			note.setTimeOff(n.getTimeOff());
			listNotes.add(note);
			print("je viens de finir $note");
		}
	}

	List<Note> getListeNote(){
		return listNotes;
	}

}
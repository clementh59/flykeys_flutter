import 'dart:core';


class Note{

	static final String TAG = "class : NOTE --> ";

	int key;
	int timeOn;
	int timeOff;
	bool _isAnotherColor;

	Note(int key, int timeOn) {
		this.key = key;
		this.timeOn = timeOn;
		timeOff = -1;
		_isAnotherColor = false;
	}

	int getKey() {
		return key;
	}

	int getTimeOn() {
		return timeOn;
	}

	int getTimeOff() {
		return timeOff;
	}

	void setTimeOff(int timeOff) {
		this.timeOff = timeOff;
	}

	bool aDejaUneNoteOff(){
		if (timeOff==-1)
			return false;
		return true;
	}


	bool get isAnotherColor => _isAnotherColor;

  void setIsAnotherColor() {
    _isAnotherColor = true;
  }

  @override
	String toString() {
		return "La note est (" + getKey().toString() + ") le temps de début est " + getTimeOn().toString() + " et la note dure " + (getTimeOff()-getTimeOn()).toString();
	}


}
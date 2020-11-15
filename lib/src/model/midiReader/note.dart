import 'dart:core';


class Note{

	static final String TAG = "class : NOTE --> ";

	int key;
	int timeOn;
	int timeOff;
	String color;

	/// @param {String} color : ex -> "MD", "MG", ...
	Note(this.key, this.timeOn, this.timeOff, this.color);

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

	String getColor(){
		return this.color;
	}

	bool aDejaUneNoteOff(){
		if (timeOff==-1)
			return false;
		return true;
	}

	bool isReleaseAndPush() {
		return color.contains("_R&P");
	}

  void setIsReleaseAndPushColor() {
		if (!isReleaseAndPush())
    	color += "_R&P";
  }

  @override
	String toString() {
		return "La note est (" + getKey().toString() + ") le temps de début est " + getTimeOn().toString() + " et la note dure " + (getTimeOff()-getTimeOn()).toString();
	}


}
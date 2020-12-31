class BluetoothConstants {

	static const int MTU_SIZE = 254;
	static const int SCAN_TIMEOUT = 6; //time out de 6s pour le scan
	static const String uuidOfMainCommunication =
			"beb5483e-36e1-4688-b7f5-ea07361b26a8";
	static const String uuidOfTickCommunication =
			"beb5483e-36e1-4688-b7f5-ea07361b26a7";

	static const CODE_MODE_APPRENTISSAGE_ENVOI_DU_MORCEAU = 0xFD;
	static const CODE_PLAY = 0xFC;
	static const CODE_PAUSE = 0xFB;
	static const CODE_DELAY = 0xFA;
	static const CODE_SET_I_HAVE_TO_WAIT_FOR_USER_INPUT = 0xF9;
	static const CODE_SET_I_DONT_HAVE_TO_WAIT_FOR_USER_INPUT = 0xF8;
	static const CODE_I_SEND_COLOR = 0xF7;
	static const CODE_MODE_LIGHTNING_SHOW = 0xF6;
	static const CODE_SET_UP_MIDI_KEYBOARD_LIMIT = 0xF4;
	static const CODE_LIGHT_LEDS = 0xF3;
	static const CODE_CLEAR_LEDS = 0xF2;

	static const CODE_NEW_TICK = 0xBD;

	static const mapStringColorToCode = {
		'MD':0x02,
		'MD_R&P': 0x03,
		'MG':0x05,
		'MG_R&P':0x06,
	};

	static const CODE_CHANGE_THE_SHOWN_HAND = 0xF5;
	static const CODES_SHOW_THE_TWO_HANDS = [CODE_CHANGE_THE_SHOWN_HAND, 0];
	static const CODES_SHOW_ONLY_THE_RIGHT_HAND = [CODE_CHANGE_THE_SHOWN_HAND, 1];
	static const CODES_SHOW_ONLY_THE_LEFT_HAND = [CODE_CHANGE_THE_SHOWN_HAND, 2];


}
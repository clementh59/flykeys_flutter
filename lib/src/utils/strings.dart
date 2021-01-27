class Strings{

	//region Login / Signup
	static const String mdp_too_short = "Le mot de passe doit faire au moins 6 caractères";
	static const String la_creation_de_compte_a_echoue = "La création du compte a échoué";
	static const String email_non_valide = "L'email n'est pas valide";
	static const String mdp_peut_pas_etre_vide = "Le mot de passe ne peux pas être vide!";
	static const String account_already_exists = "Un compte avec cet email existe déjà!";
	static const String error_wrong_password = "Le mot de passe est invalide!";
	static const String email_envoye = "Email envoyé!";
	static const String entre_ton_email_pour_reinitialiser = "Entre ton email pour pouvoir réinitialiser ton mot de passe!";
	static const String deconnection = "Déconnexion";

	//region Errors Firebase connection
	static const String ERROR_INVALID_CUSTOM_TOKEN =  "The custom token format is incorrect. Please check the documentation.";
	static const String ERROR_CUSTOM_TOKEN_MISMATCH = "The custom token corresponds to a different audience.";
	static const String ERROR_INVALID_CREDENTIAL = "The supplied auth credential is malformed or has expired.";
	static const String ERROR_USER_MISMATCH = "The supplied credentials do not correspond to the previously signed in user.";
	static const String ERROR_REQUIRES_RECENT_LOGIN = "This operation is sensitive and requires recent authentication. Log in again before retrying this request.";
	static const String ERROR_ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL = "An account already exists with the same email address but different sign-in credentials. Sign in using a provider associated with this email address.";
	static const String ERROR_CREDENTIAL_ALREADY_IN_USE = "This credential is already associated with a different user account.";
	static const String ERROR_USER_DISABLED = "The user account has been disabled by an administrator.";
	static const String ERROR_USER_TOKEN_EXPIRED = "The user\'s credential is no longer valid. The user must sign in again.";
	static const String ERROR_USER_NOT_FOUND = "There is no user record corresponding to this identifier. The user may have been deleted.";
	static const String ERROR_INVALID_USER_TOKEN = "The user\'s credential is no longer valid. The user must sign in again.";
	static const String ERROR_OPERATION_NOT_ALLOWED = "This operation is not allowed. You must enable this service in the console.";
	//endregion

	//endregion

	//region Shared Prefs
	static const String WAIT_FOR_USER_INPUT_SHARED_PREFS = "WAIT_FOR_USER_INPUT";
	static const String COLOR_MD_SHARED_PREFS = "COLOR_MD";
	static const String COLOR_MG_SHARED_PREFS = "COLOR_MG";
	static const String BRIGHTNESS_SHARED_PREFS = "BRIGHTNESS_SHARED_PREFS";
	static const String I_DID_ONBOARDING_SHARED_PREFS = "I_DID_ONBOARDING";
	static const String PIANO_INFOS_SHARED_PREFS = "PIANO_INFOS";

	static const String RECENT_SEARCH_SHARED_PREFS = "RECENT_SEARCH_SHARED_PREFS";
	//endregion

}
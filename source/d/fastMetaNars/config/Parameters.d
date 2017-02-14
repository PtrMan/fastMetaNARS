module fastMetaNars.config.Parameters;

// https://github.com/opennars/opennars/blob/1.6.5_devel17_RetrospectiveAnticipation/nars_core/nars/config/Parameters.java
struct Parameters {
	/** determines the internal precision used for TruthValue calculations.
     *  Change at your own risk
     */
    static const float TRUTH_EPSILON = 0.01f;

    static bool DEBUG_BAG = true;
    static bool DEBUG = true;


	/** Level separation in LevelBag, one digit, for display (run-time adjustable) and management (fixed)
     */
    static float BAG_THRESHOLD = 1.0f;
}

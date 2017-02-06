module fastMetaNars.config.Parameters;

// https://github.com/opennars/opennars/blob/1.6.5_devel17_RetrospectiveAnticipation/nars_core/nars/config/Parameters.java
struct Parameters {
	/** determines the internal precision used for TruthValue calculations.
     *  Change at your own risk
     */
    static const float TRUTH_EPSILON = 0.01f;
}

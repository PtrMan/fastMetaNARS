#include "Deriver.h"

#include "Ruletable.h"
#include "TermConcept.h"

vector<UnifiedTerm> derive(ReasonerInstance &reasonerInstance, vector<UnifiedTermIndex> &leftPathTermIndices, vector<UnifiedTermIndex> &rightPathTermIndices, float k) {

	vector<UnifiedTerm> resultTerms;

	UnifiedTermIndex previousLeftIndex = leftPathTermIndices[leftPathTermIndices.size() - 1]; // AUTOGEN< need it to check for the flags of the left concept >
	UnifiedTerm previousLeft = reasonerInstance.accessTermByIndex(previousLeftIndex);

	UnifiedTermIndex previousRightIndex = rightPathTermIndices[leftPathTermIndices.size() - 1]; // AUTOGEN< need it to check for the flags of the right concept >
	UnifiedTerm previousRight = reasonerInstance.accessTermByIndex(previousRightIndex);

	typedef decltype(previousLeft.termFlags) TermFlagsType;

	if (
		// AUTOGEN< check flags for match >
		(previousLeft.termFlags == (static_cast<decltype(previousLeft.termFlags)>(static_cast<TermFlagsType>(EnumTermFlags::INHERITANCE_TORIGHT))) && previousRight.termFlags == (static_cast<decltype(previousLeft.termFlags)>(static_cast<TermFlagsType>(EnumTermFlags::INHERITANCE_TORIGHT))))

		// AUTOGEN< check for source pattern >
		&& (true && (previousLeft.left.value == previousRight.left.value))

		// AUTOGEN check eventually for the unequal precondition
		&& (previousRight.right.value != previousLeft.right.value)
		) {

		Ruletable::GeneralizedBinaryRule rule;
		rule.sourceLeft = Ruletable::EnumDerivationSource::BRIGHT;
		rule.sourceRight = Ruletable::EnumDerivationSource::ARIGHT;
		rule.termFlags = static_cast<decltype(rule.termFlags)>(static_cast<TermFlagsType>(EnumTermFlags::INHERITANCE_TOLEFT) | static_cast<TermFlagsType>(EnumTermFlags::INHERITANCE_TORIGHT));
		rule.truthFunction = Ruletable::EnumTruthFunction::REVISION;

		UnifiedTerm resultTerm = Ruletable::ruletableGeneralizedBinary(previousLeft, previousRight, k, rule);
		resultTerms.push_back(resultTerm);

		// AUTOGEN TODO< PATRICK ASK < do we need to append the stuff before the tree  > >
	}
	else

		if (
			// AUTOGEN< check flags for match >
			(previousLeft.termFlags == (static_cast<decltype(previousLeft.termFlags)>(static_cast<TermFlagsType>(EnumTermFlags::INHERITANCE_TORIGHT))) && previousRight.termFlags == (static_cast<decltype(previousLeft.termFlags)>(static_cast<TermFlagsType>(EnumTermFlags::INHERITANCE_TOLEFT) | static_cast<TermFlagsType>(EnumTermFlags::INHERITANCE_TORIGHT))))

			// AUTOGEN< check for source pattern >
			&& (true && (previousLeft.left.value == previousRight.right.value))

			// AUTOGEN check eventually for the unequal precondition
			&& (previousRight.left.value != previousLeft.right.value)
			) {

			Ruletable::GeneralizedBinaryRule rule;
			rule.sourceLeft = Ruletable::EnumDerivationSource::BLEFT;
			rule.sourceRight = Ruletable::EnumDerivationSource::ARIGHT;
			rule.termFlags = static_cast<decltype(rule.termFlags)>(static_cast<TermFlagsType>(EnumTermFlags::INHERITANCE_TORIGHT));
			rule.truthFunction = Ruletable::EnumTruthFunction::ANALOGY;

			UnifiedTerm resultTerm = Ruletable::ruletableGeneralizedBinary(previousLeft, previousRight, k, rule);
			resultTerms.push_back(resultTerm);

			// AUTOGEN TODO< PATRICK ASK < do we need to append the stuff before the tree  > >
		}
		else
			;
	return resultTerms;
}
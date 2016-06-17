#pragma once

#include <cstdint>

#include "TermConcept.h"
#include "UnifiedTerm.h"
#include "FrequencyCertainty.h"

struct Ruletable {
	enum class EnumDerivationSource {
		ALEFT,
		ARIGHT,
		BLEFT,
		BRIGHT,
	};

	enum class EnumTruthFunction {
		REVISION,
		COMPARISION,
		ANALOGY,
		ANALOGYTICK,
		DEDUCTION2
	};

	struct GeneralizedBinaryRule {
		EnumDerivationSource sourceLeft;
		EnumDerivationSource sourceRight;
		uint32_t termFlags;
		EnumTruthFunction truthFunction;
	};



	// version with lookuptable
	// is just used for binary results, where the left and right side just can be chosen from the left or right sides of the inputs
	static UnifiedTerm ruletableGeneralizedBinary(UnifiedTerm a, UnifiedTerm b, float k, GeneralizedBinaryRule rule) {
		UnifiedTerm result;
		result.left = selectSource(rule.sourceLeft, a, b);
		result.right = selectSource(rule.sourceRight, a, b);
		result.termFlags = rule.termFlags;
		result.frequencyCertainty = lookupAndCalcFrequencyCertainty(a.frequencyCertainty, b.frequencyCertainty, k, rule.truthFunction);

		// result.derivationDescriptor = DerivationDescriptor::create(a, aTermConcept, b, bTermConcept);

		return result;

	}
private:
	// OPTIMISATION< in header for inlining >
	static UnifiedTermIndex selectSource(Ruletable::EnumDerivationSource source, UnifiedTerm a, UnifiedTerm b) {
		if (source == EnumDerivationSource::ALEFT) {
			return a.left;
		}
		else if (source == EnumDerivationSource::ARIGHT) {
			return a.right;
		}
		else if (source == EnumDerivationSource::BLEFT) {
			return b.left;
		}
		else { // if( source == EnumDerivationSource::BRIGHT ) {
			return b.right;
		}
	}

	// OPTIMISATION< in header for inlining >
	// OPTIMIZATION< could be optimized with a comparision of the middle value, like in a binary tree >
	static FrequencyCertainty lookupAndCalcFrequencyCertainty(FrequencyCertainty aFrequencyCertainty, FrequencyCertainty bFrequencyCertainty, float k, EnumTruthFunction truthFunction) {
		if (truthFunction == EnumTruthFunction::REVISION) {
			return FrequencyCertainty::fRevision(aFrequencyCertainty, bFrequencyCertainty, k);
		}
		else if (truthFunction == EnumTruthFunction::COMPARISION) {
			return FrequencyCertainty::fComparision(aFrequencyCertainty, bFrequencyCertainty, k);
		}
		else if (truthFunction == EnumTruthFunction::ANALOGY) {
			return FrequencyCertainty::fAnalogy(aFrequencyCertainty, bFrequencyCertainty, k);
		}
		else if (truthFunction == EnumTruthFunction::ANALOGYTICK) {
			return FrequencyCertainty::fAnalogyTick(aFrequencyCertainty, bFrequencyCertainty, k);
		}
		else { //if( truthFunction == EnumTruthFunction::DEDUCTION2 ) {
			return FrequencyCertainty::fDeduction2(aFrequencyCertainty, bFrequencyCertainty, k);
		}
	}
};

module fastMetaNars.inference.walker.TermWalker;

import misced.memory.ArrayStack;
import fastMetaNars.deriver.DeriverUtils;
import fastMetaNars.ReasonerInstance;
import fastMetaNars.Term;
import fastMetaNars.TermOrCompoundTermOrVariableReferer;

// used to decouple the details of the walking of the terms for transcoding into the coresponding terms
// returns the term/compoundterm and all variables
struct TermWalker {
	WalkerState[] stack;
	ReasonerInstance reasonerInstance;


	private static struct WalkerState {
		RefererOrInterval refererOrInterval;
		TemporaryDerivedCompoundWithDecoration* derivedCompound;

		bool isRefererOrInterval;

		final @property bool isDerivedCompound() {
			return !isRefererOrInterval;
		}

		static WalkerState makeRefererOrInterval(RefererOrInterval refererOrInterval) {
			WalkerState result;
			result.refererOrInterval = refererOrInterval;
			result.isRefererOrInterval = true;
			return result;
		}

		static WalkerState makeDerivedCompound(TemporaryDerivedCompoundWithDecoration *derivedCompound) {
			WalkerState result;
			result.derivedCompound = derivedCompound;
			result.isRefererOrInterval = false;
			return result;
		}
	}

	final void start(TemporaryDerivedCompoundWithDecoration* derivedCompound) {
		stack.length = 0;
		stack.length = 1;

		stack[0] = WalkerState.makeDerivedCompound(derivedCompound);
	}


	final RefererOrInterval next(out bool finished) {
		finished = false;
		if( stack.length == 0 ) {
			finished = true;
			return RefererOrInterval.init;
		}

		// TODO< log >

		WalkerState *currentWalkerState = &stack[$-1];
		WalkerState *topWalkerState = currentWalkerState;
		stack.length = stack.length-1;

		RefererOrInterval result;
		if( currentWalkerState.isRefererOrInterval ) {
			result = currentWalkerState.refererOrInterval;
		}
		else {
			Compound *compound = reasonerInstance.accessCompoundByIndex(currentWalkerState.derivedCompound.decoration.compoundIndex);
			result = RefererOrInterval.makeReferer(compound.thisTermReferer);
		}


		void innerFnPushChildrensOfCompound(Compound compound) {
			foreach( componentI; 0..compound.getComponentLength(reasonerInstance) ) {
				RefererOrInterval iterationRefererOrInterval = compound.getComponentByIndex(reasonerInstance, componentI);

				stack.push(WalkerState.makeRefererOrInterval(iterationRefererOrInterval));
			}
		}

		// depth first iteration for the current element
		// * push all childrens
		if( topWalkerState.isRefererOrInterval && topWalkerState.refererOrInterval.isReferer ) {
			TermOrCompoundTermOrVariableReferer referer = topWalkerState.refererOrInterval.referer;

			// TODO< get this index and id mess right >
			TermOrCompoundTermOrVariableReferer.EncodingType termIndex = referer.getTerm();
			Compound compound = reasonerInstance.getCompoundByIndex(cast(size_t)termIndex);
			innerFnPushChildrensOfCompound(compound);
		}
		else if( topWalkerState.isRefererOrInterval && topWalkerState.refererOrInterval.isInterval ) {
			// do nothing, we can't walk into intervals
		}
		else { // derived compound
			TemporaryDerivedCompoundWithDecoration* derivedCompound = topWalkerState.derivedCompound;

			if( derivedCompound.isVariable ) {
				// do nothing, we can't walk into variables
			}
			else if( derivedCompound.isLeaf ) {
				size_t compoundIndex = derivedCompound.decoration.compoundIndex;
				Compound compound = reasonerInstance.getCompoundByIndex(compoundIndex);
				innerFnPushChildrensOfCompound(compound);
			}
			else if( derivedCompound.isCompound ) {
				foreach( compoundIndex; 0..derivedCompound.getCompoundLength() ) {
					stack.push( WalkerState.makeDerivedCompound(derivedCompound.getCompoundByIndex(compoundIndex)) );
				}
			}
			else {
				throw new Exception("Internal error");
			}
		}



		return result;
	}
}
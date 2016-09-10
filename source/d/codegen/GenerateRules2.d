import std.typecons : Nullable, Tuple;

import lang.Parser : AbstractParser = Parser;
import lang.Token : Token;
import lang.Lexer : Lexer;

bool isOperation(const Token!EnumOperationType token, const EnumOperationType checkOperationType) {
	return token.type == Token!EnumOperationType.EnumType.OPERATION && token.contentOperation == checkOperationType;
}

string getString(const Token!EnumOperationType token) {
	return token.contentString;
}

import ArrayStack;

enum EnumOperationType {
	BRACEOPEN,
	BRACECLOSE,
	BRACKETOPEN,
	BRACKETCLOSE,
	KEY,
	POUNDKEY, // #
	SIMILARITY, // <->
	INHERITANCE, // -->
	IMPLCIATION, // ==>
	HALFH, // |-
	INDEPENDENTVAR, // $
	CONJUNCTION, // &&
	EQUIVALENCE, // <=>
	DEPENDENTVAR, // #
}

class RuleLexer : Lexer!EnumOperationType {
	override protected Token!EnumOperationType createToken(uint ruleIndex, string matchedString) {
		Token!EnumOperationType token = new Token!EnumOperationType();

		if( ruleIndex == 1 ) {
			token.type = Token!EnumOperationType.EnumType.OPERATION;
			token.contentOperation = EnumOperationType.BRACEOPEN;
		}
		else if( ruleIndex == 2 ) {
			token.type = Token!EnumOperationType.EnumType.OPERATION;
			token.contentOperation = EnumOperationType.BRACECLOSE;
		}
		else if( ruleIndex == 3 ) {
			token.type = Token!EnumOperationType.EnumType.OPERATION;
			token.contentOperation = EnumOperationType.BRACKETOPEN;
		}
		else if( ruleIndex == 4 ) {
			token.type = Token!EnumOperationType.EnumType.OPERATION;
			token.contentOperation = EnumOperationType.BRACKETCLOSE;
		}
		else if( ruleIndex == 5 ) {
			token.type = Token!EnumOperationType.EnumType.OPERATION;
			token.contentOperation = EnumOperationType.KEY;
			token.contentString = matchedString;
		}
		else if( ruleIndex == 6 ) {
			token.type = Token!EnumOperationType.EnumType.OPERATION;
			token.contentOperation = EnumOperationType.POUNDKEY;
		}
		else if( ruleIndex == 7 ) {
			token.type = Token!EnumOperationType.EnumType.OPERATION;
			token.contentOperation = EnumOperationType.SIMILARITY;
		}
		else if( ruleIndex == 8 ) {
			token.type = Token!EnumOperationType.EnumType.OPERATION;
			token.contentOperation = EnumOperationType.INHERITANCE;
		}
		else if( ruleIndex == 9 ) {
			token.type = Token!EnumOperationType.EnumType.OPERATION;
			token.contentOperation = EnumOperationType.HALFH;
		}
		else if( ruleIndex == 10 ) {
			token.type = Token!EnumOperationType.EnumType.IDENTIFIER;
			token.contentString = matchedString;
		}
		else if( ruleIndex == 11 ) {
			token.type = Token!EnumOperationType.EnumType.OPERATION;
			token.contentOperation = EnumOperationType.INDEPENDENTVAR;
			token.contentString = matchedString;
		}
		else if( ruleIndex == 12 ) {
			token.type = Token!EnumOperationType.EnumType.OPERATION;
			token.contentOperation = EnumOperationType.IMPLCIATION;
		}
		else if( ruleIndex == 13 ) {
			token.type = Token!EnumOperationType.EnumType.OPERATION;
			token.contentOperation = EnumOperationType.CONJUNCTION;
		}
		else if( ruleIndex == 14 ) {
			token.type = Token!EnumOperationType.EnumType.OPERATION;
			token.contentOperation = EnumOperationType.EQUIVALENCE;
		}

		return token;
	}

	override protected void fillRules() {
		tokenRules ~= Lexer!EnumOperationType.Rule(r"^([ \n\r\t]+)");
		tokenRules ~= Lexer!EnumOperationType.Rule(r"^(\()");
		tokenRules ~= Lexer!EnumOperationType.Rule(r"^(\))");
		tokenRules ~= Lexer!EnumOperationType.Rule(r"^(\[)");
		tokenRules ~= Lexer!EnumOperationType.Rule(r"^(\])");
		tokenRules ~= Lexer!EnumOperationType.Rule(r"^(:[a-zA-Z/\-\?!=]+)");
		tokenRules ~= Lexer!EnumOperationType.Rule(r"^(#)");
		tokenRules ~= Lexer!EnumOperationType.Rule(r"^(<->)");
		tokenRules ~= Lexer!EnumOperationType.Rule(r"^(-->)");
		tokenRules ~= Lexer!EnumOperationType.Rule(r"^(\|-)");
		tokenRules ~= Lexer!EnumOperationType.Rule(r"^([a-zA-Z][0-9A-Za-z]*)");
		tokenRules ~= Lexer!EnumOperationType.Rule(r"^(\$[a-zA-Z][0-9A-Za-z]*)");
		tokenRules ~= Lexer!EnumOperationType.Rule(r"^(==>)");
		tokenRules ~= Lexer!EnumOperationType.Rule(r"^(&&)");
		tokenRules ~= Lexer!EnumOperationType.Rule(r"^(<=>)");
	}
}

import std.variant : Variant;


struct TokenWithDecoration {
	enum EnumType {
		TOKEN,
		INDEPENDENTVAR,
		DEPENDENTVAR,
	}

	Token!EnumOperationType token;

	EnumType type;

	final @property bool isIndependentVariable() {
		return type == EnumType.INDEPENDENTVAR;
	}

	final @property bool isDependentVariable() {
		return type == EnumType.DEPENDENTVAR;
	}

	final @property bool isVariable() {
		return isIndependentVariable || isDependentVariable;
	}


	static TokenWithDecoration makeToken(Token!EnumOperationType token) {
		TokenWithDecoration result;
		result.type = EnumType.TOKEN;
		result.token = token;
		return result;
	}

	static TokenWithDecoration makeIndependentVar(Token!EnumOperationType token) {
		TokenWithDecoration result;
		result.token = token;
		result.type = EnumType.INDEPENDENTVAR;
		return result;
	}

	static TokenWithDecoration makeDependentVar(Token!EnumOperationType token) {
		TokenWithDecoration result;
		result.token = token;
		result.type = EnumType.DEPENDENTVAR;
		return result;
	}
}

class Element {
	enum EnumType {
		TOKENWITHDECORATION,
		BRACE,
	}

	static Element makeTokenWithDecoration(TokenWithDecoration tokenWithDecoration) {
		Element result = new Element(EnumType.TOKENWITHDECORATION);
		result.protectedTokenWithDecoration = tokenWithDecoration;
		return result;
	}

	static Element makeBrace() {
		Element result = new Element(EnumType.BRACE);
		return result;
	}

	protected EnumType type;

	final protected this(EnumType type) {
		this.type = type;
	}

	final @property bool isBrace() {
		return type == EnumType.BRACE;
	}

	final @property bool isTokenWithDecoration() {
		return type == EnumType.TOKENWITHDECORATION;
	}


	final @property TokenWithDecoration tokenWithDecoration() {
		assert(type == EnumType.TOKENWITHDECORATION);
		return protectedTokenWithDecoration;
	}

	protected TokenWithDecoration protectedTokenWithDecoration;
	Element[] braceContent; // without accessor because im not sure if the array can be manipulated like an reference if we pass it outside
	                        // TODO< investigate this >

	final @property Element leftChild() {
		assert(braceContent.length == 3);
		return braceContent[0];
	}

	final @property Element rightChild() {
		assert(braceContent.length == 3);
		return braceContent[2];
	}

	final @property string leftIdentifier() {
		assert(leftChild.tokenWithDecoration.token.type == Token!EnumOperationType.EnumType.IDENTIFIER);
		return leftChild.tokenWithDecoration.token.contentString;
	}

	final @property string rightIdentifier() {
		assert(rightChild.tokenWithDecoration.token.type == Token!EnumOperationType.EnumType.IDENTIFIER);
		return rightChild.tokenWithDecoration.token.contentString;
	}

	final @property EnumOperationType operation() {
		assert(braceContent[1].tokenWithDecoration.token.type == Token!EnumOperationType.EnumType.OPERATION);
		return braceContent[1].tokenWithDecoration.token.contentOperation;
	}

	final void debugIt(uint depth) {
		string spaceTimes(uint times) {
			string result;
			foreach( i; 0..times ) {
				result ~= "   ";
			}
			return result;
		}

		import std.stdio;

		if( isTokenWithDecoration ) {
			writeln(spaceTimes(depth), "token ", tokenWithDecoration.token.getString);
		}
		else {
			writeln(spaceTimes(depth), "brace");
			foreach( iterationChildren; braceContent ) {
				iterationChildren.debugIt(depth+1);
			}
		}
	}

}

class Parser : AbstractParser!EnumOperationType {
	Element[] elementsStack;

	protected final @property Element topElement() {
   		return elementsStack.top;
   	}



	override protected void fillArcs() {
		void nothing(AbstractParser!EnumOperationType parserObj, Token!EnumOperationType currentToken) {
		}

		void beginRule(AbstractParser!EnumOperationType parserObj, Token!EnumOperationType currentToken) {
        	rules ~= new Rule();
        	rules.top.rootElement = Element.makeBrace();
        	elementsStack = [rules.top.rootElement];
		}

		void beginBraceElement(AbstractParser!EnumOperationType parser, Token!EnumOperationType currentToken) {
			Element createdElement = Element.makeBrace();
			elementsStack.top.braceContent ~= createdElement;
			elementsStack.push(createdElement);
		}

		void endBraceElement(AbstractParser!EnumOperationType parser, Token!EnumOperationType currentToken) {
			elementsStack.pop();
		}

		void addTokenToBrace(AbstractParser!EnumOperationType parserObj, Token!EnumOperationType currentToken) {
        	topElement.braceContent ~= Element.makeTokenWithDecoration(TokenWithDecoration.makeToken(currentToken));
		}

		void pushIndependentVar(AbstractParser!EnumOperationType parserObj, Token!EnumOperationType currentToken) {
        	topElement.braceContent ~= Element.makeTokenWithDecoration(TokenWithDecoration.makeIndependentVar(currentToken));
		}

		void pushDependentVar(AbstractParser!EnumOperationType parserObj, Token!EnumOperationType currentToken) {
        	topElement.braceContent ~= Element.makeTokenWithDecoration(TokenWithDecoration.makeDependentVar(currentToken));
		}


		Nullable!uint nullUint;

		Arc errorArc = new Arc(AbstractParser!EnumOperationType.Arc.EnumType.ERROR    , 0                                                    , &nothing             , 0                     , nullUint                     );

		const size_t SYLOGISMSTART = 10;
		const size_t SYLOGISMWITHOUTBRACESTART = 20;

		// Tree

		// parses the main sequence made out of braces, variables, half-h, etc

		/* +  0 */this.Arcs ~= new Arc(AbstractParser!EnumOperationType.Arc.EnumType.OPERATION, cast(uint)EnumOperationType.POUNDKEY             , &nothing       , 1, Nullable!uint(5));
		/* +  1 */this.Arcs ~= new Arc(AbstractParser!EnumOperationType.Arc.EnumType.TOKEN    , cast(uint)Token!EnumOperationType.EnumType.IDENTIFIER, &nothing          , 2, nullUint);
		/* +  2 */this.Arcs ~= new Arc(AbstractParser!EnumOperationType.Arc.EnumType.OPERATION, cast(uint)EnumOperationType.BRACKETOPEN             , &beginRule       , 3, nullUint);

		/* +  3 */this.Arcs ~= new Arc(AbstractParser!EnumOperationType.Arc.EnumType.OPERATION, cast(uint)EnumOperationType.BRACKETCLOSE             , &nothing       , 0, Nullable!uint(4));
		/* +  4 */this.Arcs ~= new Arc(AbstractParser!EnumOperationType.Arc.EnumType.ARC      , SYLOGISMWITHOUTBRACESTART                                                    , &nothing, 3, nullUint);

		// TODO< set a flag in SYLOGISMWITHOUTBRACESTART if it didn't match anything and check for it here, then check it here and if its not set then it means that there was an parsing error

		/* +  5 */this.Arcs ~= new Arc(AbstractParser!EnumOperationType.Arc.EnumType.END      , 0                                                    , &nothing,1, nullUint                   );
		
		/* +  6 */this.Arcs ~= errorArc;
		/* +  7 */this.Arcs ~= errorArc;
		/* +  8 */this.Arcs ~= errorArc;
		/* +  9 */this.Arcs ~= errorArc;

		assert(this.Arcs.length == SYLOGISMSTART);

		// ARC for ([KEY SYM SYLOGISM $VAR]), brace open got already eaten
		/* + 0 */this.Arcs ~= new Arc(AbstractParser!EnumOperationType.Arc.EnumType.NIL, 0                , &beginBraceElement         , SYLOGISMSTART+1, nullUint);
		/* + 1 */this.Arcs ~= new Arc(AbstractParser!EnumOperationType.Arc.EnumType.ARC      , SYLOGISMWITHOUTBRACESTART                                        , &nothing, SYLOGISMSTART+2, nullUint);
		/* + 2 */this.Arcs ~= new Arc(AbstractParser!EnumOperationType.Arc.EnumType.OPERATION, cast(uint)EnumOperationType.BRACECLOSE               , &endBraceElement         , SYLOGISMSTART+3, nullUint);
		/* + 3 */this.Arcs ~= new Arc(AbstractParser!EnumOperationType.Arc.EnumType.END      , 0                                                    , &nothing,0, nullUint                   );

		this.Arcs ~= errorArc;

		this.Arcs ~= errorArc;
		this.Arcs ~= errorArc;
		this.Arcs ~= errorArc;
		this.Arcs ~= errorArc;
		this.Arcs ~= errorArc;

		// ARC for [KEY SYM SYLOGISM $VAR]
		// SYLOGISM can be <-> --> ==> and so on

		assert(this.Arcs.length == SYLOGISMWITHOUTBRACESTART);

		/* + 0 */this.Arcs ~= new Arc(AbstractParser!EnumOperationType.Arc.EnumType.TOKEN    , cast(uint)Token!EnumOperationType.EnumType.IDENTIFIER, &addTokenToBrace          , SYLOGISMWITHOUTBRACESTART+0, Nullable!uint(SYLOGISMWITHOUTBRACESTART+1));
		/* + 1 */this.Arcs ~= new Arc(AbstractParser!EnumOperationType.Arc.EnumType.OPERATION, cast(uint)EnumOperationType.KEY                      , &addTokenToBrace          , SYLOGISMWITHOUTBRACESTART+0, Nullable!uint(SYLOGISMWITHOUTBRACESTART+2));
		/* + 2 */this.Arcs ~= new Arc(AbstractParser!EnumOperationType.Arc.EnumType.OPERATION, cast(uint)EnumOperationType.INDEPENDENTVAR           , &pushIndependentVar            , SYLOGISMWITHOUTBRACESTART+0, Nullable!uint(SYLOGISMWITHOUTBRACESTART+3));
		/* + 3 */this.Arcs ~= new Arc(AbstractParser!EnumOperationType.Arc.EnumType.NIL, 0                , &nothing         , SYLOGISMWITHOUTBRACESTART+4, nullUint);
		/* + 4 */this.Arcs ~= new Arc(AbstractParser!EnumOperationType.Arc.EnumType.OPERATION, cast(uint)EnumOperationType.SIMILARITY               , &addTokenToBrace          , SYLOGISMWITHOUTBRACESTART+0, Nullable!uint(SYLOGISMWITHOUTBRACESTART+5));

		/* + 5 */this.Arcs ~= new Arc(AbstractParser!EnumOperationType.Arc.EnumType.OPERATION, cast(uint)EnumOperationType.INHERITANCE              , &addTokenToBrace          , SYLOGISMWITHOUTBRACESTART+0, Nullable!uint(SYLOGISMWITHOUTBRACESTART+6));
		/* + 6 */this.Arcs ~= new Arc(AbstractParser!EnumOperationType.Arc.EnumType.OPERATION, cast(uint)EnumOperationType.IMPLCIATION              , &addTokenToBrace          , SYLOGISMWITHOUTBRACESTART+0, Nullable!uint(SYLOGISMWITHOUTBRACESTART+7));
		/* + 7 */this.Arcs ~= new Arc(AbstractParser!EnumOperationType.Arc.EnumType.OPERATION, cast(uint)EnumOperationType.HALFH                    , &addTokenToBrace          , SYLOGISMWITHOUTBRACESTART+0, Nullable!uint(SYLOGISMWITHOUTBRACESTART+8));
		/* + 8 */this.Arcs ~= new Arc(AbstractParser!EnumOperationType.Arc.EnumType.OPERATION, cast(uint)EnumOperationType.KEY                      , &addTokenToBrace         , SYLOGISMWITHOUTBRACESTART+0, Nullable!uint(SYLOGISMWITHOUTBRACESTART+9));
		/* + 9 */this.Arcs ~= new Arc(AbstractParser!EnumOperationType.Arc.EnumType.OPERATION, cast(uint)EnumOperationType.CONJUNCTION              , &addTokenToBrace          , SYLOGISMWITHOUTBRACESTART+0, Nullable!uint(SYLOGISMWITHOUTBRACESTART+10));
		
		/* +10 */this.Arcs ~= new Arc(AbstractParser!EnumOperationType.Arc.EnumType.OPERATION, cast(uint)EnumOperationType.EQUIVALENCE              , &addTokenToBrace          , SYLOGISMWITHOUTBRACESTART+0, Nullable!uint(SYLOGISMWITHOUTBRACESTART+11));
		
		/* +11 */this.Arcs ~= new Arc(AbstractParser!EnumOperationType.Arc.EnumType.OPERATION, cast(uint)EnumOperationType.POUNDKEY             , &nothing       , SYLOGISMWITHOUTBRACESTART+12, Nullable!uint(SYLOGISMWITHOUTBRACESTART+13));
		/* +12 */this.Arcs ~= new Arc(AbstractParser!EnumOperationType.Arc.EnumType.TOKEN    , cast(uint)Token!EnumOperationType.EnumType.IDENTIFIER, &pushDependentVar          , SYLOGISMWITHOUTBRACESTART+0, nullUint);


		/* +13 */this.Arcs ~= new Arc(AbstractParser!EnumOperationType.Arc.EnumType.OPERATION, cast(uint)EnumOperationType.BRACEOPEN                , &nothing         , SYLOGISMWITHOUTBRACESTART+14, Nullable!uint(SYLOGISMWITHOUTBRACESTART+15));
		/* +14 */this.Arcs ~= new Arc(AbstractParser!EnumOperationType.Arc.EnumType.ARC      , SYLOGISMSTART                                        , &nothing, SYLOGISMWITHOUTBRACESTART+0, nullUint);

		/* +15 */this.Arcs ~= new Arc(AbstractParser!EnumOperationType.Arc.EnumType.END      , 0                                                    , &nothing,0, nullUint                   );
	}

	override protected void setupBeforeParsing() {
   	}

   	public static class Rule {
   		Element rootElement;

   		final @property Element[] elementsBeforeHalfH() {
   			return rootElement.braceContent[0..halfHIndex];
   		}

   		private final @property Element[] elementsAfterHalfH() {
   			return rootElement.braceContent[halfHIndex+1..$];
   		}

   		// finds out where half-h is and determines the root-element and index for the part after it
   		final void cache() {
   			// scan for half-h
   			import std.algorithm.searching : find;
   			auto findHaystack = find!(a => !a.isBrace && a.tokenWithDecoration.token.isOperation(EnumOperationType.HALFH))(rootElement.braceContent);
   			assert(findHaystack.length != 0, "half-h wasn't found!");
   			halfHIndex = rootElement.braceContent.length-findHaystack.length;
   		}

   		private size_t halfHIndex;
   	}

   	// helper for parser actions
   	protected final @property Rule lastRule() {
   		return rules[$-1];
   	}

   	public Rule[] rules;
}


struct FlagsOfCopula {
	bool nal1or2; // --> <->
	bool nal5; // ==> <=>

	bool arrowLeft, arrowRight;

	bool isConjection;

	static FlagsOfCopula makeInheritance() {
		FlagsOfCopula result;
		with(result) {
			nal1or2 = true;
			arrowRight = true;
		}
		return result;
	}

	static FlagsOfCopula makeSimilarity() {
		FlagsOfCopula result;
		with(result) {
			nal1or2 = true;
			arrowLeft = arrowRight = true;
		}

		return result;
	}

	static FlagsOfCopula makeImplication() {
		FlagsOfCopula result;
		with(result) {
			nal5 = true;
			arrowRight = true;
		}
		return result;
	}

	static FlagsOfCopula makeEquivalence() {
		FlagsOfCopula result;
		with(result) {
			nal5 = true;
			arrowLeft = arrowRight = true;
		}
		return result;
	}

	static FlagsOfCopula makeConjuction() {
		FlagsOfCopula result;
		result.isConjection = true;
		return result;
	}
}

struct Postcondition {
	string truthfunction;
}

class RuleResultWithPostconditionAndTruth {
	Element resultTransformationElement;
	Postcondition postcondition;

	final this(Element resultTransformationElement, Postcondition postcondition) {
		this.resultTransformationElement = resultTransformationElement;
		this.postcondition = postcondition;
	}
}

enum EnumSource {
	ALEFT,
	ARIGHT,
	BLEFT,
	BRIGHT,
}

struct RuleDescriptor {
	Element[2] premiseElements;

	RuleResultWithPostconditionAndTruth[] ruleResultWithPostconditionAndTruth;

	Tuple!(EnumSource, EnumSource)[] toMatchPremiseTerms; // pairs of the sources which need to match that the rule fires 
};

import std.stdio;


private RuleDescriptor translateParserRuleToRuleDescriptor(Parser.Rule parserRule) {
	assert(parserRule.elementsBeforeHalfH.length == 2, "The count of premises must be two!");

	RuleDescriptor resultRuleDescriptor;

	// handles the root element as if it were an dictionary and returns the "value" of the "key"
	static Element innerFnHandleElementAsDictionaryAndGetValueByKey(const Element root, const string key) {
		assert(false, "TODO");
	}

	void innerFnFindCommonCompoundTerms() {
		Tuple!(string, EnumSource)[] leftMatching;
		leftMatching ~= Tuple!(string, EnumSource)(parserRule.elementsBeforeHalfH[0].leftIdentifier, EnumSource.ALEFT);
		leftMatching ~= Tuple!(string, EnumSource)(parserRule.elementsBeforeHalfH[0].rightIdentifier, EnumSource.ARIGHT);

		Tuple!(string, EnumSource)[] rightMatching;
		rightMatching ~= Tuple!(string, EnumSource)(parserRule.elementsBeforeHalfH[1].leftIdentifier, EnumSource.BLEFT);
		rightMatching ~= Tuple!(string, EnumSource)(parserRule.elementsBeforeHalfH[1].rightIdentifier, EnumSource.BRIGHT);

		foreach( iterationLeftMatching; leftMatching ) {
			foreach( iterationRightMatching; rightMatching ) {
				if( iterationLeftMatching[0] == iterationRightMatching[0] ) {
					resultRuleDescriptor.toMatchPremiseTerms ~= Tuple!(EnumSource, EnumSource)(iterationLeftMatching[1], iterationRightMatching[1]);				
				}
			}
		}
	}

	static RuleResultWithPostconditionAndTruth innerFnConvertElementsOfResultWithPostconditionAndTruthToDescriptor(Element[] elements) {
		assert(elements.length == 3);

		if( elements[1].tokenWithDecoration.token.contentString != ":post" ) {
			throw new Exception(":post expected at [1]!");
		}

		static Postcondition innerFnConvertPostconditionToDescriptor(Element element) {
			Postcondition resultPostcondition;
			resultPostcondition.truthfunction = element.braceContent[0].tokenWithDecoration.token.contentString;
			return resultPostcondition;
		}

		return new RuleResultWithPostconditionAndTruth(elements[0], innerFnConvertPostconditionToDescriptor(elements[2]));
	}

	innerFnFindCommonCompoundTerms();


	assert((parserRule.elementsAfterHalfH[0].braceContent.length % 3) == 0, "Number of Elements after half-h must be devisible by 3, because structure is <postCompound :post postConditions>");

	for( size_t childElementIndex = 0; childElementIndex < parserRule.elementsAfterHalfH[0].braceContent.length; childElementIndex += 3) {
		resultRuleDescriptor.ruleResultWithPostconditionAndTruth ~= innerFnConvertElementsOfResultWithPostconditionAndTruthToDescriptor(parserRule.elementsAfterHalfH[0].braceContent[childElementIndex..childElementIndex+3]);
	}



	resultRuleDescriptor.premiseElements = parserRule.elementsBeforeHalfH[0..2];

	return resultRuleDescriptor;
}

/+ uncommented 08.09.2016 because it needs an overhaul to account for the new clojure like parsing

private RuleDescriptor[] translateParserRulesToRuleDescriptors(Parser.Rule[] parserRules) {
	string getTruthFunction(Parser.DictionaryElement dictionaryElement) {
		foreach( iterationContent; dictionaryElement.content ) {
			if( !iterationContent.convertsTo!string() ) {
				continue;
			}

			string iterationKey = iterationContent.get!string();


			writeln(iterationKey[0..3]);
			if( iterationKey[0..3] == ":t/" ) {
				return iterationKey;
			}
		}

		// TODO< throw something >
		return "";
	}




	RuleDescriptor[] translatedRules;

	foreach( iterationParserRule; parserRules ) {
		writeln(iterationParserRule.attributeDictionary.keys);

		writeln(iterationParserRule.elementsBefore.length, " ", iterationParserRule.elementsAfter.length);

		string cppTruthFunctionEnum = translateTruthFunctionToCppEnum(getTruthFunction(iterationParserRule.attributeDictionary[":post"]));

		EnumSource sourceLeft = findSource(iterationParserRule, iterationParserRule.elementsAfter[0].leftIdentifier);
		EnumSource sourceRight = findSource(iterationParserRule, iterationParserRule.elementsAfter[0].rightIdentifier);

		FlagsOfCopula flagsOfSourceCopula[2];
		flagsOfSourceCopula[0] = translateOperationToCopola(iterationParserRule.elementsBefore[0].operation);
		flagsOfSourceCopula[1] = translateOperationToCopola(iterationParserRule.elementsBefore[1].operation);
		FlagsOfCopula flagsOfTargetCopula = translateOperationToCopola(iterationParserRule.elementsAfter[0].operation);

		RuleDescriptor ruleDescriptorToAdd = RuleDescriptor(sourceLeft, sourceRight, flagsOfSourceCopula, flagsOfTargetCopula, cppTruthFunctionEnum);

		// translate precondition
		if( ":pre" in iterationParserRule.attributeDictionary ) {
			Parser.DictionaryElement preDictionaryElement = iterationParserRule.attributeDictionary[":pre"];

			foreach( iterationDictContent; preDictionaryElement.content ) {
				if( iterationDictContent.convertsTo!(Parser.Element) && iterationDictContent.get!(Parser.Element).braceContent.length != 0 ) {
					Token!EnumOperationType firstToken = iterationDictContent.get!(Parser.Element).braceContent[0].tokenWithDecoration;

					bool isFirstTokenKey = iterationDictContent.get!(Parser.Element).braceContent[0].tokenWithDecoration.token.type == Token!EnumOperationType.EnumType.OPERATION && firstToken.contentOperation == EnumOperationType.KEY;
					bool isFirstTokenUnequal = firstToken.contentString == ":!=";
					if( isFirstTokenKey && isFirstTokenUnequal ) {

						assert(iterationDictContent.get!(Parser.Element).braceContent.length == 3);
						assert(iterationDictContent.get!(Parser.Element).braceContent[1].tokenWithDecoration.token.type == Token!EnumOperationType.EnumType.IDENTIFIER);
						assert(iterationDictContent.get!(Parser.Element).braceContent[2].tokenWithDecoration.token.type == Token!EnumOperationType.EnumType.IDENTIFIER);

						string preConditionUnequalVariablennames[2];
						preConditionUnequalVariablennames[0] = iterationDictContent.get!(Parser.Element).braceContent[1].tokenWithDecoration.token.contentString;
						preConditionUnequalVariablennames[1] = iterationDictContent.get!(Parser.Element).braceContent[2].tokenWithDecoration.token.contentString;

						EnumSource[2] sources;
						sources[0] = findSource(iterationParserRule, preConditionUnequalVariablennames[0]);
						sources[1] = findSource(iterationParserRule, preConditionUnequalVariablennames[1]);
						ruleDescriptorToAdd.preconditionUnequal = sources;

						break;
					}
				}
			}
		}

		// find common left side term thingies

		Tuple!(string, EnumSource)[] leftMatching;
		leftMatching ~= Tuple!(string, EnumSource)(iterationParserRule.elementsBefore[0].leftIdentifier, EnumSource.ALEFT);
		leftMatching ~= Tuple!(string, EnumSource)(iterationParserRule.elementsBefore[0].rightIdentifier, EnumSource.ARIGHT);

		Tuple!(string, EnumSource)[] rightMatching;
		rightMatching ~= Tuple!(string, EnumSource)(iterationParserRule.elementsBefore[1].leftIdentifier, EnumSource.BLEFT);
		rightMatching ~= Tuple!(string, EnumSource)(iterationParserRule.elementsBefore[1].rightIdentifier, EnumSource.BRIGHT);

		foreach( iterationLeftMatching; leftMatching ) {
			foreach( iterationRightMatching; rightMatching ) {
				if( iterationLeftMatching[0] == iterationRightMatching[0] ) {
					ruleDescriptorToAdd.toMatchPremiseTerms ~= Tuple!(EnumSource, EnumSource)(iterationLeftMatching[1], iterationRightMatching[1]);				
				}
			}
		}

		translatedRules ~= ruleDescriptorToAdd;
	}

	return translatedRules;



}
+/




void main() {
	//

	string nal = """
		;;Equivalence and Implication Rules
          ;Similarity to Inheritance
          #R[(S --> P) (S <-> P) |- (S --> P) :post (:t/struct-int :p/belief) :pre (:question?)]
          ;Inheritance to Similarity
          #R[(S <-> P) (S --> P) |- (S <-> P) :post (:t/struct-abd :p/belief) :pre (:question?)]


          #R[(P --> S) (S --> P) |- (P --> S) :post (:t/conversion :p/belief) :pre (:question?)]


          ;;Inheritance-Related Syllogisms
         ; If A is a special case of B and B is a special case of C so is A a special case of C (strong) the other variations are hypotheses (weak)
         #R[(A --> B) (B --> C) |- (A --> C) :pre ((:!= A C)) :post (:t/deduction :d/strong :allow-backward)]
         #R[(A --> B) (A --> C) |- (C --> B) :pre ((:!= B C)) :post (:t/abduction :d/weak :allow-backward)]
         #R[(A --> C) (B --> C) |- (B --> A) :pre ((:!= A B)) :post (:t/induction :d/weak :allow-backward)]
         #R[(A --> B) (B --> C) |- (C --> A) :pre ((:!= C A)) :post (:t/exemplification :d/weak :allow-backward)]

         ; similarity from inheritance
         ; If S is a special case of P and P is a special case of S then S and P are similar
         #R[(S --> P) (P --> S) |- (S <-> P) :post (:t/intersection :d/strong :allow-backward)]

         ; inheritance from similarty <- TODO check why this one was missing
         #R[(S <-> P) (P --> S) |- (S --> P) :post (:t/reduce-conjunction :d/strong :allow-backward)]

         ; similarity-based syllogism
         ; If P and S are a special case of M then they might be similar (weak)
         ; also if P and S are a general case of M
         #R[(P --> M) (S --> M) |- (S <-> P) :post (:t/comparison :d/weak :allow-backward) :pre ((:!= S P))]
         #R[(M --> P) (M --> S) |- (S <-> P) :post (:t/comparison :d/weak :allow-backward) :pre ((:!= S P))]

         ; If M is a special case of P and S and M are similar then S is also a special case of P (strong)
         #R[(M --> P) (S <-> M) |- (S --> P) :pre ((:!= S P)) :post (:t/analogy :d/strong :allow-backward)]
         #R[(P --> M) (S <-> M) |- (P --> S) :pre ((:!= S P)) :post (:t/analogy :d/strong :allow-backward)]
         #R[(M <-> P) (S <-> M) |- (S <-> P) :pre ((:!= S P)) :post (:t/resemblance :d/strong :allow-backward)]
	""";

	RuleLexer lexer = new RuleLexer();
	Parser parser = new Parser();

	// testing area
	/*
	{
	lexer.setSource(
	"""
	""");
	}
	//*/




	//lexer.setSource("""
//#R[(A --> B) (B --> C) |- (A --> C) :pre ((:!= A C)) :post (:t/deduction :d/strong :allow-backward)]""");

	/* uncommented 06.09.2016, worked, just want to experiment with variables below
lexer.setSource(
"""
#R[(M --> P) (M --> S) |- (S <-> P) :post (:t/comparison :d/weak :allow-backward) :pre ((:!= S P))]
#R[(M --> P) (S <-> M) |- (S --> P) :pre ((:!= S P)) :post (:t/analogy :d/strong :allow-backward)]""");
	//*/

	/*
	lexer.setSource(
	"""
	 #R[(S --> M) (P --> M) |- ((P --> $X) ==> (S --> $X)) :post (:t/abduction)
                               ]
	""");
	//*/
	
	//*
	lexer.setSource(
	"""
	 #R[(S --> M) (P --> M) |- (((P --> $X) ==> (S --> $X)) :post (:t/abduction)
                                      ((S --> $X) ==> (P --> $X)) :post (:t/induction)
                                      ((P --> $X) <=> (S --> $X)) :post (:t/comparison)
                                      (&& (S --> #Y) (P --> #Y)) :post (:t/intersection))
                                          :pre (:belief? (:!= S P))]
	""");
	//*/


	parser.setLexer(lexer);
   	
   	string errorMessage;
    bool parsingSuccess = parser.parse(errorMessage);

	if( !parsingSuccess ) {
		errorMessage = "Parsing Failed: " ~ errorMessage;
		import std.stdio;
		writeln(errorMessage);

		return;
	}

	// cache all rules
	foreach( iterationRule; parser.rules ) {
		iterationRule.cache();
	}

	parser.rules[0].rootElement.debugIt(0);


	RuleDescriptor ruleDescriptor = translateParserRuleToRuleDescriptor(parser.rules[0]);

	writeln(generateDCodeForDeriver(ruleDescriptor));

	//RuleDescriptor[] ruleDescriptors = translateParserRulesToRuleDescriptors(parser.rules);
	//writeln(generateCodeCppForDeriver(ruleDescriptors));
}



enum EnumCopulaForm {
	PREFIX, // example : (&& A B)
	NONPRFIX, // example : (A --> B)
}

// generates the target code (currently C++) for the "deriver"(which currently just does some pretty basic things)

class CodegenDelegates {
	

	string function() signatureOpen;
	string function() signatureClose;

	string function(FlagsOfCopula flags) convertFlagsOfCopulaToFlags;
	string function(EnumSource source) getPremiseVariableForSource;
	string function(string truthfunction) truthFunctionCode; // gets the raw truthfunction key as in the clojure like DSL, has to return an Enum value in the target language

	string function(string variableName) independentVariableCreation; // has to generate the code for the generation of the variable with the specific name
	string function(string variableName) dependentVariableCreation;

	// generates code for the creation of a temporary compound which is returned from the deriver
	// the arguments are already generated code
	// copulaCode is generated code, too
	string function(EnumCopulaForm copulaForm, string copulaCode, string[] arguments) temporaryCompoundCreation;

	// has to generate the code for the matching of the premise of the derivation
	string function(Tuple!(EnumSource, EnumSource)[] toMatchPremiseTerms) codeForPremisePatternMatching;
}

class CodegenStringTemplates {
	string templateEntry, templateLeave;

	string templateCheckEntry, templateCheckLeave;
}

string generateDCodeForDeriver(RuleDescriptor ruleDescriptor) {
	static string signatureOpen() {
		return "UnifiedTerm[] derive(ReasonerInstance reasonerInstance, UnifiedTermIndex[] leftPathTermIndices, UnifiedTermIndex[] rightPathTermIndices, float k) {";
	}

	static string signatureClose() {
		return "}";
	}

	static string convertFlagsOfCopulaToFlags(FlagsOfCopula flags) {
		string result;

		if( flags.nal1or2 ) {
			result ~= "cast(TermFlagsType)EnumTermFlags.NAL1OR2 |";
		}
		if( flags.nal5 ) {
			result ~= "cast(TermFlagsType)EnumTermFlags.NAL5 |";
		}
		if( flags.arrowLeft ) {
			result ~= "cast(TermFlagsType)EnumTermFlags.ARROWLEFT |";
		}
		if( flags.arrowRight ) {
			result ~= "cast(TermFlagsType)EnumTermFlags.ARROWRIGHT |";
		}
		if( flags.isConjection ) {
			result ~= "cast(TermFlagsType)EnumTermFlags.CONJUNCTION |";
		}

		result = result[0..$-1];
		return result;
	}

	static string getPremiseVariableForSource(EnumSource source) {
		final switch(source) {
			case EnumSource.ALEFT: return "premiseLeft.left";
			case EnumSource.ARIGHT: return "premiseLeft.right";
			case EnumSource.BLEFT: return "premiseRight.left";
			case EnumSource.BRIGHT: return "premiseRight.right";
		}
	}

	static string truthFunctionCode(string truthFunction) {
		static string translateTruthFunctionToCppEnum(string truthFunction) {
			assert(truthFunction[0..3] == ":t/");
			string untranslated = truthFunction[3..$];

			import std.array : replace;
			import std.uni : toUpper;
			return untranslated.replace("-", "").toUpper;
		}

		return translateTruthFunctionToCppEnum(truthFunction);
	}

	static string independentVariableCreation(string variableName) {
		// TODO< map somehow the variables to integers and create temporary objects which describe them >
		return "TODO<independent variable creation>";
	}

	static string dependentVariableCreation(string variableName) {
		// TODO< map somehow the variables to integers and create temporary objects which describe them >
		return "TODO<dependent variable creation>";
	}

	static string temporaryCompoundCreation(EnumCopulaForm copulaForm, string copulaCode, string[] arguments) {
		assert(arguments.length == 2, "just implemented for binary compounds!");

		// NOTE< we ignore prefix and postfix form for now for the generated code >
		const string
			leftSideAsString = arguments[0],
			rightSideAsString = arguments[1];
		return "genBinary(%s, %s, %s)".format(copulaCode, leftSideAsString, rightSideAsString);
	}

	static string codeForPremisePatternMatching(Tuple!(EnumSource, EnumSource)[] toMatchPremiseTerms) {
		string nestedCodeForSourcePattern = "true";
		foreach( iterationToMatchInputTerm; toMatchPremiseTerms ) {
			nestedCodeForSourcePattern ~= format("&& (%s == %s)", getPremiseVariableForSource(iterationToMatchInputTerm[0]) ~ ".value", getPremiseVariableForSource(iterationToMatchInputTerm[1]) ~ ".value");
		}

		return nestedCodeForSourcePattern;
	}


	

	CodegenDelegates delegates = new CodegenDelegates;
	delegates.signatureOpen = &signatureOpen;
	delegates.signatureClose = &signatureClose;
	delegates.convertFlagsOfCopulaToFlags = &convertFlagsOfCopulaToFlags;
	delegates.getPremiseVariableForSource = &getPremiseVariableForSource;
	delegates.truthFunctionCode = &truthFunctionCode;
	delegates.independentVariableCreation = &independentVariableCreation;
	delegates.dependentVariableCreation = &dependentVariableCreation;
	delegates.temporaryCompoundCreation = &temporaryCompoundCreation;
	delegates.codeForPremisePatternMatching = &codeForPremisePatternMatching;

	CodegenStringTemplates stringTemplates = new CodegenStringTemplates;
	stringTemplates.templateEntry = """
			TemporaryUnifiedTerm[] resultTerms;

			UnifiedTermIndex premiseLeftIndex = leftPathTermIndices[$]; // AUTOGEN< need it to check for the flags of the left concept >
			UnifiedTerm premiseLeft = reasonerInstance.accessTermByIndex(premiseLeftIndex);

			UnifiedTermIndex premiseRightIndex = rightPathTermIndices[$]; // AUTOGEN< need it to check for the flags of the right concept >
			UnifiedTerm premiseRight = reasonerInstance.accessTermByIndex(premiseRightIndex);

			alias typeof(previousLeft.termFlags) TermFlagsType;
	""";

	stringTemplates.templateLeave = """return resultTerms;""";

	stringTemplates.templateCheckEntry = """
		if( 
			// AUTOGEN< check flags for match >
			(previousLeft.termFlags == (static_cast<decltype(previousLeft.termFlags)>(%s)) && previousRight.termFlags == (static_cast<decltype(previousLeft.termFlags)>(%s)))

			// AUTOGEN< check for source pattern >
			&& (%s)

			// AUTOGEN check eventually for the unequal precondition
			%s
		) {
	""";
	

	stringTemplates.templateCheckLeave = "}\n else \n";


	return generateCodeForDeriver(delegates, stringTemplates, ruleDescriptor);
}


bool isBinaryNonprefixCopula(EnumOperationType operationType) {
	/* nonfinal */ switch(operationType) with (EnumOperationType) {
		case SIMILARITY: // <->
		case INHERITANCE: // -->
		case IMPLCIATION: // ==>
		case EQUIVALENCE: // <=>
		return true;
		default:
		return false;
	}
}

bool isBinaryPrefixCopula(EnumOperationType operationType) {
	/* nonfinal */ switch(operationType) with (EnumOperationType) {
		case CONJUNCTION:
		return true;
		default:
		return false;
	}
}

alias Element Compound;

bool isCopula(Compound compound) {
	if( compound.isBrace ) {
		return false;
	}

	if( compound.tokenWithDecoration.isVariable ) {
		return false;
	}

	Token!EnumOperationType token = compound.tokenWithDecoration.token;

	if( token.type != Token!EnumOperationType.EnumType.OPERATION ) {
		return false;
	}

	return token.contentOperation.isBinaryNonprefixCopula || token.contentOperation.isBinaryPrefixCopula;
}

// helper to decide if a Element is a binary compound
bool isBinaryCompound(Compound compound) {
	return compound.braceContent.length == 3 && compound.braceContent[1].isCopula;
}

import std.format : format;

string generateCodeForDeriver(CodegenDelegates delegates, CodegenStringTemplates stringTemplates, RuleDescriptor ruleDescriptor) {
	string generated;

	generated ~= delegates.signatureOpen() ~ "\n";
	generated ~= stringTemplates.templateEntry;

	static FlagsOfCopula convertCopulaElementToFlagsOfCopula(Element copulaElement) {
		assert(copulaElement.isCopula);
		
		Token!EnumOperationType token = copulaElement.tokenWithDecoration.token;
		/* nonfinal */ switch(token.contentOperation) with (EnumOperationType) {
			case SIMILARITY: return FlagsOfCopula.makeSimilarity();
			case INHERITANCE: return FlagsOfCopula.makeInheritance();
			case IMPLCIATION: return FlagsOfCopula.makeImplication();
			case EQUIVALENCE: return FlagsOfCopula.makeEquivalence();
			case CONJUNCTION: return FlagsOfCopula.makeConjuction();
			default: throw new Exception("Internal error"); // or not implemented
		}
	}

	EnumSource getSourceOfPremiseVariableByName(string premiseVariableName) {
		bool doesPremiseVariableApearInLeafElementRecursivly(Element element) {
			return element.tokenWithDecoration.token.contentString == premiseVariableName;
		}

		bool doesPremiseVariableApearInCompoundRecursivly(Compound compound) {
			if( compound.isBrace ) {
				assert(compound.isBinaryCompound); // just binary compounds are for now implemented

				return doesPremiseVariableApearInCompoundRecursivly(compound.leftChild) || doesPremiseVariableApearInCompoundRecursivly(compound.rightChild);
			}
			else if( compound.isTokenWithDecoration ) {
				return doesPremiseVariableApearInLeafElementRecursivly(compound);
			}
			else {
				throw new Exception("Internal error"); // may be because its not implemented
			}
		}

		// an enum to inform getSourceOfPremiseVariableByNameForCompound() about on which side it "looks"
		enum EnumPremiseSide {
			LEFT,
			RIGHT,
		}

		EnumSource getSourceOfPremiseVariableByNameForCompound(Compound compound, EnumPremiseSide premiseSide) {
			assert(doesPremiseVariableApearInCompoundRecursivly(compound));

			assert(compound.isBinaryCompound); // just binary compounds are for now implemented

			assert(!compound.leftChild.tokenWithDecoration.isVariable);
			assert(!compound.rightChild.tokenWithDecoration.isVariable);

			if( compound.leftChild.tokenWithDecoration.token.contentString == premiseVariableName ) {
				final switch(premiseSide) with(EnumPremiseSide) {
					case LEFT: return EnumSource.ALEFT;
					case RIGHT: return EnumSource.ARIGHT;
				}
			}
			else if( compound.rightChild.tokenWithDecoration.token.contentString == premiseVariableName ) {
				final switch(premiseSide) with(EnumPremiseSide) {
					case LEFT: return EnumSource.BLEFT;
					case RIGHT: return EnumSource.BRIGHT;
				}
			}
			else {
				throw new Exception("Internal error, premiseVariable wasn't found, but its guranteed to be found, should never happen!");
			}
		}

		if( doesPremiseVariableApearInCompoundRecursivly(ruleDescriptor.premiseElements[0]) ) {
			return getSourceOfPremiseVariableByNameForCompound(ruleDescriptor.premiseElements[0], EnumPremiseSide.LEFT);
		}
		else if( doesPremiseVariableApearInCompoundRecursivly(ruleDescriptor.premiseElements[1]) ) {
			return getSourceOfPremiseVariableByNameForCompound(ruleDescriptor.premiseElements[1], EnumPremiseSide.RIGHT);
		}
		else {
			throw new Exception("premiseVariableName \"" ~ premiseVariableName ~ "\" wasn't found in left or right premisses!");
		}
	}

	// returns the to generated code for the token
	// used in the recursive codgen code for the creation of the temporary objects describing the creation of the comounds/terms
	string nestedFnGetCodeOfToken(TokenWithDecoration tokenWithDecoration) {
		Token!EnumOperationType token = tokenWithDecoration.token;

		if( tokenWithDecoration.isIndependentVariable ) {
			return delegates.independentVariableCreation(token.contentString);
		}
		else if( tokenWithDecoration.isDependentVariable ) {
			return delegates.dependentVariableCreation(token.contentString);
		}
		else {
			EnumSource sourceOfPremiseVariable = getSourceOfPremiseVariableByName(token.contentString);
			return delegates.getPremiseVariableForSource(sourceOfPremiseVariable);
		}
	}


	string delegate(Element element) nestedFnGetCodeOfCompoundCreationRecursivly;

	string nestedFnGetCodeOfBinaryCompoundCreationRecursivly(EnumCopulaForm copulaForm, Element copulaElement, Element leftSideElement, Element rightSideElement) {
		string copulaAsString = delegates.convertFlagsOfCopulaToFlags(convertCopulaElementToFlagsOfCopula(copulaElement));

		string leftSideAsString, rightSideAsString;

		// check if it are compounds and recursivly call nestedFnGetStringOfCompundCreationRecursivly if its the case
		// else we check if it is an premise variable, if it is the case we generate the code for accessing it

		if( leftSideElement.isTokenWithDecoration ) {
			leftSideAsString = nestedFnGetCodeOfToken(leftSideElement.tokenWithDecoration);
		}
		else if( leftSideElement.isBrace ) {
			leftSideAsString = nestedFnGetCodeOfCompoundCreationRecursivly(leftSideElement);
		}
		else {
			throw new Exception("Internal Error");
		}

		if( rightSideElement.isTokenWithDecoration ) {
			rightSideAsString = nestedFnGetCodeOfToken(rightSideElement.tokenWithDecoration);
		}
		else if( rightSideElement.isBrace ) {
			rightSideAsString = nestedFnGetCodeOfCompoundCreationRecursivly(rightSideElement);
		}
		else {
			throw new Exception("Internal Error");
		}

		return delegates.temporaryCompoundCreation(copulaForm, copulaAsString, [leftSideAsString, rightSideAsString]);
	}

	// returns the string for the codegen.
	// The generated code builds an TemporaryUnifiedTerm with the structure in the target, the terms which apear in the premise get referenced by the coresponding variables.
	nestedFnGetCodeOfCompoundCreationRecursivly = (Element element){
		EnumCopulaForm nestedFnGetCopulaForm() {
			if( element.braceContent[0].isCopula ) {
				return EnumCopulaForm.PREFIX;
			}
			else if( element.braceContent[1].isCopula ) {
				return EnumCopulaForm.NONPRFIX;
			}
			else {
				throw new Exception("Internal Error - unknown compound form");
			}
		}

		if( element.braceContent.length == 3 ) {
			final switch(nestedFnGetCopulaForm()) with(EnumCopulaForm) {
				case NONPRFIX: return nestedFnGetCodeOfBinaryCompoundCreationRecursivly(nestedFnGetCopulaForm(), element.braceContent[1], element.braceContent[0], element.braceContent[2]);
				case PREFIX: return nestedFnGetCodeOfBinaryCompoundCreationRecursivly(nestedFnGetCopulaForm(), element.braceContent[0], element.braceContent[1], element.braceContent[2]);
			}
		}
		else {
			throw new Exception("Nonbinary compounds are not implemented!");
		}
	};

	string nestedFnGetStringOfTermForResult(RuleResultWithPostconditionAndTruth rule) {
		string createdCompoundCode = nestedFnGetCodeOfCompoundCreationRecursivly(rule.resultTransformationElement);

		// TODO< put the string into the templates >
		return "genTerm(%s, %s)".format(createdCompoundCode, delegates.truthFunctionCode(rule.postcondition.truthfunction));
	}


	string nestedCodeForUnequalCheck = "TODO";

	generated ~= stringTemplates.templateCheckEntry.format( 
		"TODO", //convertFlagsOfCopulaToFlags(ruleDescriptor.flagsOfSourceCopula[0]),
		"TODO", //convertFlagsOfCopulaToFlags(ruleDescriptor.flagsOfSourceCopula[1]),
		delegates.codeForPremisePatternMatching(ruleDescriptor.toMatchPremiseTerms),
		nestedCodeForUnequalCheck
	);


	foreach( iterationRuleResultWithPostconditionAndTruth; ruleDescriptor.ruleResultWithPostconditionAndTruth ) {
		// TODO< put the string into the templates >
		generated ~= "resultTerms ~= %s".format(nestedFnGetStringOfTermForResult(iterationRuleResultWithPostconditionAndTruth)) ~ ";\n";
	}

	generated ~= stringTemplates.templateCheckLeave;
	

	generated ~= stringTemplates.templateLeave;
	generated ~= delegates.signatureClose() ~ "\n";

	return generated;
}

/+ uncommented 09.09.2016 because overhaul and a language independent interface(now for D) is needed
string generateCodeCppForDeriver(RuleDescriptor[] ruleDescriptors) {
	// the signature of the generate function is
	const string signature = "vector<UnifiedTerm> derive(ReasonerInstance &reasonerInstance, vector<UnifiedTermIndex> &leftPathTermIndices, vector<UnifiedTermIndex> &rightPathTermIndices, float k)";


	string generateCodeForRuleDescriptor(RuleDescriptor ruleDescriptor) {

		

		string templateCheckEntry = """
			if( 
				// AUTOGEN< check flags for match >
				(previousLeft.termFlags == (static_cast<decltype(previousLeft.termFlags)>(%s)) && previousRight.termFlags == (static_cast<decltype(previousLeft.termFlags)>(%s)))

				// AUTOGEN< check for source pattern >
				&& (%s)

				// AUTOGEN check eventually for the unequal precondition
				%s
			) {
		""";
		

		string templateCheckLeave = "}\n else \n";

		string templateRuletableGeneralizedBinary = """
				Ruletable::GeneralizedBinaryRule rule;
				rule.sourceLeft = Ruletable::%s;
				rule.sourceRight = Ruletable::%s;
				rule.termFlags = static_cast<decltype(rule.termFlags)>(%s);
				rule.truthFunction = Ruletable::EnumTruthFunction::%s;

				UnifiedTerm resultTerm = Ruletable::ruletableGeneralizedBinary(previousLeft, previousRight, k, rule);
				resultTerms.push_back(resultTerm);
		""";


		string emittedCode;

		import std.format : format;

		string nestedCodeForUnequalCheck;
		// if there is a unequal precondition we have to generate code for it which will be emitted
		if( !ruleDescriptor.preconditionUnequal.isNull ) {
			
			string unequalTestLeftVariableCode = getVariableForSource(ruleDescriptor.preconditionUnequal.get()[0]) ~ ".value";
			string unequalTestRightVariableCode = getVariableForSource(ruleDescriptor.preconditionUnequal.get()[1]) ~ ".value";

			nestedCodeForUnequalCheck = format("&& (%s != %s)", unequalTestLeftVariableCode, unequalTestRightVariableCode);
		}


		string getNestedCodeForSourcePattern() {
			string nestedCodeForSourcePattern = "true";
			foreach( iterationToMatchInputTerm; ruleDescriptor.toMatchPremiseTerms ) {
				nestedCodeForSourcePattern ~= format("&& (%s == %s)", getVariableForSource(iterationToMatchInputTerm[0]) ~ ".value", getVariableForSource(iterationToMatchInputTerm[1]) ~ ".value");
			}

			return nestedCodeForSourcePattern;
		}


		emittedCode ~= format(templateCheckEntry, 
			convertFlagsOfCopulaToFlags(ruleDescriptor.flagsOfSourceCopula[0]),
			convertFlagsOfCopulaToFlags(ruleDescriptor.flagsOfSourceCopula[1]),
			getNestedCodeForSourcePattern(),
			nestedCodeForUnequalCheck
		);




		// TODO< implement case where the generalized binary can't be used >
		emittedCode ~= format(templateRuletableGeneralizedBinary,
			convertSourceToCpp(ruleDescriptor.sourceLeft),
			convertSourceToCpp(ruleDescriptor.sourceRight),
			convertFlagsOfCopulaToFlags(ruleDescriptor.flagsOfTargetCopula),
			ruleDescriptor.rule
		);

		emittedCode ~= templateCheckLeave;

		

		return emittedCode;
	}


	string generated;

	generated ~= signature ~ " {\n";
	generated ~= templateEntry;

	foreach( iterationRuleDescriptor; ruleDescriptors) {
		generated ~= generateCodeForRuleDescriptor(iterationRuleDescriptor);
	}

	generated ~= ";\n"; // finish the else from the last templateCheckLeave


	generated ~= templateLeave;
	generated ~= "}\n";

	return generated;
}
+/

// TODO< translate precondition >

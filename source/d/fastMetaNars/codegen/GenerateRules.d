module fastMetaNars.codegen.GenerateRules;

import std.typecons : Nullable, Tuple;

import fastMetaNars.lang.Parser : AbstractParser = Parser;
import fastMetaNars.lang.Token : Token;
import fastMetaNars.lang.Lexer : Lexer;

bool isOperation(const Token!EnumOperationType token, const EnumOperationType checkOperationType) {
	return token.type == Token!EnumOperationType.EnumType.OPERATION && token.contentOperation == checkOperationType;
}

string getString(const Token!EnumOperationType token) {
	return token.contentString;
}

import misced.memory.ArrayStack;

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

import fastMetaNars.FlagsOfCopula;


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

// walks the paths of the childrens and returns this element
Element walk(Element entry, size_t[] childrenIndices) {
	if( childrenIndices.length == 0 ) {
		return entry;
	}
	else {
		return walk(entry.braceContent[childrenIndices[0]], childrenIndices[1..$]);
	}
}

struct RuleDescriptor {
	Element[2] premiseElements;

	final @property Element leftPremiseElement() {
		return premiseElements[0];
	}

	final @property Element rightPremiseElement() {
		return premiseElements[1];
	}

	bool preconditionIsQuestion;
	Nullable!(Tuple!(EnumSource, EnumSource)) preconditionUnequality;


	RuleResultWithPostconditionAndTruth[] ruleResultWithPostconditionAndTruth;

	Tuple!(EnumSource, EnumSource)[] toMatchPremiseTerms; // pairs of the sources which need to match that the rule fires 
};

import std.stdio;

// helper function which checks for a certain name
private bool existsName(Element[] elements, string label) {
	foreach( iElement; elements ) {
		if( !iElement.isTokenWithDecoration ) {
			continue;
		}

		if( elements[1].tokenWithDecoration.token.contentString == label ) {
			return true;
		}
	}
	
	return false;
}

import std.exception : enforce;

private RuleDescriptor translateParserRuleToRuleDescriptor(Parser.Rule parserRule) {
	assert(parserRule.elementsBeforeHalfH.length == 2, "The count of premises must be two!");

	RuleDescriptor resultRuleDescriptor;

	// handles the root element as if it were an dictionary and returns the "value" of the "key"
	static Element innerFnHandleElementAsDictionaryAndGetValueByKey(const Element root, const string key) {
		assert(false, "TODO");
	}

	Tuple!(string, EnumSource)[] matching;
	matching ~= Tuple!(string, EnumSource)(parserRule.elementsBeforeHalfH[0].leftIdentifier, EnumSource.ALEFT);
	matching ~= Tuple!(string, EnumSource)(parserRule.elementsBeforeHalfH[0].rightIdentifier, EnumSource.ARIGHT);
	matching ~= Tuple!(string, EnumSource)(parserRule.elementsBeforeHalfH[1].leftIdentifier, EnumSource.BLEFT);
	matching ~= Tuple!(string, EnumSource)(parserRule.elementsBeforeHalfH[1].rightIdentifier, EnumSource.BRIGHT);

	EnumSource innerFnGetSourceAdressByName(string name) {
		foreach( iMatching; matching ) {
			if( iMatching[0] == name ) {
				return iMatching[1];
			}
		}

		throw new Exception("Couldn't find name " ~ name);
	}

	void innerFnFindCommonCompoundTerms() {
		Tuple!(string, EnumSource)[] leftMatching = matching[0..2];
		Tuple!(string, EnumSource)[] rightMatching = matching[2..4];

		assert(leftMatching.length == 2);
		assert(rightMatching.length == 2);

		
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

		writeln(elements[1].tokenWithDecoration.token.contentString);

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

	import std.stdio;

	Element preElement;

	// find ":pre" and store the preElement
	foreach( i; 0..parserRule.elementsAfterHalfH.length-1 ) {
		if( !parserRule.elementsAfterHalfH[i].isTokenWithDecoration ) {
			continue;
		}

		if( parserRule.elementsAfterHalfH[i].tokenWithDecoration.token.contentString == ":pre" ) {
			preElement = parserRule.elementsAfterHalfH[i+1];
			break;
		}
	}

	if( parserRule.elementsAfterHalfH.existsName(":post") ) { // handling of one post expression, not inside an brace
		// we assume that post is at index 1
		resultRuleDescriptor.ruleResultWithPostconditionAndTruth ~= innerFnConvertElementsOfResultWithPostconditionAndTruthToDescriptor(parserRule.elementsAfterHalfH[0..0+3]);
	}
	else { // handling of multiple post expressions, inside an brace
		assert((parserRule.elementsAfterHalfH[0].braceContent.length % 3) == 0, "Number of Elements after half-h must be devisible by 3, because structure is <postCompound :post postConditions>");

		for( size_t childElementIndex = 0; childElementIndex < parserRule.elementsAfterHalfH[0].braceContent.length; childElementIndex += 3) {
			resultRuleDescriptor.ruleResultWithPostconditionAndTruth ~= innerFnConvertElementsOfResultWithPostconditionAndTruthToDescriptor(parserRule.elementsAfterHalfH[0].braceContent[childElementIndex..childElementIndex+3]);
		}

	}

	if( preElement !is null ) {
		enforce(preElement.isBrace);

		foreach( iPreElement; preElement.braceContent ) {
			if( iPreElement.isTokenWithDecoration ) {
				if( iPreElement.tokenWithDecoration.token.contentString == ":question?" ) {
					resultRuleDescriptor.preconditionIsQuestion = true;
				}
			}
			else if( iPreElement.isBrace ) {
				Element conditionBrace = iPreElement;

				enforce(conditionBrace.braceContent.length == 3, "must have 3 elements");
				enforce(conditionBrace.braceContent[0].isTokenWithDecoration && conditionBrace.braceContent[0].tokenWithDecoration.token.contentString == ":!=", "precondition must be !=");

				string comparisionNames[2];
				comparisionNames[0] = conditionBrace.braceContent[1].tokenWithDecoration.token.contentString;
				comparisionNames[1] = conditionBrace.braceContent[2].tokenWithDecoration.token.contentString;
				resultRuleDescriptor.preconditionUnequality = Tuple!(EnumSource, EnumSource)(innerFnGetSourceAdressByName(comparisionNames[0]), innerFnGetSourceAdressByName(comparisionNames[1]));
			}
		}
	}


	resultRuleDescriptor.premiseElements = parserRule.elementsBeforeHalfH[0..2];

	return resultRuleDescriptor;
}

import std.algorithm.searching : find;
import std.string : split, join;
import std.algorithm.iteration : map;
import std.array : array;

void main() {
	//

	string nal = """
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
	
	/* commented 11.02.2017 
	lexer.setSource(
	"""
	 #R[(S --> M) (P --> M) |- (((P --> $X) ==> (S --> $X)) :post (:t/abduction)
                                      ((S --> $X) ==> (P --> $X)) :post (:t/induction)
                                      ((P --> $X) <=> (S --> $X)) :post (:t/comparison)
                                      (&& (S --> #Y) (P --> #Y)) :post (:t/intersection))
                                          :pre (:belief? (:!= S P))]
	""");
	//*/


	string nal2 = """
	      #R[(S --> P) (S <-> P) |- (S --> P) :post (:t/struct-int :p/belief) :pre (:question?)]
          ;Inheritance to Similarity
          #R[(S <-> P) (S --> P) |- (S <-> P) :post (:t/struct-abd :p/belief) :pre (:question?)]



          #R[(P --> S) (S --> P) |- (P --> S) :post (:t/conversion :p/belief) :pre (:question?)]


          ;;Inheritance-Related Syllogisms
         ; If A is a special case of B and B is a special case of C so is A a special case of C (strong) the other variations are hypotheses (weak)
         #R[(A --> B) (B --> C) |- (A --> C) :post (:t/deduction :d/strong :allow-backward) :pre ((:!= A C)) ]
         #R[(A --> B) (A --> C) |- (C --> B) :post (:t/abduction :d/weak :allow-backward) :pre ((:!= B C))]
         #R[(A --> C) (B --> C) |- (B --> A) :post (:t/induction :d/weak :allow-backward) :pre ((:!= A B))]
         #R[(A --> B) (B --> C) |- (C --> A) :post (:t/exemplification :d/weak :allow-backward) :pre ((:!= C A))]
	""";

	string[] splitedLines = nal2.split("\n");
	string[] unquotedSplitedLines = splitedLines.map!(v => v[0..v.length-v.find(";").length]).array;
	string cleanedNal = unquotedSplitedLines.join("\n");

	writeln(cleanedNal);

	lexer.setSource(cleanedNal);


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


	RuleDescriptor[] ruleDescriptors = parser.rules.map!(v => translateParserRuleToRuleDescriptor(v)).array;

	string generatedCode = generateDCodeForDeriver(ruleDescriptors);

	{
		import std.File;
		File file = File("fastMetaNars/autogenerated/Deriver.d", "w");
		file.write(generatedCode);
		file.close();
	}

	writeln("generation was successfull!");

	//RuleDescriptor[] ruleDescriptors = translateParserRulesToRuleDescriptors(parser.rules);
	//writeln(generateCodeCppForDeriver(ruleDescriptors));
}



enum EnumCopulaForm {
	PREFIX, // example : (&& A B)
	NONPRFIX, // example : (A --> B)
}

enum EnumVariableType {
	INDEPENDENT,
	DEPENDENT,
}

// generates the target code (currently C++) for the "deriver"(which currently just does some pretty basic things)

class CodegenDelegates {
	string function() signatureOpen;
	string function() signatureClose;

	string function(FlagsOfCopula flags) convertFlagsOfCopulaToCtor;
	string function(EnumSource source) getPremiseVariableForSource;
	string function(string truthfunction) truthFunctionCode; // gets the raw truthfunction key as in the clojure like DSL, has to return an Enum value in the target language

	string function(EnumVariableType variableType, uint variableIndex) variableCreation; // has to generate the code for the referencing of the variable with the specific id

	// generates code for the creation of a temporary compound which is returned from the deriver
	// the arguments are already generated code
	// copulaCode is generated code, too
	string function(EnumCopulaForm copulaForm, string copulaCode, string[] arguments) temporaryCompoundCreation;

	// has to generate the code for the matching of the premise of the derivation
	string function(Tuple!(EnumSource, EnumSource)[] toMatchPremiseTerms, bool twistSides) codeForPremisePatternMatching;

	string function(EnumSource a, EnumSource b, bool checkForEqual, bool twistSides) codeForPrecondition;

}

class CodegenStringTemplates {
	string templatePreamble;

	string templateEntry, templateLeave;

	string templateCheckEntry, templateCheckLeave;
}

string generateDCodeForDeriver(RuleDescriptor[] ruleDescriptors) {
	static string signatureOpen() {
		return "TemporaryDerivedTerm*[] derive(ReasonerInstance reasonerInstance, UnifiedTermIndex premiseLeftIndex, UnifiedTermIndex premiseRightIndex, bool isQuestion) {";
	}

	static string signatureClose() {
		return "}";
	}

	static string convertFlagsOfCopulaToCtor(FlagsOfCopula flags) {
		string result;

		result ~= "FlagsOfCopula(";

		result ~= (flags.nal1or2 ? "true" : "false") ~ ",";
		result ~= (flags.nal5 ? "true" : "false") ~ ",";
		result ~= (flags.arrowLeft ? "true" : "false") ~ ",";
		result ~= (flags.arrowRight ? "true" : "false") ~ ",";
		result ~= (flags.isConjection ? "true" : "false");

		result ~= ")";

		return result;
	}

	static string getPremiseVariableForSource(EnumSource source) {
		final switch(source) {
			case EnumSource.ALEFT: return "premiseLeft.left(reasonerInstance)";
			case EnumSource.ARIGHT: return "premiseLeft.right(reasonerInstance)";
			case EnumSource.BLEFT: return "premiseRight.left(reasonerInstance)";
			case EnumSource.BRIGHT: return "premiseRight.right(reasonerInstance)";
		}
	}

	static string truthFunctionCode(string truthFunction) {
		static string translateTruthFunctionToEnum(string truthFunction) {
			assert(truthFunction[0..3] == ":t/");
			string untranslated = truthFunction[3..$];

			import std.array : replace;
			import std.uni : toUpper;
			return "RuleTable.EnumTruthFunction." ~ untranslated.replace("-", "").toUpper;
		}

		return translateTruthFunctionToEnum(truthFunction);
	}

	static string variableCreation(EnumVariableType variableType, uint variableIndex) {
		if( variableType == EnumVariableType.INDEPENDENT ) {
			return "makeReferenceIndependentVariable(%s)".format(variableIndex);
		}
		else {
			assert(variableType == EnumVariableType.DEPENDENT);
			return "makeReferenceDependentVariable(%s)".format(variableIndex);
		}
	}

	static string temporaryCompoundCreation(EnumCopulaForm copulaForm, string copulaCode, string[] arguments) {
		assert(arguments.length == 2, "just implemented for binary compounds!");

		// NOTE< we ignore prefix and postfix form for now for the generated code >
		const string
			leftSideAsString = arguments[0],
			rightSideAsString = arguments[1];
		return "genBinary(%s, %s, %s)".format(copulaCode, leftSideAsString, rightSideAsString);
	}

	// twistSides : are the premise sides (left and right) switched?
	static string codeForPremisePatternMatching(Tuple!(EnumSource, EnumSource)[] toMatchPremiseTerms, bool twistSides) {
		string nestedCodeForSourcePattern = "true";
		foreach( iterationToMatchInputTerm; toMatchPremiseTerms ) {
			nestedCodeForSourcePattern ~= format("&& (%s == %s)", getPremiseVariableForSource(twistSource(iterationToMatchInputTerm[0], twistSides)), getPremiseVariableForSource(twistSource(iterationToMatchInputTerm[1], twistSides)));
		}

		return nestedCodeForSourcePattern;
	}

	// twistSides : are the premise sides (left and right) switched?
	static string codeForPrecondition(EnumSource a, EnumSource b, bool checkForEqual, bool twistSides) {
		return format("&& (%s %s %s)", getPremiseVariableForSource(twistSource(a, twistSides)), checkForEqual ? "==" : "!=", getPremiseVariableForSource(twistSource(b, twistSides)));
	}


	

	CodegenDelegates delegates = new CodegenDelegates;
	delegates.signatureOpen = &signatureOpen;
	delegates.signatureClose = &signatureClose;
	delegates.convertFlagsOfCopulaToCtor = &convertFlagsOfCopulaToCtor;
	delegates.getPremiseVariableForSource = &getPremiseVariableForSource;
	delegates.truthFunctionCode = &truthFunctionCode;
	delegates.variableCreation = &variableCreation;
	delegates.temporaryCompoundCreation = &temporaryCompoundCreation;
	delegates.codeForPremisePatternMatching = &codeForPremisePatternMatching;
	delegates.codeForPrecondition = &codeForPrecondition;



	CodegenStringTemplates stringTemplates = new CodegenStringTemplates;
	stringTemplates.templatePreamble = """
	module fastMetaNars.autogenerated.Deriver;

	import fastMetaNars.ReasonerInstance;
	import fastMetaNars.Term;
	import fastMetaNars.FlagsOfCopula;
	import fastMetaNars.RuleTable;


	import fastMetaNars.deriver.DeriverUtils;

	// HACK< TODO< recode this and remove > we define the type here >
	alias uint UnifiedTermIndex;
	""";

	stringTemplates.templateEntry = """
			TemporaryDerivedTerm*[] resultTerms;

			Compound* premiseLeft = reasonerInstance.accessCompoundByIndex(premiseLeftIndex);
			Compound* premiseRight = reasonerInstance.accessCompoundByIndex(premiseRightIndex);

	""";

	stringTemplates.templateLeave = """return resultTerms;""";

	stringTemplates.templateCheckEntry = """
		%s if( 
			// AUTOGEN< check flags for match >
			((%s.flagsOfCopula == %s) && (%s.flagsOfCopula == %s))

			// AUTOGEN< check for source pattern >
			&& (%s)

			// AUTOGEN< check eventually for the preconditions >
			%s
		) {
	""";
	

	stringTemplates.templateCheckLeave = "}\n";


	return generateCodeForDeriver(delegates, stringTemplates, ruleDescriptors);
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

Element getNonprefixCopulaElement(Compound compound) {
	Element result = compound.braceContent[1];
	assert(result.isCopula);
	return result;
}

Element getPrefixCopulaElement(Compound compound) {
	Element result = compound.braceContent[0];
	assert(result.isCopula);
	return result;
}


EnumSource twistSource(EnumSource source, bool twisted) {
	if( twisted ) {
		final switch(source) {
			case EnumSource.ALEFT: return EnumSource.BLEFT;
			case EnumSource.ARIGHT: return EnumSource.BRIGHT;
			case EnumSource.BLEFT: return EnumSource.ALEFT;
			case EnumSource.BRIGHT: return EnumSource.ARIGHT;
		}
	}
	else {
		return source;
	}
}

import std.format : format;

string generateCodeForDeriver(CodegenDelegates delegates, CodegenStringTemplates stringTemplates, RuleDescriptor[] ruleDescriptors) {
	string generated;

	generated ~= stringTemplates.templatePreamble;

	generated ~= delegates.signatureOpen() ~ "\n";
	generated ~= stringTemplates.templateEntry;

	uint lookupVariable(EnumVariableType variableType, string name) {
		// TODO< realize real lookup for the 5% of the rules >
		// for this we need to store all variables of the rule into a dictionary
		// then we need to make a lookup here

		// we return just zero because in most rules we just use one variable
		return 0;
	}


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

	

	foreach( iRuleDescriptor; ruleDescriptors ) {

		// we twist the two premise sides
		foreach( bool twisted; [false, true] ) {

			EnumSource getSourceOfPremiseVariableByName(string premiseVariableName) {
				bool doesPremiseVariableApearInLeafElementRecursivly(Element element) {
					return element.tokenWithDecoration.token.contentString == premiseVariableName;
				}

				bool doesPremiseVariableAppearInCompoundRecursivly(Compound compound) {
					if( compound.isBrace ) {
						assert(compound.isBinaryCompound); // just binary compounds are for now implemented

						return doesPremiseVariableAppearInCompoundRecursivly(compound.leftChild) || doesPremiseVariableAppearInCompoundRecursivly(compound.rightChild);
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
					assert(doesPremiseVariableAppearInCompoundRecursivly(compound));

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

				// we have to switch the side of the premise to be checked if the sides are twisted
				EnumPremiseSide switchpremiseSideIfTwisted(EnumPremiseSide side) {
					if( twisted ) {
						final switch(side) with(EnumPremiseSide) {
							case LEFT : return RIGHT;
							case RIGHT : return LEFT;
						}
					}
					else {
						return side;
					}
				}

				if( doesPremiseVariableAppearInCompoundRecursivly(iRuleDescriptor.premiseElements[0]) ) {
					return getSourceOfPremiseVariableByNameForCompound(iRuleDescriptor.premiseElements[0], switchpremiseSideIfTwisted(EnumPremiseSide.LEFT));
				}
				else if( doesPremiseVariableAppearInCompoundRecursivly(iRuleDescriptor.premiseElements[1]) ) {
					return getSourceOfPremiseVariableByNameForCompound(iRuleDescriptor.premiseElements[1], switchpremiseSideIfTwisted(EnumPremiseSide.RIGHT));
				}
				else {
					throw new Exception("premiseVariableName \"" ~ premiseVariableName ~ "\" wasn't found in left or right premisses!");
				}
			}

			// returns the to generated code for the token
			// used in the recursive codgen code for the creation of the temporary objects describing the creation of the compounds/terms
			string nestedFnGetCodeOfToken(TokenWithDecoration tokenWithDecoration, bool twisted) {
				Token!EnumOperationType token = tokenWithDecoration.token;

				if( tokenWithDecoration.isIndependentVariable ) {
					return delegates.variableCreation(EnumVariableType.INDEPENDENT, lookupVariable(EnumVariableType.INDEPENDENT, token.contentString));
				}
				else if( tokenWithDecoration.isDependentVariable ) {
					return delegates.variableCreation(EnumVariableType.DEPENDENT, lookupVariable(EnumVariableType.DEPENDENT, token.contentString));
				}
				else {
					EnumSource sourceOfPremiseVariable = getSourceOfPremiseVariableByName(token.contentString);
					return delegates.getPremiseVariableForSource(twistSource(sourceOfPremiseVariable, twisted));
				}
			}


			string delegate(Element element) nestedFnGetCodeOfCompoundCreationRecursivly;

			string nestedFnGetCodeOfBinaryCompoundCreationRecursivly(EnumCopulaForm copulaForm, Element copulaElement, Element leftSideElement, Element rightSideElement) {
				string copulaAsString = delegates.convertFlagsOfCopulaToCtor(convertCopulaElementToFlagsOfCopula(copulaElement));

				string leftSideAsString, rightSideAsString;

				// check if it are compounds and recursivly call nestedFnGetStringOfCompundCreationRecursivly if its the case
				// else we check if it is an premise variable, if it is the case we generate the code for accessing it

				if( leftSideElement.isTokenWithDecoration ) {
					leftSideAsString = nestedFnGetCodeOfToken(leftSideElement.tokenWithDecoration, twisted);
				}
				else if( leftSideElement.isBrace ) {
					leftSideAsString = nestedFnGetCodeOfCompoundCreationRecursivly(leftSideElement);
				}
				else {
					throw new Exception("Internal Error");
				}

				if( rightSideElement.isTokenWithDecoration ) {
					rightSideAsString = nestedFnGetCodeOfToken(rightSideElement.tokenWithDecoration, twisted);
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


		
			// generate code for the check of the premises
			{
				string nestedCodeForPreconditionCheck = !iRuleDescriptor.preconditionUnequality.isNull ? delegates.codeForPrecondition(iRuleDescriptor.preconditionUnequality[0], iRuleDescriptor.preconditionUnequality[1], false/*checkForEqual*/, twisted) : "";
				string nestedCodeForQuestionCheck = iRuleDescriptor.preconditionIsQuestion ? "&& isQuestion" : "";

				string nestedCodeForPreconditions = nestedCodeForQuestionCheck ~ nestedCodeForPreconditionCheck;

				// we do walk because later on we have to match deeper terms
				Element leftPremiseCompoundCopulaElement = iRuleDescriptor.leftPremiseElement.walk([]).getNonprefixCopulaElement;
				Element rightPremiseCompoundCopulaElement = iRuleDescriptor.rightPremiseElement.walk([]).getNonprefixCopulaElement;
				
				bool withElseString = twisted; // we need an else for the twisted case
				string elseString = withElseString ? "else" : ""; // twisted assignments can have the else prefix

				generated ~= stringTemplates.templateCheckEntry.format( 
					elseString,

					twisted ?  "premiseRight" : "premiseLeft",
					delegates.convertFlagsOfCopulaToCtor(convertCopulaElementToFlagsOfCopula(twisted ? rightPremiseCompoundCopulaElement : leftPremiseCompoundCopulaElement)),

					twisted ?  "premiseLeft" : "premiseRight",
					delegates.convertFlagsOfCopulaToCtor(convertCopulaElementToFlagsOfCopula(twisted ? leftPremiseCompoundCopulaElement : rightPremiseCompoundCopulaElement)),
					delegates.codeForPremisePatternMatching(iRuleDescriptor.toMatchPremiseTerms, twisted),
					nestedCodeForPreconditions
				);
			}


			foreach( iterationRuleResultWithPostconditionAndTruth; iRuleDescriptor.ruleResultWithPostconditionAndTruth ) {
				// TODO< put the string into the templates >
				generated ~= "resultTerms ~= %s".format(nestedFnGetStringOfTermForResult(iterationRuleResultWithPostconditionAndTruth)) ~ ";\n";
			}

			generated ~= stringTemplates.templateCheckLeave;
		}

	}


	// TODO< rewrite as string templates >
	generated ~= ";\n"; // finish the else from the last templateCheckLeave


	generated ~= stringTemplates.templateLeave;
	generated ~= delegates.signatureClose() ~ "\n";

	return generated;
}

/+ uncommented 09.09.2016 because overhaul and a language independent interface(now for D) is needed
string generateCodeCppForDeriver(RuleDescriptor[] ruleDescriptors) {
	// the signature of the generate function is
	const string signature = "vector<UnifiedTerm> derive(ReasonerInstance &reasonerInstance, vector<UnifiedTermIndex> &leftPathTermIndices, vector<UnifiedTermIndex> &rightPathTermIndices, float k)";


	string generateCodeForRuleDescriptor(RuleDescriptor ruleDescriptor) {

		


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
			convertFlagsOfCopulaToCtor(ruleDescriptor.flagsOfSourceCopula[0]),
			convertFlagsOfCopulaToCtor(ruleDescriptor.flagsOfSourceCopula[1]),
			getNestedCodeForSourcePattern(),
			nestedCodeForUnequalCheck
		);




		// TODO< implement case where the generalized binary can't be used >
		emittedCode ~= format(templateRuletableGeneralizedBinary,
			convertSourceToCpp(ruleDescriptor.sourceLeft),
			convertSourceToCpp(ruleDescriptor.sourceRight),
			convertFlagsOfCopulaToCtor(ruleDescriptor.flagsOfTargetCopula),
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

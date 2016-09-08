import std.typecons : Nullable, Tuple;

import lang.Parser : AbstractParser = Parser;
import lang.Token : Token;
import lang.Lexer : Lexer;


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
}

class RuleLexer : Lexer!EnumOperationType {
	override protected Token!EnumOperationType createToken(uint ruleIndex, string matchedString) {
		import std.stdio;
		//writeln(matchedString);

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
		}
		else if( ruleIndex == 12 ) {
			token.type = Token!EnumOperationType.EnumType.OPERATION;
			token.contentOperation = EnumOperationType.IMPLCIATION;
		}



		return token;
	}

	override protected void fillRules() {
		tokenRules ~= Lexer!EnumOperationType.Rule(r"^([ \n\r]+)");
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
		tokenRules ~= Lexer!EnumOperationType.Rule(r"^\$");
		tokenRules ~= Lexer!EnumOperationType.Rule(r"^(==>)");
	}
}

import std.variant : Variant;


struct TokenWithDecoration {
	Token!EnumOperationType token;
	bool isIndependentVariable;

	static TokenWithDecoration makeToken(Token!EnumOperationType token) {
		TokenWithDecoration result;
		result.token = token;
		return result;
	}

	static TokenWithDecoration makeIndependentVar(Token!EnumOperationType token) {
		TokenWithDecoration result;
		result.token = token;
		result.isIndependentVariable = true;
		return result;
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
			elementsStack.push(Element.makeBrace());
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
		/* + 2 */this.Arcs ~= new Arc(AbstractParser!EnumOperationType.Arc.EnumType.OPERATION, cast(uint)EnumOperationType.INDEPENDENTVAR           , &nothing            , SYLOGISMWITHOUTBRACESTART+3, Nullable!uint(SYLOGISMWITHOUTBRACESTART+4));
		/* + 3 */this.Arcs ~= new Arc(AbstractParser!EnumOperationType.Arc.EnumType.TOKEN    , cast(uint)Token!EnumOperationType.EnumType.IDENTIFIER, &pushIndependentVar , SYLOGISMWITHOUTBRACESTART+0, nullUint);
		/* + 4 */this.Arcs ~= new Arc(AbstractParser!EnumOperationType.Arc.EnumType.OPERATION, cast(uint)EnumOperationType.SIMILARITY               , &addTokenToBrace          , SYLOGISMWITHOUTBRACESTART+0, Nullable!uint(SYLOGISMWITHOUTBRACESTART+5));

		/* + 5 */this.Arcs ~= new Arc(AbstractParser!EnumOperationType.Arc.EnumType.OPERATION, cast(uint)EnumOperationType.INHERITANCE              , &addTokenToBrace          , SYLOGISMWITHOUTBRACESTART+0, Nullable!uint(SYLOGISMWITHOUTBRACESTART+6));
		/* + 6 */this.Arcs ~= new Arc(AbstractParser!EnumOperationType.Arc.EnumType.OPERATION, cast(uint)EnumOperationType.IMPLCIATION              , &addTokenToBrace          , SYLOGISMWITHOUTBRACESTART+0, Nullable!uint(SYLOGISMWITHOUTBRACESTART+7));
		/* + 7 */this.Arcs ~= new Arc(AbstractParser!EnumOperationType.Arc.EnumType.OPERATION, cast(uint)EnumOperationType.HALFH                    , &addTokenToBrace          , SYLOGISMWITHOUTBRACESTART+0, Nullable!uint(SYLOGISMWITHOUTBRACESTART+8));
		/* + 8 */this.Arcs ~= new Arc(AbstractParser!EnumOperationType.Arc.EnumType.OPERATION, cast(uint)EnumOperationType.KEY                      , &addTokenToBrace         , SYLOGISMWITHOUTBRACESTART+0, Nullable!uint(SYLOGISMWITHOUTBRACESTART+9));
		/* + 9 */this.Arcs ~= new Arc(AbstractParser!EnumOperationType.Arc.EnumType.NIL, 0                                                          , &nothing          , SYLOGISMWITHOUTBRACESTART+0, Nullable!uint(SYLOGISMWITHOUTBRACESTART+10));
		
		/* +10 */this.Arcs ~= new Arc(AbstractParser!EnumOperationType.Arc.EnumType.NIL, 0                                                          , &nothing          , SYLOGISMWITHOUTBRACESTART+0, Nullable!uint(SYLOGISMWITHOUTBRACESTART+11));
		/* +11 */this.Arcs ~= new Arc(AbstractParser!EnumOperationType.Arc.EnumType.NIL, 0                                                          , &nothing          , SYLOGISMWITHOUTBRACESTART+0, Nullable!uint(SYLOGISMWITHOUTBRACESTART+12));
		/* +12 */this.Arcs ~= new Arc(AbstractParser!EnumOperationType.Arc.EnumType.NIL, 0                                                          , &nothing          , SYLOGISMWITHOUTBRACESTART+0, Nullable!uint(SYLOGISMWITHOUTBRACESTART+13));


		/* +13 */this.Arcs ~= new Arc(AbstractParser!EnumOperationType.Arc.EnumType.OPERATION, cast(uint)EnumOperationType.BRACEOPEN                , &beginBraceElement         , SYLOGISMWITHOUTBRACESTART+14, Nullable!uint(SYLOGISMWITHOUTBRACESTART+15));
		/* +14 */this.Arcs ~= new Arc(AbstractParser!EnumOperationType.Arc.EnumType.ARC      , SYLOGISMSTART                                        , &nothing, SYLOGISMWITHOUTBRACESTART+0, nullUint);

		/* +15 */this.Arcs ~= new Arc(AbstractParser!EnumOperationType.Arc.EnumType.END      , 0                                                    , &nothing,0, nullUint                   );
	}

	override protected void setupBeforeParsing() {
   	}

   	public static class Element {
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


   		final @property TokenWithDecoration tokenWithDecoration() {
   			assert(type == EnumType.TOKENWITHDECORATION);
   			return protectedTokenWithDecoration;
   		}

   		protected TokenWithDecoration protectedTokenWithDecoration;
   		Element[] braceContent; // without accessor because im not sure if the array can be manipulated like an reference if we pass it outside
   		                        // TODO< investigate this >



   		final @property string leftIdentifier() {
   			assert(braceContent[0].tokenWithDecoration.token.type == Token!EnumOperationType.EnumType.IDENTIFIER);
   			return braceContent[0].tokenWithDecoration.token.contentString;
   		}

   		final @property string rightIdentifier() {
   			assert(braceContent[0].tokenWithDecoration.token.type == Token!EnumOperationType.EnumType.IDENTIFIER);
   			return braceContent[0].tokenWithDecoration.token.contentString;
   		}

   		final @property EnumOperationType operation() {
   			assert(braceContent[1].tokenWithDecoration.token.type == Token!EnumOperationType.EnumType.OPERATION);
   			return braceContent[1].tokenWithDecoration.token.contentOperation;
   		}

   	}

   	public static class DictionaryElement {
   		public Variant[] content;
   	}

   	public static class Rule {
   		public enum EnumType {
   			BEFORE,
   			AFTER
   		}

   		EnumType type;

   		Element rootElement;

   		final @property Element[] elementsBeforeHalfh() {
   			assert(false, "TODO");	
   		} 

   		final @property Element[] elementsAfterHalfh() {
   			assert(false, "TODO");
   		}
   	}

   	// helper for parser actions
   	protected final @property Rule lastRule() {
   		return rules[$-1];
   	}

   	public Rule[] rules;
}

enum EnumSource {
	ALEFT,
	ARIGHT,
	BLEFT,
	BRIGHT,
}



struct FlagsOfCopula {
	bool flagInheritanceToLeft, flagInheritanceToRight;
}

struct RuleDescriptor {
	final this(EnumSource sourceLeft, EnumSource sourceRight, FlagsOfCopula flagsOfSourceCopula[2], FlagsOfCopula flagsOfTargetCopula, string rule) {
		this.sourceLeft = sourceLeft;
		this.sourceRight = sourceRight;
		this.flagsOfSourceCopula = flagsOfSourceCopula;
		this.flagsOfTargetCopula = flagsOfTargetCopula;
		this.rule = rule;
	}

	EnumSource sourceLeft, sourceRight;
	FlagsOfCopula flagsOfSourceCopula[2];
	FlagsOfCopula flagsOfTargetCopula;
	string rule;

	Nullable!(EnumSource[2]) preconditionUnequal; // is the translated precondition
	
	Tuple!(EnumSource, EnumSource)[] toMatchInputTerms; // pairs of the sources which need to match that the rule fires 
};

import std.stdio;


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

	string translateTruthFunctionToCppEnum(string truthFunction) {
		assert(truthFunction[0..3] == ":t/");
		string untranslated = truthFunction[3..$];

		import std.array : replace;
		import std.uni : toUpper;
		return untranslated.replace("-", "").toUpper;
	}

	// tries to find the variablenname on the left side of half-h
	EnumSource findSource(Parser.Rule rule, string variablenname) {
		if( rule.elementsBefore[0].leftIdentifier == variablenname ) {
			return EnumSource.ALEFT;
		}
		else if( rule.elementsBefore[0].rightIdentifier == variablenname ) {
			return EnumSource.ARIGHT;
		}
		else if( rule.elementsBefore[1].leftIdentifier == variablenname ) {
			return EnumSource.BLEFT;
		}
		else if( rule.elementsBefore[1].rightIdentifier == variablenname ) {
			return EnumSource.BRIGHT;
		}
		else {
			return EnumSource.BLEFT;
			// TODO< throw something "Couldn't find source" >
		}

	}

	FlagsOfCopula translateOperationToCopola(EnumOperationType operation) {
		FlagsOfCopula result;
		result.flagInheritanceToLeft = (operation == EnumOperationType.SIMILARITY);
		result.flagInheritanceToRight = (operation == EnumOperationType.INHERITANCE || operation == EnumOperationType.SIMILARITY);
		return result;
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
					ruleDescriptorToAdd.toMatchInputTerms ~= Tuple!(EnumSource, EnumSource)(iterationLeftMatching[1], iterationRightMatching[1]);				
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


	// this is just for testing the parser
	//*
	lexer.setSource("#R[(M --> P) |-  (A --> C) :pre (:!=)]"); // (M --> S) |- (S <-> P)]");
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
	
	/* uncommented because its in a crappy format, still TODO
	lexer.setSource(
	"""
	 #R[(S --> M) (P --> M) |- (((P --> $X) ==> (S --> $X)) :post (:t/abduction)
                                      ((S --> $X) ==> (P --> $X)) :post (:t/induction)
                                      ((P --> $X) <=> (S --> $X)) :post (:t/comparison)
                                      (&& (S --> #Y) (P --> #Y)) :post (:t/intersection))
                                          :pre (:belief? (:!= S P))]
	""");
	*/


	parser.setLexer(lexer);
   	
   	string errorMessage;
    bool parsingSuccess = parser.parse(errorMessage);

	if( !parsingSuccess ) {
		errorMessage = "Parsing Failed: " ~ errorMessage;
		import std.stdio;
		writeln(errorMessage);

		return;
	}


	//RuleDescriptor[] ruleDescriptors = translateParserRulesToRuleDescriptors(parser.rules);
	//writeln(generateCodeCppForDeriver(ruleDescriptors));
}



// generates the target code (currently C++) for the "deriver"(which currently just does some pretty basic things)

string generateCodeCppForDeriver(RuleDescriptor[] ruleDescriptors) {
	// the signature of the generate function is
	const string signature = "vector<UnifiedTerm> derive(ReasonerInstance &reasonerInstance, vector<UnifiedTermIndex> &leftPathTermIndices, vector<UnifiedTermIndex> &rightPathTermIndices, float k)";


	string generateCodeForRuleDescriptor(RuleDescriptor ruleDescriptor) {
		string getVariableForSource(EnumSource source) {
			final switch(source) {
				case EnumSource.ALEFT: return "previousLeft.left";
				case EnumSource.ARIGHT: return "previousLeft.right";
				case EnumSource.BLEFT: return "previousRight.left";
				case EnumSource.BRIGHT: return "previousRight.right";
			}
		}


		string convertFlagsOfCopulaToFlags(FlagsOfCopula flags) {
			string result;

			if( flags.flagInheritanceToLeft ) {
				result ~= "static_cast<TermFlagsType>(EnumTermFlags::INHERITANCE_TOLEFT) |";
			}
			if( flags.flagInheritanceToRight ) {
				result ~= "static_cast<TermFlagsType>(EnumTermFlags::INHERITANCE_TORIGHT) |";
			}

			result = result[0..$-1];
			return result;
		}

		// helper
		string convertSourceToCpp(EnumSource source) {
			final switch(source) {
				case EnumSource.ALEFT : return "EnumDerivationSource::ALEFT";
				case EnumSource.ARIGHT : return "EnumDerivationSource::ARIGHT";
				case EnumSource.BLEFT : return "EnumDerivationSource::BLEFT";
				case EnumSource.BRIGHT : return "EnumDerivationSource::BRIGHT";
			}
		}


		

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

				// AUTOGEN TODO< PATRICK ASK < do we need to append the stuff before the tree  > >
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
			foreach( iterationToMatchInputTerm; ruleDescriptor.toMatchInputTerms ) {
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

	string templateEntry = """
			vector<UnifiedTerm> resultTerms;

			UnifiedTermIndex previousLeftIndex = leftPathTermIndices[leftPathTermIndices.size()-1]; // AUTOGEN< need it to check for the flags of the left concept >
			UnifiedTerm previousLeft = reasonerInstance.accessTermByIndex(previousLeftIndex);

			UnifiedTermIndex previousRightIndex = rightPathTermIndices[leftPathTermIndices.size()-1]; // AUTOGEN< need it to check for the flags of the right concept >
			UnifiedTerm previousRight = reasonerInstance.accessTermByIndex(previousRightIndex);

			typedef decltype(previousLeft.termFlags) TermFlagsType;
	""";

	string templateLeave = """return resultTerms;""";

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

// TODO< translate precondition >

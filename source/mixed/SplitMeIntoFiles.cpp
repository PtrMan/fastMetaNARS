#include <cstddef>
#include <cstdint>
#include <vector>


using namespace std;

/****
// http://stackoverflow.com/questions/664014/what-integer-hash-function-are-good-that-accepts-an-integer-hash-key
uint32_t hash_(uint32_t x) {
    x = ((x >> 16) ^ x) * 0x45d9f3b;
    x = ((x >> 16) ^ x) * 0x45d9f3b;
    x = ((x >> 16) ^ x);
    return x;
}
****/

/****
uint32_t bloomHash1(uint32_t x) {
  return hash_(x);
}
****/

/****
template<size_t NumberOfBits>
struct StaticBitset {
  StaticBitset() {
    reset();
  }

  void reset() {
    for(size_t i = 0; i < elmentsOfArray(array); i++) {
      array[i] = 0;
    }
  }

  static StaticBitset or_(StaticBitset a, StaticBitset b) {
    StaticBitset result;
    for( size_t i = 0; i < elmentsOfArray(result.array); i++ ) {
      result.array[i] = a.array[i] | b.array[i];
    }
    return result;
  }

  static bool existsOverlap(StaticBitset a, StaticBitset b) {
    StaticBitset result;
    for( size_t i = 0; i < elmentsOfArray(result.array); i++ ) {
      if( a.array[i] & b.array[i]) {
        return true;
      }
    }
    return false;
  }


  bool get(size_t bitIndex) {
    size_t arrayIndex = bitIndex / NUMBEROFBITSFORMACHINEWORD;
    size_t bitIndex = bitIndex % NUMBEROFBITSFORMACHINEWORD;
    return array[arrayIndex] & (1 << bitIndex);
  }

  void set(size_t bitIndex, bool value) {
    size_t arrayIndex = bitIndex / NUMBEROFBITSFORMACHINEWORD;
    size_t bitIndexInWord = bitIndex % NUMBEROFBITSFORMACHINEWORD;

    size_t negationMask = ~(1 << bitIndexInWord);

    if( value ) {
      array[arrayIndex] |= (1 << bitIndexInWord);
    }
    else {
      array[arrayIndex] = array[arrayIndex] & negationMask;
    }
  }

  const size_t NUMBEROFBITSFORMACHINEWORD = sizeof(size_t)*8;

  size_t array[NumberOfBits/(NUMBEROFBITSFORMACHINEWORD)+1]; // TODO< remove +1 if modulo is zero >
};
****/


/******
#include "StaticBitset.h"
#include "Hash.h"


template<size_t NumberOfBits, typename ValueType>
struct Bloomfilter {
  void set(ValueType value) {
    // for all hash functions
    setBit(bloomHash1(value));
  }

  bool test(ValueType value) {
    bool isSet = true;

    // for all hash functions
    isSet &= checkBit(bloomHash1(value));

    return isSet;
  }

  void reset() {
    filter.reset();
  }

  static bool overlap(Bloomfilter<NumberOfBits, ValueType> a, Bloomfilter<NumberOfBits, ValueType> b) {
    return StaticBitset<NumberOfBits>::existsOverlap(a.filter, b.filter);
  }

  static Bloomfilter<NumberOfBits, ValueType> union_(Bloomfilter<NumberOfBits, ValueType> a, Bloomfilter<NumberOfBits, ValueType> b) {
    Bloomfilter<NumberOfBits, ValueType> result;
    result.filter = StaticBitset<NumberOfBits>::or_(a.filter, b.filter);
    return result;
  }

protected:
  void setBit(size_t index) {
    filter.set(index % NumberOfBits, true);
  }

  bool checkBit(size_t index) {
    return filter.get(index % NumberOfBits);
  }

  static uint32_t bloomHash1(uint32_t x) {
	  return hash_(x);
  }

  StaticBitset<NumberOfBits> filter;
};
*****/

/*****
typedef unsigned MachineType;

const bool CHECK = true;

typedef uint32_t ConceptTermIndexType;
typedef ConceptTermIndexType ConceptIndexType;
typedef ConceptTermIndexType TermIndexType;

// unique id for a term for the state of the reasoner
typedef uint32_t TermIdType;


*****/


// typesafe TermId type for the unique identification of a term
/************
struct TermId {
  uint32_t value;
};*****/



// Typesafe Concept type
struct Concept {
  ConceptIndexType index;

  bool operator==(const Concept &rhs){
    return index == rhs.index;
  }

  bool operator==(const Concept &rhs) const {
    return index == rhs.index;
  }

  bool operator!=(const Concept &rhs){
    return !this->operator==(rhs);
  }
};

/************
enum class EnumTermConcept {
  CONCEPT = 0, // must be 0 for fast check
  TERM
};

// unifies the adress of a term or a concept into one value
struct TermConcept {
  static TermConcept makeTerm(ConceptTermIndexType index) {
    size_t numberOfBits = sizeof(ConceptTermIndexType)*8;

    TermConcept result;
    result.folded = (1 << (numberOfBits-1)) | index;
    return result;
  }

  static TermConcept makeConcept(ConceptTermIndexType index) {
    TermConcept result;
    result.folded = index;
    return result;
  }

  bool operator==(const TermConcept &rhs){
    return folded == rhs.folded;
  }

  bool operator!=(const TermConcept &rhs){
    return !this->operator==(rhs);
  }

  EnumTermConcept getType() {
    size_t numberOfBits = sizeof(ConceptTermIndexType)*8;
    return static_cast<EnumTermConcept>(folded >> (numberOfBits-1));
  }

  ConceptTermIndexType maskOutIndex() {
    return static_cast<ConceptTermIndexType>(-1) & folded;
  }
protected:
  ConceptTermIndexType folded; // highest bit encodes if its a term
};
******/

/******

#include <array>
#include <cstring>
**
 * A stamp like in the classic NARS which contains the stamp history (as TermIdType values) and a bloomfilter for the values
 *
template<size_t NumberOfElements, size_t BloofilterNumberOfBits>
struct DualStamp {
  DualStamp() {
    used = 0;
  }

  void insertAtFront(vector<TermIdType> termIds) {
    size_t newUsed = min(used + termIds.size(), termIdHistory.size());

    // push the old values to the back
    memmove(&termIdHistory[termIds.size()], &termIdHistory, (termIdHistory.size()-termIds.size()) * sizeof(TermIdType));

    for( size_t i = 0; i < termIds.size(); i++ ) {
      termIdHistory[i] = termIds[i];
    }

    bool sizeDidntChange = newUsed == used;
    if( sizeDidntChange ) {
      recalcBloomfilter(newUsed);
    }
    else {
      addToBloomfilter(termIds);
    }
  }

  size_t used;
  array<TermIdType, NumberOfElements> termIdHistory;
  Bloomfilter<BloofilterNumberOfBits, TermIdType> bloomfilter;
protected:
  void recalcBloomfilter(size_t newSize) {
    bloomfilter.reset();

    for( size_t i = 0; i < newSize; i++ ) {
      bloomfilter.set(termIdHistory[i]);
    }
  }

  void addToBloomfilter(vector<TermIdType> termIds) {
    for( size_t i = 0; i < termIds.size(); i++ ) {
      bloomfilter.set(termIds[i]);
    }
  }
};
*****/



/****
struct FrequencyCertainty {
  FrequencyCertainty() {}
  
  FrequencyCertainty(float frequency, float certainty) {
    this->frequency = frequency;
    this->certainty = certainty;
  }
  
  float frequency, certainty;
};

float _and(float a, float b) {
  return a*b;
}

float _and(float a, float b, float c, float d) {
  return a*b*c*d;
}


// rigid flexibility, page 85
FrequencyCertainty fAnalogy(FrequencyCertainty _1, FrequencyCertainty _2, float k) {
  float c1 = _1.certainty;
  float c2 = _2.certainty;
  float f1 = _1.frequency;
  float f2 = _2.frequency;

  return FrequencyCertainty(f1*f2, c1*f2*f2*c2*c2);
}

// tick function
// rigid flexibility, page 84
FrequencyCertainty fAnalogyTick(FrequencyCertainty _1, FrequencyCertainty _2, float k) {
  return fAnalogy(_2, _1, k);
}

FrequencyCertainty fDedudction(FrequencyCertainty _1, FrequencyCertainty _2, float k) {
  float c1 = _1.certainty;
  float c2 = _2.certainty;
  float f1 = _1.frequency;
  float f2 = _2.frequency;
  
  return FrequencyCertainty(_and(f1, f2), _and(f1, c1, f2, c2));
}


FrequencyCertainty fDeduction2(FrequencyCertainty _1, FrequencyCertainty _2, float k) {
  float c1 = _1.certainty;
  float c2 = _2.certainty;
  float f1 = _1.frequency;
  float f2 = _2.frequency;

  return FrequencyCertainty(f1*f2, c1*c2*(f1 + f2 - f1*f2));
}

FrequencyCertainty fAbduction(FrequencyCertainty _1, FrequencyCertainty _2, float k) {
  float c1 = _1.certainty;
  float c2 = _2.certainty;
  float f1 = _1.frequency;
  float f2 = _2.frequency;
  
  return FrequencyCertainty(f2, f1*c1*c2/(f1*c1*c2 + k));
}

FrequencyCertainty fInduction(FrequencyCertainty _1, FrequencyCertainty _2, float k) {
  float c1 = _1.certainty;
  float c2 = _2.certainty;
  float f1 = _1.frequency;
  float f2 = _2.frequency;
  
  return FrequencyCertainty(f1, c1*f2*c2/(c1*f2*c2 + k));
}

FrequencyCertainty fRevision(FrequencyCertainty _1, FrequencyCertainty _2, float k) {
  float c1 = _1.certainty;
  float c2 = _2.certainty;
  float f1 = _1.frequency;
  float f2 = _2.frequency;
  
  float _1minusC1 = 1.0f - c1;
  float _1minusC2 = 1.0f - c2;
  
  float frequency = (f1*c1*_1minusC2 + f2*c2*_1minusC1) / (c1*_1minusC2 + c2*_1minusC1);
  float certainty = (c1*_1minusC2 + c2*_1minusC1) / (c1*_1minusC2 + c2*_1minusC1 + _1minusC1*_1minusC2);
  return FrequencyCertainty(frequency, certainty);
}

// rigid flexibility page 84
FrequencyCertainty fComparision(FrequencyCertainty _1, FrequencyCertainty _2, float k) {
  float c1 = _1.certainty;
  float c2 = _2.certainty;
  float f1 = _1.frequency;
  float f2 = _2.frequency;

  float frequency = (f1*f2)/(f1 + f2 - f1*f2);
  float certainty = (c1*c2*(f1+f2-f1*f2)) / (c1*c2*(f1+f2-f1*f2) + k);
  return FrequencyCertainty(frequency, certainty);
}
*****/







struct UnifiedTerm;

struct DerivationDescriptor {
  TermConcept derivationParents[2];

  Bloomfilter<256, TermIdType> containedParentTermIdBloomfilter;

  // helper for the creation of the DerivationDescriptor from the derivation of two UnifiedTerms
  static DerivationDescriptor create(UnifiedTerm a, TermConcept aTermConcept, UnifiedTerm b, TermConcept bTermConcept);
};

DerivationDescriptor DerivationDescriptor::create(UnifiedTerm a, TermConcept aTermConcept, UnifiedTerm b, TermConcept bTermConcept) {
  DerivationDescriptor result;

  // fuse derivation chain bloom filters
  if( aTermConcept.getType() == EnumTermConcept::TERM && bTermConcept.getType() == EnumTermConcept::TERM ) {
    // if both are terms we can unify the bloomfilters to get the new bloomfilter of the included concepts
    result.containedParentTermIdBloomfilter = Bloomfilter<256, TermIdType>::union_(a.derivationDescriptor.containedParentTermIdBloomfilter, b.derivationDescriptor.containedParentTermIdBloomfilter);
  }
  else if( aTermConcept.getType() == EnumTermConcept::TERM ) {
    result.containedParentTermIdBloomfilter = a.derivationDescriptor.containedParentTermIdBloomfilter;
    result.containedParentTermIdBloomfilter.set(a.termId.value);
  }
  else if( bTermConcept.getType() == EnumTermConcept::TERM ) {
    result.containedParentTermIdBloomfilter = b.derivationDescriptor.containedParentTermIdBloomfilter;
    result.containedParentTermIdBloomfilter.set(b.termId.value);
  }



  result.derivationParents[0] = aTermConcept;
  result.derivationParents[1] = bTermConcept;

  return result;
}


// UNCOMMENTED BECAUSE IDEA SEEMS FLAWED
/*
float bagDistributionFunction(float relative) {
  // TODO
  return relative;
}
*/

// we replace the classical bag mechanism with this
// ---
// We do have a lookup table which is filled with the indices into a vector which contains the actual elements.
// the lookup table is sampled with a linear distribution
// if the bag is at maximal capacity and a element gets replaced by another we just replace the element

// UNCOMMENTED BECAUSE IDEA SEEMS FLAWED
/*
template<size_t Size, typename ContentType>
struct StaticSizedDistributionVectorBag {
  size_t distribution[Size];
  vector<ContentType> content;

  void redistribute() {
    for( MachineType i = 0; i < Size; i++ ) {
      float distributionResult = bagDistributionFunction(static_cast<float>(i)/static_cast<float>(Size-1));

    }
  }
protected:
  void checkInvariants() {
    if( !CHECK ) {
      return;
    }

    checkInvariant();
  }

  void checkInvariant() {
    assert(content.size() <= Size);
  }
};
*/

/*******
template<typename Type>
struct BagEntity {
  BagEntity(Type value, float priority) {
    this->value = value;
    this->priority = priority;
  }

  float priority;
  Type value;
};

template<typename Type>
struct Bag {
  void put(Type element, float priority) {
    prioritySum += priority;
    elements.push_back(BagEntity<Type>(element, priority));
  }

  // value is [0, 1]
  Type reference(float value) {
    size_t index = sample(value);
    return elements[index].value;
  }

protected:


  // superslow algorithm
  // TODO< replace it with something faster >

  // value is [0, 1]
  size_t sample(float value) {
    float absolutePriority = value * prioritySum;

    float accumulator = 0.0f;
    for( MachineType i = 0; i < elements.size(); i++ ) {
      if( accumulator > absolutePriority ) {
        return i;
      }

      accumulator += elements[i].priority;
    }

    return elements.size()-1;
  }

  vector<BagEntity<Type>> elements;



  float prioritySum;
};
*****/



/*******
const unsigned STAMP_NUMBEROFELEMENTS = 2*10;
const unsigned STAMP_BLOOMFILTERNUMBEROFBITS = 64*20;

// typesafe

struct UnifiedTermIndex {
  TermIndexType value;
};


struct ClassicalTask {
  UnifiedTermIndex unifiedTerm;

  // COMMENT PATRICK< every task has a stamp >
  DualStamp<STAMP_NUMBEROFELEMENTS, STAMP_BLOOMFILTERNUMBEROFBITS> stamp;
};
****/

/********
struct ClassicalBelief {
  UnifiedTermIndex unifiedTerm;
};
******/

/********
#include <memory>

struct ClassicalConcept {
  Bag<shared_ptr<ClassicalTask>> tasks;
  Bag<shared_ptr<ClassicalBelief>> beliefs;

  UnifiedTermIndex term; // mainly for debugging purposes
  uint32_t termHash; // unique hash of the term
};
********/






// helper
// inspired by
// http://stackoverflow.com/questions/446296/where-can-i-get-a-useful-c-binary-search-algorithm
template<class Iter, class T, class Compare>
Iter binary_find(Iter begin, Iter end, const T &value, Compare comp) {
    // Finds the lower bound in at most log(last - first) + 1 comparisons
    Iter i = lower_bound(begin, end, value, comp);

    if (i != end && comp(*i, value))
        return i; // found
    else
        return end; // not found
}


/********
struct Configuration {
  float k;
};

// contains all information of a reasoner instance
struct ReasonerInstance {
  ReasonerInstance() {
    termIdCounter.value = 0x31337E; // initialize to a value which which we can easily test for assignment problems
  }

  vector<UnifiedTerm> unifiedTerms;

  TermId termIdCounter;
  Configuration configuration;

  Bag<shared_ptr<ClassicalConcept>> concepts;

  UnifiedTerm &accessTermByIndex(UnifiedTermIndex &index) {
    return unifiedTerms[index.value];
  }

protected:

};
************/






// prototype of inference

/***********
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
  static TermConcept selectSource(Ruletable::EnumDerivationSource source, UnifiedTerm a, UnifiedTerm b) {
    if( source == EnumDerivationSource::ALEFT ) {
      return a.left;
    }
    else if( source == EnumDerivationSource::ARIGHT ) {
      return a.right;
    }
    else if( source == EnumDerivationSource::BLEFT ) {
      return b.left;
    }
    else { // if( source == EnumDerivationSource::BRIGHT ) {
      return b.right;
    }
  }

  // OPTIMIZATION  could be optimized with a comparision of the middle value, like in a binary tree
  static FrequencyCertainty lookupAndCalcFrequencyCertainty(FrequencyCertainty aFrequencyCertainty, FrequencyCertainty bFrequencyCertainty, float k, EnumTruthFunction truthFunction) {
    if( truthFunction == EnumTruthFunction::REVISION ) {
      return fRevision(aFrequencyCertainty, bFrequencyCertainty, k);
    }
    else if( truthFunction == EnumTruthFunction::COMPARISION ) {
      return fComparision(aFrequencyCertainty, bFrequencyCertainty, k);
    }
    else if( truthFunction == EnumTruthFunction::ANALOGY ) {
      return fAnalogy(aFrequencyCertainty, bFrequencyCertainty, k);
    }
    else if( truthFunction == EnumTruthFunction::ANALOGYTICK ) {
      return fAnalogyTick(aFrequencyCertainty, bFrequencyCertainty, k);
    }
    else { //if( truthFunction == EnumTruthFunction::DEDUCTION2 ) {
      return fDeduction2(aFrequencyCertainty, bFrequencyCertainty, k);
    }
  }
};
*********/

// AUTOGENERATED (DERIVER)

extern void testEntry();

void derive(ReasonerInstance &reasonerInstance, vector<UnifiedTermIndex> &leftPathTermIndices, vector<UnifiedTermIndex> &rightPathTermIndices, float k) {

                        vector<UnifiedTerm> resultTerms;

                        UnifiedTermIndex previousLeftIndex = leftPathTermIndices[leftPathTermIndices.size()-1]; // AUTOGEN< need it to check for the flags of the left concept >
                        UnifiedTerm previousLeft = reasonerInstance.accessTermByIndex(previousLeftIndex);

                        UnifiedTermIndex previousRightIndex = rightPathTermIndices[leftPathTermIndices.size()-1]; // AUTOGEN< need it to check for the flags of the right concept >
                        UnifiedTerm previousRight = reasonerInstance.accessTermByIndex(previousRightIndex);


                        if(
                                // AUTOGEN< check flags for match >
                                (previousLeft.termFlags == (static_cast<decltype(previousLeft.termFlags)>(EnumTermFlags::INHERITANCE_TORIGHT )) && previousRight.termFlags == (static_cast<decltype(previousLeft.termFlags)>(EnumTermFlags::INHERITANCE_TORIGHT )))

                                // AUTOGEN< check for source pattern >
                                && (true&& (previousLeft.right == previousRight.left))

                                // AUTOGEN check eventually for the unequal precondition
                                && (previousLeft.left != previousRight.right)
                        ) {

                                Ruletable::GeneralizedBinaryRule rule;
                                rule.sourceLeft = Ruletable::EnumDerivationSource::ALEFT;
                                rule.sourceRight = Ruletable::EnumDerivationSource::BRIGHT;
                                rule.termFlags = static_cast<decltype(rule.termFlags)>(EnumTermFlags::INHERITANCE_TORIGHT );
                                rule.truthFunction = Ruletable::EnumTruthFunction::DEDUCTION;

                                UnifiedTerm resultTerm = Ruletable::ruletableGeneralizedBinary(previousLeft, previousRight, k, rule);
                                resultTerms.push_back(resultTerm);

                                // AUTOGEN< put this into sink for testing >
                                sinkFn(resultTerms);

                                // AUTOGEN TODO< PATRICK ASK < do we need to append the stuff before the tree  > >
                }
 else
;
}







// AUTOGENERATED

/*
UnifiedTerm ruletablenal2Revision00(UnifiedTerm a, TermConcept aTermConcept, UnifiedTerm b, TermConcept bTermConcept, float k) {
  UnifiedTerm result;
  result.left = a.left;
  result.right = b.right;

  result.flagToLeftInheritance = false;
  result.flagToRightInheritance = true;

  result.derivationDescriptor = DerivationDescriptor::create(a, aTermConcept, b, bTermConcept);

  result.frequencyCertainty = fRevision(a.frequencyCertainty, b.frequencyCertainty, k);

  return result;
}



UnifiedTerm ruletablenal2Revision10(UnifiedTerm a, TermConcept aTermConcept, UnifiedTerm b, TermConcept bTermConcept, float k) {
  UnifiedTerm result;
  result.left = a.right;
  result.right = b.right;

  result.flagToLeftInheritance = true;
  result.flagToRightInheritance = true;

  result.derivationDescriptor = DerivationDescriptor::create(a, aTermConcept, b, bTermConcept);

  result.frequencyCertainty = fRevision(a.frequencyCertainty, b.frequencyCertainty, k);

  return result;
}



UnifiedTerm ruletablenal2Revision20(UnifiedTerm a, TermConcept aTermConcept, UnifiedTerm b, TermConcept bTermConcept, float k) {
  UnifiedTerm result;
  result.left = a.left;
  result.right = b.right;

  result.flagToLeftInheritance = true;
  result.flagToRightInheritance = true;

  result.derivationDescriptor = DerivationDescriptor::create(a, aTermConcept, b, bTermConcept);

  result.frequencyCertainty = fRevision(a.frequencyCertainty, b.frequencyCertainty, k);

  return result;
}



UnifiedTerm ruletablenal2Revision01(UnifiedTerm a, TermConcept aTermConcept, UnifiedTerm b, TermConcept bTermConcept, float k) {
  UnifiedTerm result;
  result.left = a.left;
  result.right = a.right;

  result.flagToLeftInheritance = true;
  result.flagToRightInheritance = true;

  result.derivationDescriptor = DerivationDescriptor::create(a, aTermConcept, b, bTermConcept);

  result.frequencyCertainty = fRevision(a.frequencyCertainty, b.frequencyCertainty, k);

  return result;
}



UnifiedTerm ruletablenal2Revision11(UnifiedTerm a, TermConcept aTermConcept, UnifiedTerm b, TermConcept bTermConcept, float k) {
  UnifiedTerm result;
  result.left = a.left;
  result.right = a.right;

  result.flagToLeftInheritance = false;
  result.flagToRightInheritance = true;

  result.derivationDescriptor = DerivationDescriptor::create(a, aTermConcept, b, bTermConcept);

  result.frequencyCertainty = fRevision(a.frequencyCertainty, b.frequencyCertainty, k);

  return result;
}



UnifiedTerm ruletablenal2Revision21(UnifiedTerm a, TermConcept aTermConcept, UnifiedTerm b, TermConcept bTermConcept, float k) {
  UnifiedTerm result;
  result.left = a.left;
  result.right = a.right;

  result.flagToLeftInheritance = true;
  result.flagToRightInheritance = true;

  result.derivationDescriptor = DerivationDescriptor::create(a, aTermConcept, b, bTermConcept);

  result.frequencyCertainty = fRevision(a.frequencyCertainty, b.frequencyCertainty, k);

  return result;
}



UnifiedTerm ruletablenal2Revision02(UnifiedTerm a, TermConcept aTermConcept, UnifiedTerm b, TermConcept bTermConcept, float k) {
  UnifiedTerm result;
  result.left = b.left;
  result.right = b.right;

  result.flagToLeftInheritance = true;
  result.flagToRightInheritance = true;

  result.derivationDescriptor = DerivationDescriptor::create(a, aTermConcept, b, bTermConcept);

  result.frequencyCertainty = fRevision(a.frequencyCertainty, b.frequencyCertainty, k);

  return result;
}



UnifiedTerm ruletablenal2Revision12(UnifiedTerm a, TermConcept aTermConcept, UnifiedTerm b, TermConcept bTermConcept, float k) {
  UnifiedTerm result;
  result.left = b.left;
  result.right = b.right;

  result.flagToLeftInheritance = true;
  result.flagToRightInheritance = true;

  result.derivationDescriptor = DerivationDescriptor::create(a, aTermConcept, b, bTermConcept);

  result.frequencyCertainty = fRevision(a.frequencyCertainty, b.frequencyCertainty, k);

  return result;
}



UnifiedTerm ruletablenal2Revision22(UnifiedTerm a, TermConcept aTermConcept, UnifiedTerm b, TermConcept bTermConcept, float k) {
  UnifiedTerm result;
  result.left = b.left;
  result.right = b.right;

  result.flagToLeftInheritance = true;
  result.flagToRightInheritance = true;

  result.derivationDescriptor = DerivationDescriptor::create(a, aTermConcept, b, bTermConcept);

  result.frequencyCertainty = fRevision(a.frequencyCertainty, b.frequencyCertainty, k);

  return result;
}



UnifiedTerm ruletablenal2Comparision10(UnifiedTerm a, TermConcept aTermConcept, UnifiedTerm b, TermConcept bTermConcept, float k) {
  UnifiedTerm result;
  result.left = b.left;
  result.right = a.left;

  result.flagToLeftInheritance = true;
  result.flagToRightInheritance = true;

  result.derivationDescriptor = DerivationDescriptor::create(a, aTermConcept, b, bTermConcept);

  result.frequencyCertainty = fComparision(a.frequencyCertainty, b.frequencyCertainty, k);

  return result;
}



UnifiedTerm ruletablenal2Analogy20(UnifiedTerm a, TermConcept aTermConcept, UnifiedTerm b, TermConcept bTermConcept, float k) {
  UnifiedTerm result;
  result.left = b.left;
  result.right = a.right;

  result.flagToLeftInheritance = false;
  result.flagToRightInheritance = true;

  result.derivationDescriptor = DerivationDescriptor::create(a, aTermConcept, b, bTermConcept);

  result.frequencyCertainty = fAnalogyTick(a.frequencyCertainty, b.frequencyCertainty, k);

  return result;
}



UnifiedTerm ruletablenal2Comparision01(UnifiedTerm a, TermConcept aTermConcept, UnifiedTerm b, TermConcept bTermConcept, float k) {
  UnifiedTerm result;
  result.left = b.right;
  result.right = a.right;

  result.flagToLeftInheritance = true;
  result.flagToRightInheritance = true;

  result.derivationDescriptor = DerivationDescriptor::create(a, aTermConcept, b, bTermConcept);

  result.frequencyCertainty = fComparision(a.frequencyCertainty, b.frequencyCertainty, k);

  return result;
}



UnifiedTerm ruletablenal2Analogy21(UnifiedTerm a, TermConcept aTermConcept, UnifiedTerm b, TermConcept bTermConcept, float k) {
  UnifiedTerm result;
  result.left = a.right;
  result.right = b.right;

  result.flagToLeftInheritance = false;
  result.flagToRightInheritance = true;

  result.derivationDescriptor = DerivationDescriptor::create(a, aTermConcept, b, bTermConcept);

  result.frequencyCertainty = fAnalogyTick(a.frequencyCertainty, b.frequencyCertainty, k);

  return result;
}



UnifiedTerm ruletablenal2Analogy02(UnifiedTerm a, TermConcept aTermConcept, UnifiedTerm b, TermConcept bTermConcept, float k) {
  UnifiedTerm result;
  result.left = b.left;
  result.right = a.right;

  result.flagToLeftInheritance = false;
  result.flagToRightInheritance = true;

  result.derivationDescriptor = DerivationDescriptor::create(a, aTermConcept, b, bTermConcept);

  result.frequencyCertainty = fAnalogy(a.frequencyCertainty, b.frequencyCertainty, k);

  return result;
}



UnifiedTerm ruletablenal2Analogy12(UnifiedTerm a, TermConcept aTermConcept, UnifiedTerm b, TermConcept bTermConcept, float k) {
  UnifiedTerm result;
  result.left = a.left;
  result.right = b.left;

  result.flagToLeftInheritance = false;
  result.flagToRightInheritance = true;

  result.derivationDescriptor = DerivationDescriptor::create(a, aTermConcept, b, bTermConcept);

  result.frequencyCertainty = fAnalogy(a.frequencyCertainty, b.frequencyCertainty, k);

  return result;
}



UnifiedTerm ruletablenal2Deduction222(UnifiedTerm a, TermConcept aTermConcept, UnifiedTerm b, TermConcept bTermConcept, float k) {
  UnifiedTerm result;
  result.left = b.left;
  result.right = a.right;

  result.flagToLeftInheritance = false;
  result.flagToRightInheritance = true;

  result.derivationDescriptor = DerivationDescriptor::create(a, aTermConcept, b, bTermConcept);

  result.frequencyCertainty = fDeduction2(a.frequencyCertainty, b.frequencyCertainty, k);

  return result;
}
*/



/*
struct Unified {
  size_t left, right;
  
  bool flagToLeftInheritance;
  bool flagToRightInheritance;
  
  size_t derivationParentIndex;
  
  FrequencyCertainty frequencyCertainty;
};*/




















// deriver prototype


struct TermConceptPair {
  UnifiedTerm a;
  TermConcept aTermConcept;
  UnifiedTerm b;
  TermConcept bTermConcept;
};

// TODO< check terms for overlapping evidence, if they dont overlap put them into deriver > 

// TODO< automate this >
struct Deriver {
  static vector<UnifiedTerm> derive(TermConceptPair pair, float k) {
    vector<UnifiedTerm> result;

    // revision
    if( !pair.a.flagToLeftInheritance && pair.a.flagToRightInheritance && !pair.b.flagToLeftInheritance && pair.b.flagToRightInheritance ) {
      result.push_back(ruletablenal2Revision00(pair.a, pair.aTermConcept, pair.b, pair.bTermConcept, k));
      result.push_back(ruletablenal2Revision10(pair.a, pair.aTermConcept, pair.b, pair.bTermConcept, k));
    }
    else if( pair.a.flagToLeftInheritance && pair.a.flagToRightInheritance && !pair.b.flagToLeftInheritance && pair.b.flagToRightInheritance ) {
      result.push_back(ruletablenal2Revision20(pair.a, pair.aTermConcept, pair.b, pair.bTermConcept, k));
    }
    else if( !pair.a.flagToLeftInheritance && pair.a.flagToRightInheritance && pair.b.flagToLeftInheritance && pair.b.flagToRightInheritance ) {
      result.push_back(ruletablenal2Revision02(pair.a, pair.aTermConcept, pair.b, pair.bTermConcept, k));
    }
    else if( pair.a.flagToLeftInheritance && pair.a.flagToRightInheritance && pair.b.flagToLeftInheritance && pair.b.flagToRightInheritance ) {
      result.push_back(ruletablenal2Revision22(pair.a, pair.aTermConcept, pair.b, pair.bTermConcept, k));
    }

    // analogy, comm, ded
    if( !pair.a.flagToLeftInheritance && pair.a.flagToRightInheritance && !pair.b.flagToLeftInheritance && pair.b.flagToRightInheritance ) {
      result.push_back(ruletablenal2Comparision10(pair.a, pair.aTermConcept, pair.b, pair.bTermConcept, k));
    }
    if( pair.a.flagToLeftInheritance && pair.a.flagToRightInheritance && !pair.b.flagToLeftInheritance && pair.b.flagToRightInheritance ) {
      result.push_back(ruletablenal2Analogy20(pair.a, pair.aTermConcept, pair.b, pair.bTermConcept, k));
    }

    return result;
  }
};

/*
vector<UnifiedTerm> derive(TermConceptPair pair, float k) {
  return Deriver::derive(pair, k);
}
*/




#include <random>

// for compiler testing we need a sink
extern void sink_(vector<UnifiedTerm> vec);

struct Inference {
  void sampleConceptsInParallel(vector<shared_ptr<ClassicalConcept>> &concepts, ReasonerInstance &reasonerInstance, mt19937 &gen) {
    // TODO< parallelize this >
    for(auto iterationConcept : concepts) {
      // random numbers need to be generated before entering this

      std::uniform_real_distribution<float> distribution(0, 1);
      float randomValues[2];
      randomValues[0] = distribution(gen);
      randomValues[1] = distribution(gen);

      sampleConcept(iterationConcept, randomValues, reasonerInstance);
    }
  }

protected:
  void sampleConcept(shared_ptr<ClassicalConcept> concept, float randomValues[2], ReasonerInstance &reasonerInstance) {
    shared_ptr<ClassicalTask> task = concept->tasks.reference(randomValues[0]);
    shared_ptr<ClassicalBelief> belief = concept->beliefs.reference(randomValues[1]);

    inference(task, belief, reasonerInstance);
  }

  void inference(shared_ptr<ClassicalTask> task, shared_ptr<ClassicalBelief> belief, ReasonerInstance &reasonerInstance) {
    UnifiedTerm unifiedTermOfTask = reasonerInstance.accessTermByIndex(task->unifiedTerm);
    UnifiedTerm unifiedTermOfBelief = reasonerInstance.accessTermByIndex(belief->unifiedTerm);

    TermConceptPair pair;
    // INCOMPLETE TODO< set aTermConcept and bTermConcept >
    pair.a = unifiedTermOfTask;
    pair.b = unifiedTermOfBelief;
    sink_(Deriver::derive(pair, reasonerInstance.configuration.k));
  }
};

// for compiler testing
void test(Inference &inference, vector<shared_ptr<ClassicalConcept>> &concepts, ReasonerInstance &reasonerInstance, mt19937 &gen) {
  inference.sampleConceptsInParallel(concepts, reasonerInstance, gen);
}

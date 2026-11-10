Class {
	#name : 'MonographTest',
	#superclass : 'TestCase',
	#category : 'MyLibrary-Tests',
	#package : 'MyLibrary-Tests'
}

{ #category : 'tests' }
MonographTest >> testArithmeticMinus [

	| book result |
	book := Monograph new illustrationCount: 20.
	result := book - 5.
	self assert: book illustrationCount equals: 15.
	self assert: result identicalTo: book.

	book - 50.
	self
		assert: book illustrationCount
		equals: Monograph defaultIllustrationCount
]

{ #category : 'tests' }
MonographTest >> testArithmeticPlus [

	| book result |
	book := Monograph new illustrationCount: 10.
	result := book + 5.

	self assert: book illustrationCount equals: 15.
	self assert: result identicalTo: book
]

{ #category : 'tests' }
MonographTest >> testBookFromDictionary [
    | dict book emptyDict emptyBook |
    
    dict := Dictionary new.
    dict at: 'title' put: 'Дослідження';
         at: 'pageCount' put: 150;
         at: 'illustrationCount' put: 25.
         
    book := Monograph bookFromDictionary: dict.
    self assert: book title equals: 'Дослідження'.
    self assert: book pageCount equals: 150.
    self assert: book illustrationCount equals: 25.
    
    emptyDict := Dictionary new.
    emptyBook := Monograph bookFromDictionary: emptyDict.
    
    self assert: emptyBook pageCount equals: Monograph defaultPageCount.
    self assert: emptyBook illustrationCount equals: Monograph defaultIllustrationCount.
]

{ #category : 'tests' }
MonographTest >> testClassConstructor [
    | book year authors pubs |
    year := Year year: 2024.
    authors := OrderedCollection new.
    pubs := OrderedCollection new.
    
    book := Monograph
        authors: authors
        title: 'Наукова праця'
        publishers: pubs
        year: year
        pageCount: 300
        illustrations: 42.
        
    self assert: book title equals: 'Наукова праця'.
    self assert: book pageCount equals: 300.
    self assert: book illustrationCount equals: 42.
]

{ #category : 'tests' }
MonographTest >> testIllustrationCountValidation [
    | book |
    book := Monograph new.
    book illustrationCount: 15.
    self assert: book illustrationCount equals: 15.
    book illustrationCount: 0.
    self assert: book illustrationCount equals: 0.
    book illustrationCount: nil.
    self assert: book illustrationCount equals: Monograph defaultIllustrationCount.
    self should: [ book illustrationCount: -5 ] raise: Error.
    self should: [ book illustrationCount: '10' ] raise: Error.
]

{ #category : 'tests' }
MonographTest >> testInitialize [
    | book |
    book := Monograph new.
    self assert: book illustrationCount equals: Monograph defaultIllustrationCount.
]

{ #category : 'tests' }
MonographTest >> testPrintVolumeInfoOn [
    | book printString |
    book := Monograph new pageCount: 100; illustrationCount: 20.
    
    printString := String streamContents: [ :stream | 
        book printVolumeInfoOn: stream 
    ].
    
    self assert: (printString includesSubstring: '100 стор. та 20 іл.').
    self assert: (printString includesSubstring: 'загальний обсяг: 120 стор.').
]

{ #category : 'tests' }
MonographTest >> testTotalVolume [
    | book |
    book := Monograph new.
    book pageCount: 200.
    book illustrationCount: 50.
    self assert: book totalVolume equals: 250.
]

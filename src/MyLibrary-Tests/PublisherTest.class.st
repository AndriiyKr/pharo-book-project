Class {
	#name : 'PublisherTest',
	#superclass : 'TestCase',
	#instVars : [
		'publisher'
	],
	#category : 'MyLibrary-Tests',
	#package : 'MyLibrary-Tests'
}

{ #category : 'running' }
PublisherTest >> setUp [
    super setUp.
    publisher := Publisher 
        name: 'Видавництво Старого Лева' 
        city: 'Львів' 
        foundationYear: (Year year: 2001).
]

{ #category : 'tests' }
PublisherTest >> testAccessing [
    self assert: publisher name equals: 'Видавництво Старого Лева'.
    self assert: publisher city equals: 'Львів'.
    self assert: publisher foundationYear year equals: 2001.
]

{ #category : 'tests' }
PublisherTest >> testConstructor [
    | newPublisher testYear |
    testYear := Year year: 2012.

    newPublisher := Publisher 
        name: 'Наш Формат' 
        city: 'Київ' 
        foundationYear: testYear.

    self assert: newPublisher name equals: 'Наш Формат'.
    self assert: newPublisher city equals: 'Київ'.
    self assert: newPublisher foundationYear equals: testYear.
]

{ #category : 'tests' }
PublisherTest >> testDefaultPublisher [
    | defPublisher |
    defPublisher := Publisher defaultPublisher.

    self assert: defPublisher name equals: Publisher defaultName.
    self assert: defPublisher city equals: Publisher defaultCity.
    self assert: defPublisher foundationYear year equals: 2000.
]

{ #category : 'tests' }
PublisherTest >> testFoundationYearTypeValidation [
    self should: [ publisher foundationYear: 2001 ] raise: Error.
    self should: [ publisher foundationYear: '2001' ] raise: Error.

    publisher foundationYear: (Year year: 2026).
    self assert: publisher foundationYear year equals: 2026.
]

{ #category : 'tests' }
PublisherTest >> testPrintOn [
    | stream resultString |
    stream := WriteStream on: String new.
    publisher printOn: stream.
    resultString := stream contents.
    self assert: (resultString includesSubstring: 'Видавництво Старого Лева').
    self assert: (resultString includesSubstring: 'м. Львів').
    self assert: (resultString includesSubstring: '(').
    self assert: (resultString includesSubstring: ')').
]

{ #category : 'tests' }
PublisherTest >> testPrintOnWithMissingData [
    | emptyPublisher stream resultString |
    emptyPublisher := Publisher new.
    stream := WriteStream on: String new.
    emptyPublisher printOn: stream.
    resultString := stream contents.
    self assert: (resultString includesSubstring: Publisher defaultName).
    self assert: (resultString includesSubstring: Publisher defaultCity).
]

{ #category : 'tests' }
PublisherTest >> testSetters [
    | blankPublisher testYear |
    testYear := Year year: 1992.

    blankPublisher := Publisher new.

    blankPublisher name: 'А-БА-БА-ГА-ЛА-МА-ГА'.
    blankPublisher city: 'Київ'.
    blankPublisher foundationYear: testYear.

    self assert: blankPublisher name equals: 'А-БА-БА-ГА-ЛА-МА-ГА'.
    self assert: blankPublisher city equals: 'Київ'.
    self assert: blankPublisher foundationYear equals: testYear.
]

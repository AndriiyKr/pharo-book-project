Class {
	#name : 'PublisherTest',
	#superclass : 'TestCase',
	#category : 'MyLibrary-Tests',
	#package : 'MyLibrary-Tests'
}

{ #category : 'tests' }
PublisherTest >> testCity [
    | publisher |
    publisher := Publisher new.
    
    publisher city: 'Київ'.
    self assert: publisher city equals: 'Київ'.
    
    publisher city: nil.
    self assert: publisher city equals: Publisher defaultCity.
    
    publisher city: ''.
    self assert: publisher city equals: Publisher defaultCity.
]

{ #category : 'tests' }
PublisherTest >> testClassConstructor [
    | publisher validYear |
    validYear := Year year: 1992.

    publisher := Publisher 
        name: 'А-БА-БА-ГА-ЛА-МА-ГА' 
        city: 'Київ' 
        foundationYear: validYear.
        
    self assert: publisher name equals: 'А-БА-БА-ГА-ЛА-МА-ГА'.
    self assert: publisher city equals: 'Київ'.
    self assert: publisher foundationYear equals: validYear.
    
    publisher := Publisher 
        name: nil 
        city: nil 
        foundationYear: nil.
        
    self assert: publisher name equals: Publisher defaultName.
    self assert: publisher city equals: Publisher defaultCity.
    self assert: publisher foundationYear equals: Publisher defaultFoundationYear.
]

{ #category : 'tests' }
PublisherTest >> testDefaultPublisher [
    | publisher |
    publisher := Publisher defaultPublisher.
    
    self assert: publisher name equals: Publisher defaultName.
    self assert: publisher city equals: Publisher defaultCity.
    self assert: publisher foundationYear equals: Publisher defaultFoundationYear.
]

{ #category : 'tests' }
PublisherTest >> testFoundationYear [
    | publisher validYear |
    publisher := Publisher new.
    validYear := Year year: 1992.

    publisher foundationYear: validYear.
    self assert: publisher foundationYear equals: validYear.
    
    publisher foundationYear: nil.
    self assert: publisher foundationYear equals: Publisher defaultFoundationYear.
    
    self should: [ publisher foundationYear: 1992 ] raise: Error.
    self should: [ publisher foundationYear: '1992' ] raise: Error.
]

{ #category : 'tests' }
PublisherTest >> testName [
    | publisher |
    publisher := Publisher new.
    
    publisher name: 'А-БА-БА-ГА-ЛА-МА-ГА'.
    self assert: publisher name equals: 'А-БА-БА-ГА-ЛА-МА-ГА'.

    publisher name: nil.
    self assert: publisher name equals: Publisher defaultName.
    
    publisher name: ''.
    self assert: publisher name equals: Publisher defaultName.
]

{ #category : 'tests' }
PublisherTest >> testPublisherFromDictionary [
    | dict publisher emptyDict emptyPublisher validYear |
    validYear := Year year: 1992.
    
    dict := Dictionary new.
    dict at: 'name' put: 'А-БА-БА-ГА-ЛА-МА-ГА';
         at: 'city' put: 'Київ';
         at: 'foundationYear' put: validYear.
         
    publisher := Publisher publisherFromDictionary: dict.
    self assert: publisher name equals: 'А-БА-БА-ГА-ЛА-МА-ГА'.
    self assert: publisher city equals: 'Київ'.
    self assert: publisher foundationYear equals: validYear.
    


    emptyDict := Dictionary new.
    emptyPublisher := Publisher publisherFromDictionary: emptyDict.
    
    self assert: emptyPublisher name equals: Publisher defaultName.
    self assert: emptyPublisher city equals: Publisher defaultCity.
    self assert: emptyPublisher foundationYear equals: Publisher defaultFoundationYear.
]
